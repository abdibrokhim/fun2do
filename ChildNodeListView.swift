import SwiftUI

struct ChildNodeListView: View { 
    var parent: Node 
    var childNodes: [Node] 
    var onSelect: (Node) -> Void
    var body: some View {
        NavigationView {
            List(childNodes, id: \.id) { child in
                Button(action: {
                    onSelect(child)
                }) {
                    Text(child.title)
                }
            }
            .navigationBarTitle("Child Nodes for \(parent.title)", displayMode: .inline)
        }
    }
}
