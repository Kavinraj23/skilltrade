import Foundation
import Combine

@MainActor
final class HomeownerViewModel: ObservableObject {

    private let data = MockDataService.shared
    let currentUser: User

    @Published var bookings: [Booking]
    @Published var searchQuery: String = ""
    @Published var searchResults: [Provider] = []
    @Published var resolvedCategory: ServiceCategory = .handyman

    init() {
        self.currentUser = MockDataService.shared.homeowner
        self.bookings = MockDataService.shared.bookings(forHomeowner: MockDataService.shared.homeowner.id)
    }

    // MARK: - Search

    func search() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        resolvedCategory = data.resolveCategory(from: searchQuery)
        searchResults = data.providers(for: resolvedCategory)
    }

    // MARK: - Reviews

    func reviews(for provider: Provider) -> [Review] {
        data.reviews(for: provider.id)
    }

    // MARK: - Bookings

    func addBooking(providerId: UUID, service: String, description: String, date: Date) {
        let booking = Booking(
            id: UUID(),
            homeownerId: currentUser.id,
            providerId: providerId,
            service: service,
            description: description,
            status: .pending,
            scheduledDate: date
        )
        data.bookings.append(booking)
        bookings = data.bookings(forHomeowner: currentUser.id)
    }

    func providerName(for booking: Booking) -> String {
        data.providers.first { $0.id == booking.providerId }?.businessName ?? "Unknown Provider"
    }
}
