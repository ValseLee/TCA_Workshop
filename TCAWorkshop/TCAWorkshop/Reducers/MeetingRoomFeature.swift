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
        var availableRoomArray: [MeetingRoom] = []
        var unavailableMeetingRoomArray: [MeetingRoom] = []
        var bookedMeetingRoomArray: [MeetingRoom] = []
        var isMeetingRoomFetching: Bool = false
    }
    
    @frozen enum Action: Equatable {
        case meetingRoomCellTapped
        case onMeetingRoomListViewAppear
        case meetingRoomFetchResponse
        case processFetchedMeetingRoom(with: MeetingRoom)
        case makeMeetingRoomButtonTapped
        case bookMeetingRoom(with: MeetingRoom)
    }
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case .meetingRoomCellTapped:
            
            return .none
            
        case .onMeetingRoomListViewAppear:
            state.isMeetingRoomFetching = true
            
            return .run { send in
                let start = Date()
                defer { Logger.methodExecTimePrint(start) }
                let querySnapshot = try await collection.getDocuments()
                for doc in querySnapshot.documents {
                    let fetchedMeetingRoom = try doc.data(as: MeetingRoom.self)
                    await send(.processFetchedMeetingRoom(with: fetchedMeetingRoom))
                }
                await send(.meetingRoomFetchResponse, animation: .easeInOut)
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
            
        case let .processFetchedMeetingRoom(meetingRoom):
            self.updateMeetingRoomArray(&state, with: meetingRoom)
            return .none
            
        case .meetingRoomFetchResponse:
            state.isMeetingRoomFetching = false
            
            return .none
        
        case let .bookMeetingRoom(meetingRoom):
            
            return .run { send in
                try self.collection
                    .document(meetingRoom.id.uuidString)
                    .setData(from: meetingRoom.self, merge: true)
            }
            .merge(with: .send(.processFetchedMeetingRoom(with: meetingRoom)))
        }
    }
    
    private func updateMeetingRoomArray(
        _ state: inout State,
        with meetingRoom: MeetingRoom
    ) {
        switch meetingRoom.rentBy {
        case "CURRENT_USER":
            if state.bookedMeetingRoomArray.contains(where: { $0.id == meetingRoom.id }) {
                if let idx = state.bookedMeetingRoomArray.firstIndex(where: { $0.id == meetingRoom.id }) {
                    state.bookedMeetingRoomArray[idx] = meetingRoom
                }
            } else {
                state.bookedMeetingRoomArray.append(meetingRoom)
            }
                
        case "OTHERS":
            if state.unavailableMeetingRoomArray.contains(where: { $0.id == meetingRoom.id }) {
                if let idx = state.unavailableMeetingRoomArray.firstIndex(where: { $0.id == meetingRoom.id }) {
                    state.unavailableMeetingRoomArray[idx] = meetingRoom
                }
            } else {
                state.unavailableMeetingRoomArray.append(meetingRoom)
            }
            
        case "AVAILABLE":
            if state.availableRoomArray.contains(where: { $0.id == meetingRoom.id }) {
                if let idx = state.availableRoomArray.firstIndex(where: { $0.id == meetingRoom.id }) {
                    state.availableRoomArray[idx] = meetingRoom
                }
            } else {
                state.availableRoomArray.append(meetingRoom)
            }
            
        default:
            return
        }
    }
}

