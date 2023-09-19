//
//  MeetingCardFeature.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/18.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct MeetingCardDomain: Reducer {
    @Dependency(\.meetingRoomClient)
    var meetingRoomClient
    
    @Dependency(\.dismiss)
    var dismiss
    
    struct State: Equatable {
        var id: UUID
        var meetingInfo: MeetingInfo
        var isSubjectEditButtonTapped: Bool = false
        var isSubjectMaximumCharcterReached: Bool = false
    }
    
    enum Action: Equatable {
        case cancelButtonTapped
        case subjectEditButtonTapped
        case isSubjectEditing(String)
        case emptySubjectTextFieldButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        core()
            ._printChanges()
    }
    
    private func core() -> Reduce<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .cancelButtonTapped:
                state.isSubjectEditButtonTapped = false
                state.isSubjectMaximumCharcterReached = false
                return .run { _ in await self.dismiss() }
                
            case .subjectEditButtonTapped:
                state.isSubjectEditButtonTapped.toggle()
                
                if state.isSubjectMaximumCharcterReached,
                   state.meetingInfo.subject.count < 20 {
                    state.isSubjectMaximumCharcterReached = false
                }
                return .none
                
            case let .isSubjectEditing(newSubject):
                if newSubject.count > 20 {
                    state.isSubjectMaximumCharcterReached = true
                } else if newSubject.count <= 20 {
                    state.isSubjectMaximumCharcterReached = false
                    state.meetingInfo.subject = newSubject
                }
                
                return .none
                
            case .emptySubjectTextFieldButtonTapped:
                state.meetingInfo.subject = ""
                state.isSubjectMaximumCharcterReached = false
                
                return .none
            }
        }
    }
}
