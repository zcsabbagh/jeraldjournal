//
//  jeraldjournalApp.swift
//  jeraldjournal
//
//  Created by Zane Sabbagh on 11/14/23.
//

import SwiftUI

@main
struct jeraldjournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Record()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
