//
//  HTTPDataTransport.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Injectable abstraction over URLSession for deterministic testing and decoupling.
//

import Foundation

/// Defines network transport contract for issuing URL requests asynchronously.
protocol HTTPDataTransport: Sendable {
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)
}

/// Default production transport backed by Apple's `URLSession`.
struct URLSessionTransport: HTTPDataTransport {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}
