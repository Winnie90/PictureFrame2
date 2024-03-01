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
                    .frame(width: 400, height: 400)
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
                }
            }
    }
}

struct FramePicker: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FrameModel
    @State var lineWidth: Double = 40.0
    
    init(viewModel: FrameModel) {
        self.viewModel = viewModel
        self.lineWidth = viewModel.lineWidth
    }

    var body: some View {
        VStack {
            HStack {
                Text("Frame Picker")
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
            List {
                Section(header:
                    Text("Color")
                        .font(.headline)
                ) {
                    ColourPicker(viewModel: viewModel)
                }
                Section(header:
                    Text("Width")
                        .font(.headline)
                ) {
                    HStack {
                        Slider(value: $lineWidth, in: 1...80) { editing in
                            if editing == false {
                                //viewModel.lineWidth = lineWidth
                            }
                        }
                        Text("\(lineWidth, specifier: "%.1f")")
                    }
                }
            }
        }
        .padding(20)
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
