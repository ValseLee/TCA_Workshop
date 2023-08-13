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
        /// ``var availableRoomArray = [MeetingRoom]()``
        /// 코드도 빌드가 가능하지만 후에 ``ForEachStore`` 등 TCA API에서 요구하는 Identifable을
        /// 만족하기 위해 ``IdentifiedArrayOf<Element>`` 타입을 써주는 것이 편하다
        var availableRoomArray: IdentifiedArrayOf<MeetingRoom> = []
        var unavailableMeetingRoomArray: IdentifiedArrayOf<MeetingRoom> = []
        var bookedMeetingRoomArray: IdentifiedArrayOf<MeetingRoom> = []
        var isMeetingRoomFetching: Bool = false
        var isMeetingRoomFetchFailed: Bool = false
        var isFetchAvailable: Bool = true
    }
    
    @frozen enum Action: Equatable {
        case onMeetingRoomListViewAppear
        case meetingRoomFetchResponse
        case processFetchedMeetingRoomIntoState(with: MeetingRoom)
        case fetchFailed
        case confirmationDialogRetryButtonTapped
        case confirmationDialogDismissed
    }
    
    var body: some ReducerOf<MeetingRoomListDomain> {
        Reduce { state, action in
            switch action {
                case .onMeetingRoomListViewAppear:
                    state.isMeetingRoomFetching = true
                    
                    return .run { send in
                        try await fetchMeetingRooms(send: send)
                        
                    } catch: { error, send in
                        print("FETCH FAILED: ", error)
                        await send(.fetchFailed)
                    }
                    
                case let .processFetchedMeetingRoomIntoState(meetingRoom):
                    self.updateMeetingRoomArray(&state, with: meetingRoom)
                    return .none
                    
                case .meetingRoomFetchResponse:
                    state.isMeetingRoomFetching = false
                    state.isMeetingRoomFetchFailed = false
                    return .none
                    
                case .fetchFailed:
                    state.isMeetingRoomFetching = false
                    if state.isMeetingRoomFetchFailed { // several retries
                        state.isFetchAvailable = false
                        return .none
                        
                    } else {
                        state.isMeetingRoomFetchFailed = true
                    }
                    
                    return .none
                    
                case .confirmationDialogRetryButtonTapped:
                    state.isMeetingRoomFetching = true
                    
                    return .run { send in
                        try await fetchMeetingRooms(send: send)
                        
                    } catch: { error, send in
                        print("FETCH FAILED AGAIN: ", error)
                        await send(.fetchFailed)
                    }
                    
                case .confirmationDialogDismissed:
                    return .none
            }
        }
    }
    
    // MARK: - METHODS
    private func fetchMeetingRooms(send: Send<MeetingRoomListDomain.Action>) async throws {
        let start = Date()
        defer { Logger.methodExecTimePrint(start) }
        let querySnapshot = try await Constants.FIREBASE_COLLECTION.getDocuments()
        for doc in querySnapshot.documents {
            let fetchedMeetingRoom = try doc.data(as: MeetingRoom.self)
            await send(
                .processFetchedMeetingRoomIntoState(with: fetchedMeetingRoom)
            )
        }
        
        await send(.meetingRoomFetchResponse, animation: .easeInOut)
    }
    
    private func updateMeetingRoomArray(
        _ state: inout State,
        with meetingRoom: MeetingRoom
    ) {
        switch meetingRoom.rentBy {
            case "CURRENT_USER":
                if state.bookedMeetingRoomArray.contains(
                    where: { $0.id == meetingRoom.id }
                ) {
                    if let idx = state.bookedMeetingRoomArray.firstIndex(
                        where: { $0.id == meetingRoom.id }
                    ) {
                        state.bookedMeetingRoomArray[idx] = meetingRoom
                    }
                } else {
                    state.bookedMeetingRoomArray.append(meetingRoom)
                }
                
            case "OTHERS":
                if state.unavailableMeetingRoomArray.contains(
                    where: { $0.id == meetingRoom.id }
                ) {
                    if let idx = state.unavailableMeetingRoomArray.firstIndex(
                        where: { $0.id == meetingRoom.id }
                    ) {
                        state.unavailableMeetingRoomArray[idx] = meetingRoom
                    }
                } else {
                    state.unavailableMeetingRoomArray.append(meetingRoom)
                }
                
            case "AVAILABLE":
                if state.availableRoomArray.contains(
                    where: { $0.id == meetingRoom.id }
                ) {
                    if let idx = state.availableRoomArray.firstIndex(
                        where: { $0.id == meetingRoom.id }
                    ) {
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

