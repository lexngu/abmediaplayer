//
//  MediaAlignmentItem.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 21.03.23.
//

import Foundation

struct MediaAlignmentItem: Identifiable {
    let id = UUID()
    var name: String
       
    var alignmentBases: [String: [String]] /* alignmentBaseName: [alignmentPoints] */
    
    var alignments: [UUID: [String: [String: Float]]] /* mediaItemId: [alignmentBaseName: [alignmentPoint: mediaTime]] */
}
