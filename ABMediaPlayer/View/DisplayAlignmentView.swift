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
    private let singleSecondWidth: Double = 15
    private let timecodeEveryNSeconds: Double = 5
    
    // State
    @State var currentMediaItem: MediaItem?
    @State var currentTime: Double = 0
    @State var currentMarker: String?
    @State var currentPlayerObserverToken: Any?
    
    @State var requestedMarker: String?
    @State var requestedTime: Double?
    @State var requestedMediaItem: MediaItem?
    
    @State var player = AVPlayer()
    @State var currentMediaItemInfo: String?
    
    @State var avPlayerItemCache: [MediaItem: AVPlayerItem] = [:]
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        VStack {
                            Text("CURRENT TIME").font(.system(size: 12)).foregroundColor(Color.gray)
                            Text(secondsToTimecodeString(time: currentTime)).font(.system(size: 25))
                        }
                        VStack {
                            Text("CURRENT MARKER").font(.system(size: 12)).foregroundColor(Color.gray)
                            Text(currentMarker ?? "-").font(.system(size: 25))
                            MarkerPickerView(alignmentModel: $alignmentModel, requestedMarker: $requestedMarker).onChange(of: requestedMarker) { _ in
                                if requestedMarker == nil {
                                    return
                                }
                                setCurrentMarker(newMarker: requestedMarker!)
                                requestedMarker = nil
                            }.frame(maxWidth: 300).disabled(currentMediaItem == nil)
                        }
                        VStack {
                            Text("CURRENT MEDIA").font(.system(size: 12)).foregroundColor(Color.gray)
                            Text(currentMediaItem?.name ?? "-").font(.system(size: 25))
                            MediaPickerView(alignmentModel: $alignmentModel, requestedMediaItem: $requestedMediaItem).onChange(of: requestedMediaItem) { _ in
                                if requestedMediaItem == nil {
                                    return
                                }
                                setCurrentMediaItem(newMediaItem: requestedMediaItem!)
                                requestedMediaItem = nil
                            }.frame(maxWidth: 300)
                        }
                        VStack {
                            Text("CURRENT MEDIA INFORMATION").font(.system(size: 12)).foregroundColor(Color.gray)
                            Text(currentMediaItemInfo ?? "").font(.system(size: 14))
                        }
                    }.frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func setCurrentTime(newCurrentTime: Double) {
        currentTime = newCurrentTime
        currentMarker = alignmentModel.inferLatestMarker(time: currentTime, mediaItem: currentMediaItem)
        if player.currentItem != nil {
            player.seek(to: CMTime(seconds: newCurrentTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
    }
    
    func setCurrentMediaItem(newMediaItem: MediaItem) {
        if currentMediaItem != nil {
            if currentMediaItem == newMediaItem {
                return
            }
            
            let alignedMarkerInformation = alignmentModel.calculateAlignedMarkerInformation(sourceMediaItem: currentMediaItem!, marker: currentMarker!, time: currentTime, targetMediaItem: newMediaItem)
            
            requestedTime = alignedMarkerInformation.targetMarkerTime
        }
        var newPlayerItem: AVPlayerItem?
        if let cachedItem = avPlayerItemCache[newMediaItem]  {
            newPlayerItem = cachedItem
        } else {
            var isStale = false
            do {
                let url = try URL(resolvingBookmarkData: newMediaItem.bookmarkData!, bookmarkDataIsStale: &isStale)
                if isStale {
                    print("\(url) is stale!")
                }
               
                newPlayerItem = AVPlayerItem(url: url)
                avPlayerItemCache[newMediaItem] = newPlayerItem
            } catch {
                print("Bookmark error \(error)")
            }
        }
        if newPlayerItem != nil {
            switchPlayerItem(newPlayerItem: newPlayerItem!)
            setCurrentTime(newCurrentTime: requestedTime ?? 0)
            
            async {
                do {
                    currentMediaItemInfo = ""
                    
                    let tracks = try await player.currentItem!.asset.load(.tracks)
                    
                    for track in tracks {
                        let formatDescriptions = try await track.load(.formatDescriptions)
                        currentMediaItemInfo! += formatDescriptions.debugDescription
                    }
                } catch {
                    print("ERROR")
                }
            }
        } else {
            print("ERROR")
        }
        
        currentMediaItem = newMediaItem
    }
    
    func switchPlayerItem(newPlayerItem: AVPlayerItem) {
        player.replaceCurrentItem(with: newPlayerItem)
        player.play()
        
        if currentPlayerObserverToken == nil {
            currentPlayerObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { _ in
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
