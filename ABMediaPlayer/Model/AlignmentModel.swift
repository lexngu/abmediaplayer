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

class AlignmentModel: ObservableObject {
    private var alignmentBase: AlignmentBase
    
    let allMarkers: [String]
    let allMarkerTimes: [Float]
    let allMediaItems: [MediaItem]
    
    let markerToMarkerTime: [MediaItem: [String: Float]]
    
    init(alignmentBase: AlignmentBase) {
        self.alignmentBase = alignmentBase
        
        let mediaAlignments = alignmentBase.mediaAlignments?.sortedArray(using: [NSSortDescriptor(keyPath: \MediaAlignment.objectID, ascending: true)]) as! [MediaAlignment]
        allMarkers = alignmentBase.markers?.components(separatedBy: "\n") ?? []
        allMediaItems = mediaAlignments.map {o in o.mediaItem!}.sorted { $0.name! < $1.name! }
        
        // Plausibility checks
        if mediaAlignments.count == 0 {
            print("Warning! Media alignment count should not be zero!")
        }
        if allMarkers.count == 0 {
            print("Warning! Marker count should not be zero!")
        }
        if allMediaItems.count == 0 {
            print("Warning! Media item count should not be zero!")
        }
        
        markerToMarkerTime = AlignmentModel.buildMarkerToMarkerTime(mediaAlignments: mediaAlignments)
        allMarkerTimes = AlignmentModel.buildAllMarkerTimes(markerToMarkerTime: markerToMarkerTime)
        
    }
    
    private static func buildMarkerToMarkerTime(mediaAlignments: [MediaAlignment]) -> [MediaItem: [String: Float]] {
        var result: [MediaItem: [String: Float]] = [:]
        var expectedMarkerCount: Int?
        
        for ma in mediaAlignments {
            var _markerToMarkerTime: [String: Float] = [:]
            
            let maMarkers = ma.markers!.components(separatedBy: "\n")
            expectedMarkerCount = expectedMarkerCount ?? maMarkers.count
            if expectedMarkerCount != maMarkers.count {
                print("Warning! Markers count differ!")
            }
            for maMarker in maMarkers {
                let markerAndTime = maMarker.components(separatedBy: ",")
                let marker = markerAndTime[0]
                let time = Float(markerAndTime[1])
                
                _markerToMarkerTime[marker] = time
            }

            result[ma.mediaItem!] = _markerToMarkerTime
        }
        
        return result
    }
    
    private static func buildAllMarkerTimes(markerToMarkerTime: [MediaItem: [String: Float]]) -> [Float] {
        var _allMarkerTimes: Set<Float> = Set()
        
        for mtmtEntry in markerToMarkerTime {
            for time in Array(mtmtEntry.value.values) {
                _allMarkerTimes.insert(time)
            }
        }
        
        return Array(_allMarkerTimes).sorted()
    }
    
    func inferLatestMarker(time: Float, mediaItem: MediaItem) -> String? {
        if markerToMarkerTime[mediaItem] == nil {
            print("Error! Marker information requested for a non-existing mediaItem!")
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
    
    func calculateAlignedMarkerInformation(sourceMediaItem: MediaItem, marker: String, time: Float, targetMediaItem: MediaItem) -> AlignedMarkerInformation {
        var result = AlignedMarkerInformation(sourceMediaItem: sourceMediaItem, targetMediaItem: targetMediaItem, sourceMarkerTimeUntilNextMarker: 0, sourceMarkerTime: time, targetMarkerTimeUntilNextMarker: 0, targetMarkerTime: 0, markerProgressPercentage: 0)
        
        let markerIndex = allMarkers.firstIndex(of: marker)
        if markerIndex == nil {
            print("Error! Marker does not exist!")
            return result
        }
        let nextMarkerIndex = allMarkers.index(after: markerIndex!)

        if markerToMarkerTime[sourceMediaItem] == nil || markerToMarkerTime[targetMediaItem] == nil {
            print("Error! sourceMediaItem or targetMediaItem is nil!")
            return result
        }
        let smiMarkerToTime = markerToMarkerTime[sourceMediaItem]!
        let tmiMarkerToTime = markerToMarkerTime[targetMediaItem]!
        let smiStartMarkerTime: Float = smiMarkerToTime[marker]!
        let tmiStartMarkerTime: Float = tmiMarkerToTime[marker]!
        
        var smiNextMarkerTime, tmiNextMarkerTime: Float
        if nextMarkerIndex < allMarkers.endIndex { // time of next marker - or else time at end of media item (= duration)
            let nextMarker: String = allMarkers[nextMarkerIndex]
            
            smiNextMarkerTime = smiMarkerToTime[nextMarker]!
            tmiNextMarkerTime = tmiMarkerToTime[nextMarker]!
        } else {
            smiNextMarkerTime = sourceMediaItem.duration
            tmiNextMarkerTime = targetMediaItem.duration
        }
        
        result.sourceMarkerTimeUntilNextMarker = smiNextMarkerTime - smiStartMarkerTime
        result.targetMarkerTimeUntilNextMarker = tmiNextMarkerTime - tmiStartMarkerTime
        result.markerProgressPercentage = max(0, (result.sourceMarkerTime - smiStartMarkerTime) / result.sourceMarkerTimeUntilNextMarker)
        result.targetMarkerTime = (result.markerProgressPercentage * result.targetMarkerTimeUntilNextMarker) + tmiStartMarkerTime
        
        return result
    }
}
