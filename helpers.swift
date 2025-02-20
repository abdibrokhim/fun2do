import SwiftUI

func mixColors(colors: [UIColor]) -> UIColor { 
    guard !colors.isEmpty 
    else { 
        return UIColor.blue 
    } 
    var totalR: CGFloat = 0, 
        totalG: CGFloat = 0, 
        totalB: CGFloat = 0, 
        totalA: CGFloat = 0 
    for color in colors { 
        var r: CGFloat = 0, 
            g: CGFloat = 0, 
            b: CGFloat = 0, 
            a: CGFloat = 0 
        color.getRed(
            &r, 
            green: &g, 
            blue: &b, 
            alpha: &a) 
        totalR += r 
        totalG += g 
        totalB += b 
        totalA += a 
    } 
    let count = CGFloat(colors.count) 
    return UIColor(red: totalR/count, green: totalG/count, blue: totalB/count, alpha: totalA/count) 
}

func dotOffset(for nodeType: NodeType, dot: DotPosition) -> CGPoint {
    // Node size depends on whether it's a parent or child.
    let size: CGFloat = (nodeType == .parent) ? 120 : 80
    
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
    let size: CGFloat = (nodeType == .parent) ? 120 : 80
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
