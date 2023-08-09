//
//  ContentView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/04.
//

import SwiftUI
import ComposableArchitecture
import FirebaseFirestore

struct ContentView: View {
    let store: StoreOf<MeetingRoomFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                if viewStore.state.isMeetingRoomFetching {
                    ProgressView()
                } else {
                    ForEach(
                        Constants.MeetingRoomCondition.allCases,
                        id: \.hashValue
                    ) { cases in
                        meetingRoomSectionBuilder(
                            type: cases,
                            viewStore: viewStore
                        )
                    }
                }
            }
            .onAppear {
                viewStore.send(.onMeetingRoomListViewAppear)
            }
        }
    }
    
    // MARK: - Methods
    /// 리스트의 각 섹션을 만들어주는 빌더
    /// - Parameter type: 어떤 타입의 미팅룸을 만들고 싶은지 전달
    /// - Returns: 해당 미팅룸의 타입에 따라 뷰 리턴
    private func meetingRoomSectionBuilder(
        type: Constants.MeetingRoomCondition,
        viewStore: ViewStoreOf<MeetingRoomFeature>
    ) -> some View {
        Section {
            switch type {
            case .available:
                if viewStore.state.availableRoomArray.isEmpty {
                    Text("예약 가능한 회의실이 없어요!")
                } else {
                    ForEach(viewStore.state.availableRoomArray) { meetingRoom in
                        Text(meetingRoom.rentBy)
                    }
                }
                
            case .unavailable:
                if viewStore.state.unavailableMeetingRoomArray.isEmpty {
                    Text("예약된 회의실이 없어요!")
                } else {
                    ForEach(viewStore.state.unavailableMeetingRoomArray) { meetingRoom in
                        Text(meetingRoom.rentBy)
                    }
                }
                
            case .booked:
                if viewStore.state.bookedMeetingRoomArray.isEmpty {
                    Text("내가 예약한 회의실이 없어요!")
                } else {
                    ForEach(viewStore.state.bookedMeetingRoomArray) { meetingRoom in
                        Text(meetingRoom.rentBy)
                    }
                }
            }
            
        } header: {
            switch type {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(initialState: MeetingRoomFeature.State()) {
                MeetingRoomFeature()
            }
        )
    }
}
