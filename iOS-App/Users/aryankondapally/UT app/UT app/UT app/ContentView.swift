import SwiftUI

struct ContentView: View {
  @State private var selectedTab: Tab = .home

  // Our three tabs
  enum Tab {
    case feedback, home, profile
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      
      // ── 1) Feedback (left) ───────────────────────────────
      NavigationStack {
        FeedbackView()
      }
      .tabItem {
        Label("Feedback", systemImage: "bubble.left.and.bubble.right.fill")
      }
      .tag(Tab.feedback)

      // ── 2) Home (middle) ─────────────────────────────────
      NavigationStack {
        ScrollView {
          VStack(spacing: 40) {
            Spacer().frame(height: 30)

            Image("gymLogo")
              .resizable()
              .scaledToFit()
              .frame(width: 150, height: 150)

            VStack(spacing: 20) {
              NavigationLink {
                GymGraphView(title: "Gregory Gym")
              } label: {
                Text("Gregory Gym")
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color("BurntOrange"))
                  .foregroundColor(.white)
                  .cornerRadius(8)
              }

              NavigationLink {
                GymGraphView(title: "Recreational Center")
              } label: {
                Text("Recreational Center")
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color("BurntOrange"))
                  .foregroundColor(.white)
                  .cornerRadius(8)
              }
            }
            .padding(.horizontal)

            Spacer().frame(height: 50)
          }
          .padding()
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text("University Gyms")
              .font(.headline)
          }
        }
      }
      .tabItem {
        Label("Home", systemImage: "house.fill")
      }
      .tag(Tab.home)

      // ── 3) Profile/Admin (right) ─────────────────────────
      NavigationStack {
        ProfileView()
      }
      .tabItem {
        Label("Profile", systemImage: "person.fill")
      }
      .tag(Tab.profile)
    }
  }
}

// Preview stub
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
