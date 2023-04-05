//
//  DisplayAlignmentView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 03.04.23.
//

import SwiftUI
import AVFoundation
import AVKit

func secondsToTimecodeString(time: Double) -> String {
    let seconds = time.truncatingRemainder(dividingBy: Double(60))

    let minutes = (time - seconds).truncatingRemainder(dividingBy: 60*60) / 60
    let hours = (time > 3600) ? (time - seconds - minutes) / (60*60) : 0
    
    return String(format: "%02d:%02d:%02d", Int(hours), Int(minutes), Int(seconds))
}

struct DisplayAlignmentView: View {
    @State var alignmentModel: AlignmentModel
    
    // UI constants
    private var singleSecondWidth: Double = 15
    private var timecodeEveryNSeconds: Double = 5
    
    // State
    @State private var currentMediaItem: MediaItem?
    @State private var currentTime: Double = 0
    @State private var currentMarker: String?
    
    @State private var timeOffset: Double = 0
    @State private var requestedMarker: String?
    @State private var requestedTime: Double?
    
    @State private var player = AVPlayer(url: URL(string: "https://cloud.winterkraut.de/index.php/s/fZGwEmkLs6spiR9/download?path=%2FNono%20(mp4%2C%20DDplus%20JOC)&files=20230305_nono.mp4")!)
    
    var body: some View {
        VStack(spacing: 0) {
            VideoPlayer(player: player).frame(height: 200)
            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    // horizontal scrolling
                    let visibleTimeSpan = size.width / singleSecondWidth
                    let earliestVisibleTime = timeOffset
                    let latestVisibleTime = timeOffset + visibleTimeSpan

                    if currentTime >= latestVisibleTime {
                        timeOffset += visibleTimeSpan
                    }
                    if currentTime < earliestVisibleTime {
                        timeOffset = max(timeOffset - visibleTimeSpan, 0)
                    }

                    context.transform = context.transform.translatedBy(x: 0, y: 45)

                    // Navigation
                    context.draw(Text("CURRENT TIME").foregroundColor(.gray), at: CGPoint(x: 0, y: 0), anchor: .topLeading)
                    context.draw(Text("CURRENT MARKER").foregroundColor(.gray), at: CGPoint(x: size.width/2, y: 0), anchor: .topLeading)
                    context.draw(Text("MARKER MAP").foregroundColor(.gray), at: CGPoint(x: 0, y: 90), anchor: .topLeading)

                    context.draw(Text(secondsToTimecodeString(time: currentTime)).font(.system(size: 25)), at: CGPoint(x: 0, y: 25), anchor: .topLeading)
                    context.draw(Text(currentMarker ?? "-").font(.system(size: 25)), at: CGPoint(x: size.width/2, y: 25), anchor: .topLeading)

                    context.transform = context.transform.translatedBy(x: 10, y: 115)
                    let latestMarkerTime = alignmentModel.allMarkerTimes.last
                    let timecodeDrawingCount: Int = Int((latestMarkerTime! / Double(timecodeEveryNSeconds)).rounded()) + 1
                    for i in 0..<timecodeDrawingCount {
                        context.draw(Text("| " + secondsToTimecodeString(time: Double(i)*timecodeEveryNSeconds)).font(.system(size: 12)).foregroundColor(.gray), at: CGPoint(x: ((Double(i) * timecodeEveryNSeconds) - timeOffset) * singleSecondWidth, y: 0), anchor: .topLeading)
                    }

                    // media item row
                    context.transform = context.transform.translatedBy(x: 0, y: 20)
                    for mediaItem in alignmentModel.allMediaItems {
                        let mediaItemMarkerToMarkerTimes = alignmentModel.markerToMarkerTime[mediaItem]
                        for (marker, time) in (mediaItemMarkerToMarkerTimes ?? [:]) {
                            context.draw(Text("| " + marker).foregroundColor(.gray), at: CGPoint(x: (time - timeOffset) * singleSecondWidth, y: 20), anchor: .topLeading)

                            if currentMarker == marker && currentMediaItem != nil && currentMarker != nil {
                                let alignedMarkerInformation = alignmentModel.calculateAlignedMarkerInformation(sourceMediaItem: currentMediaItem!, marker: currentMarker!, time: currentTime, targetMediaItem: mediaItem)
                                context.draw(Image(systemName: "play"), at: CGPoint(x: (alignedMarkerInformation.targetMarkerTime - timeOffset) * singleSecondWidth, y: 20), anchor: .topLeading)
                            }
                        }

                        context.translateBy(x: 0, y: 50)
                    }
                }.edgesIgnoringSafeArea(.all)
                VStack {
                    Picker("Marker", selection: $requestedMarker) {
                        Text("Jump to").tag(Optional<String>(nil))
                        ForEach(alignmentModel.allMarkers, id: \.self) { marker in
                            Text(marker).tag(Optional(marker)).font(.system(size: 25))
                        }
                    }.pickerStyle(.menu).position(x: 120, y: 110).frame(width: 170, height: 90).onChange(of: requestedMarker) { _ in
                        if requestedMarker == nil {
                            return
                        }
                        setCurrentMarker(newMarker: requestedMarker!)
                        requestedMarker = nil
                    }
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(Array(alignmentModel.allMediaItems.enumerated()), id: \.offset) { idx, mediaItem in
                            Button(action: {
                                setCurrentMediaItem(newMediaItem: mediaItem)
                            }, label: { Text(mediaItem.name!).bold(currentMediaItem == mediaItem) })
                        }
                    }.position(x: 60, y: 115).onChange(of: requestedTime) { _ in
                        if requestedTime == nil {
                            return
                        }
                        setCurrentTime(newCurrentTime: requestedTime!)
                        requestedTime = nil
                    }
                }
            }
        }.onAppear() {
            if currentMediaItem == nil {
                currentMediaItem = alignmentModel.allMediaItems.first
            }
            if currentMediaItem != nil {
                currentMarker = alignmentModel.inferLatestMarker(time: currentTime, mediaItem: currentMediaItem!)
            }
            
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { _ in
                let playerCurrentTimeSeconds = player.currentTime().seconds

                // update currentTime
                currentTime = playerCurrentTimeSeconds
                
                // update currentMarker
                if currentMediaItem != nil {
                    currentMarker = alignmentModel.inferLatestMarker(time: currentTime, mediaItem: currentMediaItem)
                }
            }
        }
    }
    
    init(alignmentModel: AlignmentModel) {
        self.alignmentModel = alignmentModel
    }
    
    func setCurrentTime(newCurrentTime: Double) {
        print("set to \(newCurrentTime)")
        currentTime = newCurrentTime
        
        if player.currentItem != nil {
            player.seek(to: CMTime(seconds: newCurrentTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
    }
    
    func setCurrentMediaItem(newMediaItem: MediaItem) {
        let alignedMarkerInformation = alignmentModel.calculateAlignedMarkerInformation(sourceMediaItem: currentMediaItem!, marker: currentMarker!, time: currentTime, targetMediaItem: newMediaItem)
        
        currentMediaItem = newMediaItem
        requestedTime = alignedMarkerInformation.targetMarkerTime
    }
    
    func setCurrentMarker(newMarker: String) {
        currentMarker = newMarker
    
        setCurrentTime(newCurrentTime: alignmentModel.markerToMarkerTime[currentMediaItem!]![currentMarker!]!)
    }
}

struct DisplayAlignmentView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let alignmentBase = try PersistenceController.preview.container.viewContext.fetch(AlignmentBase.fetchRequest()).last!
            let alignmentModel = AlignmentModel(alignmentBase: alignmentBase)
            
            return AnyView(DisplayAlignmentView(alignmentModel: alignmentModel))
        } catch {
            return AnyView(Text("error"))
        }
    }
}
