//
//  ManageMeetingRoom.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/09.
//

import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct MeetingRoomDomain: Reducer {
    struct State: Equatable, Identifiable {
        @BindingState var rentLearnerName: String
        @BindingState var rentDate: Date
        
        var id: UUID
        var selectedMeetingRoom: MeetingRoom
        var isReservationButtonTapped: Bool = false
    }
    
    @frozen enum Action: Equatable {
        case reservationButtonTapped(MeetingRoom)
        case reservationResponse
    }
    
    var body: some ReducerOf<MeetingRoomDomain> {
        Reduce { state, action in
            switch action {
            case let .reservationButtonTapped(meetingRoom):
                state.isReservationButtonTapped = true
                state.selectedMeetingRoom.rentBy = state.rentLearnerName
                state.selectedMeetingRoom.rentDate = state.rentDate
                
                return .run { send in
                    try await Constants.FIREBASE_COLLECTION
                        .document(meetingRoom.id.uuidString)
                        .setData([
                            "id": meetingRoom.id.uuidString,
                            "rentDate": Timestamp(date: meetingRoom.rentDate),
                            "rentBy": meetingRoom.rentBy,
                            "meetingRoomName": meetingRoom.meetingRoomName
                        ])
                    await send(.reservationResponse)
                }
                
            case .reservationResponse:
                state.isReservationButtonTapped = false
                
                return .none
            default:
                fatalError()
            }
        }
    }
}
