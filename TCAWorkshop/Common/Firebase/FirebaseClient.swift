//
//  FirebaseClient.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

protocol FirebaseInterface {
    associatedtype FirebaseData: Codable
    
    var update: @Sendable (_ with: FirebaseData) async throws -> Void { get }
    var fetch: @Sendable () async throws -> [FirebaseData] { get }
}

struct MeetingRoomClient: FirebaseInterface {
    var update: (@Sendable (_ with: MeetingRoom) async throws -> Void)
    var fetch: (@Sendable () async throws -> [MeetingRoom])
}

extension MeetingRoomClient {
    static let live = Self(
    update: { meetingRoom in
        Constants.FIREBASE_COLLECTION
            .document(meetingRoom.id.uuidString)
            .setData(
                [
                    "rentDate": Timestamp(date: meetingRoom.rentDate),
                    "rentBy": meetingRoom.rentBy,
                    "rentHourAndMinute": meetingRoom.rentHourAndMinute,
                ],
                merge: true
            )
    }, fetch: {
        /// 속도 개선의 역사... 1.1초 -> 0.6초 -> 0.3초
        /// withTaskGroup으로 멀티 쓰레딩하겠다고 까불다가 1.1초 맞았다.
        /// 각 메소드를 group task로 추가하지 않고 멀티쓰레딩이라고 까불었던것.
        /// 기존엔 for 문도 돌리고 Store에 send도 같이 엮여있었다.
        /// 0.6초가 나왔다. 로직이 서로 엮이는 게 성능 저하의 원인으로 보였다.
        /// 로직 책임을 명확히 나누고 fetch는 fetch만 하게 하고 store는 그 데이터를 따로 처리하도록 했다.
        /// 0.3초 진입 성공🎉
        async let docSnapshot = try Constants.FIREBASE_COLLECTION
            .getDocuments()
        
        let result = try await docSnapshot.documents.map {
            try $0.data(as: MeetingRoom.self)
        }
        
        return result
    })

    static let test = Self(
        update: { meetingRoom in
            print("\(meetingRoom.id), Update")
        }, fetch: {
            print("Fetch Start in: \(Constants.FIREBASE_COLLECTION.description)")
            return [MeetingRoom.testInstance()]
        }
    )
}
