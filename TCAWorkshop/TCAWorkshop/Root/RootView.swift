//
//  RootView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/04.
//

import SwiftUI
import ComposableArchitecture
import FirebaseFirestore

struct RootView: View {
    let store: StoreOf<MeetingRoomListDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            if viewStore.state.isFetchAvailable {
                List {
                    if viewStore.state.isMeetingRoomFetching {
                        ProgressView()
                    } else {
                        ForEach(
                            Constants.MeetingRoomCondition.allCases,
                            id: \.hashValue
                        ) { cases in
                            meetingRoomSectionBuilder(
                                with: cases,
                                by: viewStore.state
                            )
                        }
                    }
                }
                .onAppear {
                    viewStore.send(.onMeetingRoomListViewAppear)
                }
                .navigationTitle("회의쓱싹")
                .refreshable {
                    viewStore.send(.listRefreshed)
                }
                .confirmationDialog(
                    "",
                    isPresented: viewStore.binding(
                        get: { $0.isMeetingRoomFetchFailed },
                        send: .confirmationDialogDismissed
                    )
                ) {
                    Button {
                        viewStore.send(.confirmationDialogRetryButtonTapped)
                    } label: {
                        Text("재시도")
                            .bold()
                    }
                } message: {
                    Text("미팅룸 로딩에 실패했습니다.\n재시도 하시겠습니까?")
                }
            } else {
                Text("회의실을 가져올 수 없습니다.\n앱을 재시동한 후, 네트워크 환경을 확인해 주세요 :)")
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
            }
        }
    }
    
    // MARK: - Methods
    /// 리스트의 각 섹션을 만들어주는 빌더
    /// - Parameter type: 어떤 타입의 미팅룸을 만들고 싶은지 전달
    /// - Returns: 해당 미팅룸의 타입에 따라 뷰 리턴
    private func meetingRoomSectionBuilder(
        with condition: Constants.MeetingRoomCondition,
        by state: MeetingRoomListDomain.State
    ) -> some View {
        Section {
            if isEachMeetingRoomArrayEmpty(
                in: condition, state
            ) {
                switch condition {
                case .available:
                    Text("예약할 수 있는 회의실이 없어요!")
                    
                case .unavailable:
                    Text("다른 사람들이 예약한 회의실이 없어요!")
                    
                case .booked:
                    Text("내가 예약한 회의실이 없어요!")
                }
            }
            
            ForEachStore(
                self.store.scope(
                    state: { getEachState(by: condition, $0) },
                    action: getEachAction(by: condition)
                )
            ) { store in
                NavigationLink {
                    MeetingRoomView(store: store)
                } label: {
                    WithViewStore(
                        store,
                        observe: { $0.selectedMeetingRoom }
                    ) { selectedMeetingRoom in
                        Text(selectedMeetingRoom.rentBy)
                    }
                }
            }
        } header: {
            switch condition {
            case .available:
                Text("예약할 수 있는 회의실")
            case .unavailable:
                Text("다른 사람들이 예약한 회의실")
            case .booked:
                Text("내가 예약한 회의실")
            }
        }
    }
    
    private func getEachState(
        by condition: Constants.MeetingRoomCondition,
        _ state: MeetingRoomListDomain.State
    ) -> IdentifiedArrayOf<MeetingRoomDomain.State> {
        switch condition {
        case .available:
            return state.availableMeetingRoomArray
        case .unavailable:
            return state.unavailableMeetingRoomArray
        case .booked:
            return state.bookedMeetingRoomArray
        }
    }
    
    private func getEachAction(
        by condition: Constants.MeetingRoomCondition
    ) -> (MeetingRoomDomain.State.ID, MeetingRoomDomain.Action) -> MeetingRoomListDomain.Action {
        switch condition {
        case .available:
            return MeetingRoomListDomain.Action
                .availableMeetingRoom(id:action:)
        case .unavailable:
            return MeetingRoomListDomain.Action
                .unavailableMeetingRoom(id:action:)
        case .booked:
            return MeetingRoomListDomain.Action
                .bookedMeetingRoom(id:action:)
        }
    }

    private func isEachMeetingRoomArrayEmpty(
        in condition: Constants.MeetingRoomCondition,
        _ state: MeetingRoomListDomain.State
    ) -> Bool {
        switch condition {
        case .available:
            return state.availableMeetingRoomArray.isEmpty
        case .unavailable:
            return state.unavailableMeetingRoomArray.isEmpty
        case .booked:
            return state.bookedMeetingRoomArray.isEmpty
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootView(
                store: Store(initialState: MeetingRoomListDomain.State()) {
                    MeetingRoomListDomain()
                }
            )
        }
    }
}
