//
//  GuessAge.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/09/25.
//

import Foundation

struct GuessAge: Codable, Equatable {
    var count: Int
    var name: String
    var age: Int?
    
    static func testInstance() -> Self {
        GuessAge(count: 0, name: "TEST", age: 0)
    }
}
