import SwiftUI

struct ConnectionView: View { 
    var from: CGPoint 
    var to: CGPoint
    var body: some View {
        Path { path in
            path.move(to: from)
            // Now compute the control point based on the actual endpoints.
            // (You can tweak this calculation as needed for a pleasing curve.)
            let control = CGPoint(x: (from.x + to.x)/2, y: (from.y + to.y)/2)
            path.addQuadCurve(to: to, control: control)
        }
        .stroke(Color.gray, lineWidth: 2)
    }
}

