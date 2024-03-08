//
//  FrameSize.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 08/03/2024.
//

import Foundation

enum FrameWidth: Double, CaseIterable {
    case small = 40.0
    case medium = 80.0
    case large = 120.0
}

extension FrameWidth {
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
