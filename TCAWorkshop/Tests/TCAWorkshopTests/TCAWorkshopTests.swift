//
//  TCAWorkshopTests.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/08/04.
//

import XCTest
import ComposableArchitecture
import FirebaseSharedSwift
import Firebase
@testable import TCAWorkshop

@MainActor
final class TCAWorkshopTests: XCTestCase {
    let store = TestStore(initialState: MeetingRoomFeature.State()) {
        MeetingRoomFeature()
    }

    func testFetchResponse() async throws {
        await store.send(.onMeetingRoomListViewAppear) {
            $0.isMeetingRoomFetching = true
        }
        
        await store.send(.meetingRoomFetchResponse) {
            $0.isMeetingRoomFetching = false
        }
    }
}
