//
//  EnvironmentValues.swift
//
//
//  Created by Adon Omeri on 2025-05-06.
//

import SwiftUI

// MARK: - TintColor

/// Currently, it is impossible to read the .tint(Color) modifier on a view.
/// This is a custom environement value as an alternative implementation of it.
public struct TintColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: () -> Color = { .accentColor }
}

public extension EnvironmentValues {
    var tintColor: () -> Color {
        get { self[TintColorEnvironmentKey.self] }
        set { self[TintColorEnvironmentKey.self] = newValue }
    }
}

// MARK: - HoveringOverLuminareItem

public struct HoveringOverLuminareItem: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var hoveringOverLuminareItem: Bool {
        get { self[HoveringOverLuminareItem.self] }
        set { self[HoveringOverLuminareItem.self] = newValue }
    }
}
