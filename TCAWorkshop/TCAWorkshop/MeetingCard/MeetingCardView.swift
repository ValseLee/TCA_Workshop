//
//  MeeitngCardView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/09/18.
//

import ComposableArchitecture
import SwiftUI

struct MeeitngCardView: View {
    let store: StoreOf<MeetingCardDomain>
    
    var body: some View {
        WithViewStore(
            self.store,
            observe: { $0 }
        ) { viewStore in
            ScrollView {
                LazyVStack(pinnedViews: .sectionHeaders) {
                    Section {
                        Text(viewStore.state.meetingInfo.subject)
                            .bold()
                    } header: {
                        subjectHeaderBuilder(with: "미팅 주제")
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("총 인원: \(viewStore.state.meetingInfo.participants.count)")
                                
                            
                            ForEach(
                                viewStore.meetingInfo.participants,
                                id: \.self
                            ) { names in
                                Text(names)
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.horizontal)
                    } header: {
                        subjectHeaderBuilder(with: "참여 인원")
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
            .padding()
    }
}

struct MeeitngCardView_Previews: PreviewProvider {
    static var previews: some View {
        MeeitngCardView(
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
