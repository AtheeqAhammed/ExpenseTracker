//
//  TransactionAPIClient.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Responsible strictly for HTTP requests, response validation, and JSON decoding.
//

import Foundation

/// API client executing REST network calls for transactions.
///
/// Follows single responsibility:
/// 1. Builds URL requests.
/// 2. Sends via injectable HTTP transport.
/// 3. Validates HTTP status codes.
/// 4. Decodes JSON payloads.
/// 5. Maps DTOs to clean domain models.
/// Does not handle local caching or UI presentation.
struct TransactionAPIClient: Sendable {

    private let baseURL: URL
    private let transport: any HTTPDataTransport

    init(
        baseURL: URL,
        transport: any HTTPDataTransport = URLSessionTransport()
    ) {
        self.baseURL = baseURL
        self.transport = transport
    }

    /// Fetches transactions list from the remote REST endpoint: GET /transactions
    func fetchTransactions() async throws -> [Transaction] {
        let endpoint = baseURL.appendingPathComponent("transactions")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        request.timeoutInterval = 30

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await transport.data(for: request)
        } catch {
            if error is CancellationError {
                throw error
            }

            if let urlError = error as? URLError,
               urlError.code == .cancelled {
                throw error
            }

            throw APIError.networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let dtos = try decoder.decode(
                [TransactionDTO].self,
                from: data
            )

            return dtos.map { $0.toDomain() }
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw APIError.decodingFailed
        }
    }

    /// Creates a transaction on the remote server: POST /transactions
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        let endpoint = baseURL.appendingPathComponent("transactions")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let dto = TransactionDTO(from: transaction)
        request.httpBody = try encoder.encode(dto)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await transport.data(for: request)
        } catch {
            if error is CancellationError { throw error }
            throw APIError.networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let returnedDto = try decoder.decode(TransactionDTO.self, from: data)
        return returnedDto.toDomain()
    }
}
