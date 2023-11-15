//
//  jeraldjournalApp.swift
//  jeraldjournal
//
//  Created by Zane Sabbagh on 11/14/23.
//

import SwiftUI
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct jeraldjournalApp: App {
    let persistenceController = PersistenceController.shared

    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
