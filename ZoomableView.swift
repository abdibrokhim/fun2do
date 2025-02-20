import SwiftUI

struct ZoomableView<Content: View>: View {
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var currentScale: CGFloat = 1.0
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(currentScale * gestureScale)
            .gesture(
                MagnificationGesture()
                    .updating($gestureScale) { latestGestureScale, state, _ in
                        state = latestGestureScale
                    }
                    .onEnded { finalGestureScale in
                        currentScale *= finalGestureScale
                    }
            )
    }
}
