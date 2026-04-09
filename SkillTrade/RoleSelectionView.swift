import SwiftUI

struct RoleSelectionView: View {
    @State private var selectedRole: Role? = nil

    var body: some View {
        if let role = selectedRole {
            switch role {
            case .homeowner:
                HomeownerRootView()
            case .provider:
                ProviderRootView()
            }
        } else {
            selectionScreen
        }
    }

    private var selectionScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("SkillTrade")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Connect with trusted tradespeople")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 16) {
                Button {
                    selectedRole = .homeowner
                } label: {
                    RoleCard(
                        icon: "house.fill",
                        title: "I need help",
                        subtitle: "Find a tradesperson for your home"
                    )
                }

                Button {
                    selectedRole = .provider
                } label: {
                    RoleCard(
                        icon: "wrench.and.screwdriver.fill",
                        title: "I'm a tradesperson",
                        subtitle: "Manage your bookings and profile"
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct RoleCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RoleSelectionView()
}
