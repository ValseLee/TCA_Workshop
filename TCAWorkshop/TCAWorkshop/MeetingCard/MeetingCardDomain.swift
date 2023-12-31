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
        
        var nameCardLongPressedDuration: Double = 0
        var isNameCardLongPressed: Bool = false
        
        var isMeetingParticipantAddedButtonTapped: Bool = false
        var isMeetingParticipantMaximumCharacterReached: Bool = false
        var meetingParticipantName: String = "New"
    }
    
    enum Action: Equatable {
        case cancelButtonTapped
        case subjectEditButtonTapped
        case isSubjectEditing(String)
        case emptySubjectTextFieldButtonTapped
        
        case isNameCardLongPressing
        case isNameCardLongPressed
        
        case isMeetingParticipantAddedButtonTapped
        case isMeetingParticipantEditted(String)
        case emptyMeetingParticipantTextFieldButtonTapped
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
                
            case .isNameCardLongPressing:
//                state.nameCardLongPressedDuration += 0.2
                return .none
                
            case .isNameCardLongPressed:
                state.isNameCardLongPressed = true
                return .none
                
            case .isMeetingParticipantAddedButtonTapped:
                if state.isMeetingParticipantAddedButtonTapped {
                    state.isMeetingParticipantAddedButtonTapped = false
                    guard state.meetingParticipantName == "New" || state.meetingParticipantName.count == 0 else {
                        state.meetingInfo.participants.append(state.meetingParticipantName)
                        return .none
                    }
                } else {
                    state.meetingParticipantName = "New"
                    state.isMeetingParticipantAddedButtonTapped = true
                }
 
                return .none
                
            case let .isMeetingParticipantEditted(newParticipant):
                if newParticipant.count > 10 {
                    state.isMeetingParticipantMaximumCharacterReached = true
                } else if newParticipant.count <= 10 {
                    state.isMeetingParticipantMaximumCharacterReached = false
                    state.meetingParticipantName = newParticipant
                }
                
                return .none
                
            case .emptyMeetingParticipantTextFieldButtonTapped:
                state.meetingParticipantName = ""
                return .none
            }
        }
    }
}
