//
//  DependencyValue+MeetingRoomClient.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/23.
//

import ComposableArchitecture

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
