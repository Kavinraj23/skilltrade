import SwiftUI

struct ProviderProfileView: View {
    @EnvironmentObject var vm: HomeownerViewModel
    let provider: Provider
    @State private var showBookingForm = false
    @State private var reviews: [Review] = []

    var body: some View {
        List {
            // Header
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
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 4)
            }

            // Bio
            Section("About") {
                Text(provider.bio)
                    .font(.subheadline)
            }

            // Services
            Section("Services") {
                ForEach(provider.services, id: \.self) { service in
                    Label(service, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }

            // Reviews
            Section("Reviews") {
                if reviews.isEmpty {
                    Text("No reviews yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(reviews) { review in
                        ReviewRow(review: review)
                    }
                }
            }
        }
        .navigationTitle(provider.businessName)
        .navigationBarTitleDisplayMode(.inline)
        .task { reviews = await vm.reviews(for: provider) }
        .safeAreaInset(edge: .bottom) {
            Button {
                showBookingForm = true
            } label: {
                Text("Book Now")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            .background(.regularMaterial)
        }
        .sheet(isPresented: $showBookingForm) {
            BookingFormView(provider: provider)
                .environmentObject(vm)
        }
    }
}

struct ReviewRow: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                StarRatingView(rating: Double(review.rating))
                Spacer()
                Text(review.homeownerName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(review.comment)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        ProviderProfileView(provider: MockDataService.shared.providers[0])
            .environmentObject(HomeownerViewModel())
    }
}
