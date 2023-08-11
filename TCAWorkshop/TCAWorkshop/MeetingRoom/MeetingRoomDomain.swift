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

struct ManageMeetingRoom: Reducer {
    struct State: Equatable {
        @BindingState var rentLearnerName: String
        @BindingState var rentDate: Date
        
        var selectedMeetingRoom: MeetingRoom
    }
    
    @frozen enum Action: Equatable {
        case reservationButtonTapped
    }
    
    var body: some ReducerOf<ManageMeetingRoom> {
        Reduce { state, action in
            switch action {
            case .reservationButtonTapped:
                let newMeetingRoom = MeetingRoom(
                    id: .init(),
                    meetingRoomName: "Test",
                    rentDate: .now,
                    rentBy: Constants.DUMMY_MEETINGROOM_RENTNAMES.randomElement()!
                )
                
                return .run { send in
                    /// <NSThread: 0x600000b96080>{number = 6, name = (null)}
                    /// <NSThread: 0x600000bd1300>{number = 10, name = (null)}
                    /// .run의 클로저는 그 자체로 Task를 생성하여 동시성 작업을 실행한다.
                    try await Constants.FIREBASE_COLLECTION
                        .document(newMeetingRoom.id.uuidString)
                        .setData([
                            "id": newMeetingRoom.id.uuidString,
                            "rentDate": Timestamp(date: newMeetingRoom.rentDate),
                            "rentBy": newMeetingRoom.rentBy,
                            "meetingRoomName": newMeetingRoom.meetingRoomName
                        ])
                }
            }
        }
    }
}
