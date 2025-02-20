import SwiftUI

enum NodeType { case genesis, parent, child }

struct Node: Identifiable { 
    let id = UUID() 
    var title: String 
    var description: String = "" 
    var deadline: Date = Date() 
    var status: String = "" 
    var type: NodeType 
    var position: CGPoint 
    var color: UIColor
    var childIDs: [UUID] = []
    var parentID: UUID? = nil
    /// For child nodes, we record the creation time so we know the total duration.
    var creationDate: Date? = nil
}
