//
//  MediaRow.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 11.03.23.
//

import SwiftUI
import AVKit

struct MediaRow: View {
    
    @State private var currentPlayer : AVPlayer
    @State private var currentItem : AVPlayerItem
    @State private var loopStartTime : CMTime = CMTime.invalid
    @State private var loopEndTime : CMTime = CMTime.invalid
    
    private var playerA, playerB : AVPlayer
    private var itemA, itemB : AVPlayerItem
    
    init() {
        itemA = AVPlayerItem(url: URL(string: "https://cloud.winterkraut.de/index.php/s/wWkxqjEpAfmoYDR/download?path=&files=mediaA.mp4")!)
        
        itemB = AVPlayerItem(url: URL(string: "https://cloud.winterkraut.de/index.php/s/wWkxqjEpAfmoYDR/download?path=&files=mediaB.mp4")!)
        
        playerA = AVPlayer()
        playerB = AVPlayer()
        playerA.sourceClock = playerB.sourceClock
        
        _currentPlayer = State(initialValue: playerA)
        _currentItem = State(initialValue: itemA)
    }
    
    var body: some View {
        VStack {
            VideoPlayer(player: currentPlayer)
                .frame(width: 300   , height: 200, alignment: .center)
            Text("Currently listening to " + ((currentItem.asset as? AVURLAsset)?.url.absoluteString)!)
            Spacer()
            Button("Play/Pause", action: togglePlaybackButtonClicked)
            Button("Switch", action: switchButtonClicked)
            Button("Loop: Start", action: loopStart)
            Button("Loop: End", action: loopEnd)
        }.buttonStyle(.borderedProminent)
    }
    
    func checkLoop() {
        if (loopEndTime.isValid && loopStartTime.isValid) {
            if (currentPlayer.timeControlStatus == .playing) {
                if (currentPlayer.currentTime() >= loopEndTime) {
                    currentPlayer.seek(to: loopStartTime)
                }
            }
        }
    }
    
    func togglePlaybackButtonClicked() {
        if (currentPlayer.timeControlStatus == .paused) {
            currentPlayer.replaceCurrentItem(with: itemA)
            currentPlayer.play()
            loopStartTime = currentPlayer.currentTime()
        } else {
            currentPlayer.pause()
            loopStartTime = CMTime.invalid
            loopEndTime = CMTime.invalid
        }
    }
    
    func loopStart() {
        loopStartTime = currentPlayer.currentTime()
        loopEndTime = CMTime.invalid
        
        var loopCheckInterval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerA.addPeriodicTimeObserver(forInterval: loopCheckInterval, queue: .main, using: {(time) in checkLoop()})
        playerB.addPeriodicTimeObserver(forInterval: loopCheckInterval, queue: .main, using: {(time) in checkLoop()})
    }
    
    func loopEnd() {
        if (loopEndTime == CMTime.invalid) {
            loopEndTime = currentPlayer.currentTime()
        } else {
            loopStartTime = CMTime.invalid
            loopEndTime = CMTime.invalid
        }
    }
    
    
    func switchButtonClicked() {
        let newItem : AVPlayerItem
        if (currentItem == itemA) {
            newItem = itemB
        } else {
            newItem = itemA
        }
        
        let newPlayer : AVPlayer
        if (currentPlayer == playerA) {
            newPlayer = playerB
        } else {
            newPlayer = playerA
        }
        
        newPlayer.replaceCurrentItem(with: newItem)
        let currentTime = currentPlayer.currentTime()
        if (currentTime.isValid) {
            newPlayer.seek(to: currentPlayer.currentTime())
        }
        newPlayer.play()
        currentPlayer.pause()
        currentPlayer = newPlayer
        currentItem = newItem
    }
}

struct MediaRow_Previews: PreviewProvider {
    static var previews: some View {
        MediaRow()
    }
}
