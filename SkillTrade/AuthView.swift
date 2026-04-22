import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var selectedRole = "homeowner"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 28) {
                        VStack(spacing: 6) {
                            Text("SkillTrade").font(.largeTitle.bold())
                            Text("Connect with trusted tradespeople")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(.top, 60)

                        VStack(spacing: 16) {
                            if isSignUp {
                                TextField("Full Name", text: $name)
                                    .textFieldStyle(.roundedBorder)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("I am a...").font(.subheadline).foregroundStyle(.secondary)
                                    Picker("Role", selection: $selectedRole) {
                                        Text("Homeowner").tag("homeowner")
                                        Text("Service Provider").tag("provider")
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }

                            TextField("Email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)

                            SecureField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)

                            if !authVM.errorMessage.isEmpty {
                                Text(authVM.errorMessage)
                                    .font(.caption).foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                            }

                            Button {
                                if isSignUp {
                                    authVM.signUp(email: email, password: password,
                                                  name: name, role: selectedRole)
                                } else {
                                    authVM.signIn(email: email, password: password)
                                }
                            } label: {
                                Group {
                                    if authVM.isLoading { ProgressView() }
                                    else { Text(isSignUp ? "Create Account" : "Sign In").fontWeight(.semibold) }
                                }
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.blue).foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(authVM.isLoading)
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                        Button { withAnimation { isSignUp.toggle() } } label: {
                            Text(isSignUp ? "Already have an account? Sign In"
                                         : "Don't have an account? Sign Up")
                                .font(.subheadline).foregroundStyle(.blue)
                        }
                    }
                }
            }
            .toolbar {
                if authVM.showAuthScreen {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back") { authVM.cancelManualLogin() }
                    }
                }
            }
        }
    }
}
