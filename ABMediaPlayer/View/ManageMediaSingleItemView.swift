//
//  ManageMediaSingleItemView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 31.03.23.
//

import SwiftUI
import AVKit

struct ManageMediaSingleItemView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private var player: AVPlayer
    
    var mediaItem: MediaItem
    
    var body: some View {
        VStack {
            Text(mediaItem.name ?? "")
            Text(player.error.debugDescription)
            VideoPlayer(player: player).frame(width: 300, height: 200, alignment: .center)
        }
    }
    
    init(mediaItem: MediaItem) {
        self.mediaItem = mediaItem
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: mediaItem.bookmarkData!, bookmarkDataIsStale: &isStale)
            if isStale {
                print("\(url) is stale!")
            }
            self.player = AVPlayer(url: url)
        } catch {
            print("Bookmark error \(error)")
            self.player = AVPlayer()
        }
    }
    
    
}

struct ManageMediaSingleItemView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let mediaItem = MediaItem(context: viewContext)
        mediaItem.name = "20230305_nono.mp4"
        mediaItem.size = 268343715
        mediaItem.format = "MPEG-4"
        mediaItem.duration = 2049.183
        
        return ManageMediaSingleItemView(mediaItem: mediaItem).environment(\.managedObjectContext, viewContext)
    }
}
