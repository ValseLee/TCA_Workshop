//
//  GuessMyFeature.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/10/06.
//

import ComposableArchitecture

struct GuessMyFeature: Reducer {
    struct State: Equatable {
        var path = StackState<Path.State>()
        var recentGuessMyAgeInformation: String?
    }
    enum Action: Equatable {
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .path(.element(id: id, action: .guessMyAge(.guessAgeResponse(_)))):
                guard let guessMyAgeState = state.path[id: id, case: /Path.State.guessMyAge]
                else { return .none }
                
                if !guessMyAgeState.isGuessAgeIncorrect {
                    state.recentGuessMyAgeInformation = guessMyAgeState.name
                }
                return .none
            case .path:
                return .none
            }
        }
        // MARK: 모든 Stack 에 대해 부모-자식 간 통합 및 NavigationStack 설정을 진행하는 .forEach
        .forEach(
            \.path,
             action: /Action.path
        ) {
            Path()
        }
    }
    
    struct Path: Reducer {
        enum State: Equatable {
            case guessMyAge(GuessMyAgeFeature.State)
        }
        enum Action: Equatable {
            case guessMyAge(GuessMyAgeFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(
                state: /State.guessMyAge,
                action: /Action.guessMyAge
            ) {
                GuessMyAgeFeature()
            }
        }
    }

}
