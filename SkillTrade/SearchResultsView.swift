import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var vm: HomeownerViewModel

    var body: some View {
        Group {
            if vm.searchResults.isEmpty {
                ContentUnavailableView(
                    "No results",
                    systemImage: "magnifyingglass",
                    description: Text("Try describing your problem differently.")
                )
            } else {
                List(vm.searchResults) { provider in
                    NavigationLink(destination: ProviderProfileView(provider: provider).environmentObject(vm)) {
                        ProviderRow(provider: provider)
                    }
                }
            }
        }
        .navigationTitle(vm.resolvedCategory.rawValue + "s")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProviderRow: View {
    let provider: Provider

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(provider.businessName)
                .font(.headline)
            Text(provider.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                StarRatingView(rating: provider.averageRating)
                Text(String(format: "%.1f", provider.averageRating))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("(\(provider.reviewCount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label(provider.city, systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StarRatingView: View {
    let rating: Double
    var maxStars: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxStars, id: \.self) { star in
                Image(systemName: starImage(for: star))
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
    }

    private func starImage(for star: Int) -> String {
        if Double(star) <= rating {
            return "star.fill"
        } else if Double(star) - 0.5 <= rating {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

#Preview {
    let vm = HomeownerViewModel()
    vm.searchQuery = "pipe leak"
    vm.searchResults = MockDataService.shared.providers.filter { $0.category == .plumber }
    vm.resolvedCategory = .plumber
    return NavigationStack {
        SearchResultsView()
            .environmentObject(vm)
    }
}
