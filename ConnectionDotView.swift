import SwiftUI

struct ConnectionDotView: View { 
    var node: Node 
    // The dot’s position relative to the node’s top-left corner. 
    var dotPosition: CGPoint 
    var dotType: DotPosition
    var onDragEnded: ((UUID, CGPoint, DotPosition) -> Void)? = nil
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 10, height: 10)
            .position(dotPosition)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // The dot's global position BEFORE dragging:
                        let initialDotGlobal = dotGlobalPosition(node: node, dot: dotType)
                        // Then add the user's drag translation:
                        let endPoint = CGPoint(x: initialDotGlobal.x + value.translation.width,
                                               y: initialDotGlobal.y + value.translation.height)
                        onDragEnded?(node.id, endPoint, dotType)
                    }
            )
    }
}
