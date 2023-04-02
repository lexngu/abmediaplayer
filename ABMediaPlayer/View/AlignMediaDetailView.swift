//
//  AlignMediaDetailView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import SwiftUI

struct AlignMediaDetailView: View {
    let mediaAlignmentItem: MediaAlignmentItem
    @State private var selectedAlignmentBaseName: String = ""
    
    var body: some View {
        VStack {
            Picker("Alignment Base", selection: $selectedAlignmentBaseName) {
                ForEach(Array(mediaAlignmentItem.alignmentBases.keys), id: \.self) { baseName in
                    Text(baseName)
                }
            }
            if selectedAlignmentBaseName != "" {
                let alignmentPoints = mediaAlignmentItem.alignmentBases[selectedAlignmentBaseName]
                ScrollView(.horizontal) {
                    ZStack(alignment: .bottomLeading) {
                        ForEach(0..<10) {
                            Text("Alignment #\($0)")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .frame(width: 200, height: 100)
                                .background(.red)
                                .offset(x: CGFloat($0) * 205)
                        }
                    }.frame(width: 2050, height: 100)
                }
            } else {
                Text("Choose an alignment base")
            }
        }.padding(.bottom)
    }
}

struct AlignMediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let alignmentBaseName = "Memory Location"
        let alignmentBases = [
            alignmentBaseName: ["1a", "1b", "1c"]
        ]
        let mediaUUID = UUID()
        let alignments: [UUID: [String: [String: Float]]] = [
            mediaUUID: [alignmentBaseName: ["1a": 0, "1b": 1.5, "1c": 4]]
        ]
        
        let mediaAlignmentItem = MediaAlignmentItem(name: "Nono Project", alignmentBases: alignmentBases, alignments: alignments)
        
        
        AlignMediaDetailView(mediaAlignmentItem: mediaAlignmentItem)
    }
}
