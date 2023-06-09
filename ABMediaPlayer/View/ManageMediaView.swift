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
        VStack {
            Button { fileImporterIsShowing.toggle() }
            label: {
                Label("Add local media", systemImage: "doc.badge.plus")
            }.fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [UTType.audiovisualContent], onCompletion: fileImporterCompleted)
            List {
                ForEach(availableMediaItems) { item in
                    NavigationLink(item.name!, value: Route.mediaMode(item))
                }.onDelete(perform: onDeleteMediaItem)
            }
        }
    }
    
    func onDeleteMediaItem(indexSet: IndexSet) {
        for index in indexSet {
            viewContext.delete(availableMediaItems[index])
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
        NavigationStack {
            ManageMediaView()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .mediaMode(let mediaItem):
                    ManageMediaSingleItemView(mediaItem: mediaItem)
                default:
                    Text("ERROR")
                }
            }
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
