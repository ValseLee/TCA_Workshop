//
//  AvailableMeetingRoomDomain.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import ComposableArchitecture
import Foundation

struct AvailableMeetingRoomFeature: Reducer {
    struct State: Equatable, Identifiable {
        @BindingState var selectedMeetingRoom: MeetingRoom
        var id: UUID
        
        var isReservationButtonTapped: Bool = false
        var isReservationCompleted: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onMeetingRoomViewAppear
        
        case reservationButtonTapped
        case reservationResponse
        case rentDatePicked(Date)
        case rentHourAndMinutePicked(Int)
    }
    
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onMeetingRoomViewAppear:
                return .none
                
            case .reservationButtonTapped:
                return .none
                
            case .reservationResponse:
                return .none
                
            case let .rentDatePicked(date):
                state.selectedMeetingRoom.rentDate = date
                return .none
                
            case let .rentHourAndMinutePicked(time):
                state.selectedMeetingRoom.rentHourAndMinute = time
                return .none
            }
        }
    }
}

