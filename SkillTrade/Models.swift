import Foundation

// MARK: - Enums

enum Role {
    case homeowner
    case provider
}

enum BookingStatus {
    case pending
    case confirmed
    case completed
}

enum ServiceCategory: String, CaseIterable {
    case plumber   = "Plumber"
    case electrician = "Electrician"
    case hvac      = "HVAC"
    case roofer    = "Roofer"
    case handyman  = "Handyman"
}

// MARK: - Models

struct User: Identifiable {
    let id: UUID
    let name: String
    let role: Role
}

struct Provider: Identifiable {
    let id: UUID
    let name: String
    let businessName: String
    let services: [String]
    let bio: String
    let city: String
    let averageRating: Double
    let reviewCount: Int
    let category: ServiceCategory
}

struct Booking: Identifiable {
    let id: UUID
    let homeownerId: UUID
    let providerId: UUID
    let service: String
    let description: String
    var status: BookingStatus
    let scheduledDate: Date
}

struct Review: Identifiable {
    let id: UUID
    let providerId: UUID
    let homeownerName: String
    let rating: Int
    let comment: String
}
