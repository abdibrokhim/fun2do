import SwiftUI

struct ConnectionDotView: View { 
    var node: Node 
    // The dot’s position relative to the node’s top-left corner. 
    var dotPosition: CGPoint 
    var onDragEnded: ((UUID, CGPoint) -> Void)? = nil
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 10, height: 10)
            .position(dotPosition)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // Calculate the dot’s center in global coordinates.
                        let nodeCenterOffset = CGPoint(x: node.position.x, y: node.position.y)
                        let dotCenter = CGPoint(x: nodeCenterOffset.x + dotPosition.x, y: nodeCenterOffset.y + dotPosition.y)
                        let endPoint = CGPoint(x: dotCenter.x + value.translation.width,
                                               y: dotCenter.y + value.translation.height)
                        onDragEnded?(node.id, endPoint)
                    }
            )
    }
}
