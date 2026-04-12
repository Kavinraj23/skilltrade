import Foundation
import FirebaseFirestore

// MARK: - FirestoreService
// Drop-in replacement for MockDataService.
// ViewModels call these methods; swap the implementation here to change the backend.

final class FirestoreService {

    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Providers

    func providers(for category: ServiceCategory) async throws -> [Provider] {
        let snapshot = try await db.collection("providers")
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "averageRating", descending: true)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Provider.self) }
    }

    func provider(id: String) async throws -> Provider {
        let doc = try await db.collection("providers").document(id).getDocument()
        return try doc.data(as: Provider.self)
    }

    // MARK: - Reviews

    func reviews(forProvider providerId: String) async throws -> [Review] {
        let snapshot = try await db.collection("providers")
            .document(providerId)
            .collection("reviews")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Review.self) }
    }

    func addReview(_ review: Review, forProvider providerId: String) async throws {
        let ref = db.collection("providers").document(providerId).collection("reviews").document()
        try ref.setData(from: review)
    }

    // MARK: - Bookings

    func bookings(forHomeowner homeownerId: String) async throws -> [Booking] {
        let snapshot = try await db.collection("bookings")
            .whereField("homeownerId", isEqualTo: homeownerId)
            .order(by: "scheduledDate", descending: false)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Booking.self) }
    }

    func bookings(forProvider providerId: String) async throws -> [Booking] {
        let snapshot = try await db.collection("bookings")
            .whereField("providerId", isEqualTo: providerId)
            .order(by: "scheduledDate", descending: false)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Booking.self) }
    }

    func addBooking(_ booking: Booking) async throws {
        let ref = db.collection("bookings").document()
        try ref.setData(from: booking)
    }

    func updateBookingStatus(bookingId: String, status: BookingStatus) async throws {
        try await db.collection("bookings")
            .document(bookingId)
            .updateData(["status": status.rawValue])
    }

    // MARK: - Real-time Listeners
    // Returns a detach handle — call it in onDisappear to stop listening.

    func listenToBookings(forHomeowner homeownerId: String, onChange: @escaping ([Booking]) -> Void) -> ListenerRegistration {
        db.collection("bookings")
            .whereField("homeownerId", isEqualTo: homeownerId)
            .order(by: "scheduledDate", descending: false)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let bookings = docs.compactMap { try? $0.data(as: Booking.self) }
                onChange(bookings)
            }
    }

    func listenToBookings(forProvider providerId: String, onChange: @escaping ([Booking]) -> Void) -> ListenerRegistration {
        db.collection("bookings")
            .whereField("providerId", isEqualTo: providerId)
            .order(by: "scheduledDate", descending: false)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let bookings = docs.compactMap { try? $0.data(as: Booking.self) }
                onChange(bookings)
            }
    }

    // MARK: - Users

    func createUserDoc(_ user: User) async throws {
        guard let id = user.id else { return }
        try db.collection("users").document(id).setData(from: user)
    }

    func fetchUser(id: String) async throws -> User {
        let doc = try await db.collection("users").document(id).getDocument()
        return try doc.data(as: User.self)
    }

    // MARK: - Seed (debug only — delete after first run)

    #if DEBUG
    func seedProviders() async throws {
        let providers: [[String: Any]] = [
            [
                "name": "Marco Rivera", "businessName": "Rivera Plumbing Co.",
                "bio": "15 years of residential and commercial plumbing across the Bay Area. Licensed and insured.",
                "city": "San Jose", "category": "Plumber",
                "services": ["Leak Repair", "Pipe Installation", "Drain Cleaning"],
                "averageRating": 4.8, "reviewCount": 3
            ],
            [
                "name": "Dana Park", "businessName": "Park & Sons Plumbing",
                "bio": "Family-run business since 1998. We treat every home like our own.",
                "city": "Oakland", "category": "Plumber",
                "services": ["Water Heater Install", "Pipe Repair", "Bathroom Remodel"],
                "averageRating": 4.5, "reviewCount": 2
            ],
            [
                "name": "Jordan Lee", "businessName": "Bright Wire Electric",
                "bio": "Master electrician with 10+ years of experience. Safety-first approach on every job.",
                "city": "San Francisco", "category": "Electrician",
                "services": ["Panel Upgrades", "Outlet Installation", "Lighting"],
                "averageRating": 4.9, "reviewCount": 3
            ],
            [
                "name": "Sam Torres", "businessName": "Torres Electric LLC",
                "bio": "Specializing in modern smart-home wiring and EV infrastructure.",
                "city": "Fremont", "category": "Electrician",
                "services": ["Rewiring", "EV Charger Install", "Troubleshooting"],
                "averageRating": 4.6, "reviewCount": 2
            ],
            [
                "name": "Chris Nguyen", "businessName": "Cool Comfort HVAC",
                "bio": "Certified HVAC technician. We keep you cool in summer and warm in winter.",
                "city": "Santa Clara", "category": "HVAC",
                "services": ["AC Install", "Furnace Repair", "Duct Cleaning"],
                "averageRating": 4.7, "reviewCount": 3
            ],
            [
                "name": "Riley Kim", "businessName": "Kim Roofing & More",
                "bio": "Licensed roofer with 20 years in the trade. Every job comes with a 5-year warranty.",
                "city": "Sunnyvale", "category": "Roofer",
                "services": ["Shingle Replacement", "Leak Inspection", "Gutter Repair"],
                "averageRating": 4.4, "reviewCount": 2
            ],
            [
                "name": "Taylor Brown", "businessName": "Brown's Handyman Services",
                "bio": "No job too small. Available weekends and evenings.",
                "city": "Berkeley", "category": "Handyman",
                "services": ["Furniture Assembly", "Drywall Repair", "Painting"],
                "averageRating": 4.3, "reviewCount": 3
            ],
            [
                "name": "Morgan Wells", "businessName": "Wells All-Around Repairs",
                "bio": "Jack of all trades, master of getting things done right the first time.",
                "city": "Palo Alto", "category": "Handyman",
                "services": ["General Repairs", "Carpentry", "Door & Window Fixes"],
                "averageRating": 4.6, "reviewCount": 2
            ]
        ]
        for p in providers {
            try await db.collection("providers").addDocument(data: p)
        }
        print("✅ Providers seeded")
    }
    #endif
}
