//
//  NewMediaAlignmentView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 02.04.23.
//

import SwiftUI

struct NewMediaAlignmentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedMediaItem: MediaItem?
    @State private var markers: String = "marker,0"
    @State private var createButtonDisabled = true
    
    @State var alignmentBase: AlignmentBase
    @State var availableMediaItems: [MediaItem]
    @Binding var isShowingNewMediaAlignmentView: Bool
    
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
            TextEditor(text: $markers).border(Color.gray).frame(minHeight: 200)
            Button("Create", action: createButtonClicked).disabled(createButtonDisabled)
        }
    }
    
    func createButtonClicked() {
        let newMediaAlignment = MediaAlignment(context: viewContext)
        newMediaAlignment.id = UUID()
        newMediaAlignment.alignmentBase = alignmentBase
        newMediaAlignment.mediaItem = selectedMediaItem
        newMediaAlignment.markers = markers
        
        alignmentBase.addToMediaAlignments(newMediaAlignment)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        isShowingNewMediaAlignmentView.toggle()
    }
}

struct NewMediaAlignmentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        
        NewMediaAlignmentView(alignmentBase: AlignmentBase(), availableMediaItems: [], isShowingNewMediaAlignmentView: .constant(true))
            .environment(\.managedObjectContext, viewContext)
    }
}
