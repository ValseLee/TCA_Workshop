//
//  MeetingRoom.swift
//  BeforeTCA
//
//  Created by Celan on 2023/08/05.
//

import Foundation

struct MeetingRoom: Identifiable, Hashable, Codable {
    var id: UUID
    var meetingRoomName: String
    var rentDate: Date
    var rentBy: String
    var rentHourAndMinute: Int
    
    static func testInstance() -> Self {
        MeetingRoom(
            id: .init(),
            meetingRoomName: "TEST",
            rentDate: .now,
            rentBy: Constants.DUMMY_MEETINGROOM_RENTNAMES.randomElement()!,
            rentHourAndMinute: 1
        )
    }
}
