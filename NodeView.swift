import SwiftUI

// MARK: - NodeView

struct NodeView: View {
    @Binding var node: Node
    var onSelect: (() -> Void)? = nil
    // Callback for when a connection gesture ends.
    var onConnectionDragEnded: ((UUID, CGPoint, DotPosition) -> Void)? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var showConnectionDots = false
    
    // Node size: 120 for parent; 80 for others.
    var size: CGFloat {
        node.type == .parent ? 120 : 80
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
            Group {
                if showConnectionDots {
                    ConnectionDotView(node: node, dot: .top, onDragEnded: onConnectionDragEnded)
                    ConnectionDotView(node: node, dot: .bottom, onDragEnded: onConnectionDragEnded)
                    ConnectionDotView(node: node, dot: .left, onDragEnded: onConnectionDragEnded)
                    ConnectionDotView(node: node, dot: .right, onDragEnded: onConnectionDragEnded)
                }
            }
        )
        // Use .position so that node.position represents the CENTER.
        .position(x: node.position.x + dragOffset.width, y: node.position.y + dragOffset.height)
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
        .simultaneousGesture(
            TapGesture().onEnded {
                if node.type == .parent {
                    onSelect?()
                }
            }
        )
        .gesture(
            LongPressGesture(minimumDuration: 1)
                .onEnded { _ in
                    withAnimation { showConnectionDots.toggle() }
                }
        )
    }
}
