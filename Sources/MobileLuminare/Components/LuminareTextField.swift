//
//  LuminareTextField.swift
//
//
//  Created by Adon Omeri on 2025-05-06.
//

import SwiftUI
#if os(macOS)
    import AppKit
#endif

public struct LuminareTextField<F>: View where F: ParseableFormatStyle, F.FormatOutput == String {
    let elementMinHeight: CGFloat = 34
    let horizontalPadding: CGFloat = 8

    @Binding var value: F.FormatInput?
    var format: F
    let placeholder: LocalizedStringKey
    let onSubmit: (() -> Void)?

    #if os(macOS)
        @State var monitor: Any?
    #endif

    public init(_ placeholder: LocalizedStringKey, value: Binding<F.FormatInput?>, format: F, onSubmit: (() -> Void)? = nil) {
        _value = value
        self.format = format
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    public init(_ placeholder: LocalizedStringKey, text: Binding<String>, onSubmit: (() -> Void)? = nil) where F == StringFormatStyle {
        self.init(placeholder, value: .init(text), format: StringFormatStyle(), onSubmit: onSubmit)
    }

    public var body: some View {
        TextField(placeholder, value: $value, format: format)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: elementMinHeight)
            .textFieldStyle(.plain)
            .onSubmit {
                if let onSubmit {
                    onSubmit()
                }
            }
        #if os(macOS)
            .onAppear {
                guard monitor == nil else { return }

                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let window = NSApp.keyWindow, window.animationBehavior == .documentWindow {
                        window.keyDown(with: event)

                        // Fixes cmd+w to close window.
                        let wKey = 13
                        if event.keyCode == wKey, event.modifierFlags.contains(.command) {
                            return nil
                        }
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor {
                    NSEvent.removeMonitor(monitor)
                }
                monitor = nil
            }
        #endif
    }
}
