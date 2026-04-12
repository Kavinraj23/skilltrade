import Foundation
import FirebaseFirestore

// MARK: - MockDataService
// Hardcoded data used for previews and the keyword resolver.
// All live data now comes from FirestoreService — this file is kept only
// for SwiftUI previews and the resolveCategory helper.

final class MockDataService {

    static let shared = MockDataService()
    private init() {}

    // MARK: - Stable String IDs

    private let p1 = "provider-001"
    private let p2 = "provider-002"
    private let p3 = "provider-003"
    private let p4 = "provider-004"
    private let p5 = "provider-005"
    private let p6 = "provider-006"
    private let p7 = "provider-007"
    private let p8 = "provider-008"

    // MARK: - Preview Users

    let homeowner = User(
        id: "homeowner-001",
        name: "Alex Johnson",
        email: "alex@example.com",
        role: .homeowner
    )

    let providerUser = User(
        id: "provider-001",
        name: "Marco Rivera",
        email: "marco@example.com",
        role: .provider
    )

    // MARK: - Preview Providers

    lazy var providers: [Provider] = [
        Provider(
            id: p1,
            name: "Marco Rivera",
            businessName: "Rivera Plumbing Co.",
            services: ["Leak Repair", "Pipe Installation", "Drain Cleaning"],
            bio: "15 years of residential and commercial plumbing across the Bay Area. Licensed and insured.",
            city: "San Jose",
            category: .plumber,
            averageRating: 4.8,
            reviewCount: 3
        ),
        Provider(
            id: p2,
            name: "Dana Park",
            businessName: "Park & Sons Plumbing",
            services: ["Water Heater Install", "Pipe Repair", "Bathroom Remodel"],
            bio: "Family-run business since 1998. We treat every home like our own.",
            city: "Oakland",
            category: .plumber,
            averageRating: 4.5,
            reviewCount: 2
        ),
        Provider(
            id: p3,
            name: "Jordan Lee",
            businessName: "Bright Wire Electric",
            services: ["Panel Upgrades", "Outlet Installation", "Lighting"],
            bio: "Master electrician with 10+ years of experience. Safety-first approach on every job.",
            city: "San Francisco",
            category: .electrician,
            averageRating: 4.9,
            reviewCount: 3
        ),
        Provider(
            id: p4,
            name: "Sam Torres",
            businessName: "Torres Electric LLC",
            services: ["Rewiring", "EV Charger Install", "Troubleshooting"],
            bio: "Specializing in modern smart-home wiring and EV infrastructure.",
            city: "Fremont",
            category: .electrician,
            averageRating: 4.6,
            reviewCount: 2
        ),
        Provider(
            id: p5,
            name: "Chris Nguyen",
            businessName: "Cool Comfort HVAC",
            services: ["AC Install", "Furnace Repair", "Duct Cleaning"],
            bio: "Certified HVAC technician. We keep you cool in summer and warm in winter.",
            city: "Santa Clara",
            category: .hvac,
            averageRating: 4.7,
            reviewCount: 3
        ),
        Provider(
            id: p6,
            name: "Riley Kim",
            businessName: "Kim Roofing & More",
            services: ["Shingle Replacement", "Leak Inspection", "Gutter Repair"],
            bio: "Licensed roofer with 20 years in the trade. Every job comes with a 5-year warranty.",
            city: "Sunnyvale",
            category: .roofer,
            averageRating: 4.4,
            reviewCount: 2
        ),
        Provider(
            id: p7,
            name: "Taylor Brown",
            businessName: "Brown's Handyman Services",
            services: ["Furniture Assembly", "Drywall Repair", "Painting"],
            bio: "No job too small. Available weekends and evenings.",
            city: "Berkeley",
            category: .handyman,
            averageRating: 4.3,
            reviewCount: 3
        ),
        Provider(
            id: p8,
            name: "Morgan Wells",
            businessName: "Wells All-Around Repairs",
            services: ["General Repairs", "Carpentry", "Door & Window Fixes"],
            bio: "Jack of all trades, master of getting things done right the first time.",
            city: "Palo Alto",
            category: .handyman,
            averageRating: 4.6,
            reviewCount: 2
        )
    ]

    // MARK: - Preview Reviews

    lazy var reviews: [Review] = [
        Review(id: "r1",  homeownerId: "homeowner-001", homeownerName: "Alex J.",   rating: 5, comment: "Fixed our leak in under an hour. Super professional."),
        Review(id: "r2",  homeownerId: "homeowner-001", homeownerName: "Beth T.",   rating: 5, comment: "Arrived on time, clean work, fair price."),
        Review(id: "r3",  homeownerId: "homeowner-001", homeownerName: "Carlos M.", rating: 4, comment: "Great service, just a little pricey.")
    ]

    // MARK: - Preview Bookings

    lazy var bookings: [Booking] = {
        let tomorrow  = Calendar.current.date(byAdding: .day, value: 1,  to: Date())!
        let nextWeek  = Calendar.current.date(byAdding: .day, value: 7,  to: Date())!
        let lastWeek  = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return [
            Booking(id: "b1", homeownerId: "homeowner-001", providerId: p1,
                    service: "Leak Repair",        description: "Kitchen faucet dripping.",
                    status: .confirmed,  scheduledDate: tomorrow),
            Booking(id: "b2", homeownerId: "homeowner-001", providerId: p3,
                    service: "Outlet Installation", description: "Two new outlets in garage.",
                    status: .pending,    scheduledDate: nextWeek),
            Booking(id: "b3", homeownerId: "homeowner-001", providerId: p5,
                    service: "AC Install",          description: "Replace window unit with mini-split.",
                    status: .completed,  scheduledDate: lastWeek)
        ]
    }()

    // MARK: - Keyword → Category resolver (used by HomeownerViewModel)

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
