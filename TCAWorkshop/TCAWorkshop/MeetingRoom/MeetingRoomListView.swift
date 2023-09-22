//
//  RootView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/04.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<MeetingRoomListDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            if viewStore.state.isFetchAvailable {
                List {
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
                .onAppear {
                    viewStore.send(.onMeetingRoomListViewAppear)
                }
                .navigationTitle("회의쓱싹")
                .refreshable {
                    await viewStore.send(.listRefreshed).finish()
                }
                .confirmationDialog(
                    "",
                    isPresented: viewStore.binding(
                        get: { $0.isMeetingRoomFetchFailed },
                        send: { .confirmationDialogDismissed($0) }
                    )
                ) {
                    Button {
                        viewStore.send(.confirmationDialogRetryButtonTapped)
                    } label: {
                        Text("재시도")
                    }
                } message: {
                    Text("미팅룸을 불러오는 데에 실패했습니다.\n재시도 하시겠습니까?")
                }
            } else if !viewStore.state.isFetchAvailable {
                Text("회의실을 가져올 수 없습니다.\n앱을 재시동한 후, 네트워크 환경을 확인해 주세요 :)")
                    .multilineTextAlignment(.center)
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
            switch condition {
            case .available:
                if state.isAvailableMeetingRoomArrayEmpty {
                    Text("예약할 수 있는 회의실이 없어요!")
                        .redacted(
                            reason: state.isMeetingRoomFetching
                            ? .placeholder
                            : []
                        )
                } else {
                    ForEachStore(
                        self.store.scope(
                            state: { $0.availableMeetingRoomArray },
                            action: MeetingRoomListDomain.Action.availableMeetingRoom(id:action:)
                        )
                    ) { store in
                        NavigationLink {
                            AvailableMeetingRoomView(store: store)
                        } label: {
                            WithViewStore(
                                store,
                                observe: { $0.selectedMeetingRoom }
                            ) { selectedMeetingRoom in
                                Text(selectedMeetingRoom.rentBy)
                            }
                        }
                    }
                }
                
            case .unavailable:
                if state.isUnavailableMeetingRoomArrayEmpty {
                    Text("다른 사람들이 예약한 회의실이 없어요!")
                        .redacted(
                            reason: state.isMeetingRoomFetching
                            ? .placeholder
                            : []
                        )
                } else {
                    ForEachStore(
                        self.store.scope(
                            state: { $0.unavailableMeetingRoomArray },
                            action: MeetingRoomListDomain.Action.unavailableMeetingRoom(id:action:)
                        )
                    ) { store in
                        NavigationLink {
                            UnavailableMeetingRoomView(store: store)
                        } label: {
                            WithViewStore(
                                store,
                                observe: { $0.selectedMeetingRoom }
                            ) { selectedMeetingRoom in
                                Text(selectedMeetingRoom.rentBy)
                            }
                        }
                    }
                }
                
            case .booked:
                if state.isBookedMeetingRoomArrayEmpty {
                    Text("내가 예약한 회의실이 없어요!")
                        .redacted(
                            reason: state.isMeetingRoomFetching
                            ? .placeholder
                            : []
                        )
                } else {
                    ForEachStore(
                        self.store.scope(
                            state: { $0.bookedMeetingRoomArray },
                            action: MeetingRoomListDomain.Action.bookedMeetingRoom(id:action:)
                        )
                    ) { store in
                        NavigationLink {
                            BookedMeetingRoomView(store: store)
                        } label: {
                            WithViewStore(
                                store,
                                observe: { $0.selectedMeetingRoom }
                            ) { selectedMeetingRoom in
                                Text(selectedMeetingRoom.rentBy)
                            }
                        }
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
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootView(
                store: Store(
                    initialState: MeetingRoomListDomain.State()
                ) {
                    // PREVIEW는 Test용으로 client를 초기화합니다.
                    MeetingRoomListDomain()
                        .dependency(\.meetingRoomClient, .test)
                }
            )
        }
    }
}
