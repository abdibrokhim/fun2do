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
    // Define node size based on type. 
    let size: CGFloat = (nodeType == .parent) ? 120 : 80 
    switch dot { 
        case .top: return CGPoint(x: size/2, y: 0) 
        case .bottom: return CGPoint(x: size/2, y: size) 
        case .left: return CGPoint(x: 0, y: size/2) 
        case .right: return CGPoint(x: size, y: size/2) 
    } 
}
