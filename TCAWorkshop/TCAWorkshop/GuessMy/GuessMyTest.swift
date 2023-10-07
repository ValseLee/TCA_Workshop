//
//  GuessMyTest.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/10/07.
//

import ComposableArchitecture
import XCTest
@testable import TCAWorkshop

@MainActor
final class GuessMyTest: XCTestCase {
    func testNavigationStack_Child_GuessMyAge_Parent_Update() async throws {
        let guessAgeMock = GuessAge.testInstance()
        
        let testStore = TestStore(
            initialState: GuessMyFeature.State(
                path: StackState([
                    GuessMyFeature.Path.State
                        .guessMyAge(
                            GuessMyAgeFeature.State(name: guessAgeMock.name)
                        )
                ])
            )
        ) {
            GuessMyFeature()
        }
        
        await testStore.send(.path(.element(id: 0, action: .guessMyAge(.guessAgeButtonTapped)))) {
            $0.path[id: 0, case: /GuessMyFeature.Path.State.guessMyAge]?.isGuessAgeButtonTapped = true
            $0.path[id: 0, case: /GuessMyFeature.Path.State.guessMyAge]?.age = nil
            $0.path[id: 0, case: /GuessMyFeature.Path.State.guessMyAge]?.isGuessAgeIncorrect = false
        }
        
        await testStore.receive(.path(.element(id: 0, action: .guessMyAge(.guessAgeResponse(guessAgeMock))))) {
            $0.path[id: 0, case: /GuessMyFeature.Path.State.guessMyAge]?.isGuessAgeButtonTapped = false
            $0.path[id: 0, case: /GuessMyFeature.Path.State.guessMyAge]?.age = 0
            $0.recentGuessMyAgeInformation = guessAgeMock.name
        }
    }
}
