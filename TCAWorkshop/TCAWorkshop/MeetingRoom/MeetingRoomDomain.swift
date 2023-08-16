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
import SwiftUI

struct MeetingRoomDomain: Reducer {
    @frozen enum MeetingRoomStatus {
        case reservation
        case cancelation
    }
    
    struct State: Equatable, Identifiable {
        @BindingState var rentDate: Date = .now
        @BindingState var rentHourAndMinute: Int = 1
        
        var id: UUID
        var selectedMeetingRoom: MeetingRoom
        
        var isReservationButtonTapped: Bool = false
        var isReservationCompleted: Bool = false
        var isCancelReservationButtonTapped: Bool = false
        var isCancelReservationCompleted: Bool = false
    }
    
    @frozen enum Action: Equatable, BindableAction {
        // Binding을 직접 구현하기 싫다면 BindingAction, BindableAction을 활용할 수 있다.
        // 이후에 viewStore.$_ 로 접근할 수 있다.
        case binding(BindingAction<State>)
        case reservationButtonTapped
        case reservationResponse
        
        case cancelReservationButtonTapped
        case cancelReservationResponse
        
        case rentDatePicked(Date)
        case rentHourAndMinutePicked(Int)
        case onMeetingRoomViewAppear
    }
    
    var body: some ReducerOf<MeetingRoomDomain> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onMeetingRoomViewAppear:
                state.rentDate = state.selectedMeetingRoom.rentDate
                state.rentHourAndMinute = state.selectedMeetingRoom.rentHourAndMinute
                
                state.isReservationButtonTapped = false
                state.isReservationCompleted = false
                state.isCancelReservationButtonTapped = false
                state.isCancelReservationCompleted = false
                
                return .none
            
                // MARK: - RESERVATION
            case .reservationButtonTapped:
                state.isReservationButtonTapped = true
                state.selectedMeetingRoom.rentDate = state.rentDate
                state.selectedMeetingRoom.rentHourAndMinute = state.rentHourAndMinute
                
                return .run { [meetingRoom = state.selectedMeetingRoom] send in
                    try await Task.sleep(for: .seconds(0.5))
                    try await updateMeetingRooms(by: meetingRoom, with: .reservation)
                    await send(.reservationResponse, animation: .easeInOut)
                } catch: { error, send in
                    print("RESERVATION FAILED")
                    await send(.reservationResponse, animation: .easeInOut)
                }
                
            case .reservationResponse:
                state.isReservationButtonTapped = false
                state.isReservationCompleted = true
                Task { try await Task.sleep(for: .seconds(0.5)) }
                state.selectedMeetingRoom.rentBy = "CURRENT_USER"
                return .none
            
                // MARK: - CANCELATION
            case .cancelReservationButtonTapped:
                state.isCancelReservationButtonTapped = true
                
                return .run { [meetingRoom = state.selectedMeetingRoom] send in
                    try await Task.sleep(for: .seconds(0.5))
                    try await updateMeetingRooms(by: meetingRoom, with: .cancelation)
                    await send(.cancelReservationResponse, animation: .easeInOut)
                } catch: { error, send in
                    print("CANCEL FAILED")
                    await send(.cancelReservationResponse, animation: .easeInOut)
                }
                
            case .cancelReservationResponse:
                state.isCancelReservationButtonTapped = false
                state.isCancelReservationCompleted = true
                Task { try await Task.sleep(for: .seconds(0.5)) }
                state.selectedMeetingRoom.rentBy = "AVAILABLE"
                return .none
                
                // MARK: - VIEW BINDING
            case let .rentDatePicked(date):
                state.rentDate = date
                return .none
                
            case let .rentHourAndMinutePicked(time):    
                state.rentHourAndMinute = time
                return .none
                
            default:
                fatalError()
            }
        }
    }
    
    // MARK: - Methods
    private func updateMeetingRooms(
        by meetingRoom: MeetingRoom,
        with condition: MeetingRoomStatus
    ) async throws {
        let start = Date()
        defer { Logger.methodExecTimePrint(start) }
        
        try await Constants.FIREBASE_COLLECTION
            .document(meetingRoom.id.uuidString)
            .setData(
                [
                    "rentDate": Timestamp(date: meetingRoom.rentDate),
                    "rentBy": condition == .reservation ? "CURRENT_USER" : "AVAILABLE",
                    "rentHourAndMinute": meetingRoom.rentHourAndMinute,
                ],
                merge: true
            )
    }
}
