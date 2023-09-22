//
//  BookedMeetingRoomTest.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/08/29.
//

import XCTest
import ComposableArchitecture
import XCTestDynamicOverlay
@testable import TCAWorkshop

@MainActor
final class BookedMeetingRoomTest: XCTestCase {
    let testInstance = MeetingRoom.testInstance()
    
    func testOnBookedMeetingRoomCancelButtonTapped() async throws {
        let store = TestStore(
            initialState: BookedMeetingRoomFeature.State(
                selectedMeetingRoom: testInstance,
                id: testInstance.id
            )) {
                BookedMeetingRoomFeature()
            } withDependencies: {
                $0.continuousClock = ImmediateClock()
            }
        
        await store.send(.cancelReservationButtonTapped) {
            $0.isCancelReservationButtonTapped = true
            $0.selectedMeetingRoom.rentBy = "AVAILABLE"
        }
        
        await store.receive(.cancelReservationResponse) {
            $0.isCancelReservationButtonTapped = false
            $0.isCancelReservationCompleted = true
        }
    }
    
    /// Task가 정상적으로 취소되는지 확인하는 테스트 코드
    func testOnBookedMeetingRoomCancelButtonTappedFailed() async throws {
        let store = TestStore(
            initialState: BookedMeetingRoomFeature.State(
                selectedMeetingRoom: testInstance,
                id: testInstance.id
            )) {
                BookedMeetingRoomFeature()
            } withDependencies: {
                $0.continuousClock = ContinuousClock()
                // 만약 테스트가 실패한다면!
                $0.meetingRoomClient.update = { _ in throw CancelError.cancelled }
            }
        
        await store.send(.cancelReservationButtonTapped) {
            try Task.checkCancellation()
            $0.isCancelReservationButtonTapped = true
            $0.selectedMeetingRoom.rentBy = "AVAILABLE"
        }
        
        await store.receive(.cancelReservationCancelled, timeout: .seconds(1.0)) {
            $0.isCancelReservationCancelled = true
            $0.isCancelReservationButtonTapped = false
        }
    }
    
    func testMeetingCardRoomAppear() async throws {
//        let now = Date.now
        let testMeetingRoomInstance = MeetingRoom.testInstance()
        let testMeetingInfoInstance = MeetingInfo.testInstance()
//        testMeetingInfoInstance.date = now
        
        let store = TestStore(
            initialState: BookedMeetingRoomFeature.State(
                selectedMeetingRoom: testMeetingRoomInstance,
                id: testMeetingRoomInstance.id
            )) {
                BookedMeetingRoomFeature()
            } withDependencies: {
                $0.date.now = .now
            }
        
        await store.send(.browseMeetingInfoButtonTapped) {
            $0.meetingRoomInfo = .init(
                id: .init(0),
                meetingInfo: testMeetingInfoInstance
            )
        }
    }
}

enum CancelError: Error {
    case cancelled
}
