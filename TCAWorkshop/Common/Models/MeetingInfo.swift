//
//  MeetingInfo.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/18.
//

import Foundation

struct MeetingInfo: Identifiable, Hashable, Codable {
    var id: UUID
    var meetingRoomID: UUID
    var participants: [String]
    var subject: String
    var date: Date
    
    static func testInstance() -> Self {
        MeetingInfo(
            id: .init(0),
            meetingRoomID: .init(0),
            participants: [
                "덕배",
                "춘용",
                "미자",
                "명실",
                "용길",
                "경수",
                "철준"
            ],
            subject: "TEST_SUBJECT",
            date: .now
        )
    }
}
