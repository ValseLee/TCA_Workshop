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
    
    @Dependency(\.date.now)
    var now: Date
    
    struct State: Equatable, Identifiable {
        @BindingState var selectedMeetingRoom: MeetingRoom
        @PresentationState var meetingRoomInfo: MeetingCardDomain.State?
        var id: UUID
        
        var isCancelReservationButtonTapped: Bool = false
        var isCancelReservationCompleted: Bool = false
        var isCancelReservationCancelled: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case meetingRoomInfoAction(PresentationAction<MeetingCardDomain.Action>)
        case binding(BindingAction<State>)
        case onViewDisappear
        case cancelReservationButtonTapped
        case cancelReservationResponse
        case cancelReservationCancelled
        case browseMeetingInfoButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        core()
            .ifLet(
                \.$meetingRoomInfo,
                 action: /Action.meetingRoomInfoAction
            ) {
                MeetingCardDomain()
            }
    }
    
    private func core() -> Reduce<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .meetingRoomInfoAction(.dismiss):
                return .none
                
            case .meetingRoomInfoAction(.presented):
                // 🧩 MeetingCardView가 present되면 해당 Action이 Receive 된다.
                return .none
                
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
                
            case .browseMeetingInfoButtonTapped:
                // !!!: Fetch 되도록 수정해야 해
                let meetingInfo = MeetingInfo.testInstance()
                state.meetingRoomInfo = .init(
                    id: meetingInfo.id,
                    meetingInfo: meetingInfo
                )
                state.meetingRoomInfo?.meetingInfo.date = now
                
                return .none
            }
        }
    }
}
