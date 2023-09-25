//
//  GuessMyAgeFeature.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/25.
//

import ComposableArchitecture

struct GuessMyAgeFeature: Reducer {
    @Dependency(\.guessAgeClient)
    var guessAgeClient

    struct State: Equatable {
        var name: String
        var age: Int?
        var isGuessAgeButtonTapped: Bool = false
        var isGuessAgeIncorrect: Bool = false
    }
    
    enum Action: Equatable {
        case nameTextFieldEditted(String)
        case emptyNameTextFieldButtonTapped
        
        case guessAgeButtonTapped
        case guessAgeResponse(GuessAge)
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
    
    private func core() -> some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .nameTextFieldEditted(name):
                state.name = name
                return .none
                
            case .emptyNameTextFieldButtonTapped:
                state.name = ""
                return .none
                
            case .guessAgeButtonTapped:
                state.isGuessAgeButtonTapped = true
                state.age = nil
                state.isGuessAgeIncorrect = false
                
                return .run { [name = state.name] send in
                    let result = try await guessAgeClient.singleFetch(name)
                    await send(
                        .guessAgeResponse(result),
                        animation: .easeInOut
                    )
                }
                
            case let .guessAgeResponse(result):
                state.isGuessAgeButtonTapped = false
                if let age = result.age {
                    state.age = age
                } else {
                    state.isGuessAgeIncorrect = true
                }
                
                return .none
            }
        }
    }
}

