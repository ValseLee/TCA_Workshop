//
//  BookedMeetingRoomDomain.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import ComposableArchitecture
import Foundation

struct BookedMeetingRoomFeature: Reducer {
    struct State: Equatable, Identifiable {
        @BindingState var selectedMeetingRoom: MeetingRoom
        var id: UUID
        
        var isCancelReservationButtonTapped: Bool = false
        var isCancelReservationCompleted: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onMeetingRoomViewAppear
        case cancelReservationButtonTapped
        case cancelReservationResponse
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onMeetingRoomViewAppear:
                return .none
                
            case .cancelReservationButtonTapped:
                return .none
                
            case .cancelReservationResponse:
                return .none
            }
        }
    }
}
