//
//  PlayMediaAlignmentView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 03.04.23.
//

import SwiftUI

struct PlayMediaView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AlignmentBase.name, ascending: true)])
    private var availableAlignmentBases: FetchedResults<AlignmentBase>
 
    @State private var selectedAlignmentBase: AlignmentBase?
    
    var body: some View {
        VStack {
            Text("Player")
            Picker("Alignment base", selection: $selectedAlignmentBase) {
                Text("Choose alignment base").tag(Optional<AlignmentBase>(nil))
                ForEach(availableAlignmentBases) { item in
                    Text(item.name!).tag(Optional(item))
                }
            }
        }
    }
}

struct PlayMediaAlignmentView_Previews: PreviewProvider {
    static var previews: some View {
        PlayMediaView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
