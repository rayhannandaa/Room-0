//
//  PressableButton.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import SwiftUI

struct PressableButton: View {
    let assetName: String
    let size: CGSize
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Image(assetName)
            .resizable()
            .frame(width: size.width, height: size.height)
            .offset(y: isPressed ? 5 : 0)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .onTapGesture {
                isPressed = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    isPressed = false
                }
            }
    }
}
