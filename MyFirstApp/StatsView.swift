import SwiftUI

struct StatsView: View {
    var body: some View {
        Text("Stats View")
            .navigationTitle("Stats")
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}
