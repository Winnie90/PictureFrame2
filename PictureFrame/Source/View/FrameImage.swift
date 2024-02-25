//
//  FrameImage.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 17/02/2024.
//

import SwiftUI

struct FrameImage: View {
    @ObservedObject var frameModel: FrameModel
    
    var body: some View {
        switch frameModel.imageState {
        case .success(let image):
            if frameModel.currentFrame == .clear {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                image
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(frameModel.currentFrame.colour, lineWidth: 40)
                    )
            }
        case .loading:
            ProgressView()
        case .empty:
            VStack {
                PhotoPicker(viewModel: frameModel)
                Text("Please select a photo.")
                    .font(.headline)
            }
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28))
                .foregroundColor(.white)
        }
    }
}
