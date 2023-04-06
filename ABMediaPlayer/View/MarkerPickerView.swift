//
//  MarkerPickerView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 05.04.23.
//

import SwiftUI

struct MarkerPickerView: View {
    
    @Binding var alignmentModel: AlignmentModel
    @Binding var requestedMarker: String?
    
    var body: some View {
        Picker("Marker", selection: $requestedMarker) {
            Text("Jump to").tag(Optional<String>(nil))
            ForEach(alignmentModel.allMarkers, id: \.self) { marker in
                Text(marker).tag(Optional(marker)).font(.system(size: 25))
            }
        }.pickerStyle(.menu)
    }
}

struct MarkerPickerView_Previews: PreviewProvider {
    
    static var previews: some View {
        do {
            let alignmentBase = try PersistenceController.preview.container.viewContext.fetch(AlignmentBase.fetchRequest()).last!
            let alignmentModel = AlignmentModel(alignmentBase: alignmentBase)
            
            return AnyView(MarkerPickerView(alignmentModel: .constant(alignmentModel), requestedMarker: .constant(Optional<String>(nil))))
        } catch {
            return AnyView(Text("error"))
        }
    }
}
