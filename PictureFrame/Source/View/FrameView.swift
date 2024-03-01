//
//  ContentView.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 16/02/2024.
//

import SwiftUI
import PhotosUI

struct FrameView: View {
    @Environment(\.openWindow) private var openWindow
    @StateObject var viewModel: FrameModel
    @State private var showingSheet = false
    
    var body: some View {
        FrameImage(viewModel: viewModel)
            .onAppear {
                if let uuid = viewModel.nextFrameId {
                    openWindow(id: "photo-frame", value: uuid)
                }
            }
            .onDisappear {
                viewModel.closeFrame()
            }
            .sheet(isPresented: $showingSheet) {
                FramePicker(viewModel: viewModel)
                    .frame(width: 400, height: 340)
            }
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    PhotoPicker(viewModel: viewModel)
                }
                ToolbarItem(placement: .bottomOrnament) {
                    NewFrameButton()
                }
                ToolbarItem(placement: .bottomOrnament) {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 28))
                    }
                    .accessibilityLabel("Customise your frame")
                }
            }
            .onTapGesture {
                showingSheet = false
            }
    }
}

struct FramePicker: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FrameModel
    
    init(viewModel: FrameModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Frame")
                    .font(.title)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                }
                .buttonStyle(.borderless)
            }
            Spacer()
            
            Text("Color")
                .font(.headline)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)
            ColourPicker(viewModel: viewModel)
                .accessibilityLabel("Pick the colour of the frame")
            
            Spacer()
            
            Text("Width")
                .font(.headline)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)
            Picker("", selection: $viewModel.frameWidth) {
                ForEach(FrameSize.allCases, id: \.self) { size in
                    Text(size.title).tag(size)
                }
            }.pickerStyle(.segmented)
            .accessibilityLabel("Pick how thick the frame is")
        }
        .padding(40)
    }
}

struct ColourPicker: View {
    @ObservedObject var viewModel: FrameModel

    var body: some View {
        HStack(spacing: 16) {
            ForEach(FrameState.allCases, id: \.self) { frame in
                Button {
                    viewModel.currentFrame = frame
                } label: {
                    if viewModel.currentFrame == frame {
                        Circle()
                            .stroke(.blue, lineWidth: 4)
                            .fill(frame.colour)
                            .frame(width: 40, height: 40)
                    } else {
                        Circle()
                            .stroke(.white, lineWidth: 2)
                            .fill(frame.colour)
                            .frame(width: 40, height: 40)
                    }
                }.buttonStyle(.borderless)
            }
            
        }
    }
}

#Preview {
    FramePicker(viewModel: FrameModel(frameId: "1"))
}
