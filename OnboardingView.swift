import SwiftUI

struct OnboardingView: View { 
    @State private var showMain = false
    @State private var showDropdown = false
    
    var body: some View {
        Group {
            if showMain {
                ZoomablePannableMapView(
                    onDoubleTap: {
                        withAnimation {
                            showDropdown.toggle()
                        }
                    }
                ) {
                    MainCanvasView(showDropdown: $showDropdown)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Welcome to fun2do!")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("Manage your tasks as interactive nodes. Connect them, move them around, and create your unique to-do network!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Button(action: {
                        withAnimation {
                            showMain = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                    }
                }
                .padding()
            }
        }
    }
}
