//
//  ContentView.swift
//  CoreMLHotdogIdentifier
//
//  Created by Irtaza Fiaz on 09/10/2024.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        CameraView(camera: camera)
    }
}

#Preview {
    ContentView()
}
