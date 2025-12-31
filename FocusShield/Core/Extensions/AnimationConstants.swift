import SwiftUI

// MARK: - Animation Duration Constants

enum AnimationDuration {
    static let instant: Double = 0.1
    static let fast: Double = 0.2
    static let normal: Double = 0.3
    static let slow: Double = 0.5
    static let breathing: Double = 4.0  // For urge surfing
}

// MARK: - Animation Presets

extension Animation {
    static let focusSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let gentleBounce = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.9)
    static let smooth = Animation.easeInOut(duration: AnimationDuration.normal)
    static let breatheIn = Animation.easeInOut(duration: AnimationDuration.breathing)
    static let breatheOut = Animation.easeInOut(duration: AnimationDuration.breathing)
}

// MARK: - Transition Presets

extension AnyTransition {
    static let fadeAndSlide = AnyTransition.opacity.combined(with: .move(edge: .bottom))
    static let fadeAndScale = AnyTransition.opacity.combined(with: .scale(scale: 0.9))
    static let slideFromTop = AnyTransition.move(edge: .top).combined(with: .opacity)
    static let slideFromBottom = AnyTransition.move(edge: .bottom).combined(with: .opacity)
}
