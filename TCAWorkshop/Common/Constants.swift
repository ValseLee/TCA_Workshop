//
//  Constants.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/07.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public enum Constants {
    @frozen enum MeetingRoomCondition: CaseIterable {
        case available
        case unavailable
        case booked
    }
    
    static let FIREBASE_COLLECTION = Firestore.firestore().collection("MeetingRooms")
    
    static let DUMMY_MEETINGROOM_RENTNAMES: [String] = [
        "CURRENT_USER",
        "OTHERS",
        "AVAILABLE",
    ]
}
