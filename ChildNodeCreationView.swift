import SwiftUI

struct ChildNodeCreationView: View { 
    @Environment(\.presentationMode) var presentationMode 
    @State private var title: String = "" 
    @State private var description: String = "" 
    @State private var deadline: Date = Date() 
    @State private var status: String = "important"
    // Child nodes will start with a default light sky color.
    var onCreate: (Node) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                TextField("Status", text: $status)
            }
            .navigationBarTitle("Create Child Node", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarItems(trailing: Button("Create") {
                // Use a custom light sky color.
                let lightSky = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
                let newNode = Node(title: title,
                                   description: description,
                                   deadline: deadline, 
                                   status: status, 
                                   type: .child,
                                   position: CGPoint(x: 150, y: 300),
                                   color: lightSky)
                onCreate(newNode)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
