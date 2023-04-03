//
//  RootView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI

enum Tabs: String {
    case media
    case alignment
}

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedSidebarItem: String?
    let sidebarItems = ["Manage media", "Align media", "Play media"]
    
    @State private var selectedTab = Tabs.media
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ManageMediaView().environment(\.managedObjectContext, viewContext).tag(Tabs.media).tabItem {
                Text("Media")
            }
            ManageAlignmentBaseView().tag(Tabs.alignment).tabItem {
                Text("Alignment")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
