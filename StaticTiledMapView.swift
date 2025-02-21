import SwiftUI

struct StaticTiledMapView: View {
    // Map image and properties
    private let mapImage = UIImage(named: "map")!
    var onDoubleTap: (() -> Void)? = nil
    
    // Customization options
    var showBorder: Bool = true
    
    // State for smooth loading
    @State private var isLoaded = false
    
    var body: some View {
        GeometryReader { geometry in
                ZStack {
                    
                    // Map container
                    VStack(spacing: 0) {
                        // Calculate dimensions based on the original map image
                        let tileWidth = mapImage.size.width
                        let tileHeight = mapImage.size.height
                        
                        // Determine how many tiles needed to fill viewport
                        let horizontalTiles = max(1, Int(ceil(geometry.size.width / tileWidth)))
                        let verticalTiles = max(1, Int(ceil(geometry.size.height / tileHeight)))
                        
                        // Calculate total map size
                        let totalWidth = CGFloat(horizontalTiles) * tileWidth
                        let totalHeight = CGFloat(verticalTiles) * tileHeight
                        
                        // Full map container
                        ZStack {
                            // Build the map grid
                            ForEach(0..<verticalTiles, id: \.self) { row in
                                ForEach(0..<horizontalTiles, id: \.self) { col in
                                    // Each individual tile
                                    Image(uiImage: mapImage)
                                        .resizable()
                                        .interpolation(.high)
                                        .antialiased(true)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: tileWidth, height: tileHeight)
                                        .position(
                                            x: CGFloat(col) * tileWidth + tileWidth / 2,
                                            y: CGFloat(row) * tileHeight + tileHeight / 2
                                        )
                                    // Fade in animation
                                        .opacity(isLoaded ? 1.0 : 0.0)
                                        .animation(.easeIn(duration: 0.3).delay(0.05 * Double(row + col)), value: isLoaded)
                                }
                            }
                            
                            // Optional border around the entire map
                            if showBorder {
                                Rectangle()
                                    .strokeBorder(Color.black.opacity(0.2), lineWidth: 1)
                                    .frame(width: totalWidth, height: totalHeight)
                            }
                        }
                        .frame(width: totalWidth, height: totalHeight)
                        // Add subtle shadow for depth
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    .onAppear {
                        // Trigger the loading animation
                        withAnimation {
                            isLoaded = true
                        }
                    }
                }
        }
    }
}
