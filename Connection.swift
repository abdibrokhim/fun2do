import SwiftUI

enum DotPosition: String { case top, bottom, left, right }

struct Connection: Identifiable { 
    let id = UUID() 
    let from: UUID 
    let to: UUID
    let fromDot: DotPosition 
    let toDot: DotPosition
}
