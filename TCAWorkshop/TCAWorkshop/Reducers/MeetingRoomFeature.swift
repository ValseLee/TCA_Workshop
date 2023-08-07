//
//  MeetingRoomStore.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/07.
//

import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct MeetingRoomFeature: Reducer {
    private let collection = Firestore.firestore().collection("MeetingRooms")
    
    struct State: Equatable {
        static func == (lhs: MeetingRoomFeature.State, rhs: MeetingRoomFeature.State) -> Bool {
            lhs.availableRoomArray == rhs.availableRoomArray &&
            lhs.bookedMeetingRoomArray == rhs.bookedMeetingRoomArray &&
            lhs.unavailableMeetingRoomArray == rhs.unavailableMeetingRoomArray
        }
        
        var firebaseListener: ListenerRegistration?
        var availableRoomArray: [MeetingRoom] = []
        var unavailableMeetingRoomArray: [MeetingRoom] = []
        var bookedMeetingRoomArray: [MeetingRoom] = []
    }
    
    @frozen enum Action: Equatable {
        case meetingRoomCellTapped
        case onMeetingRoomListViewAppear
        case makeMeetingRoomButtonTapped
    }
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case .meetingRoomCellTapped:
            
            return .none
            
        case .onMeetingRoomListViewAppear:
            
            return .run { send in
                let querySnapshot = try await collection.getDocuments()
                for doc in querySnapshot.documents {
                    // TODO: 비동기로 각 배열에 fetched된 meetingRoom을 추가해주세요
                }
            }
            
        case .makeMeetingRoomButtonTapped:
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
                try await self.collection
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
    
    @MainActor
    private func appendValues(_ state: inout State) async {
        
    }
}

