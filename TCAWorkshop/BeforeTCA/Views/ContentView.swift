//
//  ContentView.swift
//  BeforeTCA
//
//  애플 디벨로퍼 아카데미에 회의실 예약 앱이 있다면?
//  Created by Celan on 2023/08/04.
//

import SwiftUI

struct ContentView: View {
    @StateObject
    private var meetingRoomListVM: MeetingRoomListViewModel = .init()
    
    var body: some View {
        List {
            meetingRoomSectionBuilder(type: .booked)
            
            meetingRoomSectionBuilder(type: .unavailable)
            
            meetingRoomSectionBuilder(type: .available)
        }
    }
    
    // MARK: - Methods
    /// 리스트의 각 섹션을 만들어주는 빌더
    /// - Parameter type: 어떤 타입의 미팅룸을 만들고 싶은지 전달
    /// - Returns: 해당 미팅룸의 타입에 따라 뷰 리턴
    private func meetingRoomSectionBuilder(
        type: Constants.MeetingRoomCondition
    ) -> some View {
        Section {
            if isMeetingRoomExists(in: type) {
                ForEach(meetingRoomListVM.getRoomArray(with: type)) { meetingRoom in
                    NavigationLink {
                        Text(meetingRoom.rentBy)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(meetingRoom.rentBy)")
                            
                            Text("\(meetingRoom.date.formatted())")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(2)
                    }
                }
                
            } else {
                switch type {
                case .available:
                    Text("예약 가능한 회의실이 없어요!")
                case .unavailable:
                    Text("예약된 회의실이 없어요!")
                case .booked:
                    Text("내가 예약한 회의실이 없어요!")
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
    
    private func isMeetingRoomExists(
        in condition: Constants.MeetingRoomCondition
    ) -> Bool {
        switch condition {
        case .available:
            return meetingRoomListVM.availableRoomArray.count > 0
        case .unavailable:
            return meetingRoomListVM.unavailableMeetingRoomArray.count > 0
        case .booked:
            return meetingRoomListVM.bookedMeetingRoomArray.count > 0
        }
    }
}
