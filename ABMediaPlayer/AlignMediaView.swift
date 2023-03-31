//
//  AlignMediaView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI

struct AlignMediaView: View {
    var availableMediaAlignmentItems: [MediaAlignmentItem]
    
    var body: some View {
        List(availableMediaAlignmentItems) { item in
            Text(item.name)
        }
    }
}

struct AlignMediaView_Previews: PreviewProvider {
    static var previews: some View {
        let alignmentBaseName = "Memory Location"
        let alignmentBases = [
            alignmentBaseName: ["1a", "1b", "1c"]
        ]
        let mediaUUID = UUID()
        let alignments: [UUID: [String: [String: Float]]] = [
            mediaUUID: [alignmentBaseName: ["1a": 0, "1b": 1.5, "1c": 4]]
        ]
        
        let availableMediaAlignmentItems = [
            MediaAlignmentItem(name: "Nono Project", alignmentBases: alignmentBases, alignments: alignments)
        ]
        AlignMediaView(availableMediaAlignmentItems: availableMediaAlignmentItems)
    }
}
