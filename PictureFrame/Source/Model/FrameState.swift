//
//  FrameState.swift
//  PictureFrame
//
//  Created by Chris Winstanley on 08/03/2024.
//

import SwiftUI

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
