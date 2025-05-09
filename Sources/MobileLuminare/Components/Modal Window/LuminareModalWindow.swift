//
//  LuminareModalWindow.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//
// Huge thanks to https://cindori.com/developer/floating-panel :)

import SwiftUI

#if os(macOS)
    class LuminareModalMacWindow<Content: View>: NSWindow {
        weak var modal: LuminareModal<Content>?

        override func close() {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.15
                self.animator().alphaValue = 0
            }, completionHandler: {
                super.close()
                self.modal?.isPresented = false
            })
        }

        override func keyDown(with event: NSEvent) {
            let wKey = 13
            if event.keyCode == wKey, event.modifierFlags.contains(.command) {
                close()
                return
            }
            super.keyDown(with: event)
        }

        override func mouseDown(with event: NSEvent) {
            let titlebarHeight: CGFloat = (modal?.isCompact ?? false) ? 12 : 16
            if event.locationInWindow.y > frame.height - titlebarHeight {
                super.performDrag(with: event)
            } else {
                super.mouseDragged(with: event)
            }
        }

        override var canBecomeKey: Bool { true }
        override var canBecomeMain: Bool { true }

        override func resignMain() {
            if modal?.closeOnDefocus == true {
                close()
            }
        }
    }
#endif

class LuminareModal<Content>: ObservableObject where Content: View {
    @Binding var isPresented: Bool // This will sync with external state

    let closeOnDefocus: Bool
    let isCompact: Bool
    var content: () -> Content

    #if os(macOS)
        private var window: LuminareModalMacWindow<Content>?
    #endif

    init(
        isPresented: Binding<Bool>, // Accept Binding<Bool> directly
        closeOnDefocus: Bool,
        isCompact: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) {
        // Bind directly to the provided Binding<Bool>
        _isPresented = isPresented
        self.closeOnDefocus = closeOnDefocus
        self.isCompact = isCompact
        self.content = content
    }

    func updateShadow(for duration: Double) {
        #if os(macOS)
            guard isPresented, let window else { return }

            let frameRate: Double = 60
            let updatesCount = Int(duration * frameRate)
            let interval = duration / Double(updatesCount)

            for i in 0 ... updatesCount {
                DispatchQueue.main
                    .asyncAfter(deadline: .now() + Double(i) * interval) {
                        window.invalidateShadow()
                    }
            }
        #endif
    }

    #if os(macOS)
        func presentMacOSWindow() {
            guard window == nil else { return }

            window = LuminareModalMacWindow(
                contentRect: .zero,
                styleMask: [.fullSizeContentView],
                backing: .buffered,
                defer: false
            )

            window?.modal = self

            let hostingView = NSHostingView(
                rootView: LuminareModalView(
                    isCompact: isCompact,
                    content: content
                )
                .environment(\.tintColor, LuminareConstants.tint)
                .environmentObject(self)
            )

            window?.collectionBehavior.insert(.fullScreenAuxiliary)
            window?.level = .floating
            window?.backgroundColor = .clear
            window?.contentView = hostingView
            window?.contentView?.wantsLayer = true
            window?.ignoresMouseEvents = false
            window?.isOpaque = false
            window?.hasShadow = true
            window?.titlebarAppearsTransparent = true
            window?.titleVisibility = .hidden
            window?.animationBehavior = .documentWindow

            window?.center()
            window?.orderFrontRegardless()
            window?.makeKey()
        }

        func closeMacOSWindow() {
            window?.close()
            window = nil
        }
    #endif
}

struct LuminareModalModifier<PanelContent>: ViewModifier
where PanelContent: View {
    @StateObject private var modal: LuminareModal<PanelContent>
    @Binding var isPresented: Bool

    init(
        isPresented: Binding<Bool>,
        closeOnDefocus: Bool,
        isCompact: Bool,
        @ViewBuilder content: @escaping () -> PanelContent
    ) {
        _isPresented = isPresented
        _modal = StateObject(
            wrappedValue: LuminareModal(
                isPresented: isPresented,
                closeOnDefocus: closeOnDefocus,
                isCompact: isCompact,
                content: content
            )
        )
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    present()
                } else {
                    dismiss()
                }
            }
            .onDisappear {
                isPresented = false
                dismiss()
            }
        #if !os(macOS)
            .popover(isPresented: $isPresented) {
                LuminareModalView(
                    isCompact: modal.isCompact,
                    content: modal.content
                )
                .environment(\.tintColor, LuminareConstants.tint)
                .environmentObject(modal)
                .presentationCompactAdaptation(.popover)
            }
        #endif
    }

    private func present() {
        #if os(macOS)
            modal.presentMacOSWindow()
        #else
            // Popover is handled by the popover modifier
            modal.isPresented = true
        #endif
    }

    private func dismiss() {
        #if os(macOS)
            modal.closeMacOSWindow()
        #else
            modal.isPresented = false
        #endif
    }
}

public extension View {
    func luminareModal(
        isPresented: Binding<Bool>,
        closeOnDefocus: Bool = false,
        isCompact: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminareModalModifier(
                isPresented: isPresented,
                closeOnDefocus: closeOnDefocus,
                isCompact: isCompact,
                content: content
            )
        )
    }
}
