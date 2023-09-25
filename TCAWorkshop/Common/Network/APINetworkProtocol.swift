//
//  APINetworkProtocol.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/09/25.
//

import Foundation

protocol APINetworkInterface {
    associatedtype APIData: Codable
    associatedtype FetchKey: Codable
    
    var update: @Sendable (_ updateTarget: APIData) async throws -> Void { get }
    var fetchDataArray: @Sendable () async throws -> [APIData] { get }
    var singleFetch: @Sendable (_ withKey: FetchKey) async throws -> APIData { get }
}
