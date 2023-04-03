//
//  AlignMediaView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI

struct ManageAlignmentBaseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AlignmentBase.name, ascending: true)])
    private var availableAlignmentBases: FetchedResults<AlignmentBase>
    
    @State private var isShowingNewAlignmentBaseView = false
    
    var body: some View {
        NavigationStack {
            List {
                Button { isShowingNewAlignmentBaseView.toggle() } label: {
                    Label("Add alignment base", systemImage: "plus")
                }.sheet(isPresented: $isShowingNewAlignmentBaseView) {
                    NewAlignmentBaseView(isShowingNewAlignmentBaseView: $isShowingNewAlignmentBaseView)
                }
                ForEach(availableAlignmentBases) { item in
                    NavigationLink(destination: ManageAlignmentBaseDetailView(alignmentBase: item)) { Text(item.name!) }
                }.onDelete(perform: deleteAlignmentBase)
            }
            .navigationTitle("Alignments")
        }
    }
    
    func deleteAlignmentBase(offsets: IndexSet) {
        offsets.map { availableAlignmentBases[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AlignMediaView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAlignmentBaseView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
