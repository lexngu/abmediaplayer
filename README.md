# ABMediaPlayer
The ABMediaPlayer is a iOS/macOS application. It aims to facilitate the comparison of audio-visual media files, which represent the same musical idea/composition but differ with respect to their absolute timings (for instance, due to differing interpretations). It provides means to fastly jump to specified marker positions (e.g. rehearsal marks, measure numbers), and to change between aligned media items while keeping the relative playback progress between two adjacent marker positions.

This application is written in Swift, mainly relying on the  framework SwiftUI. Unfortunately, the minimum required version of the device's operating system is: macOS 13.0+ and iOS 16.0+, respectively.

The software code is to be seen as some kind of preliminary sketch. 

# Usage
1. Import media item(s).
2. Create "alignment base": Specify a name, and a list of markers. The list is to be formatted as a multi-line text with one single marker per line. No marker must contain a comma character (,). For example: "Nono Project" as name, and (replace ", " with line breaks) "1a, 2a, 3a, 2d, 3c, 4a, 5a, 4c, 6a, 5b, 4e, 5c, 4f, 5d, 7a, 8a, 7b, (6f), 9a, 6h, 8c, 9d, 7c, 10a, 11a, 12a".
3. After having an alignment base created, open it and add a "media alignment" for each media item. Select the target media and provide a list of marker-to-time assignments. This list consists of one single assignment per line, each being of the format "marker,time" (for example: 1a,0), whereby time is a number representing the timepoint in seconds. The app assumes that within the same alignment base, each media alignment uses the identical set of markers (i.e., identical ordering and identical number of lines).
4. Choose an alignment base for playback. Use the "pickers" to change the media item and to jump to markers. 