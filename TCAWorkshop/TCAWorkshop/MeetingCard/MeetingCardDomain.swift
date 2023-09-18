//
//  MeetingCardFeature.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/18.
//

import ComposableArchitecture
import Foundation

struct MeetingCardDomain: Reducer {
    @Dependency(\.meetingRoomClient)
    var meetingRoomClient
    
    @Dependency(\.dismiss)
    var dismiss
    
    struct State: Equatable {
        var id: UUID
        var meetingInfo: MeetingInfo
    }
    
    enum Action: Equatable {
        case cancelButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
    
    private func core() -> Reduce<State, Action> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            }
        }
    }
}
