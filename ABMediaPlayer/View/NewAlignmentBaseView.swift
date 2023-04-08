//
//  NewAlignmentBaseView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 02.04.23.
//

import SwiftUI

struct NewAlignmentBaseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name = ""
    @State private var markers = "marker,0"
    @Binding var isShowingNewAlignmentBaseView : Bool;
    
    var body: some View {
        List {
            Form {
                TextField(text: $name, prompt: Text("Name")) {
                    Text("Name")
                }
                TextEditor(text: $markers).border(Color.gray)
                Button("Create", action: createButtonClicked)
            }
        }
    }
    
    func createButtonClicked() {
        let newAlignmentBase = AlignmentBase(context: viewContext)
        newAlignmentBase.id = UUID()
        newAlignmentBase.name = name
        newAlignmentBase.markers = markers
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        isShowingNewAlignmentBaseView.toggle()
    }
}

struct NewAlignmentBaseView_Previews: PreviewProvider {
        
    static var previews: some View {
        NewAlignmentBaseView(isShowingNewAlignmentBaseView: .constant(true))
    }
}
