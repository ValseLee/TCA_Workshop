//
//  GuessAgeClient.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/09/25.
//

import Foundation

struct GuessAgeClient: APINetworkInterface {
    var update: @Sendable (_ updateTarget: GuessAge) async throws -> Void
    var fetchDataArray: @Sendable () async throws -> [GuessAge]
    var singleFetch: @Sendable (String) async throws -> GuessAge
}

extension GuessAgeClient {
    static let live = GuessAgeClient(
        update: { _ in },
        fetchDataArray: { [.testInstance()] },
        singleFetch: { name in
            let (data, response) = try await URLSession.shared.data(
                from: URL(string: "https://api.agify.io?name=\(name)")!
            )
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Fetch Failed", response)
                throw GuessAgeError.fetchError
            }
            
            let result = try JSONDecoder().decode(
                GuessAge.self,
                from: data
            )
            
            return result
        }
    )
    
    static let test = GuessAgeClient(
        update: { _ in },
        fetchDataArray: { [.testInstance()] },
        singleFetch: { with in
            return .testInstance()
        }
    )
}

enum GuessAgeError: Error {
    case fetchError
}
