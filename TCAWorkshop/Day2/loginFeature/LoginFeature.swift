//
//  LoginFeature.swift
//  TCA_Sample_Tests
//
//  Created by Celan on 2023/08/23.
//

import ComposableArchitecture
import Foundation

struct LoginFeature: Reducer {
    struct State: Equatable {
        var idString: String = ""
        var pwString: String = ""
        var isLoginButtonDisabled: Bool = true
    }
    
    enum Action: Equatable {
        case idStringEdited(String)
        case pwStringEdited(String)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .idStringEdited(id):
                state.idString = id
                
                if !state.pwString.isEmpty,
                   !state.idString.isEmpty {
                    state.isLoginButtonDisabled = false
                } else {
                    state.isLoginButtonDisabled = true
                }
                
                return .none
                
            case let .pwStringEdited(pw):
                state.pwString = pw
                if !state.pwString.isEmpty,
                   !state.idString.isEmpty {
                    state.isLoginButtonDisabled = false
                } else {
                    state.isLoginButtonDisabled = true
                }
                
                return .none
            }
        }
    }
}
