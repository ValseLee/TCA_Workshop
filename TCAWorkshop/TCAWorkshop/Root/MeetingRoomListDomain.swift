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
        var availableMeetingRoomArray: IdentifiedArrayOf<MeetingRoomDomain.State> = []
        var unavailableMeetingRoomArray: IdentifiedArrayOf<MeetingRoomDomain.State> = []
        var bookedMeetingRoomArray: IdentifiedArrayOf<MeetingRoomDomain.State> = []
        
        var isMeetingRoomFetching: Bool = false
        var isMeetingRoomFetchFailed: Bool = false
        var isFetchAvailable: Bool = true
    }
    
    @frozen enum Action: Equatable {
        case bookedMeetingRoom(
            id: MeetingRoomDomain.State.ID,
            action: MeetingRoomDomain.Action
        )
        
        case availableMeetingRoom(
            id: MeetingRoomDomain.State.ID,
            action: MeetingRoomDomain.Action
        )
        
        case unavailableMeetingRoom(
            id: MeetingRoomDomain.State.ID,
            action: MeetingRoomDomain.Action
        )
        
        case onMeetingRoomListViewAppear
        case meetingRoomFetchResponse
        case processFetchedMeetingRoomIntoState(with: MeetingRoom)
        case fetchFailed
        case listRefreshed
        case confirmationDialogRetryButtonTapped
        case confirmationDialogDismissed
    }
    
    var body: some ReducerOf<MeetingRoomListDomain> {
        Reduce { state, action in
        switch action {
            case .bookedMeetingRoom:
                return .none
                
            case .availableMeetingRoom:
                return .none
                
            case .unavailableMeetingRoom:
                return .none
            
            case .onMeetingRoomListViewAppear:
                state.isMeetingRoomFetching = true
            
                return .run {
                    try await fetchMeetingRooms(send: $0)
                }
                catch: { error, send in
                    print("FETCH FAILED: ", error)
                    await send(.fetchFailed)
                }
                
            case .listRefreshed:
                state.isMeetingRoomFetching = true
                return .run { try await fetchMeetingRooms(send: $0) }
                catch: { error, send in
                    print("REFRESH FAILED: ", error)
                    await send(.fetchFailed)
                }
                
            case let .processFetchedMeetingRoomIntoState(meetingRoom):
                self.makeMeetingRoom(&state, with: meetingRoom)
                return .none
                
            case .meetingRoomFetchResponse:
                state.isMeetingRoomFetching = false
                state.isMeetingRoomFetchFailed = false
                return .none
                
            case .fetchFailed:
                state.isMeetingRoomFetching = false
                if state.isMeetingRoomFetchFailed {
                    state.isFetchAvailable = false
                    return .none
                } else { state.isMeetingRoomFetchFailed = true }
                
                return .none
                
            case .confirmationDialogRetryButtonTapped:
                state.isMeetingRoomFetching = true
                
                return .run { try await fetchMeetingRooms(send: $0) }
                catch: { error, send in
                    print("FETCH FAILED AGAIN: ", error)
                    await send(.fetchFailed)
                }
                
            case .confirmationDialogDismissed:
                return .none
            }
        }
        /// 여러 State를 관리하는 child Reducer는 하나여도 된다.
        /// 그러나 각 State에 대한 액션은 서로 다른 ``case``로 처리해야 한다.
        /// State의 변경이 action을 트리거할 때, id에 해당하는 element를 찾지 못하기 때문
        .forEach(
            \.bookedMeetingRoomArray,
             action: /Action.bookedMeetingRoom(id:action:)
        ) { MeetingRoomDomain() }
        .forEach(
            \.unavailableMeetingRoomArray,
             action: /Action.unavailableMeetingRoom(id:action:)
        ) { MeetingRoomDomain() }
        .forEach(
            \.availableMeetingRoomArray,
             action: /Action.availableMeetingRoom(id:action:)
        ) { MeetingRoomDomain() }
    }
    
    // MARK: - METHODS
    private func makeMeetingRoom(
        _ state: inout State,
        with meetingRoom: MeetingRoom
    ) {
        switch meetingRoom.rentBy {
        case "CURRENT_USER":
            if state.bookedMeetingRoomArray.contains(
                where: { $0.selectedMeetingRoom == meetingRoom }
            ) {
                if let idx = state.bookedMeetingRoomArray.firstIndex(
                    where: { $0.selectedMeetingRoom == meetingRoom }) {
                    state.bookedMeetingRoomArray[idx].selectedMeetingRoom = meetingRoom
                }
            } else {
                state.bookedMeetingRoomArray.append(
                    MeetingRoomDomain.State(
                        id: meetingRoom.id,
                        selectedMeetingRoom: meetingRoom
                    )
                )
            }
            
        case "OTHERS":
            if state.unavailableMeetingRoomArray.contains(
                where: { $0.selectedMeetingRoom == meetingRoom }
            ) {
                if let idx = state.unavailableMeetingRoomArray.firstIndex(
                    where: { $0.selectedMeetingRoom == meetingRoom }) {
                    state.unavailableMeetingRoomArray[idx].selectedMeetingRoom = meetingRoom
                }
            } else {
                state.unavailableMeetingRoomArray.append(
                    MeetingRoomDomain.State(
                        id: meetingRoom.id,
                        selectedMeetingRoom: meetingRoom
                    )
                )
            }
            
        case "AVAILABLE":
            if state.availableMeetingRoomArray.contains(
                where: { $0.selectedMeetingRoom == meetingRoom }
            ) {
                if let idx = state.availableMeetingRoomArray.firstIndex(
                    where: { $0.selectedMeetingRoom == meetingRoom }) {
                    state.availableMeetingRoomArray[idx].selectedMeetingRoom = meetingRoom
                }
            } else {
                state.availableMeetingRoomArray.append(
                    MeetingRoomDomain.State(
                        id: meetingRoom.id,
                        selectedMeetingRoom: meetingRoom
                    )
                )
            }
            
        default:
            return
        }
    }
    
    private func fetchMeetingRooms(send: Send<MeetingRoomListDomain.Action>) async throws {
        let start = Date()
        defer { Logger.methodExecTimePrint(start) }
        
        let querySnapshot = try await Constants.FIREBASE_COLLECTION.getDocuments()
        for doc in querySnapshot.documents {
            let fetchedMeetingRoom = try doc.data(as: MeetingRoom.self)
            await send(.processFetchedMeetingRoomIntoState(with: fetchedMeetingRoom))
        }
        
        await send(.meetingRoomFetchResponse, animation: .easeInOut)
    }
}

