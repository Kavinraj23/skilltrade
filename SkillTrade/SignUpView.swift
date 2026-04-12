import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: Role = .homeowner
    @FocusState private var focusedField: Field?

    private enum Field { case name, email, password, confirmPassword }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Role picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("I am a...")
                        .font(.headline)

                    HStack(spacing: 12) {
                        RolePill(
                            title: "Homeowner",
                            icon: "house.fill",
                            isSelected: selectedRole == .homeowner
                        ) { selectedRole = .homeowner }

                        RolePill(
                            title: "Tradesperson",
                            icon: "wrench.and.screwdriver.fill",
                            isSelected: selectedRole == .provider
                        ) { selectedRole = .provider }
                    }
                }

                // Fields
                VStack(spacing: 12) {
                    InputField(label: "Full Name", text: $name)
                        .textContentType(.name)
                        .focused($focusedField, equals: .name)

                    InputField(label: "Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)

                    InputField(label: "Password", text: $password, isSecure: true)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .password)

                    InputField(label: "Confirm Password", text: $confirmPassword, isSecure: true)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .confirmPassword)

                    if !passwordsMatch && !confirmPassword.isEmpty {
                        Text("Passwords do not match.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    focusedField = nil
                    Task {
                        await auth.signUp(
                            name: name.trimmingCharacters(in: .whitespaces),
                            email: email.trimmingCharacters(in: .whitespaces),
                            password: password,
                            role: selectedRole
                        )
                    }
                } label: {
                    Group {
                        if auth.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Account").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!formIsValid || auth.isLoading)

                Button("Already have an account? Log in") { dismiss() }
                    .font(.subheadline)
                    .foregroundStyle(.tint)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var passwordsMatch: Bool { password == confirmPassword }

    private var formIsValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6 &&
        passwordsMatch
    }
}

// MARK: - Subviews

private struct RolePill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title).fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct InputField: View {
    let label: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(label, text: $text)
            } else {
                TextField(label, text: $text)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
