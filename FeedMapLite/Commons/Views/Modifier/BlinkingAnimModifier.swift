//
//  BlinkingAnimModifier.swift
//  FeedMapLite
//
//  Created by 신이삭 on 9/5/24.
//

import Foundation
import SwiftUI

struct BlinkingAnimModifier: AnimatableModifier {
    var shouldShow: Bool
    var opacity: Double
    var animatableData: Double {
        get {
            opacity
        }
        
        set {
            opacity = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    Color.white.zIndex(0)
                        .cornerRadius(8)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray)
                        .opacity(self.opacity).zIndex(1)
                }
                .opacity(self.shouldShow ? 1 : 0)
            }
    }
}
