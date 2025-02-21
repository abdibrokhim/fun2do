import SwiftUI

func dotOffset(for nodeType: NodeType, dot: DotPosition) -> CGPoint {
    // Node size depends on whether it's a parent or child.
    let size: CGFloat = (nodeType == .genesis) ? 60 : (nodeType == .parent) ? 40 : 20
    
    switch dot {
    case .top:
        return CGPoint(x: size / 2, y: 0)
    case .bottom:
        return CGPoint(x: size / 2, y: size)
    case .left:
        return CGPoint(x: 0, y: size / 2)
    case .right:
        return CGPoint(x: size, y: size / 2)
    }
}

/// Returns the absolute (global) position of a dot on a node's circle.
func dotGlobalPosition(node: Node, dot: DotPosition) -> CGPoint {
    // The node's top-left corner is (node.position.x, node.position.y).
    // Then we add the dotOffset for that node's type & dot side.
    let offset = dotOffset(for: node.type, dot: dot)
    return CGPoint(x: node.position.x + offset.x,
                   y: node.position.y + offset.y)
}

/// Given the node type and a dot side, returns the offset (in points)
/// from the node’s center to that dot.
func localDotOffset(nodeType: NodeType, dot: DotPosition) -> CGPoint {
    // Use the same size as the node’s drawn diameter.
    let size: CGFloat = (nodeType == .genesis) ? 60 : (nodeType == .parent) ? 40 : 20
    switch dot {
    case .top:
        return CGPoint(x: 0, y: -size/2)
    case .bottom:
        return CGPoint(x: 0, y: size/2)
    case .left:
        return CGPoint(x: -size/2, y: 0)
    case .right:
        return CGPoint(x: size/2, y: 0)
    }
}

/// Computes the global (screen) position of a dot on the node.
/// Since node.position is the CENTER of the node, we add the local offset.
func globalDotPosition(node: Node, dot: DotPosition) -> CGPoint {
    let offset = localDotOffset(nodeType: node.type, dot: dot)
    return CGPoint(x: node.position.x + offset.x, y: node.position.y + offset.y)
}

// Helper function to check if a connection already exists between two node IDs.
func canCreateConnectionBetween(_ id1: UUID, _ id2: UUID, in connections: [Connection]) -> Bool {
    // Returns true only if no connection exists in either direction.
    return !connections.contains { connection in
        (connection.from == id1 && connection.to == id2) ||
        (connection.from == id2 && connection.to == id1)
    }
}

func randomPositionWithin70Percent(of canvasSize: CGSize) -> CGPoint {
    // Calculate margins: 15% on each side means nodes appear within the central 70%
    let horizontalMargin = canvasSize.width * 0.15
    let verticalMargin = canvasSize.height * 0.15
    let randomX = CGFloat.random(in: horizontalMargin...(canvasSize.width - horizontalMargin))
    let randomY = CGFloat.random(in: verticalMargin...(canvasSize.height - verticalMargin))
    return CGPoint(x: randomX, y: randomY)
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// MARK: - Color Helpers

// Our gray-scale palette from light to dark.
let grayPaletteHex = [
    "f9fafb", // gray-50 (lightest)
    "f3f4f6", // gray-100
    "e5e7eb", // gray-200
    "d1d5db", // gray-300
    "9ca3af", // gray-400
    "6b7280", // gray-500
    "4b5563", // gray-600
    "374151", // gray-700
    "1f2937", // gray-800
    "111827", // gray-900
    "030712"  // gray-950 (darkest)
]
let grayPalette: [UIColor] = grayPaletteHex.map { UIColor(hex: $0) }

/// Calculates the color for a Child Node based on its deadline.
/// - Parameters:
///   - totalDuration: The total duration in seconds from creation to deadline.
///   - timeRemaining: The current time remaining (in seconds) until deadline.
/// - Returns: A UIColor from the palette, where full time remaining yields a light color,
///            and zero (or negative) time remaining yields the darkest color.
func childColor(totalDuration: TimeInterval, timeRemaining: TimeInterval) -> UIColor {
    // Clamp ratio between 0 and 1.
    let ratio = max(0, min(1, timeRemaining / totalDuration))
    // When ratio==1 (freshly created), use the lightest color (index 0).
    // When ratio==0 (deadline reached), use the darkest color (last index).
    let indexFloat = (1 - ratio) * Double(grayPalette.count - 1)
    let index = Int(round(indexFloat))
    return grayPalette[index]
}

/// Mix an array of UIColors by averaging their RGBA components.
func mixColors(colors: [UIColor]) -> UIColor {
    guard !colors.isEmpty else { return UIColor.blue }
    var totalR: CGFloat = 0, totalG: CGFloat = 0, totalB: CGFloat = 0, totalA: CGFloat = 0
    for color in colors {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        totalR += r
        totalG += g
        totalB += b
        totalA += a
    }
    let count = CGFloat(colors.count)
    return UIColor(red: totalR/count, green: totalG/count, blue: totalB/count, alpha: totalA/count)
}

func contrastingColor(for color: UIColor) -> Color {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    // Compute luminance using the standard formula.
    let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
    return luminance < 0.5 ? Color.white : Color.black
}

