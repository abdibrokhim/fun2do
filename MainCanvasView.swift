import SwiftUI

struct MainCanvasView: View { 
    @State private var nodes: [Node] = [] 
    @State private var connections: [Connection] = []
    
    // Dropdown and modal control.
    @State private var showDropdown = false
    @State private var showParentModal = false
    @State private var showChildModal = false
    @State private var showNoParentAlert = false
    @State private var showMaxChildAlert = false
    
    // Track the currently selected parent node (by its id).
    @State private var selectedParentID: UUID? = nil
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            // Using double-tap as a placeholder.
                .onTapGesture(count: 2) {
                    withAnimation { showDropdown.toggle() }
                }
            
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
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
            }
        }
        // Present modals.
        .sheet(isPresented: $showParentModal) {
            ParentNodeCreationView { newNode in
                nodes.append(newNode)
            }
        }
        .sheet(isPresented: $showChildModal) {
            ChildNodeCreationView { newChild in
                if let parentID = selectedParentID,
                   let index = nodes.firstIndex(where: { $0.id == parentID }) {
                    var childNode = newChild
                    childNode.parentID = parentID
                    nodes.append(childNode)
                    nodes[index].childIDs.append(childNode.id)
                    updateParentColor(for: parentID)
                }
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
                let genesisNode = Node(title: "Genesis Brain",
                                       type: .genesis,
                                       position: CGPoint(x: 200, y: 50),
                                       color: UIColor.purple)
                nodes.append(genesisNode)
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
        
        if let targetInfo = closestTarget {
            // Check for duplicate connections (regardless of dot positions)
            let duplicateExists = connections.contains { conn in
                (conn.from == sourceID && conn.to == targetInfo.node.id) ||
                (conn.from == targetInfo.node.id && conn.to == sourceID)
            }
            
            if !duplicateExists {
                connections.append(
                    Connection(from: sourceID,
                               to: targetInfo.node.id,
                               fromDot: sourceDot,
                               toDot: targetInfo.dot)
                )
            }
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
