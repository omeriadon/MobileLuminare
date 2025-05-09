//
//  LuminareDividedStack.swift
//  Luminare
//
//  Created by Adon on 2025-05-07.
//

import SwiftUI

public struct LuminareDividedStack<Content: View>: View {
    let orientation: StackOrientation
    let content: () -> Content
    
    public enum StackOrientation {
        case vertical
        case horizontal
    }
    
    public init(orientation: StackOrientation = .horizontal, @ViewBuilder content: @escaping () -> Content) {
        self.orientation = orientation
        self.content = content
    }
    
    public var body: some View {
        switch orientation {
            case .horizontal:
                makeHorizontalStack()
            case .vertical:
                makeVerticalStack()
        }
    }
    
    @ViewBuilder
    private func makeHorizontalStack() -> some View {
        _VariadicView.Tree(LuminareDividedHStackLayout()) {
            content()
        }
    }
    
    @ViewBuilder
    private func makeVerticalStack() -> some View {
        _VariadicView.Tree(LuminareDividedVStackLayout()) {
            content()
        }
    }
}

struct LuminareDividedHStackLayout: _VariadicView_UnaryViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id
        
        HStack(spacing: 0) {
            ForEach(children) { child in
                child
                
                if child.id != last {
                    Divider()
                        .edgesIgnoringSafeArea(.top)
                        .luminareBackground()
                }
            }
            .transition(.asymmetric(insertion: .identity, removal: .opacity.animation(.easeInOut(duration: 0.25))))
        }
    }
}

struct LuminareDividedVStackLayout: _VariadicView_UnaryViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id
        
        VStack(spacing: 0) {
            ForEach(children) { child in
                child
                
                if child.id != last {
                    Divider()
                        .luminareBackground()
                }
            }
            .transition(.asymmetric(insertion: .identity, removal: .opacity.animation(.easeInOut(duration: 0.25))))
        }
    }
}
