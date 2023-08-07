//
//  ContentView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/04.
//

import SwiftUI
import ComposableArchitecture
import FirebaseFirestore

struct ContentView: View {
    let store: StoreOf<MeetingRoomFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                // TODO: 동일 뷰 구성
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(initialState: MeetingRoomFeature.State()) {
                MeetingRoomFeature()
            }
        )
    }
}
