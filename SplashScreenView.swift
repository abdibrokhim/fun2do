import SwiftUI
//import PlaygroundSupport

struct SplashScreenView: View { 
    @State private var isActive = false
    var body: some View {
        Group {
            if isActive {
                OnboardingView()
            } else {
                VStack {
                    // Replace with your custom logo/image if available
                    Image(systemName: "sparkles")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    Text("fun2do")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Display splash screen for 2 seconds before transitioning
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
