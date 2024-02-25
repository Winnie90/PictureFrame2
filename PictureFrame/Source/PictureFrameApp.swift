//
//  PictureFrameApp.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 16/02/2024.
//

import SwiftUI

@main
struct PictureFrameApp: App {

    @State var size: CGSize = .zero

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

struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}
