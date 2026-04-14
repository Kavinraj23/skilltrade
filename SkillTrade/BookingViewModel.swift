import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    // MARK: - Create booking (homeowner)
    func createBooking(provider: Provider, serviceType: String,
                       problemDescription: String, scheduledDate: Date,
                       homeownerName: String, completion: (() -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        db.collection("bookings").addDocument(data: [
            "homeownerID": uid,
            "homeownerName": homeownerName,
            "providerID": provider.uid,
            "providerName": provider.name,
            "serviceType": serviceType,
            "problemDescription": problemDescription,
            "status": "pending",
            "scheduledDate": Timestamp(date: scheduledDate),
            "createdAt": Timestamp(date: Date())
        ]) { [weak self] _ in
            self?.isLoading = false
            completion?()
        }
    }

    // MARK: - Fetch homeowner bookings
    func fetchHomeownerBookings() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        db.collection("bookings")
            .whereField("homeownerID", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isLoading = false
                self.bookings = snapshot?.documents.compactMap {
                    try? $0.data(as: Booking.self)
                } ?? []
            }
    }

    // MARK: - Fetch provider bookings
    func fetchProviderBookings() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        db.collection("bookings")
            .whereField("providerID", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isLoading = false
                self.bookings = snapshot?.documents.compactMap {
                    try? $0.data(as: Booking.self)
                } ?? []
            }
    }

    // MARK: - Update booking status (provider accepts/declines, or mark complete)
    func updateStatus(bookingID: String, status: String,
                      completion: (() -> Void)? = nil) {
        db.collection("bookings").document(bookingID)
            .updateData(["status": status]) { _ in completion?() }
    }

    // MARK: - Accept booking + create conversation
    func acceptBooking(booking: Booking) {
        guard let bookingID = booking.id else { return }

        // Update booking status
        updateStatus(bookingID: bookingID, status: "accepted") { [weak self] in
            guard let self = self else { return }
            // Create conversation document
            self.db.collection("conversations").addDocument(data: [
                "homeownerID": booking.homeownerID,
                "providerID": booking.providerID,
                "bookingID": bookingID,
                "createdAt": Timestamp(date: Date())
            ])
        }
    }
}
