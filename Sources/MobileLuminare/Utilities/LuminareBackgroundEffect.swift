//
//  LuminareBackgroundEffect.swift
//
//
//  Created by Adon Omeri on 2025-05-06.
//

import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// ViewModifier to apply the background effect
public struct LuminareBackgroundEffect: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background {
                #if os(macOS)
                    VisualEffectView(
                        material: .menu,
                        blendingMode: .behindWindow
                    )
                    .ignoresSafeArea(.container, edges: .top)
                    .allowsHitTesting(false)
                #else
                    VisualEffectView()
                        .ignoresSafeArea(.container, edges: .top)
                        .allowsHitTesting(false)
                #endif
            }
    }
}

/// Cross-platform VisualEffectView
struct VisualEffectView: View {
    #if os(macOS)
        let material: NSVisualEffectView.Material
        let blendingMode: NSVisualEffectView.BlendingMode
    #endif

    var body: some View {
        #if os(macOS)
            MacOSVisualEffectView(
                material: material,
                blendingMode: blendingMode
            )
        #else
            UIKitVisualEffectView()
        #endif
    }
}

// macOS-specific NSVisualEffectView wrapper
#if os(macOS)
    struct MacOSVisualEffectView: NSViewRepresentable {
        let material: NSVisualEffectView.Material
        let blendingMode: NSVisualEffectView.BlendingMode

        func makeNSView(context _: Context) -> NSVisualEffectView {
            let visualEffectView = NSVisualEffectView()
            visualEffectView.material = material
            visualEffectView.blendingMode = blendingMode
            visualEffectView.state = .active
            visualEffectView.isEmphasized = true
            return visualEffectView
        }

        func updateNSView(_ nsView: NSVisualEffectView, context _: Context) {
            nsView.material = material
            nsView.blendingMode = blendingMode
            nsView.state = .active
        }
    }
#endif

// UIKit-based UIVisualEffectView wrapper for iOS, iPadOS, tvOS, watchOS,
// visionOS
#if !os(macOS)
    struct UIKitVisualEffectView: UIViewRepresentable {
        func makeUIView(context _: Context) -> UIVisualEffectView {
            let view =
                UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            return view
        }

        func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
            uiView.effect = UIBlurEffect(style: .systemMaterial)
        }
    }
#endif

/// Extension to make it easy to apply the modifier
public extension View {
    func luminareBackground() -> some View {
        modifier(LuminareBackgroundEffect())
    }
}
