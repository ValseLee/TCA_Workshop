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
        var minuteHourformatter: DateFormatter = DateFormatter(dateFormat: "HH:mm a", calendar: .autoupdatingCurrent)
        var dayformatter: DateFormatter = DateFormatter(dateFormat: "YY년 MM월 dd일")
        
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

