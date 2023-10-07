//
//  GuessMyAgeTest.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/09/25.
//

import ComposableArchitecture
import XCTest
@testable import TCAWorkshop

@MainActor
final class GuessMyAgeTest: XCTestCase {
    func testTextField_Writing() async throws {
        let testStore = TestStore(
            initialState: GuessMyAgeFeature.State(name: "Name")
        ) {
            GuessMyAgeFeature()
        }
        
        await testStore.send(.nameTextFieldEditted("NewName")) {
            $0.name = "NewName"
        }
    }
    
    func testTextField_Delete() async throws {
        let testStore = TestStore(
            initialState: GuessMyAgeFeature.State(name: "Name")
        ) {
            GuessMyAgeFeature()
        }
        
        await testStore.send(.emptyNameTextFieldButtonTapped) {
            $0.name = ""
        }
    }
    
    func testGuessAge_Success() async throws {
        let guessAgeInstance = GuessAge.testInstance()
        
        let testStore = TestStore(
            initialState: GuessMyAgeFeature.State(name: "Name")
        ) {
            GuessMyAgeFeature()
        } withDependencies: {
            $0.guessAgeClient.singleFetch = { _ in return guessAgeInstance }
        }
        
        await testStore.send(.guessAgeButtonTapped) {
            $0.isGuessAgeButtonTapped = true
            $0.age = nil
            $0.isGuessAgeIncorrect = false
        }
        
        await testStore.receive(.guessAgeResponse(guessAgeInstance)) {
            $0.isGuessAgeButtonTapped = false
            
            if let age = guessAgeInstance.age {
                $0.age = age
            } else {
                $0.isGuessAgeIncorrect = true
            }
        }
    }
    
    func testGuessAge_Fail() async throws {
        enum GuessAgeTestError: Error { case fetchFailed }
        
        let guessAgeInstance = GuessAge.testInstance()
        
        let testStore = TestStore(
            initialState: GuessMyAgeFeature.State(name: guessAgeInstance.name)
        ) {
            GuessMyAgeFeature()
        } withDependencies: {
            $0.guessAgeClient.singleFetch = { _ in throw GuessAgeTestError.fetchFailed }
        }
        
        await testStore.send(.guessAgeButtonTapped) {
            $0.isGuessAgeButtonTapped = true
            $0.age = nil
            $0.isGuessAgeIncorrect = false
        }
        
        await testStore.receive(.guessAgeFetchFailed)
    }
}
