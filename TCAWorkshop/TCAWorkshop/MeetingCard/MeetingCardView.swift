//
//  MeeitngCardView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/18.
//

import ComposableArchitecture
import SwiftUI

struct MeetingCardView: View {
    var num: Int = 0
    let store: StoreOf<MeetingCardDomain>
    let gridSystem: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        WithViewStore(
            self.store,
            observe: { $0 }
        ) { viewStore in
            NavigationStack {
                ScrollView {
                    LazyVStack(
                        spacing: 24,
                        pinnedViews: .sectionHeaders
                    ) {
                        Section {
                            meetingCardTextFieldView(viewStore)
                        } header: {
                            HStack {
                                subjectHeaderBuilder(with: "미팅 주제")
                                
                                Button {
                                    viewStore.send(
                                        .subjectEditButtonTapped,
                                        animation: .easeInOut
                                    )
                                } label: {
                                    Image(
                                        systemName: viewStore.state.isSubjectEditButtonTapped
                                        ? "checkmark.circle"
                                        : "pencil.circle"
                                    )
                                }
                            }
                            .padding()
                        }
                        
                        Divider()
                            .padding(.horizontal)
                            .padding(.top, 12)
                        
                        Section {
                            if viewStore.state.isMeetingParticipantAddedButtonTapped {
                                meetingParticipantTextFieldView(viewStore)
                            }
                            
                            LazyVGrid(
                                columns: gridSystem,
                                spacing: 24
                            ) {
                                eachNameCardView(viewStore)
                                
                                Button {
                                    viewStore.send(
                                        .isMeetingParticipantAddedButtonTapped,
                                        animation: .easeInOut
                                    )
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: "person.badge.plus.fill")
                                        
                                        Text("추가")
                                            .frame(maxWidth: 72)
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal)
                                    .padding(.vertical, 36)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(
                                                Color.blue,
                                                style: StrokeStyle(
                                                    lineWidth: 1.5,
                                                    dash: [6],
                                                    dashPhase: 6
                                                )
                                            )
                                            .shadow(radius: 1, x: 1, y: 2)
                                    }
                                }
                            }
                        } header: {
                            HStack {
                                subjectHeaderBuilder(with: "참여 인원")
                                
                                Text("총 인원: \(viewStore.state.meetingInfo.participants.count)명")
                            }
                            .padding()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.cancelButtonTapped)
                        } label: {
                            Text("닫기")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Methods
    private func subjectHeaderBuilder(with title: String) -> some View {
        Text(title)
            .bold()
            .font(.title2)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(
                        height: 1.5
                    )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
    
    private func maximumStringCountView(
        _ viewStore: ViewStoreOf<MeetingCardDomain>
    ) -> some View {
        HStack {
            Text("(\(viewStore.state.meetingInfo.subject.count) / \(20))")
                .monospacedDigit()
                .font(.footnote)
                .animation(nil)
        }
        .offset(y: 26)
        .bold()
        .opacity(viewStore.state.isSubjectEditButtonTapped ? 1.0 : 0.0)
        .foregroundColor(
            viewStore.state.meetingInfo.subject.count >= 20
            ? .red
            : .green
        )
        .offset(
            x: viewStore.state.isSubjectMaximumCharcterReached
            && viewStore.state.meetingInfo.subject.count >= 20
            ? 0
            : -2
        )
        .animation(
            .default.speed(3.5).repeatCount(4, autoreverses: true),
            value: viewStore.state.isSubjectMaximumCharcterReached
        )
    }
    
    private func meetingCardTextFieldView(
        _ viewStore: ViewStoreOf<MeetingCardDomain>
    ) -> some View {
        TextField(
            "",
            text: viewStore.binding(
                get: { $0.meetingInfo.subject },
                send: { .isSubjectEditing($0) }
            )
        )
        .bold()
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .multilineTextAlignment(.center)
        .disabled(!viewStore.state.isSubjectEditButtonTapped)
        .frame(maxWidth: 270)
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(maxHeight: 1.5)
                .opacity(viewStore.state.isSubjectEditButtonTapped ? 1.0 : 0.0)
                .offset(y: 6)
        }
        .overlay(alignment: .bottomTrailing) {
            maximumStringCountView(viewStore)
        }
        .overlay(alignment: .trailing) {
            HStack(spacing: 4) {
                Button {
                    viewStore.send(.emptySubjectTextFieldButtonTapped)
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            .opacity(viewStore.state.isSubjectEditButtonTapped ? 1.0 : 0.0)
            .foregroundColor(.red)
        }
    }
    
    private func eachNameCardView(_ viewStore: ViewStoreOf<MeetingCardDomain>) -> some View {
        ForEach(
            viewStore.state.meetingInfo.participants,
            id: \.self
        ) { names in
            VStack(spacing: 8) {
                Image(systemName: "person.fill")
                
                Text(names)
                    .frame(maxWidth: 72)
                    .lineLimit(1)
            }
            .padding(.horizontal)
            .padding(.vertical, 36)
            .overlay(alignment: .topTrailing) {
                if viewStore.state.isNameCardLongPressed {
                    Image(systemName: "xmark.circle")
                        .padding([.top, .trailing], 8)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.black, lineWidth: 2)
                    .shadow(radius: 1, x: 1, y: 2)
            }
        }
    }
    
    private func meetingParticipantTextFieldView(_ viewStore: ViewStoreOf<MeetingCardDomain>) -> some View {
        TextField(
            "",
            text: viewStore.binding(
                get: { $0.meetingParticipantName },
                send: { .isMeetingParticipantEditted($0) }
            )
        )
        .bold()
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .multilineTextAlignment(.center)
    }
}

struct MeeitngCardView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingCardView(
            store: Store(
                initialState: MeetingCardDomain.State(
                    id: .init(),
                    meetingInfo: .testInstance()
                ), reducer: {
                    MeetingCardDomain()
                }
            )
        )
    }
}
