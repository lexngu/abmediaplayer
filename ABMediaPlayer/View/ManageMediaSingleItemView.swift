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
    
    @State private var player: AVPlayer
    
    @State private var mediaItem: MediaItem
    
    var body: some View {
        VStack() {
            Text(mediaItem.name ?? "").font(.system(.title))
            VideoPlayer(player: player)
            List(mediaItem.mediaAlignments?.allObjects as? [MediaAlignment] ?? []) { mediaAlignment in
                Section(mediaAlignment.alignmentBase?.name ?? "") {
                    Text(mediaAlignment.markers ?? "")
                }
            }
            Spacer()
        }
    }
    
    init(mediaItem: MediaItem) {
        self.mediaItem = mediaItem
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: mediaItem.bookmarkData ?? Data(), bookmarkDataIsStale: &isStale)
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
        
        do {
            let mediaItem = try viewContext.fetch(MediaItem.fetchRequest()).first!
            return AnyView(ManageMediaSingleItemView(mediaItem: mediaItem).environment(\.managedObjectContext, viewContext))
        } catch {
            return AnyView(Text("Error!"))
        }
        
    }
}
