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
        
        var isMeetingRoomInitOnce: Bool = false
        var isMeetingRoomFetching: Bool = false
        var isMeetingRoomFetchFailed: Bool = false
        var isFetchAvailable: Bool = true
        
        var isAvailableMeetingRoomArrayEmpty: Bool = true
        var isUnavailableMeetingRoomArrayEmpty: Bool = true
        var isBookedMeetingRoomArrayEmpty: Bool = true
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
        case processFetchedMeetingRoomIntoState(with: MeetingRoom)
        case meetingRoomFetchComplete
        case meetingRoomFetchFailed
        case listRefreshed
        case confirmationDialogRetryButtonTapped
        case confirmationDialogDismissed(Bool)
        case fetchUnavailableResponse
    }
    
    var body: some ReducerOf<MeetingRoomListDomain> {
        Reduce { state, action in
            switch action {
                // MARK: - .forEach
            case .bookedMeetingRoom:
                return .none
                
            case .availableMeetingRoom:
                return .none
                
            case .unavailableMeetingRoom:
                return .none
                
                // MARK: - Render
            case .onMeetingRoomListViewAppear:
                checkIfMeetingRoomArrayIsEmpty(&state)
                
                guard state.isMeetingRoomInitOnce else {
                    state.isMeetingRoomFetching = true
                    return .run {
                        try await Task.sleep(for: .seconds(0.5))
                        try await fetchMeetingRooms(send: $0)
                    }
                    catch: { error, send in
                        print("FETCH FAILED: ", error)
                        await send(.meetingRoomFetchFailed, animation: .easeInOut)
                    }
                }
                
                return .none
                
            case .listRefreshed:
                state.isMeetingRoomFetching = true
                return .run {
                    try await Task.sleep(for: .seconds(0.5))
                    try await fetchMeetingRooms(send: $0)
                }
                catch: { error, send in
                    print("REFRESH FAILED: ", error)
                    await send(.meetingRoomFetchFailed, animation: .easeInOut)
                }
                
            case let .processFetchedMeetingRoomIntoState(fetchedMeetingRoom):
                self.makeMeetingRoom(&state, with: fetchedMeetingRoom)
                return .none
                
            case .meetingRoomFetchComplete:
                state.isMeetingRoomFetching = false
                state.isMeetingRoomFetchFailed = false
                state.isMeetingRoomInitOnce = true
                checkIfMeetingRoomArrayIsEmpty(&state)
                
                return .none
                
            case .meetingRoomFetchFailed:
                state.isMeetingRoomFetchFailed = true
                state.isMeetingRoomFetching = false
                
                return .none
                
            case .confirmationDialogRetryButtonTapped:
                state.isMeetingRoomFetching = true
                state.isMeetingRoomFetchFailed = false
                
                return .run {
                    try await Task.sleep(for: .seconds(0.5))
                    try await fetchMeetingRooms(send: $0)
                }
                catch: { error, send in
                    print("FETCH FAILED AGAIN: ", error)
                    await send(.fetchUnavailableResponse, animation: .easeInOut)
                }
                
            case let .confirmationDialogDismissed(dismissed):
                state.isMeetingRoomFetchFailed = dismissed
                return .none
                
            case .fetchUnavailableResponse:
                state.isFetchAvailable = false
                state.isMeetingRoomFetching = false
                return .none
            }
        }
        .forEach(
            \.bookedMeetingRoomArray,
             action: /Action.bookedMeetingRoom(id:action:)
        ) {
            MeetingRoomDomain()
        }
        .forEach(
            \.unavailableMeetingRoomArray,
             action: /Action.unavailableMeetingRoom(id:action:)
        ) {
            MeetingRoomDomain()
        }
        .forEach(
            \.availableMeetingRoomArray,
             action: /Action.availableMeetingRoom(id:action:)
        ) {
            MeetingRoomDomain()
        }
    }
    
    // MARK: - METHODS
    private func makeMeetingRoom(
        _ state: inout State,
        with fetchedMeetingRoom: MeetingRoom
    ) {
        switch fetchedMeetingRoom.rentBy {
        case "CURRENT_USER":
            if let idx = state.bookedMeetingRoomArray.firstIndex(
                where: { $0.selectedMeetingRoom == fetchedMeetingRoom }
            ) {
                state.bookedMeetingRoomArray[idx].selectedMeetingRoom = fetchedMeetingRoom
            } else {
                state.bookedMeetingRoomArray.append(
                    MeetingRoomDomain.State(
                        id: fetchedMeetingRoom.id,
                        selectedMeetingRoom: fetchedMeetingRoom
                    )
                )
            }
            
        case "OTHERS":
            if let idx = state.unavailableMeetingRoomArray.firstIndex(
                where: { $0.selectedMeetingRoom == fetchedMeetingRoom }
            ) {
                state.unavailableMeetingRoomArray[idx].selectedMeetingRoom = fetchedMeetingRoom
            } else {
                state.unavailableMeetingRoomArray.append(
                    MeetingRoomDomain.State(
                        id: fetchedMeetingRoom.id,
                        selectedMeetingRoom: fetchedMeetingRoom
                    )
                )
            }
            
        case "AVAILABLE":
            if let idx = state.availableMeetingRoomArray.firstIndex(
                where: { $0.selectedMeetingRoom == fetchedMeetingRoom }
            ) {
                state.availableMeetingRoomArray[idx].selectedMeetingRoom = fetchedMeetingRoom
            } else {
                state.availableMeetingRoomArray.append(
                    MeetingRoomDomain.State(
                        id: fetchedMeetingRoom.id,
                        selectedMeetingRoom: fetchedMeetingRoom
                    )
                )
            }
            
        default:
            return
        }
    }
    
    
    /// Fetch된 MeetingRoom 배열이 비어있는지 확인합니다.
    /// - Parameter state: inout으로 mutate 할 현재 State
    private func checkIfMeetingRoomArrayIsEmpty(_ state: inout State) {
        if state.availableMeetingRoomArray.isEmpty { state.isAvailableMeetingRoomArrayEmpty = true }
        else { state.isAvailableMeetingRoomArrayEmpty = false }
        
        if state.unavailableMeetingRoomArray.isEmpty { state.isUnavailableMeetingRoomArrayEmpty = true }
        else { state.isUnavailableMeetingRoomArrayEmpty = false }
        
        if state.bookedMeetingRoomArray.isEmpty { state.isBookedMeetingRoomArrayEmpty = true }
        else { state.isBookedMeetingRoomArrayEmpty = false }
    }
    
    private func fetchMeetingRooms(send: Send<MeetingRoomListDomain.Action>) async throws {
        let start = Date()
        defer { Logger.methodExecTimePrint(start) }
        
        let querySnapshot = try await Constants.FIREBASE_COLLECTION.getDocuments()
        for doc in querySnapshot.documents {
            let fetchedMeetingRoom = try doc.data(as: MeetingRoom.self)
            await send(.processFetchedMeetingRoomIntoState(with: fetchedMeetingRoom))
        }
        
        await send(.meetingRoomFetchComplete, animation: .easeInOut)
    }
}

