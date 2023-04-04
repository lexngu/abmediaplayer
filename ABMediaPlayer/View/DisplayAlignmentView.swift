//
//  DisplayAlignmentView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 03.04.23.
//

import SwiftUI
import AVFoundation
import AVKit

func secondsToTimecodeString(time: Float) -> String {
    let seconds = time.truncatingRemainder(dividingBy: 60)
    let minutes = (time - seconds).truncatingRemainder(dividingBy: 60*60) / 60
    let hours = (time > 3600) ? (time - seconds - minutes) / (60*60) : 0
    
    return String(format: "%02d:%02d:%02d", Int(hours), Int(minutes), Int(seconds))
}

struct DisplayAlignmentView: View {
    
    @State var alignmentBase: AlignmentBase
    private var alignmentModel: AlignmentModel
    
    // UI
    @State private var singleSecondWidth: Double = 15
    @State private var timecodeEveryNSeconds: Int = 5
    
    // State
    @State private var currentTime: Float = 15
    @State private var currentMediaItem: MediaItem?
    @State private var currentMarker: String?
    @State private var timeOffset: Float = 0
    
    private var player = AVPlayer(url: URL(string: "https://cloud.winterkraut.de/index.php/s/fZGwEmkLs6spiR9/download?path=%2FNono%20(mp4%2C%20DDplus%20JOC)&files=20230305_nono.mp4")!)
        
    var body: some View {
//        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 2, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { _ in
//            currentTime = Float(player.currentTime().seconds)
//        }
        return ZStack(alignment: .topLeading) {
            Canvas { context, size in
                // init
                if currentMediaItem == nil {
                    currentMediaItem = alignmentModel.allMediaItems.first
                }
                if currentMediaItem != nil {
                    currentMarker = alignmentModel.latestMarker(time: currentTime, mediaItem: currentMediaItem!)
                }
                
                // horizontal scrolling
                let visibleTimeSpan = Float(size.width / singleSecondWidth)
                let earliestVisibleTime = timeOffset
                let latestVisibleTime = timeOffset + visibleTimeSpan
               
                if currentTime >= latestVisibleTime {
                    timeOffset += visibleTimeSpan
                }
                if currentTime < earliestVisibleTime {
                    timeOffset = max(timeOffset - visibleTimeSpan, 0)
                }
                
                context.transform = context.transform.translatedBy(x: 0, y: 100)
                
                // Navigation
                context.draw(Text("CURRENT TIME").foregroundColor(.gray), at: CGPoint(x: 0, y: 0), anchor: .topLeading)
                context.draw(Text("CURRENT MARKER").foregroundColor(.gray), at: CGPoint(x: size.width/2, y: 0), anchor: .topLeading)
                context.draw(Text("MARKER MAP").foregroundColor(.gray), at: CGPoint(x: 0, y: 90), anchor: .topLeading)
                
                context.draw(Text(secondsToTimecodeString(time: currentTime)).font(.system(size: 25)), at: CGPoint(x: 0, y: 25), anchor: .topLeading)
                context.draw(Text(currentMarker ?? "-").font(.system(size: 25)), at: CGPoint(x: size.width/2, y: 25), anchor: .topLeading)
                
                context.transform = context.transform.translatedBy(x: 10, y: 115)
                let latestMarkerTime = alignmentModel.allMarkerTimes.last
                let timecodeDrawingCount: Int = Int((latestMarkerTime! / Float(timecodeEveryNSeconds)).rounded()) + 1
                for i in 0..<timecodeDrawingCount {
                    context.draw(Text("| " + secondsToTimecodeString(time: Float(i*timecodeEveryNSeconds))).font(.system(size: 12)).foregroundColor(.gray), at: CGPoint(x: Double(Float(i * timecodeEveryNSeconds) - timeOffset) * singleSecondWidth, y: 0), anchor: .topLeading)
                }
                
                // media item row
                context.transform = context.transform.translatedBy(x: 0, y: 20)
                for mediaItem in alignmentModel.allMediaItems {
                    let mediaItemMarkerToMarkerTimes = alignmentModel.markerToMarkerTime[mediaItem]
                    for (marker, time) in mediaItemMarkerToMarkerTimes! {
                        context.draw(Text("| " + marker).foregroundColor(.gray), at: CGPoint(x: Double(time - timeOffset) * singleSecondWidth, y: 20), anchor: .topLeading)
                        
                        if currentMarker == marker {
                            let progress = alignmentModel.alignedMarkerProgress(sourceMediaItem: currentMediaItem!, marker: currentMarker!, time: currentTime, targetMediaItem: mediaItem)
                            context.draw(Image(systemName: "play"), at: CGPoint(x: Double(progress.targetMarkerTime - timeOffset) * singleSecondWidth, y: 20), anchor: .topLeading)
                        }
                    }
                    
                    
                    context.translateBy(x: 0, y: 50)
                }
            }.edgesIgnoringSafeArea(.all)
//            VideoPlayer(player: player)
            VStack {
                HStack {
                    Button(action: { currentTime = max(0, currentTime - 10) }, label: { Image(systemName: "gobackward.10") })
                    Button(action: { currentTime = max(0, currentTime + 10) }, label: { Image(systemName: "goforward.10") })
                }.position(x: 40, y: 108).frame(width: 100, height: 170)
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(Array(alignmentModel.allMediaItems.enumerated()), id: \.offset) { idx, mediaItem in
                        Button(action: {
                            setCurrentMediaItem(newMediaItem: mediaItem)
                        }, label: { Text(mediaItem.name!).bold(currentMediaItem == mediaItem) })
                    }
                }.padding([.leading], 10)
                Spacer()
            }
        }
    }
    
    init(alignmentBase: AlignmentBase, alignmentModel: AlignmentModel) {
        self.alignmentBase = alignmentBase
        self.alignmentModel = alignmentModel
    }
    
    func setCurrentMediaItem(newMediaItem: MediaItem) {
        let alignedMarkerInformation = alignmentModel.alignedMarkerProgress(sourceMediaItem: currentMediaItem!, marker: currentMarker!, time: currentTime, targetMediaItem: newMediaItem)

        currentMediaItem = newMediaItem
        currentTime = alignedMarkerInformation.targetMarkerTime
    }
}

struct DisplayAlignmentView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let alignmentBase = try PersistenceController.preview.container.viewContext.fetch(AlignmentBase.fetchRequest()).last!
            return AnyView(DisplayAlignmentView(alignmentBase: alignmentBase, alignmentModel: AlignmentModel(alignmentBase: alignmentBase)))
        } catch {
            return AnyView(Text("error"))
        }
    }
}
