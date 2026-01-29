//
//  DataProvider.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 26/01/2026.
//

import Foundation

protocol DataProvider {
    func fetch(_ endpoint: String) throws -> Data
    func post(_ data: Data, to endpoint: String) async throws
}

struct RemoteDataProvider: DataProvider {
    let baseURL: String
    
    func fetch(_ endpoint: String) throws -> Data {
        let url = URL(string: baseURL + "/" + endpoint)
        let data = try Data(contentsOf: url!)
        return data
    }
    
    func post(_ data: Data, to endpoint: String) async throws {
        let url = URL(string: baseURL + "/" + endpoint)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
