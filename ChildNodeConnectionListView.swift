import SwiftUI

struct ChildNodeConnectionListView: View {
    var parent: Node
    var allChildNodes: [Node]
    var connections: [Connection]
    
    /// Called when user taps to add or remove a connection.
    /// (parentID, childID, isCurrentlyConnected) -> Void
    var onToggleConnection: (UUID, UUID, Bool) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allChildNodes, id: \.id) { child in
                    HStack {
                        Text(child.title)
                        Spacer()
                        
                        if isConnected(parent: parent, child: child) {
                            // If already connected, show X to remove
                            Button(action: {
                                onToggleConnection(parent.id, child.id, true)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .foregroundColor(.red)
                        } else {
                            // If not connected, show checkmark to add
                            Button(action: {
                                onToggleConnection(parent.id, child.id, false)
                            }) {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationBarTitle("All Child Nodes", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func isConnected(parent: Node, child: Node) -> Bool {
        connections.contains { $0.from == parent.id && $0.to == child.id }
    }
}
