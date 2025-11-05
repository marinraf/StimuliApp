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
    public let rse: Double
}


public actor NeonTimeEchoClient {
    private var hostIP: String = ""
    private var timeEchoPort: UInt16?
    private var backgroundTask: _Concurrency.Task<Void, Never>?
    private var samples: [NeonTimeEchoSample] = []

    public init() {}
    
    
    public nonisolated func start(hostIP: String, intervalSeconds: TimeInterval = 10) {
        _Concurrency.Task { [weak self] in
            guard let self else { return }
            await self._startImpl(hostIP: hostIP, intervalSeconds: intervalSeconds)
        }
    }
    
    public func analyze(samples: [NeonTimeEchoSample]) -> NeonResult? {
        guard samples.count >= 3 else {
            return nil
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

        // weighted linear regression
        let n = Double(xs.count)
        let W = ws.reduce(0, +)
        guard W > 0 else { return nil }

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
        let slope = num / den
        let intercept = yBar - slope * xBar

        // calculating RSE (residual standard error)
        var rss = 0.0
        for i in 0..<xs.count {
            let pred = intercept + slope * xs[i]
            let res = ys[i] - pred
            rss += ws[i] * pow(res, 2)
        }
        guard n > 2 else { return nil }
        let rse = sqrt(rss / (n - 2.0))
        
        guard slope.isFinite, intercept.isFinite, rse.isFinite else { return nil }
        
        print(samples)
        
        return NeonResult(intercept: intercept, slope: slope, rse: rse)
    }

    public func stopAndAnalyze() async -> NeonResult? {
        let samples = await stopAndFetchAll()
        return analyze(samples: samples)
    }
    
    public func pingOnce(hostIP: String, timeoutSeconds: TimeInterval = 5) async -> Bool {
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
        self.hostIP = hostIP
        backgroundTask?.cancel()
        backgroundTask = _Concurrency.Task { [weak self] in
            guard let self else { return }
            await self.backgroundLoop(intervalSeconds: intervalSeconds)
        }
    }
    

    private func backgroundLoop(intervalSeconds: TimeInterval) async {
        var port: UInt16?
        do {
            port = try await fetchTimeEchoPort(host: hostIP)
        } catch {
            print("TimeEcho: fetch port failed")
        }
        guard let resolvedPort = port else {
            print("TimeEcho: could not resolve time_echo_port, giving up.")
            return
        }
        timeEchoPort = resolvedPort

        while !_Concurrency.Task.isCancelled {
            do {
                let sample = try await measureOnceInternal()
                samples.append(sample)
            } catch {
                print("TimeEcho periodic measure error: \(error)")
            }

            try? await _Concurrency.Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
        }
    }


    @discardableResult
    public func stopAndFetchAll() async -> [NeonTimeEchoSample] {
        backgroundTask?.cancel()
        backgroundTask = nil
        let out = samples
        samples.removeAll(keepingCapacity: true)
        return out
    }

    private func setPort(_ p: UInt16) {
        self.timeEchoPort = p
    }

    private func measureOnceInternal() async throws -> NeonTimeEchoSample {
        guard let port = timeEchoPort else {
            throw NSError(domain: "NeonTimeEcho", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Client not initialized (port missing)."])
        }

        let params = NWParameters.tcp
        if let tcp = params.defaultProtocolStack.transportProtocol as? NWProtocolTCP.Options {
            tcp.noDelay = true
        }

        let connection = NWConnection(host: NWEndpoint.Host(hostIP),
                                      port: NWEndpoint.Port(rawValue: port)!,
                                      using: params)

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            connection.stateUpdateHandler = { st in
                switch st {
                case .ready: cont.resume(returning: ())
                case .failed(let e): cont.resume(throwing: e)
                case .waiting(let e): print("TimeEcho waiting: \(e)")
                default: break
                }
            }
            connection.start(queue: .global(qos: .userInitiated))
        }

        let t1 = nowMs()
        var t1be = t1.bigEndian
        let payload = withUnsafeBytes(of: &t1be) { Data($0) }

        try await connection.sendAsync(payload)

        let response = try await receiveExact(length: 16, over: connection)
        let t2 = nowMs()
        let tH = response.subdata(in: 8..<16).withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
        let rtt = t2 &- t1

        connection.cancel()

        return NeonTimeEchoSample(t1: t1, tH: tH, t2: t2, rtt: rtt)
    }


    private func fetchTimeEchoPort(host: String) async throws -> UInt16 {
        guard let url = URL(string: "http://\(host):8080/api/status") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
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

