//
//  GuessMyAgeView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/25.
//

import ComposableArchitecture
import SwiftUI

struct GuessMyAgeView: View {
    let store: StoreOf<GuessMyAgeFeature>
    
    var body: some View {
        WithViewStore(
            self.store,
            observe: { $0 }
        ) { viewStore in
            VStack {
                if viewStore.state.isGuessAgeButtonTapped {
                    ProgressView()
                        .padding()
                } else if let age = viewStore.state.age {
                    Text("Guessed Age: \(age)")
                        .padding()
                } else if viewStore.state.isGuessAgeIncorrect {
                    Text("Sorry, I Can't Guess Your Name ;)")
                        .padding()
                }
                
                TextField(
                    "",
                    text: viewStore.binding(
                        get: { $0.name },
                        send: { .nameTextFieldEditted($0) }
                    )
                )
                .bold()
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 160)
                .disabled(viewStore.state.isGuessAgeButtonTapped)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(maxHeight: 1.5)
                        .offset(y: 6)
                }
                .overlay(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Button {
                            viewStore.send(.emptyNameTextFieldButtonTapped)
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .foregroundColor(.red)
                }
                
                Button {
                    viewStore.send(
                        .guessAgeButtonTapped,
                        animation: .easeInOut
                    )
                } label: {
                    Text("Guess My Age")
                }
                .disabled(viewStore.state.isGuessAgeButtonTapped)
            }
        }
    }
}

struct GuessMyAgeView_Preview: PreviewProvider {
    static var previews: some View {
        GuessMyAgeView(
            store: Store(
                initialState: GuessMyAgeFeature.State(
                    name: "TEST",
                    age: 0
                ),
                reducer: {
                    GuessMyAgeFeature()
                }
            )
        )
    }
}
