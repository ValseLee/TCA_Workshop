//
//  FirebaseClient.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/22.
//

import Foundation

protocol APINetworkInterface {
    associatedtype APIData: Codable
    
    var update: @Sendable (_ with: APIData) async throws -> Void { get }
    var fetch: @Sendable () async throws -> [APIData] { get }
}

enum MeetingRoomClientError: Error {
    case fetchError
    case postError
}

struct MeetingRoomClient: APINetworkInterface {
    var update: (@Sendable (_ with: MeetingRoom) async throws -> Void)
    var fetch: (@Sendable () async throws -> [MeetingRoom])
}

extension MeetingRoomClient {
    static let live = Self(
    update: { meetingRoom in
        let updatePayload = try JSONEncoder().encode(meetingRoom)
        print("ID: ", meetingRoom.id.uuidString)
        let url = URL(string: "https://my-json-server.typicode.com/ValseLee/TCA_Workshop/meetingRooms/\(meetingRoom.id.uuidString)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PATCH"
        request.httpBody = updatePayload
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: updatePayload)
        
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            print("Update Failed", response)
            throw MeetingRoomClientError.postError
        }
        
    }, fetch: {
        let (data, response) = try await URLSession.shared.data(
            from: URL(string: "https://my-json-server.typicode.com/ValseLee/TCA_Workshop/meetingRooms")!
        )
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("Fetch Failed", response)
            throw MeetingRoomClientError.fetchError
        }
        
        let result = try JSONDecoder().decode([MeetingRoom].self, from: data)
        
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
