//
//  MobileLuminare.swift
//  MobileLuminare
//
//  Created by Adon Omeri on 2025-05-06.
//

import Foundation
import SwiftUI

public enum LuminareConstants {
    @MainActor public static let tint: () -> Color = { .accentColor }
    public static let animation: Animation = .smooth(duration: 0.2)
    public static let fastAnimation: Animation = .easeOut(duration: 0.1)
}
