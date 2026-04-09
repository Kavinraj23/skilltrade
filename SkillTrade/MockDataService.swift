import Foundation

// MARK: - MockDataService
// Single source of truth for all hardcoded data.
// Replace these methods with Firestore calls to swap in Firebase later.

final class MockDataService {

    static let shared = MockDataService()
    private init() {}

    // MARK: - Users

    let homeowner = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Alex Johnson",
        role: .homeowner
    )

    let providerUser = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "Marco Rivera",
        role: .provider
    )

    // MARK: - Provider IDs (stable so bookings/reviews can reference them)

    private let p1 = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    private let p2 = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
    private let p3 = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!
    private let p4 = UUID(uuidString: "10000000-0000-0000-0000-000000000004")!
    private let p5 = UUID(uuidString: "10000000-0000-0000-0000-000000000005")!
    private let p6 = UUID(uuidString: "10000000-0000-0000-0000-000000000006")!
    private let p7 = UUID(uuidString: "10000000-0000-0000-0000-000000000007")!
    private let p8 = UUID(uuidString: "10000000-0000-0000-0000-000000000008")!

    // MARK: - Providers

    lazy var providers: [Provider] = [
        Provider(
            id: p1,
            name: "Marco Rivera",
            businessName: "Rivera Plumbing Co.",
            services: ["Leak Repair", "Pipe Installation", "Drain Cleaning"],
            bio: "15 years of residential and commercial plumbing across the Bay Area. Licensed and insured.",
            city: "San Jose",
            averageRating: 4.8,
            reviewCount: 3,
            category: .plumber
        ),
        Provider(
            id: p2,
            name: "Dana Park",
            businessName: "Park & Sons Plumbing",
            services: ["Water Heater Install", "Pipe Repair", "Bathroom Remodel"],
            bio: "Family-run business since 1998. We treat every home like our own.",
            city: "Oakland",
            averageRating: 4.5,
            reviewCount: 2,
            category: .plumber
        ),
        Provider(
            id: p3,
            name: "Jordan Lee",
            businessName: "Bright Wire Electric",
            services: ["Panel Upgrades", "Outlet Installation", "Lighting"],
            bio: "Master electrician with 10+ years of experience. Safety-first approach on every job.",
            city: "San Francisco",
            averageRating: 4.9,
            reviewCount: 3,
            category: .electrician
        ),
        Provider(
            id: p4,
            name: "Sam Torres",
            businessName: "Torres Electric LLC",
            services: ["Rewiring", "EV Charger Install", "Troubleshooting"],
            bio: "Specializing in modern smart-home wiring and EV infrastructure.",
            city: "Fremont",
            averageRating: 4.6,
            reviewCount: 2,
            category: .electrician
        ),
        Provider(
            id: p5,
            name: "Chris Nguyen",
            businessName: "Cool Comfort HVAC",
            services: ["AC Install", "Furnace Repair", "Duct Cleaning"],
            bio: "Certified HVAC technician. We keep you cool in summer and warm in winter.",
            city: "Santa Clara",
            averageRating: 4.7,
            reviewCount: 3,
            category: .hvac
        ),
        Provider(
            id: p6,
            name: "Riley Kim",
            businessName: "Kim Roofing & More",
            services: ["Shingle Replacement", "Leak Inspection", "Gutter Repair"],
            bio: "Licensed roofer with 20 years in the trade. Every job comes with a 5-year warranty.",
            city: "Sunnyvale",
            averageRating: 4.4,
            reviewCount: 2,
            category: .roofer
        ),
        Provider(
            id: p7,
            name: "Taylor Brown",
            businessName: "Brown's Handyman Services",
            services: ["Furniture Assembly", "Drywall Repair", "Painting"],
            bio: "No job too small. Available weekends and evenings.",
            city: "Berkeley",
            averageRating: 4.3,
            reviewCount: 3,
            category: .handyman
        ),
        Provider(
            id: p8,
            name: "Morgan Wells",
            businessName: "Wells All-Around Repairs",
            services: ["General Repairs", "Carpentry", "Door & Window Fixes"],
            bio: "Jack of all trades, master of getting things done right the first time.",
            city: "Palo Alto",
            averageRating: 4.6,
            reviewCount: 2,
            category: .handyman
        )
    ]

    // MARK: - Reviews

    lazy var reviews: [Review] = [
        // Rivera Plumbing (p1)
        Review(id: UUID(), providerId: p1, homeownerName: "Alex J.", rating: 5, comment: "Fixed our leak in under an hour. Super professional."),
        Review(id: UUID(), providerId: p1, homeownerName: "Beth T.", rating: 5, comment: "Arrived on time, clean work, fair price."),
        Review(id: UUID(), providerId: p1, homeownerName: "Carlos M.", rating: 4, comment: "Great service, just a little pricey."),

        // Park & Sons (p2)
        Review(id: UUID(), providerId: p2, homeownerName: "Diana L.", rating: 5, comment: "Replaced our water heater quickly and efficiently."),
        Review(id: UUID(), providerId: p2, homeownerName: "Evan R.", rating: 4, comment: "Good work, friendly crew."),

        // Bright Wire (p3)
        Review(id: UUID(), providerId: p3, homeownerName: "Fiona K.", rating: 5, comment: "Upgraded our panel seamlessly. Very knowledgeable."),
        Review(id: UUID(), providerId: p3, homeownerName: "George P.", rating: 5, comment: "Installed 6 outlets in one afternoon. Impressed."),
        Review(id: UUID(), providerId: p3, homeownerName: "Hannah S.", rating: 5, comment: "Best electrician I've ever hired."),

        // Torres Electric (p4)
        Review(id: UUID(), providerId: p4, homeownerName: "Ivan N.", rating: 5, comment: "EV charger installed perfectly. Highly recommend."),
        Review(id: UUID(), providerId: p4, homeownerName: "Julia W.", rating: 4, comment: "Smart and efficient. Prices are fair."),

        // Cool Comfort (p5)
        Review(id: UUID(), providerId: p5, homeownerName: "Kevin O.", rating: 5, comment: "AC is ice cold again. Life saver."),
        Review(id: UUID(), providerId: p5, homeownerName: "Laura H.", rating: 5, comment: "Fast turnaround on furnace repair."),
        Review(id: UUID(), providerId: p5, homeownerName: "Mike Z.", rating: 4, comment: "Good job, communicated well throughout."),

        // Kim Roofing (p6)
        Review(id: UUID(), providerId: p6, homeownerName: "Nancy B.", rating: 4, comment: "Fixed the leak before the next rainstorm. Thank you!"),
        Review(id: UUID(), providerId: p6, homeownerName: "Oscar F.", rating: 5, comment: "Replaced all shingles in one day. Spotless cleanup."),

        // Brown's Handyman (p7)
        Review(id: UUID(), providerId: p7, homeownerName: "Paula G.", rating: 4, comment: "Assembled my IKEA furniture without complaint."),
        Review(id: UUID(), providerId: p7, homeownerName: "Quinn A.", rating: 4, comment: "Painted the living room beautifully."),
        Review(id: UUID(), providerId: p7, homeownerName: "Rachel D.", rating: 5, comment: "Patched drywall — you can't even tell it was damaged."),

        // Wells All-Around (p8)
        Review(id: UUID(), providerId: p8, homeownerName: "Steve C.", rating: 5, comment: "Fixed squeaky doors and stuck windows in one visit."),
        Review(id: UUID(), providerId: p8, homeownerName: "Tina M.", rating: 4, comment: "Solid carpenter, very punctual.")
    ]

    // MARK: - Bookings (in-memory, mutable)

    lazy var bookings: [Booking] = {
        let calendar = Calendar.current
        let tomorrow   = calendar.date(byAdding: .day, value: 1,  to: Date())!
        let nextWeek   = calendar.date(byAdding: .day, value: 7,  to: Date())!
        let lastWeek   = calendar.date(byAdding: .day, value: -7, to: Date())!
        let homeownerId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        return [
            Booking(
                id: UUID(),
                homeownerId: homeownerId,
                providerId: p1,
                service: "Leak Repair",
                description: "Kitchen faucet dripping constantly.",
                status: .confirmed,
                scheduledDate: tomorrow
            ),
            Booking(
                id: UUID(),
                homeownerId: homeownerId,
                providerId: p3,
                service: "Outlet Installation",
                description: "Need two new outlets in the garage.",
                status: .pending,
                scheduledDate: nextWeek
            ),
            Booking(
                id: UUID(),
                homeownerId: homeownerId,
                providerId: p5,
                service: "AC Install",
                description: "Replace old window unit with mini-split.",
                status: .completed,
                scheduledDate: lastWeek
            )
        ]
    }()

    // MARK: - Helpers

    func providers(for category: ServiceCategory) -> [Provider] {
        providers.filter { $0.category == category }
    }

    func reviews(for providerId: UUID) -> [Review] {
        reviews.filter { $0.providerId == providerId }
    }

    func bookings(forHomeowner homeownerId: UUID) -> [Booking] {
        bookings.filter { $0.homeownerId == homeownerId }
    }

    func bookings(forProvider providerId: UUID) -> [Booking] {
        bookings.filter { $0.providerId == providerId }
    }

    func provider(for booking: Booking) -> Provider? {
        providers.first { $0.id == booking.providerId }
    }

    func resolveCategory(from query: String) -> ServiceCategory {
        let q = query.lowercased()
        if q.contains("leak") || q.contains("pipe") || q.contains("water") || q.contains("drain") || q.contains("faucet") {
            return .plumber
        } else if q.contains("light") || q.contains("outlet") || q.contains("electric") || q.contains("wire") || q.contains("circuit") {
            return .electrician
        } else if q.contains("heat") || q.contains("ac") || q.contains("cool") || q.contains("hvac") || q.contains("furnace") || q.contains("air") {
            return .hvac
        } else if q.contains("roof") || q.contains("shingle") || q.contains("gutter") {
            return .roofer
        } else {
            return .handyman
        }
    }
}
