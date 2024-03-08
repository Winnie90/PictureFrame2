
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
    @Published var currentFrame: FrameState = .clear {
        didSet {
            saveFrame()
        }
    }
    @Published var frameWidth: FrameWidth = .small {
        didSet {
            saveFrame()
        }
    }
        
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
        loadFrame()
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
    
    private func saveFrame() {
        AppStorage.store(id: frameId, frame: currentFrame.rawValue, width: frameWidth.rawValue)
    }
    
    private func loadFrame() {
        let frameTuple = AppStorage.retrieveFrame(id: frameId)
        currentFrame = FrameState(rawValue: frameTuple.frame) ?? .clear
        frameWidth = FrameWidth(rawValue: frameTuple.width) ?? .small
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
