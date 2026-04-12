import SwiftUI

struct ProviderMyProfileView: View {
    @EnvironmentObject var vm: ProviderViewModel

    var body: some View {
        Group {
            if let provider = vm.currentProvider {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(provider.businessName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(provider.name)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                StarRatingView(rating: provider.averageRating)
                                Text(String(format: "%.1f", provider.averageRating))
                                    .fontWeight(.semibold)
                                Text("· \(provider.reviewCount) reviews")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Label(provider.city, systemImage: "location.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }

                    Section("About") {
                        Text(provider.bio)
                            .font(.subheadline)
                    }

                    Section("Services Offered") {
                        ForEach(provider.services, id: \.self) { service in
                            Label(service, systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                        }
                    }

                    Section("Stats") {
                        LabeledContent("Average Rating", value: String(format: "%.1f / 5.0", provider.averageRating))
                        LabeledContent("Total Reviews", value: "\(provider.reviewCount)")
                        LabeledContent("Category", value: provider.category.rawValue)
                    }
                }
            } else {
                ProgressView("Loading profile...")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProviderMyProfileView()
            .environmentObject(ProviderViewModel())
            .navigationTitle("My Profile")
    }
}
