//
//  TCAWorkshopTests.swift
//  TCAWorkshopTests
//
//  Created by Celan on 2023/08/04.
//

import XCTest
import ComposableArchitecture
import XCTestDynamicOverlay
@testable import TCAWorkshop

@MainActor
final class TCAWorkshopTests: XCTestCase {
    func testFetchMeetingRoomSuccessfully() async throws {
        // 1️⃣ Test를 위한 Instance를 생성
        var testInstance = MeetingRoom.testInstance()
        testInstance.rentBy = "OTHERS"
        
        // 2️⃣ Test를 위한 Store를 선언하고 dependency의 fetch가 언제나 testInstance를 리턴하도록 구현
        // 원한다면 서버 테스트도 가능하다.
        // 테스트의 편의 및 각 case 열거형에 값을 전달할 때 통일된 인스턴스를 사용하기 위해 아래처럼 구현
        let networkStore = TestStore(
            initialState: MeetingRoomListDomain.State()) {
                MeetingRoomListDomain()
            } withDependencies: { [testInstance = testInstance] dependency in
                dependency.meetingRoomClient.fetch = { return [testInstance] }
            }

        // 3️⃣ View가 보여지는 시점부터 MeetingRoom을 fetch할 때까지의 stream을 테스트하기 시작
        // action을 처음 '트리거'할 때는 `send`를 사용하며, 이 action이 되먹이는 모든 action은 `receive`로 받아온다.
        await networkStore.send(.onMeetingRoomListViewAppear) {
            $0.isMeetingRoomFetching = true
        }
        
        // 4️⃣ fetch가 되었다는 가정 하에, testInstance의 처리 이후 State가 어떻게 변하게 되는지 정의한다.
        // 이 경우, State에 예상되는 값을 할당하는 것으로 간단히 테스트를 할 수 있다.
        // 이 action이 호출되기까지 몇 초의 여유를 둘 건지 timeout에서 정해줄 수 있다.
        await networkStore.receive(
            .processFetchedMeetingRooms(with: [testInstance]),
            timeout: .seconds(1.0)
        ) {
            $0.unavailableMeetingRoomArray = [
                .init(
                    minuteHourFormatter: networkStore.dependencies.customDateFormatter.minuteHourFormatter,
                    dayFormatter: networkStore.dependencies.customDateFormatter.dayFormatter,
                    selectedMeetingRoom: testInstance,
                    id: testInstance.id
                )
            ]
        }
        
        // 5️⃣ send 된 action의 endpoint가 되는 action
        // 의도한 대로 첫 init은 true, meetingRoom의 fetch 상대는 false, 예약한 배열도 비어있지 않도록
        // State가 mutate된 것을 확인할 수 있다 ✅
        await networkStore.receive(
            .meetingRoomFetchComplete,
            timeout: .seconds(1.0)
        ) {
            $0.isMeetingRoomInitOnce = true
            $0.isMeetingRoomFetching = false
            $0.isUnavailableMeetingRoomArrayEmpty = false
        }
    }
    
    func testMeetingRoomArrays() async throws {
        let store = TestStore(initialState: MeetingRoomListDomain.State()) {
            MeetingRoomListDomain()
        }
        
        await store.send(.meetingRoomFetchComplete) {
            $0.isMeetingRoomFetching = false
            $0.isMeetingRoomFetchFailed = false
            $0.isMeetingRoomInitOnce = true
        }
    }
    
    func testTakeLongLongTimeTask() async throws {
        let store = TestStore(initialState: MeetingRoomListDomain.State()) {
            MeetingRoomListDomain()
        } withDependencies: {
            $0.continuousClock = ContinuousClock()
        }
        
        await store.send(.takeLongLongTimeTaskButtonTapped)
        await store.receive(.takeLongLongTimeTaskResponse("COMPLETE"), timeout: .seconds(120.0)) {
            $0.takeLongLongTimeTaskResult = "COMPLETE"
        }
    }
    
    func testTakeLongLongTimeTaskInShort() async throws {
        let store = TestStore(initialState: MeetingRoomListDomain.State()) {
            MeetingRoomListDomain()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.takeLongLongTimeTaskButtonTapped)
        await store.receive(.takeLongLongTimeTaskResponse("COMPLETE"), timeout: .seconds(1.0)) {
            $0.takeLongLongTimeTaskResult = "COMPLETE"
        }
    }
}
