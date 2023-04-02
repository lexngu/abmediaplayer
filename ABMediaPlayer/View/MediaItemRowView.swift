//
//  MediaItemRowView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 27.03.23.
//

import SwiftUI

/**
 * Format bytes as human-readable text.
 * Source: https://stackoverflow.com/questions/10420352/converting-file-size-in-bytes-to-human-readable-string
 *
 * @param bytes Number of bytes.
 * @param si True to use metric (SI) units, aka powers of 1000. False to use
 *           binary (IEC), aka powers of 1024.
 * @param dp Number of decimal places to display.
 *
 * @return Formatted string.
 */
func humanFileSize(bytes: Int, dp: Int = 1) -> String {
    let units = ["kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
    let thresh: Float = 1000
    let pow10Dp: Float = pow(Float(10), Float(dp))
    var bytes = Float(bytes)

    if (bytes < thresh) {
        return String(bytes) + "B";
    }
    
    var u = -1
    let r = pow10Dp
    repeat {
        bytes /= thresh;
        u += 1
    } while round(bytes * r) / r >= thresh && u < units.count - 1
    return String(round(bytes * pow10Dp) / pow10Dp) + " " + units[u];
}

func humanDuration(duration: Float) -> String {
    if (duration < 60) {
        return String(round(duration)) + "s"
    }
    let duration = round(duration) // remove nanoseconds
    let seconds = duration.truncatingRemainder(dividingBy: 60)
    let minutes = (duration - seconds).truncatingRemainder(dividingBy: 60*60) / 60
    let hours = (duration > 3600) ? (duration - seconds - minutes) / (60*60) : 0
    
    return String(format: "%02d:%02d:%02d", Int(hours), Int(minutes), Int(seconds))
}

struct MediaItemRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var mediaItem: MediaItem
    
    var body: some View {
        VStack {
            Text(mediaItem.name!)
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
//            HStack {
//                Image(systemName: "clock")
//                Text(humanDuration(duration: mediaItem.duration))
//                Image(systemName: "doc")
//                Text(humanFileSize(bytes: Int(mediaItem.size)))
//            }.frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 12))
        }
    }
}

struct MediaItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let mediaItem = MediaItem(context: viewContext)
        mediaItem.name = "20230305_nono.mp4"
        mediaItem.size = 268343715
        mediaItem.format = "MPEG-4"
        mediaItem.duration = 2049.183
        
        return MediaItemRowView(mediaItem: mediaItem).environment(\.managedObjectContext, viewContext)
    }
}
