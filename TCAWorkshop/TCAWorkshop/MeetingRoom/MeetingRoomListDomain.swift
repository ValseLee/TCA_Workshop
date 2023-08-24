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
    @Dependency(\.meetingRoomClient)
    var firebaseClient: MeetingRoomClient
    
    struct State: Equatable {
        var availableMeetingRoomArray: IdentifiedArrayOf<AvailableMeetingRoomFeature.State> = []
        var unavailableMeetingRoomArray: IdentifiedArrayOf<UnavabilableMeetingRoomFeature.State> = []
        var bookedMeetingRoomArray: IdentifiedArrayOf<BookedMeetingRoomFeature.State> = []
        
        var isMeetingRoomInitOnce: Bool = false
        var isMeetingRoomFetching: Bool = false
        var isMeetingRoomFetchFailed: Bool = false
        var isFetchAvailable: Bool = true
        
        var hasMeetingRoomChanged: Bool = false
        
        var isAvailableMeetingRoomArrayEmpty: Bool = true
        var isUnavailableMeetingRoomArrayEmpty: Bool = true
        var isBookedMeetingRoomArrayEmpty: Bool = true
    }
    
    @frozen enum Action: Equatable {
        case bookedMeetingRoom(
            id: BookedMeetingRoomFeature.State.ID,
            action: BookedMeetingRoomFeature.Action
        )
        
        case availableMeetingRoom(
            id: AvailableMeetingRoomFeature.State.ID,
            action: AvailableMeetingRoomFeature.Action
        )
        
        case unavailableMeetingRoom(
            id: UnavabilableMeetingRoomFeature.State.ID,
            action: UnavabilableMeetingRoomFeature.Action
        )
                
        case onMeetingRoomListViewAppear
        case processFetchedMeetingRooms(with: [MeetingRoom])
        
        case meetingRoomFetchComplete
        case meetingRoomFetchFailed
        case fetchUnavailableResponse
        
        case listRefreshed
        case confirmationDialogRetryButtonTapped
        case confirmationDialogDismissed(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                // MARK: - .forEach
            case let .bookedMeetingRoom(_, action):
                /// + Child의 액션보다 Parent가 받는 액션이 먼저 수행된다.
                if case .cancelReservationResponse = action {
                    state.hasMeetingRoomChanged = true
                }
                
                return .none
                
            case let .availableMeetingRoom(_, action):
                if case .reservationResponse = action {
                    state.hasMeetingRoomChanged = true
                }
                
                return .none
                
            case .unavailableMeetingRoom:
                return .none
                    
                // MARK: - Render
            case .onMeetingRoomListViewAppear:
                checkIfMeetingRoomArrayIsEmpty(&state)
                
                guard state.isMeetingRoomInitOnce else {
                    state.isMeetingRoomFetching = true
                    return .run { send in
                        let start = Date()
                        defer { Logger.methodExecTimePrint(start) }
                        
                        let fetchedMeetingRooms = try await firebaseClient.fetch()
                        await send(
                            .processFetchedMeetingRooms(with: fetchedMeetingRooms),
                            animation: .easeInOut
                        )
                    } catch: { error, send in
                        print("FETCH FAILED: ", error)
                        await send(.meetingRoomFetchFailed, animation: .easeInOut)
                    }
                }
                
                if state.hasMeetingRoomChanged {
                    state.isMeetingRoomFetching = true
                    state.availableMeetingRoomArray.removeAll()
                    state.bookedMeetingRoomArray.removeAll()
                    state.unavailableMeetingRoomArray.removeAll()
                    
                    return .run { send in
                        let fetchedMeetingRooms = try await firebaseClient.fetch()
                        await send(
                            .processFetchedMeetingRooms(with: fetchedMeetingRooms),
                            animation: .easeInOut
                        )
                    } catch: { error, send in
                        print("UPDATE FETCH FAILED: ", error)
                        await send(.meetingRoomFetchFailed, animation: .easeInOut)
                    }
                }
                
                return .none
                
            case .listRefreshed:
                state.isMeetingRoomFetching = true
                return .run { send in
                    let fetchedMeetingRooms = try await self.firebaseClient.fetch()
                    await send(
                        .processFetchedMeetingRooms(with: fetchedMeetingRooms),
                        animation: .easeInOut
                    )
                } catch: { error, send in
                    print("REFRESH FAILED: ", error)
                    await send(.meetingRoomFetchFailed, animation: .easeInOut)
                }
                                
            case let .processFetchedMeetingRooms(fetchedMeetingRooms):
                self.makeMeetingRoom(&state, with: fetchedMeetingRooms)
                return .send(.meetingRoomFetchComplete, animation: .easeInOut)
                
            case .meetingRoomFetchComplete:
                state.isMeetingRoomInitOnce = true
                state.isMeetingRoomFetching = false
                state.isMeetingRoomFetchFailed = false
                state.hasMeetingRoomChanged = false
                checkIfMeetingRoomArrayIsEmpty(&state)
                
                return .none
                
            case .meetingRoomFetchFailed:
                state.isMeetingRoomFetching = false
                state.isMeetingRoomFetchFailed = true
                
                return .none
                
            case .confirmationDialogRetryButtonTapped:
                state.isMeetingRoomFetching = true
                state.isMeetingRoomFetchFailed = false
                
                return .run { send in
                    let fetchedMeetingRooms = try await self.firebaseClient.fetch()
                    try await Task.sleep(for: .seconds(0.5))
                    await send(.meetingRoomFetchComplete, animation: .easeInOut)
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
            BookedMeetingRoomFeature()
        }
        .forEach(
            \.unavailableMeetingRoomArray,
             action: /Action.unavailableMeetingRoom(id:action:)
        ) {
            UnavabilableMeetingRoomFeature()
        }
        .forEach(
            \.availableMeetingRoomArray,
             action: /Action.availableMeetingRoom(id:action:)
        ) {
            AvailableMeetingRoomFeature()
        }
    }
    
    // MARK: - METHODS
    private func makeMeetingRoom(
        _ state: inout State,
        with fetchedMeetingRooms: [MeetingRoom]
    ) {
        fetchedMeetingRooms.forEach { fetchedMeetingRoom in
            switch fetchedMeetingRoom.rentBy {
            case "CURRENT_USER":
                if let idx = state.bookedMeetingRoomArray.firstIndex(
                    where: { $0.selectedMeetingRoom == fetchedMeetingRoom }
                ) {
                    state.bookedMeetingRoomArray[idx].selectedMeetingRoom = fetchedMeetingRoom
                } else {
                    state.bookedMeetingRoomArray.append(
                        BookedMeetingRoomFeature.State(
                            selectedMeetingRoom: fetchedMeetingRoom,
                            id: fetchedMeetingRoom.id
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
                        UnavabilableMeetingRoomFeature.State(
                            selectedMeetingRoom: fetchedMeetingRoom,
                            id: fetchedMeetingRoom.id
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
                        AvailableMeetingRoomFeature.State(
                            selectedMeetingRoom: fetchedMeetingRoom,
                            id: fetchedMeetingRoom.id
                        )
                    )
                }
                
            default:
                return
            }
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
}

