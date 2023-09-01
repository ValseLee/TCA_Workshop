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
    
    @Dependency(\.continuousClock)
    var clock: any Clock<Duration>
    
    struct State: Equatable, Identifiable {
        @BindingState var selectedMeetingRoom: MeetingRoom
        var id: UUID
        
        var isCancelReservationButtonTapped: Bool = false
        var isCancelReservationCompleted: Bool = false
        var isCancelReservationCancelled: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onViewDisappear
        case cancelReservationButtonTapped
        case cancelReservationResponse
        case cancelReservationCancelled
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
                state.isCancelReservationCancelled = false
                return .cancel(id: Constants.CANCELABLE_RESERVATION_CANCEL_ID)
                
            case .cancelReservationButtonTapped:
                guard state.isCancelReservationCompleted else {
                    state.isCancelReservationButtonTapped = true
                    state.selectedMeetingRoom.rentBy = "AVAILABLE"
                    
                    return .run { [state = state] send in
                        try await withTaskCancellation(id: Constants.CANCELABLE_RESERVATION_CANCEL_ID) {
                            // 업데이트가 외부적 요인에 의해 취소된다면 error 를 throw 한다.
                            try Task.checkCancellation()
                            try await meetingRoomClient.update(state.selectedMeetingRoom)
                            try await clock.sleep(for: .seconds(0.5))
                            await send(.cancelReservationResponse, animation: .easeInOut)
                        }
                    } catch: { error, send in
                        print("RESERVATION CANCEL FAILED", error.localizedDescription)
                        await send(.cancelReservationCancelled)
                    }
                        .cancellable(id: Constants.CANCELABLE_RESERVATION_CANCEL_ID)
                }
                
                return .send(.cancelReservationResponse, animation: .easeInOut)
                
            case .cancelReservationResponse:
                state.isCancelReservationButtonTapped = false
                state.isCancelReservationCompleted = true
                return .none
                
            case .cancelReservationCancelled:
                state.isCancelReservationButtonTapped = false
                state.isCancelReservationCancelled = true
                return .none
            }
        }
    }
}
