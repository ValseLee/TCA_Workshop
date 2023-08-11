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

struct MeetingRoomListDomain: Reducer {
    struct State: Equatable {
        var meetingRoomArray: IdentifiedArrayOf<MeetingRoomDomain.State> = []
        
        var availableRoomArray: IdentifiedArrayOf<MeetingRoom> = []
        var unavailableMeetingRoomArray: IdentifiedArrayOf<MeetingRoom> = []
        var bookedMeetingRoomArray: IdentifiedArrayOf<MeetingRoom> = []
        var isMeetingRoomFetching: Bool = false
    }
    
    @frozen enum Action: Equatable {
        case meetingRoomCellTapped
        case onMeetingRoomListViewAppear
        case meetingRoomFetchResponse
        case processFetchedMeetingRoom(with: MeetingRoom)
//        case makeMeetingRoomButtonTapped
        case bookMeetingRoom(with: MeetingRoom)
    }
    
    var body: some ReducerOf<MeetingRoomListDomain> {
        Reduce { state, action in
            switch action {
            case .meetingRoomCellTapped:
                
                return .none
                
            case .onMeetingRoomListViewAppear:
                state.isMeetingRoomFetching = true
                
                return .run { send in
                    let start = Date()
                    defer { Logger.methodExecTimePrint(start) }
                    let querySnapshot = try await Constants.FIREBASE_COLLECTION.getDocuments()
                    for doc in querySnapshot.documents {
                        let fetchedMeetingRoom = try doc.data(as: MeetingRoom.self)
                        await send(.processFetchedMeetingRoom(with: fetchedMeetingRoom))
                    }
                    await send(.meetingRoomFetchResponse, animation: .easeInOut)
                }
            
            case let .processFetchedMeetingRoom(meetingRoom):
                self.updateMeetingRoomArray(&state, with: meetingRoom)
                return .none
                
            case .meetingRoomFetchResponse:
                state.isMeetingRoomFetching = false
                
                return .none
            
            case let .bookMeetingRoom(meetingRoom):
                
                return .run { send in
                    try Constants.FIREBASE_COLLECTION
                        .document(meetingRoom.id.uuidString)
                        .setData(from: meetingRoom.self, merge: true)
                }
                .merge(with: .send(.processFetchedMeetingRoom(with: meetingRoom)))
            }
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

