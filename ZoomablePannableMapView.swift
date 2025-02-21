import SwiftUI
import Combine

struct ZoomablePannableMapView<Content: View>: View {
    let content: Content
    var onDoubleTap: (() -> Void)? = nil
    
    // Animation parameters
    private let animationDuration: Double = 0.3
    
    // Scale properties
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var currentScale: CGFloat = 1.0
    
    // Pan properties
    @State private var panOffset: CGSize = .zero
    @GestureState private var dragTranslation: CGSize = .zero
    
    // Velocity tracking for inertial scrolling
    @State private var lastDragVelocity: CGSize = .zero
    @State private var decelerationTimer: AnyCancellable?
    
    // Scale limits
    let minScale: CGFloat = 1.0
    let maxScale: CGFloat = 5.0
    
    init(onDoubleTap: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.onDoubleTap = onDoubleTap
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .scaleEffect(currentScale * gestureScale)
                .offset(x: panOffset.width + dragTranslation.width,
                        y: panOffset.height + dragTranslation.height)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: currentScale)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: panOffset)
                .gesture(
                    MagnificationGesture()
                        .updating($gestureScale) { latestGesture, state, _ in
                            state = latestGesture
                        }
                        .onEnded { value in
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                let proposedScale = currentScale * value
                                currentScale = min(max(proposedScale, minScale), maxScale)
                            }
                        }
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .updating($dragTranslation) { value, state, _ in
                            state = value.translation
                        }
                        .onChanged { value in
                            // Calculate velocity for inertial scrolling
                            if value.translation == .zero {
                                lastDragVelocity = .zero
                            } else if value.time > .now - 0.1 {
                                let timeDelta = value.time.timeIntervalSince(.now - 0.1)
                                lastDragVelocity = CGSize(
                                    width: value.translation.width / CGFloat(timeDelta),
                                    height: value.translation.height / CGFloat(timeDelta)
                                )
                            }
                        }
                        .onEnded { value in
                            // Apply the translation
                            var newPanOffset = panOffset
                            newPanOffset.width += value.translation.width
                            newPanOffset.height += value.translation.height
                            
                            // Apply inertial scrolling
                            if abs(lastDragVelocity.width) > 100 || abs(lastDragVelocity.height) > 100 {
                                applyInertialScrolling(velocity: lastDragVelocity, viewSize: geometry.size)
                            } else {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                    panOffset = newPanOffset
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation(.easeInOut(duration: animationDuration)) {
//                                if currentScale > minScale * 1.2 {
//                                    // Reset to default
//                                    currentScale = minScale
//                                    panOffset = .zero
//                                } else {
//                                    // Zoom in
//                                    currentScale = min(currentScale * 2, maxScale)
//                                }
                                onDoubleTap?()
                            }
                        }
                )
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // Apply smooth deceleration for inertial scrolling
    private func applyInertialScrolling(velocity: CGSize, viewSize: CGSize) {
        // Cancel existing timer
        decelerationTimer?.cancel()
        
        var currentVelocity = velocity
        var newOffset = panOffset
        
        // Create a timer that fires frequently to update position with decreasing velocity
        decelerationTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // Calculate new position based on velocity
                newOffset.width += currentVelocity.width * 0.016
                newOffset.height += currentVelocity.height * 0.016
                
                // Apply friction to slow down
                currentVelocity.width *= 0.92
                currentVelocity.height *= 0.92
                
                // Apply the new position with animation
                withAnimation(.linear(duration: 0.016)) {
                    panOffset = newOffset
                }
                
                // Stop when velocity becomes very small
                if abs(currentVelocity.width) < 5 && abs(currentVelocity.height) < 5 {
                    decelerationTimer?.cancel()
                }
            }
    }
}
