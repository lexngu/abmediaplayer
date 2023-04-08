//
//  PlayMediaAlignmentView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 03.04.23.
//

import SwiftUI

struct PlayMediaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var navigationPath: NavigationPath
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AlignmentBase.name, ascending: true)])
    private var availableAlignmentBases: FetchedResults<AlignmentBase>
         
    var body: some View {
        List(availableAlignmentBases) { alignmentBase in
            NavigationLink(alignmentBase.name!, value: Route.playMode(alignmentBase)).environment(\.managedObjectContext, viewContext)
        }
    }
}

struct PlayMediaView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewContext = PersistenceController.preview.container.viewContext
        
        NavigationStack {
            PlayMediaView(navigationPath: .constant(NavigationPath()))
                .environment(\.managedObjectContext, viewContext)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .playMode(let alignmentBase):
                        DisplayAlignmentView(alignmentModel: AlignmentModel(alignmentBase: alignmentBase))
                    default:
                        Text("ERROR")
                    }
                }
        }
    }
}
