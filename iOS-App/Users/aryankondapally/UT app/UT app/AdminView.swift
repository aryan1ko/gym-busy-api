import SwiftUI

struct AdminView: View {
  // MARK: – State & Storage
  @State private var username = ""
  @State private var password = ""
  @State private var errorMessage = ""
  @AppStorage("jwt-token") private var token: String?
  
  @State private var count = 0
  @State private var successMessage = ""
  @StateObject private var vm = GymBusinessViewModel()

  var body: some View {
    Group {
      // If no token, show login form
      if token == nil {
        loginForm
      } else {
        updateForm
      }
    }
    .padding()
    .navigationTitle(token == nil ? "Admin Login" : "Admin Panel")
  }

  // MARK: – Login Form
  private var loginForm: some View {
    VStack(spacing: 20) {
      TextField("Username", text: $username)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .padding().border(Color.gray)
      
      SecureField("Password", text: $password)
        .padding().border(Color.gray)
      
      Button("Log In") {
        Task {
          do {
            try await Networking.shared.login(username: username, password: password)
            errorMessage = ""
          } catch {
            errorMessage = "Login failed"
          }
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color("BurntOrange"))
      .foregroundColor(.white)
      .cornerRadius(8)
      
      if !errorMessage.isEmpty {
        Text(errorMessage).foregroundColor(.red)
      }
    }
  }

  // MARK: – Update Form
  private var updateForm: some View {
    VStack(spacing: 20) {
      Text("Set current busy count:")
        .font(.headline)
      
      TextField("0", value: $count, format: .number)
        .keyboardType(.numberPad)
        .padding().border(Color.gray)
      
      Button("Update") {
        Task {
          await vm.pushUpdate(count: count)
          successMessage = "Updated to \(count)!"
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color("BurntOrange"))
      .foregroundColor(.white)
      .cornerRadius(8)
      
      if !successMessage.isEmpty {
        Text(successMessage).foregroundColor(.green)
      }
    }
  }
}

struct AdminView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AdminView()
    }
  }
}
