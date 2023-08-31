//
//  AvailableMeetingRoomTest.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/08/31.
//

import XCTest
import ComposableArchitecture
@testable import TCAWorkshop

@MainActor
final class AvailableMeetingRoomTest: XCTestCase {
    let testMeetingRoom = MeetingRoom.testInstance()
    
    func testReservationButtonTapped() async throws {
        let store = TestStore(
            initialState: AvailableMeetingRoomFeature.State(
                selectedMeetingRoom: testMeetingRoom,
                id: testMeetingRoom.id
            )
        ) {
            AvailableMeetingRoomFeature()
        } withDependencies: {
            $0.meetingRoomClient = .test
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.reservationButtonTapped) {
            $0.isReservationButtonTapped = true
            $0.selectedMeetingRoom.rentBy = "CURRENT_USER"
        }
        
        await store.receive(.reservationResponse) {
            $0.isReservationButtonTapped = false
            $0.isReservationCompleted = true
        }
    }
    
    func testReservationCancelled() async throws {
        let store = TestStore(
            initialState: AvailableMeetingRoomFeature.State(
                selectedMeetingRoom: testMeetingRoom,
                id: testMeetingRoom.id
            )
        ) {
            AvailableMeetingRoomFeature()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.meetingRoomClient.update = { _ in throw ReservationError.cancelled }
        }
        
        await store.send(.reservationButtonTapped) {
            $0.isReservationButtonTapped = true
            $0.selectedMeetingRoom.rentBy = "CURRENT_USER"
        }
        
        await store.receive(.reservationFailed) {
            $0.isReservationButtonTapped = false
            $0.isReservationFailed = true
        }
    }
}

enum ReservationError: Error {
    case cancelled
}
