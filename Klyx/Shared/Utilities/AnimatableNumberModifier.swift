import SwiftUI

/// A ViewModifier that allows for animating numeric text changes.
/// Usage: Text("0").modifier(AnimatableNumberModifier(number: score))
struct AnimatableNumberModifier: AnimatableModifier {
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .clash(size: 110, weight: .bold)
            .opacity(0)
            .overlay(
                Text("\(Int(number))")
                    .clash(size: 110, weight: .bold)
            )
    }
}

extension View {
    func animatingNumber(_ number: Int, size: CGFloat = 110) -> some View {
        modifier(AnimatableNumberModifier(number: Double(number)))
    }
}
