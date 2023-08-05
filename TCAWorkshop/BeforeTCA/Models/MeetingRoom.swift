//
//  MeetingRoom.swift
//  BeforeTCA
//
//  Created by Celan on 2023/08/05.
//

import Foundation

struct MeetingRoom: Identifiable, Hashable {
    var id: UUID
    var date: Date
    var rentBy: String
}
