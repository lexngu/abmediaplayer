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
    
    @Binding var navigationPath: NavigationPath
    
    @State private var isShowingNewAlignmentBaseView = false
        
    var body: some View {
        Button { isShowingNewAlignmentBaseView.toggle() } label: {
            Label("Add alignment base", systemImage: "plus")
        }.sheet(isPresented: $isShowingNewAlignmentBaseView) {
            NewAlignmentBaseView(isShowingNewAlignmentBaseView: $isShowingNewAlignmentBaseView).frame(minWidth: 200, minHeight: 200)
        }
        List(availableAlignmentBases) { item in
            NavigationLink(item.name!, value: Route.alignMode(item))
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
        NavigationStack {
            ManageAlignmentBaseView(navigationPath: .constant(NavigationPath()))
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .alignMode(let alignmentBase):
                        ManageAlignmentBaseDetailView(alignmentBase: alignmentBase)
                    default:
                        Text("ERROR")
                    }
                }
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
