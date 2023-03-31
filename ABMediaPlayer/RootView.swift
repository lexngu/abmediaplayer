//
//  RootView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedSidebarItem: String?
    let sidebarItems = ["Manage media", "Align media", "Play media"]
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSidebarItem) {
                ForEach(sidebarItems, id: \.self) { item in
                    NavigationLink(value: item) {
                        Text(verbatim: item)
                    }
                }
            }
            .navigationTitle("Actions")
        } detail: {
            if let ssi = selectedSidebarItem {
                if ssi == sidebarItems[0] {
                    ManageMediaView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                } else if ssi == sidebarItems[1] {
                    AlignMediaView(availableMediaAlignmentItems: [])
                }           
            } else {
                Text("Choose an action")
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
