import SwiftUI

struct MainCanvasView: View { 
    @Binding var showDropdown: Bool
    
    @State private var nodes: [Node] = [] 
    @State private var connections: [Connection] = []
    
    @State private var showParentModal = false
    @State private var showChildModal = false
    @State private var showNoParentAlert = false
    @State private var showMaxChildAlert = false
    
    // Track the currently selected parent node (by its id).
    @State private var selectedParentID: UUID? = nil
    
    // For detail editing.
    @State private var selectedNodeForDetail: Node? = nil
    
    // Timer for updating colors in real time.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
                ZStack {
                    // Background: use Infinite or Static tiled map.
                    StaticTiledMapView()
                
                // Render connection curves.
                ForEach(connections) { connection in
                    if let fromNode = nodes.first(where: { $0.id == connection.from }),
                       let toNode = nodes.first(where: { $0.id == connection.to }) {
                        
                        let fromPoint = globalDotPosition(node: fromNode, dot: connection.fromDot)
                        let toPoint   = globalDotPosition(node: toNode,   dot: connection.toDot)
                        
                        ConnectionView(from: fromPoint, to: toPoint)
                    }
                }
                
                // Render nodes.
                ForEach($nodes) { $node in
                    NodeView(node: $node, onSelect: {
                        if node.type == .parent {
                            selectedParentID = node.id
                        }
                    }, onConnectionDragEnded: { sourceID, endPoint, sourceDot in
                        handleConnectionDragEnd(from: sourceID, at: endPoint, sourceDot: sourceDot)
                    }, onDoubleTap: { tappedNode in
                        // Open detail modal for editing.
                        selectedNodeForDetail = tappedNode
                    })
                }
                
                // Dropdown overlay.
                if showDropdown {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                Button("Create Parent Node") {
                                    showParentModal = true
                                    showDropdown = false
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
                                Button("Create Child Node") {
                                    if let parentID = selectedParentID {
                                        let childCount = nodes.filter { $0.parentID == parentID }.count
                                        if childCount >= 8 {
                                            showMaxChildAlert = true
                                        } else {
                                            showChildModal = true
                                        }
                                    } else {
                                        showNoParentAlert = true
                                    }
                                    showDropdown = false
                                }
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
                                Button("Exit") {
                                    showDropdown = false
                                }
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding()
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            // Present modals.
            .sheet(isPresented: $showParentModal) {
                ParentNodeCreationView { newNode in
                    var nodeWithPosition = newNode
                    nodeWithPosition.position = randomPositionWithin70Percent(of: canvasSize)
                    nodes.append(nodeWithPosition)
                }
            }
            .sheet(isPresented: $showChildModal) {
                ChildNodeCreationView { newChild in
                    if let parentID = selectedParentID,
                       let index = nodes.firstIndex(where: { $0.id == parentID }) {
                        var childNode = newChild
                        childNode.parentID = parentID
                        childNode.creationDate = Date() // record creation time
                        childNode.position = randomPositionWithin70Percent(of: canvasSize)
                        nodes.append(childNode)
                        nodes[index].childIDs.append(childNode.id)
                        updateParentColor(for: parentID)
                    }
                }
            }
            // Modal for editing details.
            .sheet(item: $selectedNodeForDetail) { nodeBinding in
                // Pass a binding to the selected node.
                if let index = nodes.firstIndex(where: { $0.id == nodeBinding.id }) {
                    TodoDetailView(node: $nodes[index])
                }
            }
            // Alerts.
            .alert(isPresented: $showNoParentAlert) {
                Alert(title: Text("No Parent Selected"),
                      message: Text("Please select a parent node by tapping it before creating a child node."),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showMaxChildAlert) {
                Alert(title: Text("Max Child Nodes Reached"),
                      message: Text("A parent node can have a maximum of 8 child nodes."),
                      dismissButton: .default(Text("OK")))
            }
            .onAppear {
                if !nodes.contains(where: { $0.type == .genesis }) {
                    let genesisPosition = randomPositionWithin70Percent(of: canvasSize)
                    let genesisNode = Node(title: "Genesis Brain",
                                           type: .genesis,
                                           position: genesisPosition,
                                           color: UIColor.black)
                    nodes.append(genesisNode)
                }
            }
            // Timer to update child node colors and then parent colors in real time.
            .onReceive(timer) { _ in
                let now = Date()
                for i in nodes.indices {
                    if nodes[i].type == .child, let created = nodes[i].creationDate {
                        let totalDuration = nodes[i].deadline.timeIntervalSince(created)
                        let timeRemaining = nodes[i].deadline.timeIntervalSince(now)
                        nodes[i].color = childColor(totalDuration: totalDuration, timeRemaining: timeRemaining)
                    }
                }
                // Update parent's color based on current child colors.
                let parentIDs = Set(nodes.filter { $0.type == .parent }.map { $0.id })
                for parentID in parentIDs {
                    updateParentColor(for: parentID)
                }
            }
        }
    }
    
    // Updated connection drag handler that now receives a DotPosition.
    func handleConnectionDragEnd(
        from sourceID: UUID,
        at endPoint: CGPoint,
        sourceDot: DotPosition
    ) {
        var closestTarget: (node: Node, dot: DotPosition, distance: CGFloat)? = nil
        
        for target in nodes {
            if target.id == sourceID { continue }
            for dot in [DotPosition.top, .bottom, .left, .right] {
                // Compute the global dot position for the target node.
                let targetDotGlobal = globalDotPosition(node: target, dot: dot)
                let dx = targetDotGlobal.x - endPoint.x
                let dy = targetDotGlobal.y - endPoint.y
                let dist = sqrt(dx*dx + dy*dy)
                if dist < 30 {
                    if let current = closestTarget {
                        if dist < current.distance {
                            closestTarget = (target, dot, dist)
                        }
                    } else {
                        closestTarget = (target, dot, dist)
                    }
                }
            }
        }
        
        // If a target was found, check additional rules.
        if let targetInfo = closestTarget {
            // Get the source node.
            guard let sourceNode = nodes.first(where: { $0.id == sourceID }) else { return }
            
            // BLOCK ANY CONNECTION if one node is Genesis and the other is Child.
            if (sourceNode.type == .genesis && targetInfo.node.type == .child) ||
                (sourceNode.type == .child && targetInfo.node.type == .genesis) {
                // Do not create connection.
                return
            }
            
            // Also block duplicates: if any connection exists between these two nodes (in either direction), do nothing.
            let duplicateExists = connections.contains { conn in
                (conn.from == sourceID && conn.to == targetInfo.node.id) ||
                (conn.from == targetInfo.node.id && conn.to == sourceID)
            }
            if duplicateExists { return }
            
            // Otherwise, add the connection.
            connections.append(
                Connection(from: sourceID,
                           to: targetInfo.node.id,
                           fromDot: sourceDot,
                           toDot: targetInfo.dot)
            )
        }
    }
    
    func updateParentColor(for parentID: UUID) {
        guard let parentIndex = nodes.firstIndex(where: { $0.id == parentID }) else { return }
        let childColors = nodes.filter { $0.parentID == parentID }.map { $0.color }
        if !childColors.isEmpty {
            let mixed = mixColors(colors: childColors)
            nodes[parentIndex].color = mixed
        } else {
            nodes[parentIndex].color = UIColor.blue
        }
    }
}
