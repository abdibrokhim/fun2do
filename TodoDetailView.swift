import SwiftUI

// Detail view for editing a Node's details.
struct TodoDetailView: View {
    @Binding var node: Node
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $node.title)
                TextField("Description", text: $node.description)
                DatePicker("Deadline", selection: $node.deadline, displayedComponents: [.date, .hourAndMinute])
                TextField("Status", text: $node.status)
            }
            .navigationBarTitle("Edit Todo", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
