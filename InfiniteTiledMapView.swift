import SwiftUI
import Combine

struct InfiniteTiledMapView: View {
    // Map state
    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    
    // Inertial scrolling
    @State private var velocity: CGSize = .zero
    @State private var scrollCancellable: AnyCancellable?
    
    // Tile fade-in configuration
    @State private var visibleTiles: [TileIdentifier: Bool] = [:]
    private let fadeInDuration: Double = 0.2
    
    // Load the map image from your asset catalog
    private let mapImage = UIImage(named: "map")!
    
    // Tile identification
    private struct TileIdentifier: Hashable {
        let row: Int
        let col: Int
    }
    
    var body: some View {
        GeometryReader { geometry in
            let tileWidth = mapImage.size.width
            let tileHeight = mapImage.size.height
            
            // Calculate the actual scale that will be applied
            let currentScale = scale * gestureScale
            
            // Calculate visible area plus buffer based on current scale
            let visibleWidth = geometry.size.width / currentScale
            let visibleHeight = geometry.size.height / currentScale
            
            // Calculate the number of tiles needed based on current scale
            let horizontalTiles = Int(ceil(visibleWidth / tileWidth)) + 3
            let verticalTiles = Int(ceil(visibleHeight / tileHeight)) + 3
            
            // Calculate the wrapped offset for seamless tiling
            let xOffset = (offset.width + dragOffset.width).truncatingRemainder(dividingBy: tileWidth)
            let yOffset = (offset.height + dragOffset.height).truncatingRemainder(dividingBy: tileHeight)
            
            ZStack {
                // Background color that matches map edges
                Color(UIColor(red: 240/255, green: 240/255, blue: 235/255, alpha: 1.0))
                    .edgesIgnoringSafeArea(.all)
                
                ZoomablePannableMapView {
                    ZStack {
                        ForEach(-verticalTiles/2..<verticalTiles/2, id: \.self) { row in
                            ForEach(-horizontalTiles/2..<horizontalTiles/2, id: \.self) { col in
                                let tileID = TileIdentifier(row: row, col: col)
                                
                                Image(uiImage: mapImage)
                                    .resizable()
                                    .interpolation(.high)
                                    .antialiased(true)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: tileWidth, height: tileHeight)
                                    .position(
                                        x: CGFloat(col) * tileWidth + tileWidth / 2 + xOffset,
                                        y: CGFloat(row) * tileHeight + tileHeight / 2 + yOffset
                                    )
                                    .opacity(visibleTiles[tileID] == true ? 1.0 : 0.0)
                                    .onAppear {
                                        withAnimation(.easeIn(duration: fadeInDuration)) {
                                            visibleTiles[tileID] = true
                                        }
                                    }
                                    .onDisappear {
                                        visibleTiles[tileID] = nil
                                    }
                                // Subtle shadow for depth
                                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                            }
                        }
                        
                        // Grid overlay for visual reference (optional - remove if not needed)
                        gridOverlay(tileWidth: tileWidth, tileHeight: tileHeight, opacity: 0.05)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    // Add a DragGesture with inertial scrolling
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Cancel any ongoing inertial scrolling
                                scrollCancellable?.cancel()
                                
                                // Update drag offset
                                dragOffset = value.translation
                                
                                // Calculate velocity for inertial scrolling
                                if value.time > .now - 0.1 {
                                    let timeDelta = max(0.016, value.time.timeIntervalSince(.now - 0.1))
                                    velocity = CGSize(
                                        width: value.translation.width / CGFloat(timeDelta),
                                        height: value.translation.height / CGFloat(timeDelta)
                                    )
                                }
                            }
                            .onEnded { value in
                                // Apply the drag to the main offset
                                offset.width += dragOffset.width
                                offset.height += dragOffset.height
                                dragOffset = .zero
                                
                                // Apply inertial scrolling if velocity is significant
                                if abs(velocity.width) > 50 || abs(velocity.height) > 50 {
                                    applyInertialScrolling()
                                }
                            }
                    )
                }
                .onAppear {
                    // Pre-populate initial visible tiles
                    for row in -2...2 {
                        for col in -2...2 {
                            visibleTiles[TileIdentifier(row: row, col: col)] = true
                        }
                    }
                }
            }
        }
    }
    
    // Apply smooth inertial scrolling
    private func applyInertialScrolling() {
        // Cancel any existing scroll operation
        scrollCancellable?.cancel()
        
        var currentVelocity = velocity
        var lastUpdateTime = Date()
        
        scrollCancellable = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                let now = Date()
                let elapsed = now.timeIntervalSince(lastUpdateTime)
                lastUpdateTime = now
                
                // Apply velocity to offset
                withAnimation(.linear(duration: 0.016)) {
                    offset.width += currentVelocity.width * CGFloat(elapsed)
                    offset.height += currentVelocity.height * CGFloat(elapsed)
                }
                
                // Apply friction - exponential decay feels most natural
                let friction: CGFloat = 0.94
                currentVelocity.width *= friction
                currentVelocity.height *= friction
                
                // Stop when velocity becomes very small
                if abs(currentVelocity.width) < 5 && abs(currentVelocity.height) < 5 {
                    scrollCancellable?.cancel()
                }
            }
    }
    
    // Optional grid overlay for visual reference
    private func gridOverlay(tileWidth: CGFloat, tileHeight: CGFloat, opacity: Double) -> some View {
        GeometryReader { geo in
            ZStack {
                // Vertical lines
                ForEach(0..<Int(geo.size.width/tileWidth) + 1, id: \.self) { i in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 1)
                        .position(x: CGFloat(i) * tileWidth + (offset.width + dragOffset.width).truncatingRemainder(dividingBy: tileWidth), 
                                  y: geo.size.height/2)
                        .frame(height: geo.size.height)
                }
                
                // Horizontal lines
                ForEach(0..<Int(geo.size.height/tileHeight) + 1, id: \.self) { i in
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 1)
                        .position(x: geo.size.width/2, 
                                  y: CGFloat(i) * tileHeight + (offset.height + dragOffset.height).truncatingRemainder(dividingBy: tileHeight))
                        .frame(width: geo.size.width)
                }
            }
            .opacity(opacity)
        }
    }
}
