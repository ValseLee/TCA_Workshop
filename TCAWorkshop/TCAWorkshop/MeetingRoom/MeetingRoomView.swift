//
//  MeetingRoomView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/11.
//

import ComposableArchitecture
import SwiftUI

struct MeetingRoomView: View {
    let store: StoreOf<MeetingRoomDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("")
        }
    }
}

struct MeetingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingRoomView(store: Store(initialState: MeetingRoomDomain.State(rentLearnerName: "CURRENT_USER", rentDate: .now, id: .init(), selectedMeetingRoom: .init(id: .init(), meetingRoomName: "TEST", rentDate: .now, rentBy: "TEST")), reducer: {
            MeetingRoomDomain()
        }))
    }
}
