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
    var rentDateFromUNIXTime: Int
    var rentBy: String
    var rentHourAndMinute: Int
    
    var rentDate: Date {
        get { Date.init(timeIntervalSince1970: TimeInterval(rentDateFromUNIXTime)) }
        set { return rentDateFromUNIXTime = Int(Date.now.timeIntervalSince1970) }
    }
    
    static func testInstance() -> Self {
        MeetingRoom(
            id: .init(0),
            meetingRoomName: "TEST",
//            rentDate: .now,
            rentDateFromUNIXTime: 0,
            rentBy: Constants.DUMMY_MEETINGROOM_RENTNAMES.randomElement()!,
            rentHourAndMinute: 1
        )
    }
}
