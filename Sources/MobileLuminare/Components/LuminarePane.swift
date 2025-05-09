//
//  LuminarePane.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

// Define a proper environment key for clickedOutsideFlag
private struct ClickedOutsideFlagKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var clickedOutsideFlag: Bool {
        get { self[ClickedOutsideFlagKey.self] }
        set { self[ClickedOutsideFlagKey.self] = newValue }
    }
}

public struct LuminarePane<V, C>: View where V: View, C: View {
    // Remove the luminareWindow environment reference
    #if os(macOS)
    let titlebarHeight: CGFloat = 50
    #elseif os(iOS) || os(visionOS)
    let titlebarHeight: CGFloat = 44
    #elseif os(watchOS)
    let titlebarHeight: CGFloat = 38
    #else
    let titlebarHeight: CGFloat = 40
    #endif

    let header: () -> C
    let content: () -> V

    @State private var clickedOutsideFlag = false

    public init(
        @ViewBuilder header: @escaping () -> C,
        @ViewBuilder content: @escaping () -> V
    ) {
        self.header = header
        self.content = content
    }

    public var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    content()
                }
                .padding(12)
                .environment(\.clickedOutsideFlag, clickedOutsideFlag)
                .background {
                    Color.white.opacity(0.0001)
                        .onTapGesture {
                            clickedOutsideFlag.toggle()
                        }
                        #if os(macOS) || os(iOS) || os(visionOS)
                        .ignoresSafeArea()
                        #endif
                }
            }
            .clipped()

            VStack(spacing: 0) {
                header()
                    .buttonStyle(TabHeaderButtonStyle())
                    .padding(.horizontal, 10)
                    .padding(.trailing, 5)
                    .frame(height: titlebarHeight, alignment: .leading)

                Divider()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            #if os(macOS) || os(iOS) || os(visionOS)
            .edgesIgnoringSafeArea(.top)
            #endif
        }
        .luminareBackground()
    }
}

struct TabHeaderButtonStyle: ButtonStyle {
    #if os(macOS)
    @State var isHovering: Bool = false
    #endif

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
#if os(macOS)
            .foregroundStyle(
                isHovering ? .primary : .secondary
            )
        #else
            .foregroundStyle(
                configuration.isPressed ? .primary : .secondary

            )
        #endif
            #if os(macOS)
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
            }
            #endif
    }
}
