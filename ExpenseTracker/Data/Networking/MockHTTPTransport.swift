//
//  MockHTTPTransport.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Test double for HTTPDataTransport to enable unit testing and offline demo data.
//

import Foundation

/// Mock implementation of `HTTPDataTransport` for unit tests and deterministic simulations.
final class MockHTTPTransport: HTTPDataTransport, @unchecked Sendable {

    /// Preconfigured response result (success tuple or failure error)
    var result: Result<(Data, URLResponse), Error>?

    /// Records all requests made through this transport
    private(set) var recordedRequests: [URLRequest] = []

    init(result: Result<(Data, URLResponse), Error>? = nil) {
        self.result = result
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        recordedRequests.append(request)

        if let result = result {
            switch result {
            case .success(let payload):
                return payload
            case .failure(let error):
                throw error
            }
        }

        // Default behavior: if no explicit result set, return sample seed data
        let sampleJSON = """
        [
          {
            "id": "txn-101",
            "title": "Whole Foods Groceries",
            "amount": 95.50,
            "category": "Groceries",
            "date": "2026-10-29T12:30:00Z",
            "type": "expense",
            "notes": "Weekly produce and snacks"
          },
          {
            "id": "txn-102",
            "title": "Software Engineering Salary",
            "amount": 4200.00,
            "category": "Salary",
            "date": "2026-10-28T09:00:00Z",
            "type": "income",
            "notes": "Monthly payroll direct deposit"
          },
          {
            "id": "txn-103",
            "title": "Electric & Water Bill",
            "amount": 134.20,
            "category": "Utilities & Bills",
            "date": "2026-10-27T15:45:00Z",
            "type": "expense",
            "notes": "Monthly utility bill"
          },
          {
            "id": "txn-104",
            "title": "Metro Transit Pass",
            "amount": 65.00,
            "category": "Transportation",
            "date": "2026-10-26T08:15:00Z",
            "type": "expense",
            "notes": "Monthly commuter pass"
          },
          {
            "id": "txn-105",
            "title": "Freelance iOS Consulting",
            "amount": 850.00,
            "category": "Freelance",
            "date": "2026-10-25T17:00:00Z",
            "type": "income",
            "notes": "Client project milestone"
          },
          {
            "id": "txn-106",
            "title": "Dinner at Bistro",
            "amount": 78.40,
            "category": "Food & Dining",
            "date": "2026-10-24T20:00:00Z",
            "type": "expense",
            "notes": "Dinner with friends"
          }
        ]
        """

        let data = sampleJSON.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://api.expensetracker.app/transactions")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!

        return (data, response)
    }
}
