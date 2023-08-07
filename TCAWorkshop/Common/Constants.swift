//
//  Constants.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/07.
//

import Foundation

public enum Constants {
    @frozen enum MeetingRoomCondition {
        case available
        case unavailable
        case booked
    }
    
    static let DUMMY_MEETINGROOM_RENTNAMES: [String] = [
        "CURRENT_USER",
        "OTHERS",
        "AVAILABLE",
    ]
}
