import SwiftUI

struct ParentNodeCreationView: View { 
    @Environment(\.presentationMode) var presentationMode 
    @State private var title: String = "" 
    @State private var deadline: Date = Date()
    // Parent nodes start with a default blue.
    var onCreate: (Node) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
            }
            .navigationBarTitle("Create Parent Node", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarItems(trailing: Button("Create") {
                let newNode = Node(title: title,
                                   deadline: deadline, 
                                   type: .parent,
                                   position: CGPoint(x: 150, y: 300),
                                   color: UIColor.blue)
                onCreate(newNode)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
