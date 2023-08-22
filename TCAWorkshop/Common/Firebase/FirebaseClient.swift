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
        var fetchedMeetingRooms = [MeetingRoom]()
                
        async let docSnapshot = try Constants.FIREBASE_COLLECTION
            .getDocuments()
        
        for doc in try await docSnapshot.documents {
            let fetchedMeetingRoom = try doc.data(as: MeetingRoom.self)
            /// 굳이 store의 action을 여기서 억지로 처리할 필요가 있을까
            /// 'fetch' 이상의 역할을 하게 되는데 왜?
            fetchedMeetingRooms.append(fetchedMeetingRoom)
        }
        
        return fetchedMeetingRooms
    })

    static let test = Self(
        update: { meetingRoom in
            print("\(meetingRoom.id), Update")
        }, fetch: {
            print("Fetch Start in: \(Constants.FIREBASE_COLLECTION.description)")
            return [MeetingRoom.testInstance()]
        })
}
