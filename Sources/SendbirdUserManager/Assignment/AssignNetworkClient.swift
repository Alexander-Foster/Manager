//
//  AssignNetworkClient.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation


final class AssignNetworkClient: SBNetworkClient {
    private let maxRequestPerRequest = 10
    private var lastRequestTimes: [String: [Date]] = [:]
    private let queue = DispatchQueue(label: "com.assignNetworkClient.queue", attributes: .concurrent)
    private var requestQueue: [AnyRequestBox] = []

    init() {}

    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, Error>) -> Void) where R : Request {
        guard let definition = request as? (any APIDefinition) else { return }

        queue.async {
            self.performRequest(definition) { result in
                switch result {
                case .success(let response):
                    if let response = response as? R.Response {
                        completionHandler(.success(response))
                    } else {
                        completionHandler(.failure(AssignNetworkError.invalidResponse))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }

    private func performRequest(_ definition: any APIDefinition, completion: @escaping (Result<Any, Error>) -> Void) {
        let requestKey = "\(definition.method)_\(definition.path)"

        if let times = lastRequestTimes[requestKey], times.count >= maxRequestPerRequest {
            completion(.failure(AssignNetworkError.maxRequestExceeded))
            return
        }

        if definition.rateLimit > 0 {
            waitForRateLimit(requestKey: requestKey, rateLimit: definition.rateLimit) {
                self.executeRequest(definition, requestKey: requestKey, completion: completion)
            }
        } else {
            executeRequest(definition, requestKey: requestKey, completion: completion)
        }
    }

    private func waitForRateLimit(requestKey: String, rateLimit: TimeInterval, completion: @escaping () -> Void) {
        let now = Date()
        if var times = lastRequestTimes[requestKey] {
            times = times.filter { now.timeIntervalSince($0) < rateLimit }
            if !times.isEmpty {
                let oldestRequest = times[0]
                let waitTime = rateLimit - now.timeIntervalSince(oldestRequest)
                if waitTime > 0 {
                    queue.asyncAfter(deadline: .now() + waitTime) {
                        completion()
                    }
                    return
                }
            }
            lastRequestTimes[requestKey] = times
        }
        completion()
    }

    private func executeRequest(_ definition: any APIDefinition, requestKey: String, completion: @escaping (Result<Any, Error>) -> Void) {
        definition.request { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.recordRequestTime(requestKey: requestKey)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }

            self.processNextRequestInQueue()
        }
    }

    private func recordRequestTime(requestKey: String) {
        var times = lastRequestTimes[requestKey] ?? []
        times.append(Date())
        lastRequestTimes[requestKey] = times
    }

    private func processNextRequestInQueue() {
        queue.async {
            guard !self.requestQueue.isEmpty else { return }
            let next = self.requestQueue.removeFirst()
            next.perform(with: self)
        }
    }
}

private struct AnyRequestBox {
    private let _perform: (AssignNetworkClient) -> Void

    init<R: Request>(_ request: R, completion: @escaping (Result<R.Response, Error>) -> Void) {
        _perform = { client in
            client.request(request: request, completionHandler: completion)
        }
    }

    func perform(with client: AssignNetworkClient) {
        _perform(client)
    }
}

extension AssignNetworkClient {
    private func enqueueRequest<R: Request>(_ request: R, completion: @escaping (Result<R.Response, Error>) -> Void) {
        let box = AnyRequestBox(request, completion: completion)
        requestQueue.append(box)
    }
}
