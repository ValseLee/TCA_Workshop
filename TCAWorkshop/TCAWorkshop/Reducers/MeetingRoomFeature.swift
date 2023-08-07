//
//  MeetingRoomStore.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/07.
//

import Foundation
import ComposableArchitecture

struct MeetingRoomFeature: Reducer {
    struct State: Equatable {
        var availableRoomArray: [MeetingRoom] = []
        var unavailableMeetingRoomArray: [MeetingRoom] = []
        var bookedMeetingRoomArray: [MeetingRoom] = []
    }
    
    @frozen enum Action: Equatable {
        case meetingRoomCellTapped
    }
    
    var body: some ReducerOf<MeetingRoomFeature> {
        Reduce { state, action in
            switch action {
            case .meetingRoomCellTapped:
                
                return .run { send in
                    await send(.meetingRoomCellTapped)
                }
            }
        }
    }
}

