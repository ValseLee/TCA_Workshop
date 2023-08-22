//
//  AvailableMeetingRoomDomain.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import ComposableArchitecture
import Foundation

struct AvailableMeetingRoomFeature: Reducer {
    let meetingRoomClient: MeetingRoomClient = .live
    
    struct State: Equatable, Identifiable {
        @BindingState var selectedMeetingRoom: MeetingRoom
        var id: UUID
        
        var isReservationButtonTapped: Bool = false
        var isReservationCompleted: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onViewDisappear
        case reservationButtonTapped
        case reservationResponse
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
                    /// 현 시점의 State를 immutable하게 capture copy해서 전달한다.
                    /// inout value type 의 Data race를 방지
                    return .run { [selectedMeetingRoom = state.selectedMeetingRoom] send in
                        try await self.meetingRoomClient.update(selectedMeetingRoom)
                        try! await Task.sleep(for: .seconds(0.5))
                        await send(.reservationResponse, animation: .easeInOut)
                    } catch: { error, send in
                        print("UPDATE FAILED", error.localizedDescription)
                    }
                        .cancellable(id: Constants.CANCELABLE_RESERVATION_ID)
                }
                
                return .send(.reservationResponse, animation: .easeInOut)
                
            case .reservationResponse:
                state.isReservationButtonTapped = false
                state.isReservationCompleted = true
                return .none
            }
        }
    }
}

