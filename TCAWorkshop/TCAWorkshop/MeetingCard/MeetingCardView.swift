//
//  MeeitngCardView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/18.
//

import ComposableArchitecture
import SwiftUI

struct MeetingCardView: View {
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
                                    x: viewStore.state.isSubjectMaximumCharcterReached && viewStore.state.meetingInfo.subject.count >= 20
                                    ? 0
                                    : -2
                                )
                                .animation(
                                    .default.speed(3.5).repeatCount(4, autoreverses: true),
                                    value: viewStore.state.isSubjectMaximumCharcterReached
                                )
                                                                
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
                            LazyVGrid(
                                columns: gridSystem,
                                spacing: 24
                            ) {
                                ForEach(
                                    viewStore.meetingInfo.participants,
                                    id: \.self
                                ) { names in
                                    VStack(spacing: 8) {
                                        Image(systemName: "person.fill")
                                        
                                        Text(names)
                                    }
                                    .padding(32)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .opacity(0.05)
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
