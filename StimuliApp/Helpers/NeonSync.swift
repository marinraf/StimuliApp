//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.


import Foundation
import Network
import QuartzCore


public struct NeonTimeEchoSample: Sendable {
    public let t1: UInt64 // client send time
    public let tH: UInt64 // host time
    public let t2: UInt64 // client recv time
    public let rtt: UInt64 // t2 - t1
}

public struct NeonResult: Sendable {
    public let intercept: Double
    public let slope: Double
    public let halfMinRtt: Double
    public let rse: Double
    public let numberOfSamples: Int
    public let neonSyncError: Bool
}


public actor NeonTimeEchoClient {
    private var hostIP: String = ""
    private var timeEchoPort: UInt16?
    private var backgroundTask: _Concurrency.Task<Void, Never>?
    private var samples: [NeonTimeEchoSample] = []
    private var persistentConnection: NWConnection?
    private var connectionCreatedAt: TimeInterval = 0
    private let maxConnectionAge: TimeInterval = 3600

    public init() {}
    
    
    public nonisolated func start(hostIP: String, intervalSeconds: TimeInterval = 5) {
        _Concurrency.Task { [weak self] in
            guard let self else { return }
            await self._startImpl(hostIP: hostIP, intervalSeconds: intervalSeconds)
        }
    }
    
    public func analyze(samples: [NeonTimeEchoSample]) -> NeonResult? {
        guard !samples.isEmpty else { return nil }
        
        var intercept: Double = 0
        var slope: Double = 0
        var halfMinRtt: Double = 0
        var rse: Double = 0
        let numberOfSamples: Int = samples.count
        var neonSyncError: Bool = false
        
        // Freshness check: ensure the most recent sample is within the last 30 seconds
        let now = nowMs()
        if let latestT2 = samples.map({ $0.t2 }).max(), now &- latestT2 > 30_000 {
            neonSyncError = true
        }
        
        let eps: Double = 1.0 // ms
        let rttMin: Double = samples.map { Double($0.rtt) }.min() ?? 0.0
        
        var xs = [Double]()
        var ys = [Double]()
        var ws = [Double]()
        
        for s in samples {
            let t1 = Double(s.t1)
            let mid = ((Double(s.t1) + Double(s.t2)) / 2.0)
            let offset = Double(s.tH) - mid
            let sigma = max(eps, (Double(s.rtt) - rttMin) / 2.0)
            let weight = 1.0 / (sigma * sigma)
            
            xs.append(t1)
            ys.append(offset)
            ws.append(weight)
        }
        
        let n = Double(xs.count)
        let W = ws.reduce(0, +)
        guard W > 0 else { return nil }
        
        guard let best = samples.min(by: { $0.rtt < $1.rtt }) else { return nil }
        halfMinRtt = max(eps, Double(best.rtt) / 2.0)
        
        if xs.count < 6 {
            // If we have fewer than 6 samples (30 s), use the single best (lowest RTT) sample
            let mid = (Double(best.t1) + Double(best.t2)) / 2.0
            intercept = Double(best.tH) - mid
            slope = 0.0
            rse = halfMinRtt
            
        } else if xs.count < 36 {
            // If we have fewer than 36 samples (3 min), use regression with slope = 0 (only intercept)
            let wy = zip(ys, ws).map { $0 * $1 }.reduce(0, +)
            intercept = wy / W
            slope = 0.0
            
            var rss = 0.0
            for i in 0..<ys.count {
                let res = ys[i] - intercept
                rss += ws[i] * (res * res)
            }
            
            rse = sqrt(rss / (n - 1.0))
            
        } else {
            // weighted linear regression (intercept + slope * x)
            let wx = zip(xs, ws).map { $0 * $1 }.reduce(0, +)
            let wy = zip(ys, ws).map { $0 * $1 }.reduce(0, +)

            // weighted means
            let xBar = wx / W
            let yBar = wy / W

            // calculating intercept and slope
            var num = 0.0
            var den = 0.0
            for i in 0..<xs.count {
                let xi = xs[i], yi = ys[i], wi = ws[i]
                let dx = xi - xBar
                num += wi * dx * (yi - yBar)
                den += wi * dx * dx
            }
            guard den > 0 else { return nil }
            slope = num / den
            intercept = yBar - slope * xBar

            // calculating RSE (residual standard error) with df = n - 2
            var rss = 0.0
            for i in 0..<xs.count {
                let pred = intercept + slope * xs[i]
                let res = ys[i] - pred
                rss += ws[i] * (res * res)
            }
            rse = sqrt(rss / (n - 2.0))
        }
        guard slope.isFinite, intercept.isFinite, rse.isFinite else { return nil }
        
        return NeonResult(intercept: intercept,
                          slope: slope,
                          halfMinRtt: halfMinRtt,
                          rse: rse,
                          numberOfSamples: numberOfSamples,
                          neonSyncError: neonSyncError)
    }

    public func stopAndAnalyze() async -> NeonResult? {
        let samples = await stopAndFetchAll()
        return analyze(samples: samples)
    }
    
    public func pingOnce(hostIP: String, timeoutSeconds: TimeInterval = 5) async -> Bool {
        print("-------     ping once     -------")
        do {
            let p = try await fetchTimeEchoPort(host: hostIP)
            self.timeEchoPort = p
            self.hostIP = hostIP

            let ok: Bool = try await raceWithTimeout(seconds: timeoutSeconds) { [weak self] in
                guard let self else { throw NSError(domain: "NeonTimeEcho", code: -4,
                                                    userInfo: [NSLocalizedDescriptionKey: "Deallocated"]) }
                _ = try await self.measureOnceInternal()
                return true
            }
            return ok
        } catch {
            print("Neon pingOnce error: \(error)")
            return false
        }
    }

    private func raceWithTimeout<T>(seconds: TimeInterval,
                                    _ op: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await op() }
            group.addTask {
                try await _Concurrency.Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "NeonTimeEcho", code: -3,
                              userInfo: [NSLocalizedDescriptionKey: "timeout"])
            }
            let value = try await group.next()!
            group.cancelAll()
            return value
        }
    }

    private func _startImpl(hostIP: String, intervalSeconds: TimeInterval) async {
        print("-------     start     -------")
        backgroundTask = _Concurrency.Task { [weak self] in
            guard let self else { return }
            await self.backgroundLoop(intervalSeconds: intervalSeconds)
        }
    }
    

    private func backgroundLoop(intervalSeconds: TimeInterval) async {
        var consecutiveErrors = 0
        let maxConsecutiveErrors = 5

        while !_Concurrency.Task.isCancelled {
            do {
                let neonOk = await checkNeonHealth()
                if !neonOk {
                    print("⚠️ Neon not responding, waiting...")
                    try? await _Concurrency.Task.sleep(nanoseconds: 10_000_000_000) // 10s
                    await cleanupConnection()
                    continue
                }
                
                let sample = try await raceWithTimeout(seconds: 10) { [self] in
                    try await self.measureOnceInternal()
                }
                
                samples.append(sample)
                
                // Limit samples to avoid memory leaks
                if samples.count > 10000 {
                    samples.removeFirst(samples.count - 8000)
                }
                
                consecutiveErrors = 0
                
            } catch {
                print("TimeEcho periodic measure error: \(error)")
                consecutiveErrors += 1
                
                await cleanupConnection()
                
                if consecutiveErrors >= maxConsecutiveErrors {
                    print("⚠️ Too many consecutive errors (\(consecutiveErrors)), longer backoff...")
                    try? await _Concurrency.Task.sleep(nanoseconds: 30_000_000_000) // 30s
                    consecutiveErrors = 0
                } else {
                    // exponential backoff: 1.5s, 3s, 6s, 12s
                    let backoff = min(
                        UInt64(1_500_000_000) * UInt64(1 << min(consecutiveErrors - 1, 3)),
                        10_000_000_000 // Max 10s
                    )
                    try? await _Concurrency.Task.sleep(nanoseconds: backoff)
                }
            }

            try? await _Concurrency.Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
        }
        
        await cleanupConnection()
    }

    
    private func checkNeonHealth() async -> Bool {
        print("------      check neon health     ------")
        guard let url = URL(string: "http://\(hostIP):8080/api/status") else { return false }
        
        do {
            let request = URLRequest(url: url, timeoutInterval: 5)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                return (200..<300).contains(http.statusCode)
            }
            return false
        } catch {
            print("🔍 Neon health check failed: \(error)")
            return false
        }
    }


    private func getOrCreateConnection() async throws -> NWConnection {
        print("-----      get connection      -------")
        let now = CACurrentMediaTime()
        
        if let existing = persistentConnection {
            let age = now - connectionCreatedAt
            
            if age > maxConnectionAge {
                print("🔄 Connection too old (\(Int(age))s), recreating...")
                await cleanupConnection()
            }
            else if existing.state == .ready {
                print("♻️ Reusing existing connection (age: \(Int(age))s)")
                return existing
            }
            else {
                print("💔 Connection in bad state: \(existing.state), recreating...")
                await cleanupConnection()
            }
        }
        return try await createNewConnection()
    }
    

    private func createNewConnection() async throws -> NWConnection {
        guard let port = timeEchoPort else {
            throw NSError(domain: "NeonTimeEcho", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Port missing"])
        }

        print("🔗 Creating new connection to \(hostIP):\(port)...")
        let createStart = CACurrentMediaTime()

        let params = NWParameters.tcp
        if let tcp = params.defaultProtocolStack.transportProtocol as? NWProtocolTCP.Options {
            tcp.noDelay = true
            tcp.connectionTimeout = 8
            tcp.enableKeepalive = true
        }

        let connection = NWConnection(host: NWEndpoint.Host(hostIP),
                                      port: NWEndpoint.Port(rawValue: port)!,
                                      using: params)

        try await waitReady(connection, timeout: 8)
        
        let elapsed = (CACurrentMediaTime() - createStart) * 1000
        print("✅ Connection established in \(Int(elapsed))ms")
        
        persistentConnection = connection
        connectionCreatedAt = CACurrentMediaTime()
        
        return connection
    }

    private func cleanupConnection() async {
        if let connection = persistentConnection {
            print("🧹 Cleaning up connection...")
            connection.cancel()
            persistentConnection = nil
            connectionCreatedAt = 0
        }
    }

    @discardableResult
    public func stopAndFetchAll() async -> [NeonTimeEchoSample] {
        backgroundTask?.cancel()
        backgroundTask = nil
        
        await cleanupConnection()
        
        let out = samples
        samples.removeAll(keepingCapacity: true)
        return out
    }

    private func waitReady(_ connection: NWConnection, timeout: TimeInterval) async throws {
        try await raceWithTimeout(seconds: timeout) {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                connection.stateUpdateHandler = { st in
                    switch st {
                    case .ready:
                        cont.resume(returning: ())
                    case .failed(let e):
                        cont.resume(throwing: e)
                    case .waiting(let e):
                        print("TimeEcho waiting: \(e)")
                    default:
                        break
                    }
                }
                connection.start(queue: .global(qos: .userInitiated))
            }
        }
    }

    private func measureOnceInternal() async throws -> NeonTimeEchoSample {
        let measureStart = CACurrentMediaTime()
        
        let connection = try await getOrCreateConnection()
        
        let t1 = nowMs()
        var t1be = t1.bigEndian
        let payload = withUnsafeBytes(of: &t1be) { Data($0) }

        do {
            try await connection.sendAsync(payload)

            let response = try await raceWithTimeout(seconds: 5) { [self] in
                try await self.receiveExact(length: 16, over: connection)
            }
            let t2 = nowMs()
            
            let totalTime = (CACurrentMediaTime() - measureStart) * 1000
            let tH = response.subdata(in: 8..<16).withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
            let rtt = t2 &- t1

            print("✅ Measurement: \(Int(totalTime))ms total, \(rtt)ms RTT")
            return NeonTimeEchoSample(t1: t1, tH: tH, t2: t2, rtt: rtt)
            
        } catch {
            print("❌ Measurement failed after \(Int((CACurrentMediaTime() - measureStart) * 1000))ms: \(error)")
            await cleanupConnection()
            throw error
        }
    }

    private func fetchTimeEchoPort(host: String) async throws -> UInt16 {
        print("-------     fetch time echo port    -------")
        guard let url = URL(string: "http://\(host):8080/api/status") else {
            throw URLError(.badURL)
        }
        
        let request = URLRequest(url: url, timeoutInterval: 10)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // searching in "Phone" block
        struct APIStatus: Decodable { let result: [Item] }
        struct Item: Decodable { let model: String; let data: DataBlock }
        struct DataBlock: Decodable { let time_echo_port: Int? }

        if let decoded = try? JSONDecoder().decode(APIStatus.self, from: data),
           let phone = decoded.result.first(where: { $0.model == "Phone" }),
           let p = phone.data.time_echo_port, (1..<65536).contains(p) {
            return UInt16(p)
        }

        // Fallback: flexible search in case JSON serialization changes in the future
        if let any = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let arr = any["result"] as? [[String: Any]] {
            for elem in arr {
                if let db = elem["data"] as? [String: Any],
                   let p = db["time_echo_port"] as? Int,
                   (1..<65536).contains(p) {
                    return UInt16(p)
                }
            }
        }

        throw NSError(domain: "NeonTimeEcho", code: -2,
                      userInfo: [NSLocalizedDescriptionKey: "time_echo_port not found in /api/status"])
    }


    private func nowMs() -> UInt64 {
        let value = CACurrentMediaTime() * 1000
        return UInt64(value)
    }

    private func receiveExact(length: Int, over connection: NWConnection) async throws -> Data {
        var acc = Data()
        while acc.count < length {
            let need = length - acc.count
            let chunk = try await connection.receiveAsync(min: 1, max: need)
            acc.append(chunk)
        }
        return acc
    }
}


fileprivate extension NWConnection {
    func sendAsync(_ data: Data) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            self.send(content: data, completion: .contentProcessed { err in
                if let err = err { cont.resume(throwing: err) }
                else { cont.resume(returning: ()) }
            })
        }
    }

    func receiveAsync(min: Int, max: Int) async throws -> Data {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
            self.receive(minimumIncompleteLength: min, maximumLength: max) { content, _, isComplete, error in
                if let error = error {
                    cont.resume(throwing: error)
                } else if let content = content, !content.isEmpty {
                    cont.resume(returning: content)
                } else if isComplete {
                    cont.resume(throwing: URLError(.networkConnectionLost))
                } else {
                    cont.resume(throwing: URLError(.cannotDecodeRawData))
                }
            }
        }
    }
}

