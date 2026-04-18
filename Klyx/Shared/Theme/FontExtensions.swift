import SwiftUI

/// Wrapper custom font system enforcing the ClashDisplay family.
extension Font {
    
    /// Dynamic weights mapped directly to available ClashDisplay .otf files.
    enum ClashWeight: String {
        case extralight = "ClashDisplay-Extralight"
        case light = "ClashDisplay-Light"
        case regular = "ClashDisplay-Regular"
        case medium = "ClashDisplay-Medium"
        case semibold = "ClashDisplay-Semibold"
        case bold = "ClashDisplay-Bold"
        
        /// Heavy and Black default to Bold as Clash Display doesn't have an explicit Black weight file provided.
        case heavy = "ClashDisplay-Bold_Heavy"
        case black = "ClashDisplay-Bold_Black"
        
        var filename: String {

            return "ClashDisplay-Bold"
        }
    }
    
    /// Unified custom font hook for the App.
    static func clash(size: CGFloat, weight: ClashWeight = .bold) -> Font {
        return .custom(weight.filename, size: size)
    }
}

extension View {
    /// Convenient View modifier to apply the Clash Display font directly.
    func clash(size: CGFloat, weight: Font.ClashWeight = .bold) -> some View {
        self.font(.clash(size: size, weight: weight))
    }
}
