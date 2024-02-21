//
//  PictureFrameApp.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 16/02/2024.
//

import SwiftUI

@main
struct PictureFrameApp: App {
    var body: some Scene {
        WindowGroup(id: "photo-frame", for: String.self) { $uuid in
            FrameView(viewModel: FrameModel(frameId: uuid ?? loadFirstImageId()))
        }
    }
    
    private func loadFirstImageId() -> String {
        let imageIndex = AppStorage.retrieveImageIndex()
        if !imageIndex.isEmpty {
            return imageIndex.sorted()[0]
        } else {
            return UUID().uuidString
        }
    }
}
