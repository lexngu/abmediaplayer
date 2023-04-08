//
//  MediaPickerView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 06.04.23.
//

import SwiftUI

struct MediaPickerView: View {
    
    @Binding var alignmentModel: AlignmentModel
    @Binding var requestedMediaItem: MediaItem?
    
    var body: some View {
        Picker("", selection: $requestedMediaItem) {
            Text("Change to").tag(Optional<MediaItem>(nil))
            ForEach(alignmentModel.allMediaItems) { mediaItem in
                Text(mediaItem.name ?? "NA").tag(Optional(mediaItem)).font(.system(size: 25))
            }
        }.pickerStyle(.menu)
    }
}

struct MediaPickerView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let alignmentBase = try PersistenceController.preview.container.viewContext.fetch(AlignmentBase.fetchRequest()).last!
            let alignmentModel = AlignmentModel(alignmentBase: alignmentBase)
            
            return AnyView(MediaPickerView(alignmentModel: .constant(alignmentModel), requestedMediaItem: .constant(Optional<MediaItem>(nil))))
        } catch {
            return AnyView(Text("error"))
        }
        
    }
}
