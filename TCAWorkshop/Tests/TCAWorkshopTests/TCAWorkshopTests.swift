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
    let store = TestStore(initialState: MeetingRoomListDomain.State()) {
        MeetingRoomListDomain()
    } withDependencies: {
        $0.uuid = .incrementing
        $0.date = .constant(Date())
    }

    func testFetchResponseForLastDoc() async throws {
        await store.send(.onMeetingRoomListViewAppear) {
            $0.isMeetingRoomFetching = true
        }
        
        let querySnapshot = try await Constants.FIREBASE_COLLECTION.getDocuments()
        if let lastDoc = querySnapshot.documents.last {
            let fetchedMeetingRoom = try lastDoc.data(as: MeetingRoom.self)
            let meetingRoomDomainState = MeetingRoomDomain.State(
                rentDate: self.store.dependencies.date.now,
                id: fetchedMeetingRoom.id,
                selectedMeetingRoom: fetchedMeetingRoom
            )
            
            await store.send(.processFetchedMeetingRoomIntoState(with: fetchedMeetingRoom)) {
                switch fetchedMeetingRoom.rentBy {
                case "CURRENT_USER":
                    $0.bookedMeetingRoomArray = [meetingRoomDomainState]
                case "AVAILABLE":
                    $0.availableMeetingRoomArray = [meetingRoomDomainState]
                case "OTHERS":
                    $0.unavailableMeetingRoomArray = [meetingRoomDomainState]
                default:
                    fatalError("meetingRoomDomainState?")
                }
            }
        }
    }
    
    func testMeetingRoomArrays() async throws {
        await store.send(.meetingRoomFetchComplete) {
            $0.isMeetingRoomFetching = false
            $0.isMeetingRoomFetchFailed = false
            $0.isMeetingRoomInitOnce = true
        }
    }
}
