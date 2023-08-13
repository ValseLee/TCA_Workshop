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
        var rentHourAndMinute: Int = 1
    }
    
    @frozen enum Action: Equatable {
        case reservationButtonTapped
        // !!!: TaskResult는 리턴 타입이 있는 Side Effect에 적합함
        // 수정 필요
        case reservationResponse(TaskResult<MeetingRoom>)
        case rentDatePicked(Date)
        case rentHourAndMinutePicked(Int)
    }
    
    var body: some ReducerOf<MeetingRoomDomain> {
        Reduce { state, action in
            switch action {
            case .reservationButtonTapped:
                state.isReservationButtonTapped = true
                state.selectedMeetingRoom.rentBy = state.rentLearnerName
                state.selectedMeetingRoom.rentDate = state.rentDate
                
                return .run { [meetingRoom = state.selectedMeetingRoom] send in
                    try await Constants.FIREBASE_COLLECTION
                        .document(meetingRoom.id.uuidString)
                        .setData([
                            "id": meetingRoom.id.uuidString,
                            "rentDate": Timestamp(date: meetingRoom.rentDate),
                            "rentBy": meetingRoom.rentBy,
                            "meetingRoomName": meetingRoom.meetingRoomName
                        ])
                    
                    try await Task.sleep(for: .seconds(0.5))
                    await send(
                        .reservationResponse(.success(meetingRoom)),
                        animation: .easeInOut
                    )
                    
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
}
