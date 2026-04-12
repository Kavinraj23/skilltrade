import Foundation
import FirebaseFirestore

// MARK: - Enums

enum Role: String, Codable {
    case homeowner
    case provider
}

enum BookingStatus: String, Codable {
    case pending
    case confirmed
    case completed
    case declined
}

enum ServiceCategory: String, Codable, CaseIterable {
    case plumber     = "Plumber"
    case electrician = "Electrician"
    case hvac        = "HVAC"
    case roofer      = "Roofer"
    case handyman    = "Handyman"
}

// MARK: - Models
// IDs are now String (Firestore document IDs) instead of UUID.
// @DocumentID auto-populates `id` when Firestore decodes a document.

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let email: String
    let role: Role
}

struct Provider: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let businessName: String
    let services: [String]
    let bio: String
    let city: String
    let category: ServiceCategory
    var averageRating: Double
    var reviewCount: Int
    var photoURL: String?
}

struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    let homeownerId: String
    let providerId: String
    let service: String
    let description: String
    var status: BookingStatus
    let scheduledDate: Date
}

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    let homeownerId: String
    let homeownerName: String
    let rating: Int
    let comment: String
}
