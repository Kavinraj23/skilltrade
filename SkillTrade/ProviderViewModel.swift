import Foundation
import Combine

@MainActor
final class ProviderViewModel: ObservableObject {

    private let data = MockDataService.shared
    let currentProvider: Provider

    @Published var bookings: [Booking]

    init() {
        // The hardcoded provider user maps to the first provider (Marco Rivera)
        self.currentProvider = MockDataService.shared.providers[0]
        self.bookings = MockDataService.shared.bookings(forProvider: MockDataService.shared.providers[0].id)
    }

    var pendingBookings: [Booking] {
        bookings.filter { $0.status == .pending }
    }

    var confirmedBookings: [Booking] {
        bookings.filter { $0.status == .confirmed }
    }

    func homeownerName(for booking: Booking) -> String {
        // In a real app this would look up the user; for mock data the homeowner is always Alex Johnson
        return MockDataService.shared.homeowner.name
    }

    func confirm(_ booking: Booking) {
        update(booking, to: .confirmed)
    }

    func decline(_ booking: Booking) {
        update(booking, to: .completed) // using .completed as "declined/closed" for now
    }

    private func update(_ booking: Booking, to status: BookingStatus) {
        if let idx = data.bookings.firstIndex(where: { $0.id == booking.id }) {
            data.bookings[idx].status = status
        }
        bookings = data.bookings(forProvider: currentProvider.id)
    }
}
