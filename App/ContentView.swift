import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { 
                    Label("Home", systemImage: "house") 
                }
            WorkoutView()
                .tabItem { 
                    Label("Workout", systemImage: "dumbbell") 
                }
            MindSourcesView()
                .tabItem { 
                    Label("Mind", systemImage: "house") 
                }
            PracticalSourcesView()
                .tabItem { 
                    Label("Practical", systemImage: "dumbbell") 
                }
            PlaygroundView()
                .tabItem { 
                    Label("Playground", systemImage: "dumbbell") 
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
