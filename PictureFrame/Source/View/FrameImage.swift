//
//  FrameImage.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 17/02/2024.
//

import SwiftUI

struct FrameImage: View {
    @ObservedObject var viewModel: FrameModel
    
    var body: some View {
        switch viewModel.imageState {
        case .success(let image):
            if viewModel.currentFrame == .clear {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                image
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(viewModel.currentFrame.colour, lineWidth: viewModel.lineWidth)
                    )
            }
        case .loading:
            ProgressView()
        case .empty:
            VStack {
                PhotoPicker(viewModel: viewModel)
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
