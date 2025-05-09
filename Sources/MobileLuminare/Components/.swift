//
//  LuminareBordered.swift
//  MobileLuminareTest
//
//  Created by Adon Omeri on 8/5/2025.
//

import SwiftUI


public struct LuminareBordered: ViewModifier {
    @Binding var highlight: Bool
    let cornerRadius: CGFloat = 8
    
    public init(highlight: Binding<Bool> = .constant(false)) {
        self._highlight = highlight
    }
    
    public func body(content: Content) -> some View {
        content
            .background {
                if highlight {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                } else {
                    Rectangle().foregroundStyle(.quinary)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}

extension ViewModifier {
    public func luminareBordered((highlight: Binding<Bool> = .constant(false))) -> some View {
        then({ LuminareBordered(highlight: highlight)($0) })
    }
}
