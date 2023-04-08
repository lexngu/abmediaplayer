//
//  ABMediaPlayerApp.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 11.03.23.
//

import SwiftUI
import AVFoundation

@main
struct ABMediaPlayerApp: App {
    let persistenceController = PersistenceController.shared
#if os(iOS)
    init() {
        try? AVAudioSession.sharedInstance().setCategory(
            AVAudioSession.Category.playback,
            options: AVAudioSession.CategoryOptions.mixWithOthers
        )
    }
#endif
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
