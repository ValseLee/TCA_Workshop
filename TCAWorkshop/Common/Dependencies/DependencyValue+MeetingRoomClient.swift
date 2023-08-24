//
//  DependencyValue+MeetingRoomClient.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/23.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var meetingRoomClient: MeetingRoomClient {
        get { self[FirebaseClientKey.self] }
        set { self[FirebaseClientKey.self] = newValue }
    }
}

fileprivate enum FirebaseClientKey: DependencyKey {
    static var liveValue: MeetingRoomClient = .live
    static var testValue: MeetingRoomClient = .test
}

extension DependencyValues {
    var customDateFormatter: DateFormatters {
        get { self[CustomDateFormatter.self] }
        set { self[CustomDateFormatter.self] = newValue }
    }
}

fileprivate enum CustomDateFormatter: DependencyKey {
    static var liveValue: DateFormatters = .init()
    static var testValue: DateFormatters = .init()
}


