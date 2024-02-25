//
//  AppStorage.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 21/02/2024.
//

import Foundation
import UIKit

struct AppStorage {
    static func store(imageIndex: [String]) {
        do {
            let data = try JSONEncoder().encode(imageIndex)
            let url = URL.documentsDirectory.appending(path: "PictureFrameIndex.json")
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func retrieveImageIndex() -> [String] {
        do {
            let url = URL.documentsDirectory.appending(path: "PictureFrameIndex.json")
            return try JSONDecoder().decode([String].self, from: Data(contentsOf: url))
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    static func storeImage(image: UIImage, name: String) {
        do {
            if let data = image.pngData() {
                let filename = documentsDirectory.appendingPathComponent("\(name).png")
                try data.write(to: filename)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func retrieveImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
