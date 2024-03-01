
import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
class FrameModel: ObservableObject {
    
    enum ImageState {
        case empty
        case loading(Progress)
        case success(Image)
        case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ProfileImage: Transferable {
        let image: Image
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return ProfileImage(image: image)
            }
        }
    }
    
    @Published private(set) var imageState: ImageState = .empty
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    @Published var frameId: String
    @Published var currentFrame: FrameState = .clear
    @Published var frameWidth: FrameSize = .small
        
    var nextFrameId: String? {
        let imageIndex = loadImageIndex().sorted()
        guard let currentIndex = imageIndex.firstIndex(of: frameId), let nextIndex = imageIndex[safe: currentIndex + 1] else {
            return nil
        }
        return nextIndex
    }
    
    init(frameId: String) {
        self.frameId = frameId
        if let image = loadImage() {
            imageState = .success(Image(uiImage: image))
        }
    }
    
    func closeFrame() {
        deleteImage()
    }
    
    // MARK: - Private Methods
    
    private func saveImage(image: Image) {
        guard let uiImage = image.getUIImage() else { return }
        AppStorage.storeImage(image: uiImage, name: frameId)
        deleteImage()
        var imageIndex = loadImageIndex()
        imageIndex.append(frameId)
        save(imageIndex)
    }
    
    private func loadImage() -> UIImage? {
        AppStorage.retrieveImage(named: frameId)
    }
    
    private func deleteImage() {
        var imageIndexes = loadImageIndex()
        imageIndexes.removeAll { imageId in
            imageId == frameId
        }
        save(imageIndexes)
    }
    
    private func loadImageIndex() -> [String] {
        AppStorage.retrieveImageIndex()
    }
    
    private func save(_ imageIndex: [String]) {
        AppStorage.store(imageIndex: imageIndex)
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let profileImage?):
                    self.saveImage(image: profileImage.image)
                    self.imageState = .success(profileImage.image)
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}

enum FrameState: Int, CaseIterable {
    case clear
    case black
    case white
    case wood
    case darkWood
}

extension FrameState {
    var colour: Color {
        return switch self {
        case .clear:
            Color.clear
        case .black:
            .black
        case .white:
            .white
        case .wood:
            Color("LightBrown")
        case .darkWood:
            Color("DarkBrown")
        }
    }
}

enum FrameSize: Int, CaseIterable {
    case small
    case medium
    case large
}

extension FrameSize {
    var size: Double {
        return switch self {
        case .small:
            40.0
        case .medium:
            80.0
        case .large:
            120.0
        }
    }
    
    var title: String {
        return switch self {
        case .small:
            "Small"
        case .medium:
            "Medium"
        case .large:
            "Large"
        }
    }
}
