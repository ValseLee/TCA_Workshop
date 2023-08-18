//
//  ContentView.swift
//  TCA_Sample_Tests
//
//  Created by Celan on 2023/08/03.
//

import ComposableArchitecture
import SwiftUI

struct CartDomainView: View {
    let store: StoreOf<CartFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.state.cartItemArray, id: \.self) { cartItem in
                    Text(cartItem.name)
                }
                .onDelete { indexSet in
                    viewStore.send(.listRowSwipeToRemove(indexSet))
                }
            }
            .navigationTitle("장바구니")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewStore.send(.cartButtonTapped)
                    } label: {
                        Image(systemName: "cart.badge.plus")
                    }
                }
            }
            .sheet(isPresented: viewStore.$isSheetDisplayed) {
                NavigationStack {
                    Form {
                        TextField(
                            "무엇을 살까?",
                            text: viewStore.$itemText
                        )
                    }
                    .navigationTitle("장바구니 추가하기")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewStore.send(.sheetCancelButtonTapped)
                            } label: {
                                Text("취소")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewStore.send(.sheetConfirmButtonTapped)
                            } label: {
                                Text("확인")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CartDomainView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CartDomainView(
                store: Store(
                    initialState: CartFeature.State(
                        cartItemArray: CartItem.mockArray()
                    )
                ) {
                    CartFeature()
                }
            )
        }
    }
}
