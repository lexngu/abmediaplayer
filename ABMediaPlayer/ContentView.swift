//
//  ContentView.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 11.03.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack() {
            Text("ABMediaPlayer")
                .font(.title)
            Text("v0.0.1-alpha (2023-03-11)")
                .foregroundColor(Color.gray)
            MediaRow()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
