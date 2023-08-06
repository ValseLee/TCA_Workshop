//
//  MeetingRoomListView.swift
//  BeforeTCA
//
//  Created by Celan on 2023/08/05.
//

import SwiftUI

final class MeetingRoomListViewModel: ObservableObject {
    @frozen enum MeetingRoomCondition {
        case available
        case unavailable
        case booked
    }
    
    private let DUMMIES = [
        "CURRENT_USER",
        "OTHERS",
        "AVAILABLE"
    ]
    
    @Published var availableRoomArray: [MeetingRoom] = []
    @Published var unavailableMeetingRoomArray: [MeetingRoom] = []
    @Published var bookedMeetingRoomArray: [MeetingRoom] = []
    
    init() {
        Task {
            await fetchAllMeetingRoom()
        }
    }
    
    public func fetchAllMeetingRoom() async {
        var fetched = [MeetingRoom]()
        for _ in 0..<10 {
            fetched.append(MeetingRoom(id: .init(), date: .now, rentBy: DUMMIES.randomElement()!))
        }
        
        await withTaskGroup(of: Void.self) { group in
            let start = Date()
            defer {
                Logger.methodExecTimePrint(start)
                Logger._printData(.read, "")
            }
            
            fetched.forEach { meetingRoom in
                group.addTask {
                    if meetingRoom.rentBy == "CURRENT_USER" {
                         await self.appendRoomArray(
                            by: .booked,
                            with: meetingRoom
                        )
                    } else if meetingRoom.rentBy == "OTHERS" {
                         await self.appendRoomArray(
                            by: .unavailable,
                            with: meetingRoom
                        )
                    } else {
                         await self.appendRoomArray(
                            by: .available,
                            with: meetingRoom
                        )
                    }
                }
            }
            
            await group.waitForAll()
        }
    }
    
    public func getRoomArray(with condition: MeetingRoomCondition) -> [MeetingRoom] {
        switch condition {
        case .available:
            return availableRoomArray
        case .unavailable:
            return unavailableMeetingRoomArray
        case .booked:
            return bookedMeetingRoomArray
            
        }
    }
    
    @MainActor
    private func appendRoomArray(
        by condition: MeetingRoomCondition,
        with meetingRoom: MeetingRoom
    ) {
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
