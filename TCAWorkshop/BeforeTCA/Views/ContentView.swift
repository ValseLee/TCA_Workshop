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
    
    @State private var isSectionToggled: Bool = true
    
    var body: some View {
        List {
            Section {
                if meetingRoomListVM.bookedMeetingRoomArray.count > 0 {
                    ForEach(meetingRoomListVM.bookedMeetingRoomArray) { meetingRoom in
                        Text("\(meetingRoom.rentBy)")
                    }
                } else {
                    Text("아직 내가 예약한 회의실이 없어요!")
                }
                
            } header: {
                Text("내가 예약한 회의실")
            }
            
            Section {
                if isSectionToggled {
                    Text("?")
                }
                
            } header: {
                HStack {
                    Text("회의실 찾아보기")
                    Spacer()
                    Button {
                        withAnimation {
                            isSectionToggled.toggle()
                        }
                        
                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                    .font(.footnote)
                    .rotationEffect(isSectionToggled ? .degrees(90) : .zero)
                }
            }
        }
        .task {
            await meetingRoomListVM.fetchAllMeetingRoom()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
