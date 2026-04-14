import Foundation
import FirebaseFirestore

// MARK: - User
struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var name: String
    var email: String
    var role: String
    var createdAt: Date?
}

// MARK: - Provider
struct Provider: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var name: String
    var email: String
    var services: [String]
    var bio: String
    var rating: Double
    var reviewCount: Int
    var location: String
    var availability: [String: DayAvailability]
    var createdAt: Date?
}

struct DayAvailability: Codable {
    var open: String    // e.g. "08:00"
    var close: String   // e.g. "17:00"
}

// MARK: - Booking
struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    var homeownerID: String
    var homeownerName: String
    var providerID: String
    var providerName: String
    var serviceType: String
    var problemDescription: String
    var status: String   // "pending" | "accepted" | "completed" | "cancelled"
    var scheduledDate: Date?
    var createdAt: Date?
}

// MARK: - Conversation
struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var homeownerID: String
    var providerID: String
    var bookingID: String
    var createdAt: Date?
}

// MARK: - Message
struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var conversationID: String
    var senderID: String
    var text: String
    var sentAt: Date?
}

// MARK: - Review
struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var providerID: String
    var homeownerID: String
    var homeownerName: String
    var bookingID: String
    var rating: Double
    var comment: String
    var createdAt: Date?
}

// MARK: - Service categories
enum ServiceCategory: String, CaseIterable {
    case plumber     = "Plumber"
    case electrician = "Electrician"
    case roofer      = "Roofer"
    case hvac        = "HVAC"
    case handyman    = "Handyman"
    case painter     = "Painter"

    var icon: String {
        switch self {
        case .plumber:     return "drop.fill"
        case .electrician: return "bolt.fill"
        case .roofer:      return "house.fill"
        case .hvac:        return "wind"
        case .handyman:    return "wrench.and.screwdriver.fill"
        case .painter:     return "paintbrush.fill"
        }
    }
}

let daysOfWeek = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
