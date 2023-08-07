//
//  AppDelegate+Firebase.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/07.
//

import Foundation
import Firebase
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
