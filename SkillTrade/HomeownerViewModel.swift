import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class HomeownerViewModel: ObservableObject {

    private let service = FirestoreService.shared
    private var listenerHandle: ListenerRegistration?

    @Published var bookings: [Booking] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [Provider] = []
    @Published var resolvedCategory: ServiceCategory = .handyman
    @Published var isLoading = false
    @Published var errorMessage: String?

    var currentUserId: String { Auth.auth().currentUser?.uid ?? "" }

    init() {
        startBookingListener()
    }

    deinit {
        listenerHandle?.remove()
    }

    // MARK: - Bookings

    private func startBookingListener() {
        guard !currentUserId.isEmpty else { return }
        listenerHandle = service.listenToBookings(forHomeowner: currentUserId) { [weak self] bookings in
            self?.bookings = bookings
        }
    }

    func addBooking(providerId: String, service: String, description: String, date: Date) async {
        let booking = Booking(
            homeownerId: currentUserId,
            providerId: providerId,
            service: service,
            description: description,
            status: .pending,
            scheduledDate: date
        )
        do {
            try await self.service.addBooking(booking)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search

    func search() async {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { searchResults = []; return }

        resolvedCategory = MockDataService.shared.resolveCategory(from: query)
        isLoading = true
        defer { isLoading = false }

        do {
            searchResults = try await service.providers(for: resolvedCategory)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Reviews

    func reviews(for provider: Provider) async -> [Review] {
        guard let id = provider.id else { return [] }
        return (try? await service.reviews(forProvider: id)) ?? []
    }

    // MARK: - Helpers

    func providerName(for booking: Booking) -> String {
        // Resolved lazily; in a full app cache provider names after fetching
        booking.service
    }
}
