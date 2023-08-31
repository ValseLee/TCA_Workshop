//
//  LoginTest.swift
//  TCA_Test
//
//  Created by Celan on 2023/08/25.
//

import ComposableArchitecture
import SwiftUI
import XCTest
import XCTestDynamicOverlay
@testable import TCA_Sample_Tests

@MainActor
final class LoginFeature_Test: XCTestCase {
    func testIsLoginPossible() async throws {
        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }
        
        await store.send(.idStringEdited("ID")) {
            $0.idString = "ID"
        }
        
        await store.send(.pwStringEdited("PW")) {
            $0.pwString = "PW"
            $0.isLoginButtonDisabled = false
        }
    }
}
