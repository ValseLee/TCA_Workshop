//
//  TCAWorkshopApp.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/04.
//

import SwiftUI
import ComposableArchitecture
import XCTestDynamicOverlay

@main
struct TCAWorkshopApp: App {
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                NavigationStack {
                    RootView(
                        store: Store(initialState: MeetingRoomListDomain.State()) {
                            MeetingRoomListDomain()
                                ._printChanges()
                        }
                    )
                }
            }
        }
    }
}
