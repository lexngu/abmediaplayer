//
//  AlignmentModel.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 03.04.23.
//

import Foundation

struct AlignedMarkerInformation  {
    var sourceMediaItem: MediaItem
    var targetMediaItem: MediaItem
    
    var sourceMarkerTimeUntilNextMarker: Float
    var sourceMarkerTime: Float
    
    var targetMarkerTimeUntilNextMarker: Float
    var targetMarkerTime: Float
    
    var markerProgressPercentage: Float
}

class AlignmentModel {
    private var alignmentBase: AlignmentBase
    
    let allMarkers: [String]
    let allMarkerTimes: [Float]
    let allMediaItems: [MediaItem]
    
    let markerToMarkerTime: [MediaItem: [String: Float]]
    
    var horizontalScalingFactor: Float = 1.0
    
    init(alignmentBase: AlignmentBase) {
        self.alignmentBase = alignmentBase
        let mediaAlignments = alignmentBase.mediaAlignments?.sortedArray(using: [NSSortDescriptor(keyPath: \MediaAlignment.objectID, ascending: true)]) as! [MediaAlignment]
        
        allMarkers = alignmentBase.markers?.components(separatedBy: "\n") ?? []
        
        allMediaItems = mediaAlignments.map {i in i.mediaItem!}
        
        var mtmt: [MediaItem: [String: Float]] = [:]
        for ma in mediaAlignments {
            var _markerToMarkerTime: [String: Float] = [:]
            let maMarkers = ma.markers!.components(separatedBy: "\n")
            for maMarker in maMarkers {
                let markerAndTime = maMarker.components(separatedBy: ",")
                let marker = markerAndTime[0]
                let time = Float(markerAndTime[1])
                _markerToMarkerTime[marker] = time
            }
            mtmt[ma.mediaItem!] = _markerToMarkerTime
        }
        markerToMarkerTime = mtmt
        
        var _allMarkerTimes: Set<Float> = Set()
        for mtmtEntry in markerToMarkerTime {
            for time in Array(mtmtEntry.value.values) {
                _allMarkerTimes.insert(time)
            }
        }
        allMarkerTimes = Array(_allMarkerTimes).sorted()
    }
    
    func latestMarker(time: Float, mediaItem: MediaItem) -> String? {
        if markerToMarkerTime[mediaItem] == nil {
            print("error in function latestMarker!")
            return nil
        }
        let miMarkerToTime = markerToMarkerTime[mediaItem]!
        
        if time <= 0 {
            return miMarkerToTime.keys.first!
        }
        
        var latestMarkerIdx = 0
        for (idx, (_, _time)) in miMarkerToTime.enumerated() {
            if _time > time {
                latestMarkerIdx = idx - 1
                break
            }
            latestMarkerIdx = idx
        }
        return Array(miMarkerToTime.keys)[latestMarkerIdx]
    }
    
    func alignedMarkerProgress(sourceMediaItem: MediaItem, marker: String, time: Float, targetMediaItem: MediaItem) -> AlignedMarkerInformation {
        var result = AlignedMarkerInformation(sourceMediaItem: sourceMediaItem, targetMediaItem: targetMediaItem, sourceMarkerTimeUntilNextMarker: 0, sourceMarkerTime: time, targetMarkerTimeUntilNextMarker: 0, targetMarkerTime: 0, markerProgressPercentage: 0)
        
        if markerToMarkerTime[sourceMediaItem] == nil || markerToMarkerTime[targetMediaItem] == nil {
            print("error in function alignedMarkerProgress!")
            return result
        }
        
        let smiMarkerToTime = markerToMarkerTime[sourceMediaItem]!
        let tmiMarkerToTime = markerToMarkerTime[targetMediaItem]!
        
        let smiStartMarkerIndex = smiMarkerToTime.keys.firstIndex(of: marker)!
        let smiStartMarkerTime: Float = smiMarkerToTime[marker]!
        let tmiStartMarkerTime: Float = tmiMarkerToTime[marker]!
        
        var smiNextMarkerTime, tmiNextMarkerTime: Float
        let smiNextMarkerIndex = smiMarkerToTime.keys.index(after: smiStartMarkerIndex)
        if smiNextMarkerIndex < smiMarkerToTime.endIndex {
            let nextMarker: String = smiMarkerToTime.keys[smiNextMarkerIndex]
            
            smiNextMarkerTime = smiMarkerToTime[nextMarker] ?? sourceMediaItem.duration
            tmiNextMarkerTime = tmiMarkerToTime[nextMarker] ?? targetMediaItem.duration
        } else {
            smiNextMarkerTime = sourceMediaItem.duration
            tmiNextMarkerTime = targetMediaItem.duration
        }
        
        result.sourceMarkerTimeUntilNextMarker = smiNextMarkerTime - smiStartMarkerTime
        result.markerProgressPercentage = max(0, (result.sourceMarkerTime - smiStartMarkerTime) / result.sourceMarkerTimeUntilNextMarker)
        
        result.targetMarkerTimeUntilNextMarker = tmiNextMarkerTime - tmiStartMarkerTime
        result.targetMarkerTime = (result.markerProgressPercentage * result.targetMarkerTimeUntilNextMarker) + tmiStartMarkerTime
        
        return result
    }
}
