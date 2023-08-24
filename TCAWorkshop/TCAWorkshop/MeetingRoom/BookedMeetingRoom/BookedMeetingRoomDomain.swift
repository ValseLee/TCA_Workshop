//
//  BookedMeetingRoomDomain.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import ComposableArchitecture
import Foundation

struct BookedMeetingRoomFeature: Reducer {
    @Dependency(\.meetingRoomClient)
    var meetingRoomClient: MeetingRoomClient
    
    struct State: Equatable, Identifiable {
        @BindingState var selectedMeetingRoom: MeetingRoom
        var id: UUID
        
        var isCancelReservationButtonTapped: Bool = false
        var isCancelReservationCompleted: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onViewDisappear
        case cancelReservationButtonTapped
        case cancelReservationResponse
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onViewDisappear:
                state.isCancelReservationCompleted = false
                state.isCancelReservationButtonTapped = false
                return .cancel(id: Constants.CANCELABLE_RESERVATION_CANCEL_ID)
                
            case .cancelReservationButtonTapped:
                guard state.isCancelReservationCompleted else {
                    state.isCancelReservationButtonTapped = true
                    state.selectedMeetingRoom.rentBy = "AVAILABLE"
                    
                    return .run { [selectedMeetingRoom = state.selectedMeetingRoom] send in
                        try await meetingRoomClient.update(selectedMeetingRoom)
                        try! await Task.sleep(for: .seconds(0.5))
                        await send(.cancelReservationResponse, animation: .easeInOut)
                    } catch: { error, send in
                        print("RESERVATION CANCEL FAILED", error.localizedDescription)
                    }
                        .cancellable(id: Constants.CANCELABLE_RESERVATION_CANCEL_ID)
                }
                
                return .send(.cancelReservationResponse, animation: .easeInOut)
                
            case .cancelReservationResponse:
                state.isCancelReservationButtonTapped = false
                state.isCancelReservationCompleted = true
                return .none
            }
        }
    }
}
