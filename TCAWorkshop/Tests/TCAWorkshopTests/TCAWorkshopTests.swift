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
            initialState: MeetingRoomListDomain.State()
        ) {
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
    
    func testMeetingRoomListOnAppearWithChildUpdate() async throws {
        // 조금 더 복잡한 테스트를 구성해보자.
        // 상황: 유저가 meetingRoomList를 init한 이후, child에서 meetingRoom을 취소했을 때
        
        // 1️⃣ Test를 위한 Instance를 생성
        var testInstance = MeetingRoom.testInstance()
        testInstance.rentBy = "CURRENT_USER"
        
        // 2️⃣ Test를 위한 Store를 선언
        let networkStore = TestStore(
            initialState: MeetingRoomListDomain.State(
                // 🧩 이미 예약된 배열이 있는 상황을 가정하기 때문에, bookedMeetingRoomArray에 더미 데이터를 심어준다.
                bookedMeetingRoomArray: [
                    .init(
                        selectedMeetingRoom: testInstance,
                        id: testInstance.id
                    )
                ],
                isMeetingRoomInitOnce: true,
                hasMeetingRoomChanged: true
            )
        ) {
            MeetingRoomListDomain()
        } withDependencies: { dependency in
            dependency.continuousClock = ImmediateClock()
        }
        
        // 🧩 Child 에서 CURRENT_USER의 예약을 취소했기 때문에 testInstance의 rentBy를 AVAILABLE로 수정
        // 동일한 instance가 서버에서 fetch되리라는 가정 하에 테스트 진행
        testInstance.rentBy = "AVAILABLE"
        networkStore.dependencies.meetingRoomClient.fetch = { [testInstance = testInstance] in return [testInstance] }
        
        await networkStore.send(.onMeetingRoomListViewAppear) {
            $0.isBookedMeetingRoomArrayEmpty = false
            $0.isMeetingRoomFetching = true
            // onAppear로 인해 bookedMeetingRoom은 비워져야 한다.
            $0.bookedMeetingRoomArray = []
        }
        
        // 4️⃣ fetch가 되었다는 가정 하에, testInstance가 availableMeetingRoomArray에 append 되는지 확인
        await networkStore.receive(.processFetchedMeetingRooms(with: [testInstance])) {
            $0.availableMeetingRoomArray = [
                .init(
                    selectedMeetingRoom: testInstance,
                    id: testInstance.id
                )
            ]
        }
        
        // 🧩 상단의 이벤트가 `.meetingRoomFetchComplete` 이벤트를 호출해야 하지만
        // 관련 이벤트는 현재 '실패'하지 않기 때문에 Receive 이벤트에 대한 테스트는 불필요하다고 판단한다면
        // Queue에 담겨있는 '모든' Receive 이벤트를 스킵할 수 있다.
        // 이 경우, 예상되는 Expected Failure로 남은 경고를 확인할 수 있다.
        await networkStore.skipReceivedActions(strict: true)
        
        // 🧩 Receive 이벤트 테스트를 스킵했기 때문에 아래의 테스트 코드는 작성하지 않아야 한다.
//        await networkStore.receive(.meetingRoomFetchComplete) {
//            $0.isMeetingRoomInitOnce = true
//            $0.isMeetingRoomFetching = false
//            $0.isAvailableMeetingRoomArrayEmpty = false
//            $0.isBookedMeetingRoomArrayEmpty = true
//            $0.hasMeetingRoomChanged = false
//        }
    }
    
    func testCancelMeetingRoom() async throws {
        // 1️⃣ Test를 위한 Instance를 생성
        var testInstance = MeetingRoom.testInstance()
        // 2️⃣ 이 미팅룸은 현재 유저에 의해 rent 된 상황
        testInstance.rentBy = "CURRENT_USER"
        
        let networkStore = TestStore(
            initialState: BookedMeetingRoomFeature.State(
                selectedMeetingRoom: testInstance,
                id: testInstance.id
            )
        ) {
            BookedMeetingRoomFeature()
        } withDependencies: { dependency in
            dependency.continuousClock = ImmediateClock()
        }
        
        await networkStore.send(.cancelReservationButtonTapped) {
            $0.isCancelReservationButtonTapped = true
            $0.selectedMeetingRoom.rentBy = "AVAILABLE"
        }
        
        // 3️⃣ update에 성공했다면, Response 를 받고 각 State를 변형한다.
        await networkStore.receive(.cancelReservationResponse) {
            $0.isCancelReservationButtonTapped = false
            $0.isCancelReservationCompleted = true
        }
    }
    
    func testCancelMeetingRoom_Failed() async throws {
        // 1️⃣ Test를 위한 Instance를 생성
        var testInstance = MeetingRoom.testInstance()
        // 2️⃣ 이 미팅룸은 현재 유저에 의해 rent 된 상황
        testInstance.rentBy = "CURRENT_USER"
        
        let networkStore = TestStore(
            initialState: BookedMeetingRoomFeature.State(
                selectedMeetingRoom: testInstance,
                id: testInstance.id
            )
        ) {
            BookedMeetingRoomFeature()
        } withDependencies: { dependency in
            // 3️⃣ update에 실패한 상황을 테스트하기 위해, dependency의 로직을 재할당한다.
            dependency.meetingRoomClient.update = { meetingRoom in throw MeetingRoomClientError.postError }
            dependency.continuousClock = ImmediateClock()
        }
        
        await networkStore.send(.cancelReservationButtonTapped) {
            $0.isCancelReservationButtonTapped = true
            $0.selectedMeetingRoom.rentBy = "AVAILABLE"
        }
        
        await networkStore.receive(.cancelReservationCancelled) {
            $0.isCancelReservationButtonTapped = false
            $0.isCancelReservationCancelled = true
        }
    }
    
    func testBookMeetingRoom() async throws {
        // 1️⃣ Test를 위한 Instance를 생성
        var testInstance = MeetingRoom.testInstance()
        // 2️⃣ 이 미팅룸은 현재 유저에 의해 rent 된 상황
        testInstance.rentBy = "AVAILABLE"
        
        let networkStore = TestStore(
            initialState: AvailableMeetingRoomFeature.State(
                selectedMeetingRoom: testInstance,
                id: testInstance.id
            )
        ) {
            AvailableMeetingRoomFeature()
        } withDependencies: { dependency in
            dependency.continuousClock = ImmediateClock()
        }
        
        // 3️⃣ 모든 이벤트를 테스트하지 않도록 exhaustivity 속성을 .off 할 수 있다.
        // 상단의 다른 테스트처럼 store가 플로우대로 변형하는 이벤트를 무시할 수 있다.
        // 즉, 개발자가 원하는 State에 대한 변형만 assert 할 수 있다.
        // showSkippedAssertions에 전달하는 불 값에 따라 무시된 State 변형을 출력하여 확인할 수 있다.
        networkStore.exhaustivity = .off(showSkippedAssertions: false)
        
        await networkStore.send(.reservationButtonTapped)
        // 4️⃣ 원래대로라면 해당 이벤트에서 2개의 State가 변형되어야 한다.
        // exhaustivity test를 진행했다면 각 state의 변형도 테스트해야 하지만
        // 해당 속성을 꺼두었기 때문에 State 변형이 무시된다.
        await networkStore.receive(.reservationResponse) {
            $0.isReservationCompleted = true
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
            $0.continuousClock = ImmediateClock()
            
            // 🧩 위 코드를 각주하고, 아래 각주를 해제한 뒤 테스트를 돌리면
            // 테스트가 120초 소요되고, QUARANTINED DUE TO HIGH LOGGING VOLUME 메시지를 볼 수 있다.
            // $0.continuousClock = ContinuousClock()
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
        await store.receive(.takeLongLongTimeTaskResponse("COMPLETE")) {
            $0.takeLongLongTimeTaskResult = "COMPLETE"
        }
    }
}
