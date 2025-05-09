//
//  ColorHueSliderView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

struct ColorHueSliderView: View {
    @Binding var selectedColor: Color
    @State private var selectionPosition: CGFloat = 0
    @State private var selectionOffset: CGFloat = 0
    @State private var selectionCornerRadius: CGFloat = 0
    @State private var selectionWidth: CGFloat = 0

    /// Gradient for the color spectrum slider
    private let colorSpectrumGradient = Gradient(
        colors: stride(from: 0.0, through: 1.0, by: 0.01)
            .map {
                Color(hue: $0, saturation: 1, brightness: 1)
            }
    )

    init(selectedColor: Binding<Color>) {
        _selectedColor = selectedColor
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: colorSpectrumGradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                UnevenRoundedRectangle(
                    topLeadingRadius: 2,
                    bottomLeadingRadius: selectionOffset < (
                        geo.size.width / 2
                    ) ?
                        selectionCornerRadius : 2,
                    bottomTrailingRadius: selectionOffset >
                        (geo.size.width / 2) ? selectionCornerRadius : 2,
                    topTrailingRadius: 2
                )
                .frame(width: selectionWidth, height: 12.5)
                .padding(.bottom, 0.5)
                .offset(x: selectionOffset, y: 0)
                .foregroundColor(.white)
                .shadow(radius: 3)
                .onChange(of: selectionPosition) { _ in
                    withAnimation(LuminareConstants.animation) {
                        selectionOffset = calculateOffset(
                            handleWidth: handleWidth(at: selectionPosition,
                                                     geo.size.width),
                            geo.size.width
                        )
                        selectionWidth = handleWidth(
                            at: selectionPosition,
                            geo.size.width
                        )
                        selectionCornerRadius = handleCornerRadius(
                            at: selectionPosition,
                            geo.size.width
                        )
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChange(value, geo.size.width)
                    }
            )
            .onAppear {
                selectionPosition = selectedColor.toHSB().hue * geo.size.width
                selectionOffset = calculateOffset(
                    handleWidth: handleWidth(at: selectionPosition,
                                             geo.size.width),
                    geo.size.width
                )
                selectionWidth = handleWidth(
                    at: selectionPosition,
                    geo.size.width
                )
                selectionCornerRadius = handleCornerRadius(
                    at: selectionPosition,
                    geo.size.width
                )
            }
        }
        .frame(height: 16)
    }

    private func handleDragChange(
        _ value: DragGesture.Value,
        _ viewSize: CGFloat
    ) {
        let lastPercentage = selectionPosition / viewSize

        let clampedX = max(5.5, min(value.location.x, viewSize - 5.5))
        selectionPosition = clampedX
        let percentage = selectionPosition / viewSize
        let currenthsb = selectedColor.toHSB()
        #if os(macOS)
            if percentage != lastPercentage,
               percentage == 5.5 / viewSize || percentage == (viewSize - 5.5) /
               viewSize
            {
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .alignment,
                    performanceTime: .now
                )
            }
        #endif
        withAnimation(LuminareConstants.animation) {
            selectedColor = Color(
                hue: percentage,
                saturation: max(0.0001, currenthsb.saturation),
                brightness: currenthsb.brightness
            )
        }
    }

    private func calculateOffset(handleWidth: CGFloat,
                                 _ viewSize: CGFloat) -> CGFloat
    {
        let halfWidth = handleWidth / 2
        let adjustedPosition = min(
            max(selectionPosition, halfWidth),
            viewSize - halfWidth
        )
        return adjustedPosition - halfWidth
    }

    private func handleWidth(at position: CGFloat,
                             _ viewSize: CGFloat) -> CGFloat
    {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = 1 - max(0, min(edgeDistance / 10, 1))
        return max(5, min(15, 5 + (6 * edgeFactor)))
    }

    private func handleCornerRadius(at position: CGFloat,
                                    _ viewSize: CGFloat) -> CGFloat
    {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = max(0, min(edgeDistance / 5, 1))
        return 15 * edgeFactor
    }
}
