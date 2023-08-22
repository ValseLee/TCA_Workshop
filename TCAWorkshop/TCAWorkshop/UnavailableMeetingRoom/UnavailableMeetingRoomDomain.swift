//
//  UnavailableMeetingRoom.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import ComposableArchitecture
import Foundation

struct UnavabilableMeetingRoomFeature: Reducer {
    struct State: Equatable, Identifiable {
        var selectedMeetingRoom: MeetingRoom
        var id: UUID
    }
    
    enum Action: Equatable { }
    
    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        return .none
    }
}

