//
//  RootView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI

enum Route: Hashable {
    case mode(String)
    case mediaMode(MediaItem)
    case playMode(AlignmentBase)
    case alignMode(AlignmentBase)
}

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
        
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Media", value: Route.mode("media"))
                NavigationLink("Alignment", value: Route.mode("alignment"))
                NavigationLink("Play", value: Route.mode("play"))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .mode(let mode):
                    switch mode {
                    case "media":
                        ManageMediaView()
                    case "alignment":
                        ManageAlignmentBaseView(navigationPath: $navigationPath)
                    case "play":
                        PlayMediaView(navigationPath: $navigationPath)
                    default:
                        Text("...")
                    }
                case .mediaMode(let mediaItem):
                    ManageMediaSingleItemView(mediaItem: mediaItem)
                case .alignMode(let alignmentBase):
                    ManageAlignmentBaseDetailView(alignmentBase: alignmentBase)
                case .playMode(let alignmentBase):
                    DisplayAlignmentView(alignmentModel: AlignmentModel(alignmentBase: alignmentBase))
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
