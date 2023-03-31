//
//  ABMediaPlayerApp.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 11.03.23.
//

import SwiftUI

@main
struct ABMediaPlayerApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
