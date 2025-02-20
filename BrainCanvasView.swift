import SwiftUI

// MARK: - Example Usage in a "Brain" Canvas

// (This is a simplified version of your main canvas logic.)
struct BrainCanvasView: View {
    @State private var nodes: [Node] = []
    @State private var connections: [Connection] = []
    
    // Example connection drag handler.
    func handleConnectionDragEnd(from sourceID: UUID, at endPoint: CGPoint, sourceDot: DotPosition) {
        var closestTarget: (node: Node, dot: DotPosition, distance: CGFloat)? = nil
        for target in nodes {
            if target.id == sourceID { continue }
            for dot in [DotPosition.top, .bottom, .left, .right] {
                let targetGlobal = globalDotPosition(node: target, dot: dot)
                let dx = targetGlobal.x - endPoint.x
                let dy = targetGlobal.y - endPoint.y
                let distance = sqrt(dx*dx + dy*dy)
                if distance < 30 {
                    if let current = closestTarget {
                        if distance < current.distance {
                            closestTarget = (target, dot, distance)
                        }
                    } else {
                        closestTarget = (target, dot, distance)
                    }
                }
            }
        }
        if let targetInfo = closestTarget {
            if !connections.contains(where: { $0.from == sourceID && $0.to == targetInfo.node.id }) {
                connections.append(
                    Connection(from: sourceID,
                               to: targetInfo.node.id,
                               fromDot: sourceDot,
                               toDot: targetInfo.dot)
                )
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            // Draw connection lines.
            ForEach(connections) { connection in
                if let fromNode = nodes.first(where: { $0.id == connection.from }),
                   let toNode   = nodes.first(where: { $0.id == connection.to }) {
                    let fromPoint = globalDotPosition(node: fromNode, dot: connection.fromDot)
                    let toPoint   = globalDotPosition(node: toNode, dot: connection.toDot)
                    ConnectionView(from: fromPoint, to: toPoint)
                }
            }
            // Draw nodes.
            ForEach($nodes) { $node in
                NodeView(node: $node, onConnectionDragEnded: { sourceID, endPoint, sourceDot in
                    handleConnectionDragEnd(from: sourceID, at: endPoint, sourceDot: sourceDot)
                })
            }
        }
        .onAppear {
            // Example: add two nodes.
            // Now node.position represents the center.
            nodes.append(Node(title: "Task 1", type: .parent, position: CGPoint(x: 200, y: 300), color: UIColor.blue))
            nodes.append(Node(title: "Task 2", type: .child, position: CGPoint(x: 400, y: 500), color: UIColor.green))
        }
    }
}
