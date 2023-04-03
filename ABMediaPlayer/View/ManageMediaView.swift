//
//  ManageMediaView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

struct ManageMediaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MediaItem.name, ascending: true)])
    private var availableMediaItems: FetchedResults<MediaItem>
    
    @State private var fileImporterIsShowing = false
    
    var body: some View {
        NavigationView {
            List {
                Button
                { fileImporterIsShowing.toggle() }
            label: {
                Label("Add local media", systemImage: "doc.badge.plus")
            }.fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [UTType.audiovisualContent], onCompletion: fileImporterCompleted)
                ForEach(availableMediaItems) { item in
                    NavigationLink {
                        ManageMediaSingleItemView(mediaItem: item).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    } label: {
                        MediaItemRowView(mediaItem: item)
                    }
                }.onDelete(perform: deleteLocalMediaItem)
            }
        }
    }
    
    func fileImporterCompleted(result: Result<URL, Error>) {
        switch result {
        case .success(let fileUrl):
            guard fileUrl.startAccessingSecurityScopedResource() else {
                return
            }
            defer { fileUrl.stopAccessingSecurityScopedResource() }
            
            let newMediaItem = MediaItem(context: viewContext)
            newMediaItem.id = UUID()
            newMediaItem.name = fileUrl.lastPathComponent
            newMediaItem.size = 0
            newMediaItem.format = ""
            newMediaItem.duration = 0
            do {
                newMediaItem.bookmarkData = try fileUrl.bookmarkData()
            } catch {
                print("fileImporterCompleted: Bookmark error \(error)")
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        case .failure(let error):
            print(error)
        }
    }
    
    func deleteLocalMediaItem(offsets: IndexSet) {
        offsets.map { availableMediaItems[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ManageMediaView_Previews: PreviewProvider {
    static var previews: some View {
        ManageMediaView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
