//
//  AlignMediaDetailView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI

struct ManageAlignmentBaseDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @State var alignmentBase: AlignmentBase
    
    @State private var isShowingNewMediaAlignmentView = false
    
    var body: some View {
        VStack {
            Text(alignmentBase.name ?? "NA").font(.system(.title))
            List {
                Section("Markers") {
                    ForEach((alignmentBase.markers?.components(separatedBy: "\n"))!, id: \.self) { item in
                        Text(item)
                    }
                }
                Section("Associated media items") {
                    if let mediaAlignments = alignmentBase.mediaAlignments?.allObjects as? [MediaAlignment] {
                        ForEach(mediaAlignments) { item in
                            Text((item.mediaItem?.name)!)
                        }
                    }
                    Button { isShowingNewMediaAlignmentView.toggle() } label: {
                        Label("New media alignment", systemImage: "plus")
                    }
                }
            }
        }.sheet(isPresented: $isShowingNewMediaAlignmentView) {
            NewMediaAlignmentView(markers: alignmentBase.markers ?? "", isShowingNewMediaAlignmentView: $isShowingNewMediaAlignmentView, alignmentBase: $alignmentBase).environment(\.managedObjectContext, viewContext)
        }
    }
}

struct AlignMediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        
        do {
            let alignmentBase = (try viewContext.fetch(AlignmentBase.fetchRequest()).first)!
            
            return AnyView(ManageAlignmentBaseDetailView(alignmentBase: alignmentBase).environment(\.managedObjectContext, viewContext))
        } catch {
            return AnyView(Text("error"))
        }
    }
}
