//
//  Styles.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/18/25.
//

import SwiftUI

struct CompactGreenCTA: ButtonStyle {
    var small: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.horizontal, small ? 16 : 28)
            .padding(.vertical, small ? 8 : 10)
            .background(
                RoundedRectangle(cornerRadius: small ? 14 : 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.20, green: 0.70, blue: 0.30),
                                     Color(red: 0.10, green: 0.60, blue: 0.20)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.28), radius: small ? 8 : 10, y: small ? 3 : 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
