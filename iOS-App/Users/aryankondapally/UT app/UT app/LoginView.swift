import SwiftUI

struct LoginView: View {
  @State private var username = ""
  @State private var password = ""
  @State private var errorMsg = ""
  @State private var didLogin = false

  var body: some View {
    VStack(spacing: 20) {
      TextField("Username", text: $username).disableAutocorrection(true).textInputAutocapitalization(.never).padding().border(.gray)
      SecureField("Password", text: $password).padding().border(.gray)

      Button("Log In") {
        Task {
          do {
            try await Networking.shared.login(username: username, password: password)
            didLogin = true
          } catch {
            errorMsg = "Login failed"
          }
        }
      }
      .padding().background(Color.burntOrange).foregroundColor(.white).cornerRadius(8)

      if !errorMsg.isEmpty {
        Text(errorMsg).foregroundColor(.red)
      }
    }
    .padding()
    .fullScreenCover(isPresented: $didLogin) {
      AdminView()  // or your main TabView
    }
  }
}
