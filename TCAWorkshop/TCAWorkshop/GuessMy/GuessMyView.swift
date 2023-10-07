//
//  GuessMyView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/10/06.
//

import ComposableArchitecture
import SwiftUI

struct GuessMyView: View {
    let store: StoreOf<GuessMyFeature>
    
    var body: some View {
        NavigationStackStore(
            self.store.scope(
                state: \.path,
                action: { .path($0) }
            )
        ) {
            WithViewStore(
                self.store,
                observe: { $0.recentGuessMyAgeInformation }
            ) { viewStore in
                if let guessedAgeInformation = viewStore.state {
                    VStack {
                        Text("Recent Guess My Age Game: ")
                        Text(guessedAgeInformation)
                    }
                }
                
                NavigationLink(
                    state: GuessMyFeature.Path.State
                        .guessMyAge(
                            GuessMyAgeFeature.State(name: "test")
                        )
                ) {
                    Text("Guess My Age")
                }
            }
            
        } destination: { state in
            switch state {
            case .guessMyAge:
                CaseLet(
                    /GuessMyFeature.Path.State.guessMyAge,
                     action: GuessMyFeature.Path.Action.guessMyAge,
                     then: GuessMyAgeView.init(store:)
                )
            }
        }
        .navigationTitle("'Guess My'")
    }
}

struct GuessMyView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GuessMyView(
                store: Store(
                    initialState: GuessMyFeature.State()
                ) {
                    GuessMyFeature()
                }
            )
        }
    }
}
