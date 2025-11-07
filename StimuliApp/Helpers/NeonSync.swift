//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.


// VERSION CLAUDE

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
    
    // ✅ CONNECTION POOLING: Reutilizar conexión TCP
    private var persistentConnection: NWConnection?
    private var connectionCreatedAt: TimeInterval = 0
    private let maxConnectionAge: TimeInterval = 600 // 10 minutos

    public init() {}
    
    
    public nonisolated func start(hostIP: String, intervalSeconds: TimeInterval = 5) {
        _Concurrency.Task { [weak self] in
            guard let self else { return }
            await self._startImpl(hostIP: hostIP, intervalSeconds: intervalSeconds)
        }
    }
    
    public func analyze(samples: [NeonTimeEchoSample]) -> NeonResult? {
        guard !samples.isEmpty else { return nil }

        // Freshness check: ensure the most recent sample is within the last 60 seconds
        let now = nowMs()
        
        print(now)
        
        print(samples)
        
        if let latestT2 = samples.map({ $0.t2 }).max(), now &- latestT2 > 60_000 {
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

        let n = Double(xs.count)
        let W = ws.reduce(0, +)
        guard W > 0 else { return nil }

        // If we have fewer than 6 samples, use the single best (lowest RTT) sample
        if xs.count < 6 {
            // pick the sample with the minimum RTT
            guard let best = samples.min(by: { $0.rtt < $1.rtt }) else { return nil }
            let mid = (Double(best.t1) + Double(best.t2)) / 2.0
            let intercept = Double(best.tH) - mid
            let slope = 0.0
            // RSE heuristic: half the RTT in ms, bounded by eps
            let rse = max(eps, Double(best.rtt) / 2.0)

            guard intercept.isFinite, rse.isFinite else { return nil }

            print(samples)
            print(intercept, slope)

            return NeonResult(intercept: intercept, slope: slope, rse: rse)
        }

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
        let slope = num / den
        let intercept = yBar - slope * xBar

        // calculating RSE (residual standard error) with df = n - 2
        var rss = 0.0
        for i in 0..<xs.count {
            let pred = intercept + slope * xs[i]
            let res = ys[i] - pred
            rss += ws[i] * (res * res)
        }
        guard n > 2 else { return nil }
        let rse = sqrt(rss / (n - 2.0))

        guard slope.isFinite, intercept.isFinite, rse.isFinite else { return nil }

        print("more than 6")
        print(samples)
        print(intercept, slope)

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
        
        // Cancelar tarea anterior y limpiar conexión
        backgroundTask?.cancel()
        await cleanupConnection()
        
        backgroundTask = _Concurrency.Task { [weak self] in
            guard let self else { return }
            await self.backgroundLoop(intervalSeconds: intervalSeconds)
        }
    }
    
    // ✅ BACKGROUND LOOP CON CONNECTION POOLING
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

        var consecutiveErrors = 0
        let maxConsecutiveErrors = 5

        while !_Concurrency.Task.isCancelled {
            do {
                // ✅ VERIFICAR disponibilidad del Neon antes de medir
                let neonOk = await checkNeonHealth()
                if !neonOk {
                    print("⚠️ Neon not responding, waiting...")
                    try? await _Concurrency.Task.sleep(nanoseconds: 10_000_000_000) // 10s
                    continue
                }
                
                // ✅ TIMEOUT GLOBAL para toda la operación
                let sample = try await raceWithTimeout(seconds: 10) { [self] in
                    try await self.measureOnceInternal()
                }
                
                print("-----------     vamos       ----------------", CACurrentMediaTime())
                samples.append(sample)
                
                // Limitar samples para evitar memory leak
                if samples.count > 10000 {
                    samples.removeFirst(samples.count - 8000)
                }
                
                consecutiveErrors = 0 // Reset en éxito
                
            } catch {
                print("TimeEcho periodic measure error: \(error)")
                consecutiveErrors += 1
                
                // Limpiar conexión en caso de error
                await cleanupConnection()
                
                // Si hay muchos errores seguidos, esperar más
                if consecutiveErrors >= maxConsecutiveErrors {
                    print("⚠️ Too many consecutive errors (\(consecutiveErrors)), longer backoff...")
                    try? await _Concurrency.Task.sleep(nanoseconds: 30_000_000_000) // 30s
                    consecutiveErrors = 0
                } else {
                    // Backoff exponencial: 1.5s, 3s, 6s, 12s
                    let backoff = min(
                        UInt64(1_500_000_000) * UInt64(1 << min(consecutiveErrors - 1, 3)),
                        10_000_000_000 // Max 10s
                    )
                    try? await _Concurrency.Task.sleep(nanoseconds: backoff)
                }
            }

            try? await _Concurrency.Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
        }
        
        // Limpiar al salir
        await cleanupConnection()
    }

    // ✅ VERIFICAR SALUD DEL NEON
    private func checkNeonHealth() async -> Bool {
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

    // ✅ OBTENER O CREAR CONEXIÓN PERSISTENTE
    private func getOrCreateConnection() async throws -> NWConnection {
        let now = CACurrentMediaTime()
        
        // Verificar si conexión actual es válida
        if let existing = persistentConnection {
            let age = now - connectionCreatedAt
            
            // Si es muy vieja, renovarla
            if age > maxConnectionAge {
                print("🔄 Connection too old (\(Int(age))s), recreating...")
                await cleanupConnection()
            }
            // Si está ready, usarla
            else if existing.state == .ready {
                print("♻️ Reusing existing connection (age: \(Int(age))s)")
                return existing
            }
            // Si está en mal estado, limpiar
            else {
                print("💔 Connection in bad state: \(existing.state), recreating...")
                await cleanupConnection()
            }
        }
        
        // Crear nueva conexión
        return try await createNewConnection()
    }
    
    // ✅ CREAR NUEVA CONEXIÓN
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
            // Configurar keep-alive para conexiones persistentes
            tcp.enableKeepalive = true
        }

        let connection = NWConnection(host: NWEndpoint.Host(hostIP),
                                      port: NWEndpoint.Port(rawValue: port)!,
                                      using: params)

        // Establecer conexión con timeout
        try await waitReady(connection, timeout: 8)
        
        let elapsed = (CACurrentMediaTime() - createStart) * 1000
        print("✅ Connection established in \(Int(elapsed))ms")
        
        persistentConnection = connection
        connectionCreatedAt = CACurrentMediaTime()
        
        return connection
    }

    // ✅ LIMPIAR CONEXIÓN
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

    // ✅ MEDICIÓN CON CONEXIÓN PERSISTENTE
    private func measureOnceInternal() async throws -> NeonTimeEchoSample {
        let measureStart = CACurrentMediaTime()
        
        let connection = try await getOrCreateConnection()
        
        // ❌ NO cancelar la conexión - la reutilizamos
        
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
            // En caso de error, marcar conexión como mala
            await cleanupConnection()
            throw error
        }
    }

    private func fetchTimeEchoPort(host: String) async throws -> UInt16 {
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






//// VERSION CHAT GPT
//
//
////  StimuliApp is licensed under the MIT License.
////  Copyright © 2020 Rafael Marín. All rights reserved.
//
//import Foundation
//import Network
//import QuartzCore
//
//public struct NeonTimeEchoSample: Sendable {
//    public let t1: UInt64 // client send time
//    public let tH: UInt64 // host time
//    public let t2: UInt64 // client recv time
//    public let rtt: UInt64 // t2 - t1
//}
//
//public struct NeonResult: Sendable {
//    public let intercept: Double
//    public let slope: Double
//    public let rse: Double
//}
//
//public actor NeonTimeEchoClient {
//    private var hostIP: String = ""
//    private var timeEchoPort: UInt16?
//    private var backgroundTask: _Concurrency.Task<Void, Never>?
//    private var samples: [NeonTimeEchoSample] = []
//
//    public init() {}
//
//    deinit {
//        print("NeonTimeEchoClient deinit")
//    }
//
//    // Arranca el loop periódico en background.
//    public nonisolated func start(hostIP: String, intervalSeconds: TimeInterval = 5) {
//        _Concurrency.Task { [weak self] in
//            guard let self else { return }
//            await self._startImpl(hostIP: hostIP, intervalSeconds: intervalSeconds)
//        }
//    }
//
//    // Analiza las muestras (con heurística si hay pocas).
//    public func analyze(samples: [NeonTimeEchoSample]) -> NeonResult? {
//        guard !samples.isEmpty else { return nil }
//
//        // Freshness: si la última muestra es muy antigua, consideramos no válido
//        let now = nowMs()
//        if let latestT2 = samples.map({ $0.t2 }).max(), now &- latestT2 > 60_000 {
//            return nil
//        }
//
//        let eps: Double = 1.0 // ms
//        let rttMin: Double = samples.map { Double($0.rtt) }.min() ?? 0.0
//
//        var xs = [Double]()
//        var ys = [Double]()
//        var ws = [Double]()
//
//        for s in samples {
//            let t1 = Double(s.t1)
//            let mid = (Double(s.t1) + Double(s.t2)) / 2.0
//            let offset = Double(s.tH) - mid
//            let sigma = max(eps, (Double(s.rtt) - rttMin) / 2.0)
//            let weight = 1.0 / (sigma * sigma)
//
//            xs.append(t1)
//            ys.append(offset)
//            ws.append(weight)
//        }
//
//        let n = Double(xs.count)
//        let W = ws.reduce(0, +)
//        guard W > 0 else { return nil }
//
//        // Con pocas muestras, usa la de menor RTT como estimador simple
//        if xs.count < 6 {
//            guard let best = samples.min(by: { $0.rtt < $1.rtt }) else { return nil }
//            let mid = (Double(best.t1) + Double(best.t2)) / 2.0
//            let intercept = Double(best.tH) - mid
//            let slope = 0.0
//            let rse = max(eps, Double(best.rtt) / 2.0)
//            guard intercept.isFinite, rse.isFinite else { return nil }
//            return NeonResult(intercept: intercept, slope: slope, rse: rse)
//        }
//
//        // Regresión lineal ponderada: intercept + slope * x
//        let wx = zip(xs, ws).map { $0 * $1 }.reduce(0, +)
//        let wy = zip(ys, ws).map { $0 * $1 }.reduce(0, +)
//
//        let xBar = wx / W
//        let yBar = wy / W
//
//        var num = 0.0
//        var den = 0.0
//        for i in 0..<xs.count {
//            let xi = xs[i], yi = ys[i], wi = ws[i]
//            let dx = xi - xBar
//            num += wi * dx * (yi - yBar)
//            den += wi * dx * dx
//        }
//        guard den > 0 else { return nil }
//
//        let slope = num / den
//        let intercept = yBar - slope * xBar
//
//        var rss = 0.0
//        for i in 0..<xs.count {
//            let pred = intercept + slope * xs[i]
//            let res = ys[i] - pred
//            rss += ws[i] * (res * res)
//        }
//        guard n > 2 else { return nil }
//        let rse = sqrt(rss / (n - 2.0))
//
//        guard slope.isFinite, intercept.isFinite, rse.isFinite else { return nil }
//        return NeonResult(intercept: intercept, slope: slope, rse: rse)
//    }
//
//    public func stopAndAnalyze() async -> NeonResult? {
//        let samples = await stopAndFetchAll()
//        return analyze(samples: samples)
//    }
//
//    // Envía una sola medida con timeout y devuelve true/false.
//    public func pingOnce(hostIP: String, timeoutSeconds: TimeInterval = 5) async -> Bool {
//        do {
//            let p = try await fetchTimeEchoPort(host: hostIP)
//            self.timeEchoPort = p
//            self.hostIP = hostIP
//
//            let ok: Bool = try await raceWithTimeout(seconds: timeoutSeconds) { [weak self] in
//                guard let self else {
//                    throw NSError(domain: "NeonTimeEcho", code: -4,
//                                  userInfo: [NSLocalizedDescriptionKey: "Deallocated"])
//                }
//                _ = try await self.measureOnceInternal()
//                return true
//            }
//            return ok
//        } catch {
//            print("Neon pingOnce error: \(error)")
//            return false
//        }
//    }
//
//    // Helper: carrera entre una operación y un timeout.
//    private func raceWithTimeout<T>(seconds: TimeInterval,
//                                    _ op: @escaping () async throws -> T) async throws -> T {
//        try await withThrowingTaskGroup(of: T.self) { group in
//            group.addTask { try await op() }
//            group.addTask {
//                try await _Concurrency.Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
//                throw NSError(domain: "NeonTimeEcho", code: -3,
//                              userInfo: [NSLocalizedDescriptionKey: "timeout"])
//            }
//            let value = try await group.next()!
//            group.cancelAll()
//            return value
//        }
//    }
//
//    // Implementación del arranque del bucle
//    private func _startImpl(hostIP: String, intervalSeconds: TimeInterval) async {
//        self.hostIP = hostIP
//        backgroundTask?.cancel()
//        backgroundTask = _Concurrency.Task { [weak self] in
//            guard let self else { return }
//            await self.backgroundLoop(intervalSeconds: intervalSeconds)
//        }
//    }
//
//    // Bucle de medición con backoff y re-resolución del puerto tras fallos encadenados.
//    private func backgroundLoop(intervalSeconds: TimeInterval) async {
//        func resolvePort() async -> UInt16? {
//            do { return try await fetchTimeEchoPort(host: hostIP) }
//            catch { print("TimeEcho: fetch port failed: \(error)"); return nil }
//        }
//
//        guard let initialPort = await resolvePort() else {
//            print("TimeEcho: could not resolve time_echo_port, giving up.")
//            return
//        }
//        timeEchoPort = initialPort
//
//        var consecutiveFailures = 0
//
//        while !_Concurrency.Task.isCancelled {
//            print("TimeEcho tick @", CACurrentMediaTime(), "cancelled?", _Concurrency.Task.isCancelled)
//            do {
//                let sample = try await measureOnceInternal()
//                samples.append(sample)
//                consecutiveFailures = 0
//                print("----------- OK sample ----------------", CACurrentMediaTime())
//            } catch {
//                consecutiveFailures += 1
//                print("TimeEcho periodic measure error (#\(consecutiveFailures)): \(error)")
//
//                // Re-resolver puerto cada 3 fallos seguidos
//                if consecutiveFailures % 3 == 0 {
//                    if let newPort = await resolvePort() {
//                        timeEchoPort = newPort
//                        print("TimeEcho: re-resolved port:", newPort)
//                    }
//                }
//                // Backoff corto para permitir recuperación de la pila de red
//                try? await _Concurrency.Task.sleep(nanoseconds: 1_500_000_000)
//            }
//
//            try? await _Concurrency.Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
//        }
//    }
//
//    @discardableResult
//    public func stopAndFetchAll() async -> [NeonTimeEchoSample] {
//        backgroundTask?.cancel()
//        backgroundTask = nil
//        let out = samples
//        samples.removeAll(keepingCapacity: true)
//        return out
//    }
//
//    // Espera a READY con cleanup de handler y timeout.
//    private func waitReady(_ connection: NWConnection, timeout: TimeInterval) async throws {
//        try await raceWithTimeout(seconds: timeout) {
//            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
//                connection.stateUpdateHandler = { st in
//                    switch st {
//                    case .ready:
//                        connection.stateUpdateHandler = nil
//                        cont.resume(returning: ())
//                    case .failed(let e):
//                        connection.stateUpdateHandler = nil
//                        cont.resume(throwing: e)
//                    case .waiting(let e):
//                        // Útil para diagnosticar problemas de ruta
//                        print("TimeEcho waiting: \(e)")
//                    default:
//                        break
//                    }
//                }
//                connection.start(queue: .global(qos: .userInitiated))
//            }
//        }
//    }
//
//    // Una medición con timeouts internos y cancelación garantizada.
//    private func measureOnceInternal() async throws -> NeonTimeEchoSample {
//        guard let port = timeEchoPort else {
//            throw NSError(domain: "NeonTimeEcho", code: -1,
//                          userInfo: [NSLocalizedDescriptionKey: "Client not initialized (port missing)."])
//        }
//
//        let params = NWParameters.tcp
//        if let tcp = params.defaultProtocolStack.transportProtocol as? NWProtocolTCP.Options {
//            tcp.noDelay = true
//        }
//        params.allowLocalEndpointReuse = true
//
//        let connection = NWConnection(host: NWEndpoint.Host(hostIP),
//                                      port: NWEndpoint.Port(rawValue: port)!,
//                                      using: params)
//        defer {
//            connection.cancel()
//            // Pequeña pausa para que el stack libere recursos antes del próximo intento
//            Task { try? await Task.sleep(nanoseconds: 200_000_000) } // 200 ms
//        }
//
//        // Timeout total holgado; internos más estrictos
//        return try await raceWithTimeout(seconds: 8) { [self] in
//            try await waitReady(connection, timeout: 3)
//
//            let t1 = nowMs()
//            var t1be = t1.bigEndian
//            let payload = withUnsafeBytes(of: &t1be) { Data($0) }
//
//            try await connection.sendAsync(payload)
//
//            let response = try await raceWithTimeout(seconds: 3) {
//                try await self.receiveExact(length: 16, over: connection)
//            }
//            let t2 = nowMs()
//            let tH = response.subdata(in: 8..<16).withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
//            let rtt = t2 &- t1
//
//            return NeonTimeEchoSample(t1: t1, tH: tH, t2: t2, rtt: rtt)
//        }
//    }
//
//    // Descubre el puerto en /api/status
//    private func fetchTimeEchoPort(host: String) async throws -> UInt16 {
//        guard let url = URL(string: "http://\(host):8080/api/status") else {
//            throw URLError(.badURL)
//        }
//        let (data, response) = try await URLSession.shared.data(from: url)
//        guard let http = response as? HTTPURLResponse,
//              (200..<300).contains(http.statusCode) else {
//            throw URLError(.badServerResponse)
//        }
//
//        // Estructura esperada
//        struct APIStatus: Decodable { let result: [Item] }
//        struct Item: Decodable { let model: String; let data: DataBlock }
//        struct DataBlock: Decodable { let time_echo_port: Int? }
//
//        if let decoded = try? JSONDecoder().decode(APIStatus.self, from: data),
//           let phone = decoded.result.first(where: { $0.model == "Phone" }),
//           let p = phone.data.time_echo_port, (1..<65536).contains(p) {
//            return UInt16(p)
//        }
//
//        // Fallback genérico por si cambia el esquema
//        if let any = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//           let arr = any["result"] as? [[String: Any]] {
//            for elem in arr {
//                if let db = elem["data"] as? [String: Any],
//                   let p = db["time_echo_port"] as? Int,
//                   (1..<65536).contains(p) {
//                    return UInt16(p)
//                }
//            }
//        }
//
//        throw NSError(domain: "NeonTimeEcho", code: -2,
//                      userInfo: [NSLocalizedDescriptionKey: "time_echo_port not found in /api/status"])
//    }
//
//    private func nowMs() -> UInt64 {
//        let value = CACurrentMediaTime() * 1000
//        return UInt64(value)
//    }
//
//    private func receiveExact(length: Int, over connection: NWConnection) async throws -> Data {
//        var acc = Data()
//        while acc.count < length {
//            let need = length - acc.count
//            let chunk = try await connection.receiveAsync(min: 1, max: need)
//            acc.append(chunk)
//        }
//        return acc
//    }
//}
//
//// MARK: - NWConnection helpers
//
//fileprivate extension NWConnection {
//    func sendAsync(_ data: Data) async throws {
//        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
//            self.send(content: data, completion: .contentProcessed { err in
//                if let err = err { cont.resume(throwing: err) }
//                else { cont.resume(returning: ()) }
//            })
//        }
//    }
//
//    func receiveAsync(min: Int, max: Int) async throws -> Data {
//        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
//            self.receive(minimumIncompleteLength: min, maximumLength: max) { content, _, isComplete, error in
//                if let error = error {
//                    cont.resume(throwing: error)
//                } else if let content = content, !content.isEmpty {
//                    cont.resume(returning: content)
//                } else if isComplete {
//                    cont.resume(throwing: URLError(.networkConnectionLost))
//                } else {
//                    cont.resume(throwing: URLError(.cannotDecodeRawData))
//                }
//            }
//        }
//    }
//}





//// VERSION CLAUDE + CHATGPT
//
//import Foundation
//import Network
//import QuartzCore
//
//public struct NeonTimeEchoSample: Sendable {
//    public let t1: UInt64 // client send time
//    public let tH: UInt64 // host time
//    public let t2: UInt64 // client recv time
//    public let rtt: UInt64 // t2 - t1
//}
//
//public struct NeonResult: Sendable {
//    public let intercept: Double
//    public let slope: Double
//    public let rse: Double
//}
//
//public actor NeonTimeEchoClient {
//    private var hostIP: String = ""
//    private var timeEchoPort: UInt16?
//    private var backgroundTask: _Concurrency.Task<Void, Never>?
//    private var samples: [NeonTimeEchoSample] = []
//
//    // Pooling / persistencia
//    private var persistentConnection: NWConnection?
//    private var isReady: Bool = false
//    private var connectionCreatedAt: CFTimeInterval = 0
//    private var lastUseAt: CFTimeInterval = 0
//    private let maxConnectionAge: CFTimeInterval = 300   // 5 min
//    private let maxIdleAge: CFTimeInterval = 60          // 60 s
//
//    public init() {}
//
//    // MARK: - API pública
//
//    public nonisolated func start(hostIP: String, intervalSeconds: TimeInterval = 5) {
//        _Concurrency.Task { [weak self] in
//            guard let self else { return }
//            await self._startImpl(hostIP: hostIP, intervalSeconds: intervalSeconds)
//        }
//    }
//
//    public func stopAndAnalyze() async -> NeonResult? {
//        let samples = await stopAndFetchAll()
//        return analyze(samples: samples)
//    }
//
//    @discardableResult
//    public func stopAndFetchAll() async -> [NeonTimeEchoSample] {
//        backgroundTask?.cancel()
//        backgroundTask = nil
//        await cleanupConnection()
//        let out = samples
//        samples.removeAll(keepingCapacity: true)
//        return out
//    }
//
//    /// Chequea conectividad en ~timeoutSeconds (bloquea hasta resolver)
//    public func pingOnce(hostIP: String, timeoutSeconds: TimeInterval = 5) async -> Bool {
//        do {
//            let p = try await fetchTimeEchoPort(host: hostIP)
//            self.timeEchoPort = p
//            self.hostIP = hostIP
//            let ok: Bool = try await raceWithTimeout(seconds: timeoutSeconds) { [weak self] in
//                guard let self else {
//                    throw NSError(domain: "NeonTimeEcho", code: -4,
//                                  userInfo: [NSLocalizedDescriptionKey: "Deallocated"])
//                }
//                _ = try await self.measureOnceInternal()
//                return true
//            }
//            return ok
//        } catch {
//            print("Neon pingOnce error: \(error)")
//            return false
//        }
//    }
//
//    // MARK: - Medición / análisis
//
//    public func analyze(samples: [NeonTimeEchoSample]) -> NeonResult? {
//        guard !samples.isEmpty else { return nil }
//
//        // Freshness (60 s)
//        let now = nowMs()
//        if let latestT2 = samples.map({ $0.t2 }).max(), now &- latestT2 > 60_000 {
//            return nil
//        }
//
//        let eps: Double = 1.0
//        let rttMin: Double = samples.map { Double($0.rtt) }.min() ?? 0.0
//
//        var xs = [Double](), ys = [Double](), ws = [Double]()
//        for s in samples {
//            let t1 = Double(s.t1)
//            let mid = (Double(s.t1) + Double(s.t2)) / 2.0
//            let offset = Double(s.tH) - mid
//            let sigma = max(eps, (Double(s.rtt) - rttMin) / 2.0)
//            let weight = 1.0 / (sigma * sigma)
//            xs.append(t1); ys.append(offset); ws.append(weight)
//        }
//
//        let n = Double(xs.count)
//        let W = ws.reduce(0, +)
//        guard W > 0 else { return nil }
//
//        if xs.count < 6 {
//            guard let best = samples.min(by: { $0.rtt < $1.rtt }) else { return nil }
//            let mid = (Double(best.t1) + Double(best.t2)) / 2.0
//            let intercept = Double(best.tH) - mid
//            let slope = 0.0
//            let rse = max(eps, Double(best.rtt) / 2.0)
//            guard intercept.isFinite, rse.isFinite else { return nil }
//            return NeonResult(intercept: intercept, slope: slope, rse: rse)
//        }
//
//        // Regresión lineal ponderada
//        let wx = zip(xs, ws).map(*).reduce(0, +)
//        let wy = zip(ys, ws).map(*).reduce(0, +)
//        let xBar = wx / W, yBar = wy / W
//
//        var num = 0.0, den = 0.0
//        for i in 0..<xs.count {
//            let dx = xs[i] - xBar, wi = ws[i]
//            num += wi * dx * (ys[i] - yBar)
//            den += wi * dx * dx
//        }
//        guard den > 0 else { return nil }
//        let slope = num / den
//        let intercept = yBar - slope * xBar
//
//        var rss = 0.0
//        for i in 0..<xs.count {
//            let pred = intercept + slope * xs[i]
//            let res = ys[i] - pred
//            rss += ws[i] * res * res
//        }
//        guard n > 2 else { return nil }
//        let rse = sqrt(rss / (n - 2.0))
//        guard slope.isFinite, intercept.isFinite, rse.isFinite else { return nil }
//        return NeonResult(intercept: intercept, slope: slope, rse: rse)
//    }
//
//    // MARK: - Loop en background
//
//    private func _startImpl(hostIP: String, intervalSeconds: TimeInterval) async {
//        self.hostIP = hostIP
//        backgroundTask?.cancel()
//        await cleanupConnection()
//
//        backgroundTask = _Concurrency.Task { [weak self] in
//            guard let self else { return }
//            await self.backgroundLoop(intervalSeconds: intervalSeconds)
//        }
//    }
//
//    private func backgroundLoop(intervalSeconds: TimeInterval) async {
//        var port: UInt16?
//        do { port = try await fetchTimeEchoPort(host: hostIP) }
//        catch { print("TimeEcho: fetch port failed") }
//        guard let resolvedPort = port else {
//            print("TimeEcho: could not resolve time_echo_port, giving up.")
//            return
//        }
//        timeEchoPort = resolvedPort
//
//        var consecutiveErrors = 0
//        let maxConsecutiveErrors = 5
//
//        while !_Concurrency.Task.isCancelled {
//            do {
//                // Salud del Neon
//                if !(await checkNeonHealth()) {
//                    print("⚠️ Neon not responding, waiting…")
//                    try? await _Concurrency.Task.sleep(nanoseconds: 10_000_000_000)
//                    continue
//                }
//
//                // Medición con timeout global
//                let sample = try await raceWithTimeout(seconds: 10) { [self] in
//                    try await self.measureOnceInternal()
//                }
//                samples.append(sample)
//                if samples.count > 1000 { samples.removeFirst(samples.count - 800) }
//
//                consecutiveErrors = 0
//
//            } catch {
//                print("TimeEcho periodic measure error: \(error)")
//                consecutiveErrors += 1
//
//                // Re-intenta descubrir puerto tras varios errores
//                if consecutiveErrors >= 2 {
//                    if let p = try? await fetchTimeEchoPort(host: hostIP) {
//                        timeEchoPort = p
//                    }
//                }
//
//                await cleanupConnection()
//
//                if consecutiveErrors >= maxConsecutiveErrors {
//                    print("⚠️ Too many consecutive errors (\(consecutiveErrors)), longer backoff…")
//                    try? await _Concurrency.Task.sleep(nanoseconds: 30_000_000_000)
//                    consecutiveErrors = 0
//                } else {
//                    // Backoff exponencial capado a 10 s
//                    let backoff = min(
//                        UInt64(1_500_000_000) * UInt64(1 << min(consecutiveErrors - 1, 3)),
//                        10_000_000_000
//                    )
//                    try? await _Concurrency.Task.sleep(nanoseconds: backoff)
//                }
//            }
//
//            try? await _Concurrency.Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
//        }
//
//        await cleanupConnection()
//    }
//
//    // MARK: - Conectividad
//
//    private func getOrCreateConnection() async throws -> NWConnection {
//        let now = CACurrentMediaTime()
//
//        // Recicla por antigüedad/inactividad
//        if let _ = persistentConnection {
//            if (now - connectionCreatedAt) > maxConnectionAge { await cleanupConnection() }
//            else if (now - lastUseAt) > maxIdleAge { await cleanupConnection() }
//        }
//
//        if let existing = persistentConnection, isReady {
//            // Conexión lista y reciente: reutilizar
//            return existing
//        }
//
//        return try await createNewConnection()
//    }
//
//    private func createNewConnection() async throws -> NWConnection {
//        guard let port = timeEchoPort else {
//            throw NSError(domain: "NeonTimeEcho", code: -1,
//                          userInfo: [NSLocalizedDescriptionKey: "Port missing"])
//        }
//
//        let params = NWParameters.tcp
//        if let tcp = params.defaultProtocolStack.transportProtocol as? NWProtocolTCP.Options {
//            tcp.noDelay = true
//            tcp.connectionTimeout = 8
//            tcp.enableKeepalive = true
//        }
//
//        let connection = NWConnection(host: NWEndpoint.Host(hostIP),
//                                      port: NWEndpoint.Port(rawValue: port)!,
//                                      using: params)
//
//        // Handlers
//        isReady = false
//        connection.stateUpdateHandler = { [weak self] st in
//            guard let self else { return }
//            switch st {
//            case .ready: self.isReady = true
//            case .failed, .cancelled: self.isReady = false
//            default: break
//            }
//        }
//        connection.betterPathUpdateHandler = { [weak self] _ in
//            // Si el sistema detecta mejor ruta, forzamos recreación limpia
//            Task { await self?.cleanupConnection() }
//        }
//
//        try await waitReady(connection, timeout: 8)
//
//        // Ya está lista: limpia handler para evitar retener closures
//        connection.stateUpdateHandler = nil
//
//        persistentConnection = connection
//        connectionCreatedAt = CACurrentMediaTime()
//        lastUseAt = connectionCreatedAt
//        return connection
//    }
//
//    private func cleanupConnection() async {
//        if let connection = persistentConnection {
//            connection.cancel()
//            persistentConnection = nil
//            isReady = false
//            connectionCreatedAt = 0
//            // Pequeña pausa para evitar problemas de TIME_WAIT
//            try? await _Concurrency.Task.sleep(nanoseconds: 200_000_000) // 200 ms
//        }
//    }
//
//    private func waitReady(_ connection: NWConnection, timeout: TimeInterval) async throws {
//        try await raceWithTimeout(seconds: timeout) {
//            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
//                connection.stateUpdateHandler = { st in
//                    switch st {
//                    case .ready: cont.resume(returning: ())
//                    case .failed(let e): cont.resume(throwing: e)
//                    case .waiting(let e): print("TimeEcho waiting: \(e)")
//                    default: break
//                    }
//                }
//                connection.start(queue: .global(qos: .userInitiated))
//            }
//        }
//    }
//
//    // Una medición (reutiliza conexión si es posible)
//    private func measureOnceInternal() async throws -> NeonTimeEchoSample {
//        let connection = try await getOrCreateConnection()
//
//        let t1 = nowMs()
//        var t1be = t1.bigEndian
//        let payload = withUnsafeBytes(of: &t1be) { Data($0) }
//
//        do {
//            try await connection.sendAsync(payload)
//            let response = try await raceWithTimeout(seconds: 5) { [self] in
//                try await self.receiveExact(length: 16, over: connection)
//            }
//            let t2 = nowMs()
//            lastUseAt = CACurrentMediaTime()
//
//            let tH = response.subdata(in: 8..<16)
//                .withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
//            let rtt = t2 &- t1
//            return NeonTimeEchoSample(t1: t1, tH: tH, t2: t2, rtt: rtt)
//
//        } catch {
//            // Marca la conexión como mala y fuerza recreación
//            await cleanupConnection()
//            throw error
//        }
//    }
//
//    // MARK: - Utilidades de red
//
//    private func checkNeonHealth() async -> Bool {
//        guard let url = URL(string: "http://\(hostIP):8080/api/status") else { return false }
//        do {
//            let request = URLRequest(url: url, timeoutInterval: 5)
//            let (_, response) = try await URLSession.shared.data(for: request)
//            if let http = response as? HTTPURLResponse { return (200..<300).contains(http.statusCode) }
//            return false
//        } catch {
//            print("🔍 Neon health check failed: \(error)")
//            return false
//        }
//    }
//
//    private func fetchTimeEchoPort(host: String) async throws -> UInt16 {
//        guard let url = URL(string: "http://\(host):8080/api/status") else {
//            throw URLError(.badURL)
//        }
//        let request = URLRequest(url: url, timeoutInterval: 10)
//        let (data, response) = try await URLSession.shared.data(for: request)
//        guard let http = response as? HTTPURLResponse,
//              (200..<300).contains(http.statusCode) else {
//            throw URLError(.badServerResponse)
//        }
//
//        struct APIStatus: Decodable { let result: [Item] }
//        struct Item: Decodable { let model: String; let data: DataBlock }
//        struct DataBlock: Decodable { let time_echo_port: Int? }
//
//        if let decoded = try? JSONDecoder().decode(APIStatus.self, from: data),
//           let phone = decoded.result.first(where: { $0.model == "Phone" }),
//           let p = phone.data.time_echo_port, (1..<65536).contains(p) {
//            return UInt16(p)
//        }
//
//        if let any = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//           let arr = any["result"] as? [[String: Any]] {
//            for elem in arr {
//                if let db = elem["data"] as? [String: Any],
//                   let p = db["time_echo_port"] as? Int,
//                   (1..<65536).contains(p) {
//                    return UInt16(p)
//                }
//            }
//        }
//
//        throw NSError(domain: "NeonTimeEcho", code: -2,
//                      userInfo: [NSLocalizedDescriptionKey: "time_echo_port not found in /api/status"])
//    }
//
//    // MARK: - Helpers genéricos
//
//    private func nowMs() -> UInt64 {
//        let value = CACurrentMediaTime() * 1000
//        return UInt64(value)
//    }
//
//    private func raceWithTimeout<T>(seconds: TimeInterval,
//                                    _ op: @escaping () async throws -> T) async throws -> T {
//        try await withThrowingTaskGroup(of: T.self) { group in
//            group.addTask { try await op() }
//            group.addTask {
//                try await _Concurrency.Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
//                throw NSError(domain: "NeonTimeEcho", code: -3,
//                              userInfo: [NSLocalizedDescriptionKey: "timeout"])
//            }
//            let value = try await group.next()!
//            group.cancelAll()
//            return value
//        }
//    }
//
//    private func receiveExact(length: Int, over connection: NWConnection) async throws -> Data {
//        var acc = Data()
//        while acc.count < length {
//            let need = length - acc.count
//            let chunk = try await connection.receiveAsync(min: 1, max: need)
//            acc.append(chunk)
//        }
//        return acc
//    }
//}
//
//fileprivate extension NWConnection {
//    func sendAsync(_ data: Data) async throws {
//        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
//            self.send(content: data, completion: .contentProcessed { err in
//                if let err = err { cont.resume(throwing: err) }
//                else { cont.resume(returning: ()) }
//            })
//        }
//    }
//
//    func receiveAsync(min: Int, max: Int) async throws -> Data {
//        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
//            self.receive(minimumIncompleteLength: min, maximumLength: max) { content, _, isComplete, error in
//                if let error = error {
//                    cont.resume(throwing: error)
//                } else if let content = content, !content.isEmpty {
//                    cont.resume(returning: content)
//                } else if isComplete {
//                    cont.resume(throwing: URLError(.networkConnectionLost))
//                } else {
//                    cont.resume(throwing: URLError(.cannotDecodeRawData))
//                }
//            }
//        }
//    }
//}
