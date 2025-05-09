//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

public struct LuminareColorPicker: View {
    @Binding var currentColor: Color

    @State private var text: String
    @State private var showColorPicker = false
    let colorNames: (red: LocalizedStringKey, green: LocalizedStringKey, blue: LocalizedStringKey)
    let formatStrategy: StringFormatStyle.HexStrategy

    public init(
        color: Binding<Color>, colorNames: (red: LocalizedStringKey, green: LocalizedStringKey, blue: LocalizedStringKey),
        formatStrategy: StringFormatStyle.HexStrategy = .uppercasedWithWell
    ) {
        self._currentColor = color
        self._text = State(initialValue: color.wrappedValue.toHex())
        self.colorNames = colorNames
        self.formatStrategy = formatStrategy
    }

    public var body: some View {
        HStack {
            LuminareTextField(
                "Hex Color",
                value: .init($text),
                format: StringFormatStyle(parseStrategy: .hex(formatStrategy)),
                onSubmit: {
                    if let newColor = Color(hex: text) {
                        currentColor = newColor
                        text = newColor.toHex()
                    } else {
                        text = currentColor.toHex() // revert to last valid color
                    }
                }
            )
            .modifier(LuminareBordered())

            Button {
                showColorPicker.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(currentColor)
                    .frame(width: 26, height: 26)
                    .padding(4)
                    .modifier(LuminareBordered())
            }
            .buttonStyle(PlainButtonStyle())
            .luminareModal(isPresented: $showColorPicker, closeOnDefocus: true, isCompact: true) {
                ColorPickerModalView(color: $currentColor, hexColor: $text, colorNames: colorNames)
                    .frame(width: 280)
            }
        }
        .onChange(of: currentColor) { _ in
            text = currentColor.toHex()
        }
    }
}
