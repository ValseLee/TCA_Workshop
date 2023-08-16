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
    struct State: Equatable, Identifiable {
        @BindingState var rentLearnerName: String = ""
        @BindingState var rentDate: Date = .now
        
        var id: UUID
        var selectedMeetingRoom: MeetingRoom
        var isReservationButtonTapped: Bool = false
        var isReservationCompleted: Bool = false
        
        var isCancelReservationButtonTapped: Bool = false
        var isCancelReservationCompleted: Bool = false
        
        var rentHourAndMinute: Int = 1
    }
    
    @frozen enum Action: Equatable, BindableAction {
        // Binding을 직접 구현하기 싫다면 BindingAction, BindableAction을 활용할 수 있다.
        // 이후에 viewStore.$_ 로 접근할 수 있다.
        case binding(BindingAction<State>)
        case reservationButtonTapped
        // !!!: TaskResult는 리턴 타입이 있는 Side Effect에 적합함
        // 수정 필요
        case reservationResponse(TaskResult<MeetingRoom>)
        case rentDatePicked(Date)
        case rentHourAndMinutePicked(Int)
        
        case cancelReservationButtonTapped
        case cancelReservationResponse
    }
    
    var body: some ReducerOf<MeetingRoomDomain> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .reservationButtonTapped:
                state.isReservationButtonTapped = true
                state.selectedMeetingRoom.rentDate = state.rentDate
                state.selectedMeetingRoom.rentBy = state.rentLearnerName
                
                return .run { [meetingRoom = state.selectedMeetingRoom] send in
                    try await updateMeetingRooms(by: meetingRoom)
                    await send(.reservationResponse(.success(meetingRoom)), animation: .easeInOut)
                } catch: { error, send in
                    await send(
                        .reservationResponse(.failure(error)),
                        animation: .easeInOut
                    )
                }
                
            case let .reservationResponse(.success(meetingRoom)):
                state.isReservationButtonTapped = false
                state.isReservationCompleted = true
                print("RESERVATION SUCCESS at", meetingRoom.rentDate)
                return .none
                
            case let .reservationResponse(.failure(error)):
                state.isReservationButtonTapped = false
                print("RESERVATION FAILED", error.localizedDescription)
                return .none
            
                
            case .cancelReservationButtonTapped:
                state.isCancelReservationButtonTapped = true
                state.selectedMeetingRoom.rentBy = "AVAILABLE"
                
                return .run { [meetingRoom = state.selectedMeetingRoom] send in
                    try await updateMeetingRooms(by: meetingRoom)
                    await send(.cancelReservationResponse, animation: .easeInOut)
                } catch: { error, send in
                    await send(
                        .reservationResponse(.failure(error)),
                        animation: .easeInOut
                    )
                }
                
            case .cancelReservationResponse:
                state.isCancelReservationButtonTapped = false
                state.isCancelReservationCompleted = true
                return .none
                
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
        by meetingRoom: MeetingRoom
    ) async throws {
        let start = Date()
        defer { Logger.methodExecTimePrint(start) }
        
        try await Constants.FIREBASE_COLLECTION
            .document(meetingRoom.id.uuidString)
            .setData(
                [
                    "rentDate": Timestamp(date: meetingRoom.rentDate),
                    "rentBy": meetingRoom.rentBy,
                    "rentHourAndMinute": meetingRoom.rentHourAndMinute,
                ],
                merge: true
            )
        
        try await Task.sleep(for: .seconds(0.5))
    }
}
