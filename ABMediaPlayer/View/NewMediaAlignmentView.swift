//
//  NewMediaAlignmentView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 02.04.23.
//

import SwiftUI

struct NewMediaAlignmentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AlignmentBase.name, ascending: true)])
    private var availableAlignmentBases: FetchedResults<AlignmentBase>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MediaItem.name, ascending: true)])
    private var availableMediaItems: FetchedResults<MediaItem>
    
    @State private var selectedMediaItem: MediaItem?
    @State var markers: String = ""
    @Binding var isShowingNewMediaAlignmentView: Bool
    @Binding var alignmentBase: AlignmentBase
    @State private var createButtonDisabled = true
    
    var body: some View {
        List {
            Picker("Media item", selection: $selectedMediaItem) {
                Text("Choose media item").tag(Optional<MediaItem>(nil))
                ForEach(availableMediaItems) { item in
                    Text(item.name!).tag(Optional(item))
                }
            }.onChange(of: selectedMediaItem) { tag in
                createButtonDisabled = tag == Optional<MediaItem>(nil)
            }
            TextEditor(text: $markers)
            Button("Create", action: createButtonClicked).disabled(createButtonDisabled)
        }
    }
    
    func createButtonClicked() {
        let newMediaAlignment = MediaAlignment(context: viewContext)
        newMediaAlignment.id = UUID()
        newMediaAlignment.alignmentBase = alignmentBase
        newMediaAlignment.mediaItem = selectedMediaItem
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        alignmentBase.objectWillChange.send()
        isShowingNewMediaAlignmentView.toggle()
    }
}

struct NewMediaAlignmentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        
        NewMediaAlignmentView(isShowingNewMediaAlignmentView: .constant(true), alignmentBase: .constant(AlignmentBase())).environment(\.managedObjectContext, viewContext)
    }
}
