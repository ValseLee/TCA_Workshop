//
//  MeetingRoomListView.swift
//  BeforeTCA
//
//  Created by Celan on 2023/08/05.
//

import SwiftUI

final class MeetingRoomListViewModel: ObservableObject {
    enum MeetingRoomCondition {
        case available
        case unavailable
        case booked
    }
    
    @Published var availableRoomArray: [MeetingRoom] = []
    @Published var unavailableMeetingRoomArray: [MeetingRoom] = []
    @Published var bookedMeetingRoomArray: [MeetingRoom] = []
    
    public func fetchAllMeetingRoom() async {
        try? await Task.sleep(for: .seconds(1))
        let fetched = Array(repeating: MeetingRoom(id: .init(), date: .now, rentBy: "others"), count: 10)
        
        await withTaskGroup(of: Void.self) { group in
            fetched.forEach { meetingRoom in
                if meetingRoom.rentBy == "CURRENT_USER" {
                    group.addTask { [weak self] in
                        await self?.appendRoomArray(by: .booked, with: meetingRoom)
                    }
                } else if meetingRoom.rentBy == "OTHERS" {
                    group.addTask { [weak self] in
                        await self?.appendRoomArray(by: .unavailable, with: meetingRoom)
                    }
                } else {
                    group.addTask { [weak self] in
                        await self?.appendRoomArray(by: .available, with: meetingRoom)
                    }
                }
            }
            
            if group.isEmpty { Logger._printData(.read, fetched) }
        }
    }
    
    @MainActor
    private func appendRoomArray(
        by condition: MeetingRoomCondition,
        with meetingRoom: MeetingRoom
    ) async {
        switch condition {
        case .available:
            self.availableRoomArray.append(meetingRoom)
        case .booked:
            self.bookedMeetingRoomArray.append(meetingRoom)
        case .unavailable:
            self.unavailableMeetingRoomArray.append(meetingRoom)
        }
    }
}
