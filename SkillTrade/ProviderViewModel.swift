import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class ProviderViewModel: ObservableObject {

    private let service = FirestoreService.shared
    private var listenerHandle: ListenerRegistration?

    @Published var currentProvider: Provider?
    @Published var bookings: [Booking] = []
    @Published var errorMessage: String?

    var currentUserId: String { Auth.auth().currentUser?.uid ?? "" }

    var pendingBookings: [Booking]   { bookings.filter { $0.status == .pending } }
    var confirmedBookings: [Booking] { bookings.filter { $0.status == .confirmed } }

    init() {
        Task {
            await loadProvider()
            startBookingListener()
        }
    }

    deinit {
        listenerHandle?.remove()
    }

    // MARK: - Provider Profile

    private func loadProvider() async {
        guard !currentUserId.isEmpty else { return }
        currentProvider = try? await service.provider(id: currentUserId)
    }

    // MARK: - Bookings

    private func startBookingListener() {
        guard !currentUserId.isEmpty else { return }
        listenerHandle = service.listenToBookings(forProvider: currentUserId) { [weak self] bookings in
            self?.bookings = bookings
        }
    }

    func confirm(_ booking: Booking) {
        updateStatus(booking, to: .confirmed)
    }

    func decline(_ booking: Booking) {
        updateStatus(booking, to: .declined)
    }

    private func updateStatus(_ booking: Booking, to status: BookingStatus) {
        guard let id = booking.id else { return }
        Task {
            do {
                try await service.updateBookingStatus(bookingId: id, status: status)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func homeownerName(for booking: Booking) -> String {
        // Placeholder — wire to a users cache once Auth is in place
        "Homeowner"
    }
}
