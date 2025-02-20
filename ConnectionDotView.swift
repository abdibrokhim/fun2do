import SwiftUI

// MARK: - ConnectionDotView

struct ConnectionDotView: View {
    var node: Node
    var dot: DotPosition
    // Callback: (node.id, final global point, dot type)
    var onDragEnded: ((UUID, CGPoint, DotPosition) -> Void)? = nil
    
    var body: some View {
        // The node’s drawn size:
        let size: CGFloat = (node.type == .parent) ? 120 : 80
        // In the node’s local coordinate space, the center is at (size/2, size/2)
        // The dot’s offset from center is given by localDotOffset.
        let localOffset = localDotOffset(nodeType: node.type, dot: dot)
        let dotPos = CGPoint(x: size/2 + localOffset.x,
                             y: size/2 + localOffset.y)
        
        return Circle()
            .fill(Color.white)
            .frame(width: 10, height: 10)
            .position(dotPos)
            .gesture(
                DragGesture().onEnded { value in
                    // Get the dot's global position (based on the node's center)
                    let startGlobal = globalDotPosition(node: node, dot: dot)
                    let endGlobal = CGPoint(x: startGlobal.x + value.translation.width,
                                            y: startGlobal.y + value.translation.height)
                    onDragEnded?(node.id, endGlobal, dot)
                }
            )
    }
}
