//
//  ContentView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/04.
//

import SwiftUI
import ComposableArchitecture

struct MeetingRoom: Identifiable, Hashable {
    var id: UUID
    var date: Date
    var rentBy: String
}


struct MeetingRoomStore: Reducer {
    struct State: Equatable {
        var meetingRoom: MeetingRoom
    }
    
    @frozen enum Action: Equatable {
        case meetingRoomCellTapped
    }
    
    var body: some ReducerOf<MeetingRoomStore> {
        Reduce { state, action in
            switch action {
            case .meetingRoomCellTapped:
                state.meetingRoom.rentBy = ""
                
                return .run { send in
                    await send(.meetingRoomCellTapped)
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
