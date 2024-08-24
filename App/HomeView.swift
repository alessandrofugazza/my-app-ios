import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image("MachineLifeformHead")
                .resizable()
                .scaledToFit()
            Text("こんにちは。")
                .font(.largeTitle)
            Text("元気ですか。")
        }

    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


