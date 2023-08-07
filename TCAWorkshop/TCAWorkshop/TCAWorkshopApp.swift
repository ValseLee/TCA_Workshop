//
//  TCAWorkshopApp.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/04.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAWorkshopApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: MeetingRoomFeature.State()) {
                    MeetingRoomFeature()
                }
            )
        }
    }
}
