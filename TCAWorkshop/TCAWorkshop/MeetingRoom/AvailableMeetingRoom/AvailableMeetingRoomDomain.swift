//
//  AvailableMeetingRoomDomain.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import ComposableArchitecture
import Foundation

struct AvailableMeetingRoomFeature: Reducer {
    @Dependency(\.meetingRoomClient)
    var meetingRoomClient: MeetingRoomClient
    
    @Dependency(\.continuousClock)
    var clock: any Clock<Duration>
    
    struct State: Equatable, Identifiable {
        @BindingState var selectedMeetingRoom: MeetingRoom
        var id: UUID
        
        var isReservationButtonTapped: Bool = false
        var isReservationCompleted: Bool = false
        var isReservationFailed: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onViewDisappear
        
        case reservationButtonTapped
        case reservationResponse
        case reservationFailed
    }
    
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onViewDisappear:
                state.isReservationCompleted = false
                state.isReservationButtonTapped = false
                return .cancel(id: Constants.CANCELABLE_RESERVATION_ID)
                
            case .reservationButtonTapped:
                guard state.isReservationCompleted else {
                    state.isReservationButtonTapped = true
                    state.selectedMeetingRoom.rentBy = "CURRENT_USER"
                    return .run { [selectedMeetingRoom = state.selectedMeetingRoom] send in
                        try await self.meetingRoomClient.update(selectedMeetingRoom)
                        try await clock.sleep(for: .seconds(0.5))
                        await send(.reservationResponse, animation: .easeInOut)
                    } catch: { error, send in
                        print("UPDATE FAILED", error.localizedDescription)
                        await send(.reservationFailed)
                    }
                        .cancellable(id: Constants.CANCELABLE_RESERVATION_ID)
                }
                
                return .send(.reservationResponse, animation: .easeInOut)
                
            case .reservationResponse:
                state.isReservationButtonTapped = false
                state.isReservationCompleted = true
                return .none
                
            case .reservationFailed:
                state.isReservationButtonTapped = false
                state.isReservationFailed = true
                return .none
            }
        }
    }
}

