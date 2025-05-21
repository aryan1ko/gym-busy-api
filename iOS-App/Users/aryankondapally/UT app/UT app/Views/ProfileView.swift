//
//  ProfileView.swift
//  UT app
//
//  Created by Aryan Kondapally on 5/19/25.
//

import SwiftUI

struct ProfileView: View {
  // MARK: – Auth State
  @State private var username     = ""
  @State private var password     = ""
  @State private var errorMessage = ""
  @AppStorage("jwt-token") private var token: String?

  // MARK: – Admin State
  @State private var count          = 0
  @State private var successMessage = ""
  @FocusState private var isInputFocused: Bool

  // single shared VM for whichever gym page you visit
  @StateObject private var vm = GymBusinessViewModel()

  var body: some View {
    Group {
      if token == nil {
        loginForm
      } else {
        adminPanel
      }
    }
    .background(Color.white.ignoresSafeArea())
  }

  // ── Login Form ────────────────────────────
  private var loginForm: some View {
    VStack(spacing: 20) {
      TextField("Username", text: $username)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )

      SecureField("Password", text: $password)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )

      Button("Log In") {
        Task {
          do {
            try await Networking.shared.login(
              username: username,
              password: password
            )
            errorMessage = ""
          } catch {
            errorMessage = "Login failed – check credentials."
          }
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color("BurntOrange"))
      .foregroundColor(.white)
      .cornerRadius(8)

      if !errorMessage.isEmpty {
        Text(errorMessage)
          .foregroundColor(.red)
          .multilineTextAlignment(.center)
      }
    }
    .padding()
    .navigationTitle("Admin Login")
  }

  // ── Admin Panel ───────────────────────────
  private var adminPanel: some View {
    VStack(spacing: 20) {
      Text("Set current busy count:")
        .font(.headline)

      TextField("0", value: $count, format: .number)
        .keyboardType(.numberPad)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .focused($isInputFocused)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )

      Button("Update") {
        Task {
          await vm.pushUpdate(count: count)
          successMessage = "Updated to \(count)!"
          isInputFocused = false
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color("BurntOrange"))
      .foregroundColor(.white)
      .cornerRadius(8)

      if !successMessage.isEmpty {
        Text(successMessage)
          .foregroundColor(.green)
      }

      Button(role: .destructive) {
        token = nil
        username = ""
        password = ""
        count = 0
        successMessage = ""
      } label: {
        Text("Log Out")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.red.opacity(0.8))
          .foregroundColor(.white)
          .cornerRadius(8)
      }
      .padding(.top, 30)
    }
    .padding()
    .navigationTitle("Admin Panel")
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ProfileView()
    }
  }
}
