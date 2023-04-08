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
    
    @State private var availableMediaItems: [MediaItem]?
    
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
                        }.onDelete(perform: onDeleteAssociatedMediaItem)
                    }
                    Button { isShowingNewMediaAlignmentView.toggle() } label: {
                        Label("New media alignment", systemImage: "plus")
                    }.disabled(availableMediaItems?.count == 0)
                }
            }
        }
        .sheet(isPresented: $isShowingNewMediaAlignmentView) {
            NewMediaAlignmentView(alignmentBase: alignmentBase, availableMediaItems: availableMediaItems ?? [], isShowingNewMediaAlignmentView: $isShowingNewMediaAlignmentView)
        }
        .onAppear() {
            let allMediaItems = (try? viewContext.fetch(MediaItem.fetchRequest()) as [MediaItem]) ?? []
            let alreadyAlignedMediaItems = (alignmentBase.mediaAlignments?.allObjects as? [MediaAlignment])?.compactMap({ $0.mediaItem }) ?? []
            availableMediaItems = Array(Set(allMediaItems).symmetricDifference(alreadyAlignedMediaItems))
        }
    }
    
    private func onDeleteAssociatedMediaItem(indexSet: IndexSet) {
        let mediaAlignments = alignmentBase.mediaAlignments?.allObjects as? [MediaAlignment]
        for index in indexSet {
            alignmentBase.removeFromMediaAlignments(mediaAlignments![index])
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
