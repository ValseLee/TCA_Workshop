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
}
