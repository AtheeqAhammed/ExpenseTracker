//
//  APIError.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Typed errors for predictable network and API failure handling.
//

import Foundation

/// Clean typed errors representing networking and decoding failures.
///
/// These errors serve two purposes:
/// - The API client can distinguish HTTP failures, decoding failures, and connection problems.
/// - The ViewModel can display a user-friendly message without knowing networking details.
enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case networkError(underlyingDescription: String)
    case noData
    case unknown(underlyingDescription: String)

    /// Convenience helper to wrap standard Swift errors
    static func networkError(underlying: Error) -> APIError {
        .networkError(underlyingDescription: underlying.localizedDescription)
    }

    /// Convenience helper to wrap unknown errors
    static func unknown(underlying: Error) -> APIError {
        .unknown(underlyingDescription: underlying.localizedDescription)
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."

        case .invalidResponse:
            return "The server returned an invalid response."

        case .httpError(let statusCode):
            return "The server returned status code \(statusCode)."

        case .decodingFailed:
            return "Unable to read the server response."

        case .networkError:
            return "Unable to connect. Check your internet connection."

        case .noData:
            return "The server returned no data."

        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
