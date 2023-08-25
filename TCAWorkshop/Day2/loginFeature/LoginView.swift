//
//  LoginView.swift
//  TCA_Sample_Tests
//
//  Created by Celan on 2023/08/23.
//

import ComposableArchitecture
import SwiftUI

struct LoginView: View {
    let store: StoreOf<LoginFeature>
    
    var body: some View {
        WithViewStore(
            self.store,
            observe: { $0 }
        ) { viewStore in
            HStack {
                VStack {
                    TextField(
                        "ID",
                        text: viewStore.binding(
                            get: { $0.idString },
                            send: { .idStringEdited($0) }
                        )
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    
                    SecureField(
                        "Password",
                        text: viewStore.binding(
                            get: { $0.pwString },
                            send: { .pwStringEdited($0) }
                        )
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                }
                
                Button {
                  // code
                } label: {
                    Text("Login")
                }
                .disabled(
                    viewStore.state.isLoginButtonDisabled
                )
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store: .init(
                initialState: LoginFeature.State(), reducer: {
                    LoginFeature()
                }
            )
        )
    }
}
