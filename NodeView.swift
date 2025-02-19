import SwiftUI

struct NodeView: View { 
    @Binding var node: Node 
    // Callback for when a parent node is tapped. 
    var onSelect: (() -> Void)? = nil 
    // Callback for when a connection gesture ends: (source node id, end point) 
    var onConnectionDragEnded: ((UUID, CGPoint) -> Void)? = nil 
    @State private var dragOffset: CGSize = .zero
    @State private var showConnectionDots = false
    
    // Define the size based on node type.
    var size: CGFloat {
        switch node.type {
        case .parent: return 120
        default: return 80
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(node.color))
                .frame(width: size, height: size)
            Text(node.title)
                .foregroundColor(.white)
                .font(node.type == .parent ? .headline : .subheadline)
        }
        .overlay(
            // If connection dots are visible, show them at top, bottom, left, and right.
            Group {
                if showConnectionDots {
                    // Top dot
                    ConnectionDotView(node: node, dotPosition: CGPoint(x: size/2, y: 0), onDragEnded: onConnectionDragEnded)
                    // Bottom dot
                    ConnectionDotView(node: node, dotPosition: CGPoint(x: size/2, y: size), onDragEnded: onConnectionDragEnded)
                    // Left dot
                    ConnectionDotView(node: node, dotPosition: CGPoint(x: 0, y: size/2), onDragEnded: onConnectionDragEnded)
                    // Right dot
                    ConnectionDotView(node: node, dotPosition: CGPoint(x: size, y: size/2), onDragEnded: onConnectionDragEnded)
                }
            }
        )
        .offset(x: node.position.x + dragOffset.width,
                y: node.position.y + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    node.position.x += value.translation.width
                    node.position.y += value.translation.height
                    dragOffset = .zero
                }
        )
        // A simultaneous tap gesture for parent selection.
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if node.type == .parent {
                        onSelect?()
                    }
                }
        )
        // Long press to toggle connection dots.
        .gesture(
            LongPressGesture(minimumDuration: 1)
                .onEnded { _ in
                    withAnimation { showConnectionDots.toggle() }
                }
        )
        // If this node is a selected parent, add a highlight border.
        .overlay(
            RoundedRectangle(cornerRadius: size/2)
                .stroke(Color.yellow, lineWidth: 3)
                .opacity( (node.type == .parent && showConnectionDots) ? 1 : 0)
        )
    }
}
