//
//  View+ButtonLabel.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import SwiftUI

struct ButtonLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold()
            .foregroundColor(.primary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .shadow(radius: 10)
    }
}

extension View {
    public func makeButtonLabelWithStyle() -> some View {
        modifier(ButtonLabelModifier())
    }
}
