import SwiftUI

// MARK: - Tab container
struct HomeownerTabView: View {
    var body: some View {
        TabView {
            HomeownerSearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            HomeownerBookingsView()
                .tabItem { Label("Bookings", systemImage: "calendar") }
            HomeownerInboxView()
                .tabItem { Label("Messages", systemImage: "message") }
            HomeownerProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

// MARK: - Search
struct HomeownerSearchView: View {
    @StateObject private var vm = ProvidersViewModel()
    @State private var selectedCategory: ServiceCategory? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryChip(label: "All", icon: "square.grid.2x2",
                                     isSelected: selectedCategory == nil) {
                            selectedCategory = nil; vm.fetchProviders()
                        }
                        ForEach(ServiceCategory.allCases, id: \.self) { cat in
                            CategoryChip(label: cat.rawValue, icon: cat.icon,
                                         isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                                vm.fetchProviders(service: cat.rawValue)
                            }
                        }
                    }
                    .padding(.horizontal).padding(.vertical, 10)
                }

                if vm.isLoading {
                    ProgressView().padding()
                } else if vm.providers.isEmpty {
                    ContentUnavailableView("No providers found",
                        systemImage: "person.slash",
                        description: Text("Try a different category"))
                } else {
                    List(vm.providers) { provider in
                        NavigationLink(destination: ProviderDetailView(provider: provider)) {
                            ProviderRowView(provider: provider)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Find Help")
            .onAppear { vm.fetchProviders() }
        }
    }
}

// MARK: - Category chip
struct CategoryChip: View {
    let label: String; let icon: String
    let isSelected: Bool; let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label).font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Provider row
struct ProviderRowView: View {
    let provider: Provider
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(provider.name).font(.headline)
            Text(provider.services.joined(separator: " · "))
                .font(.subheadline).foregroundStyle(.secondary)
            HStack {
                Image(systemName: "star.fill").foregroundStyle(.yellow)
                Text(String(format: "%.1f", provider.rating))
                Text("(\(provider.reviewCount) reviews)").foregroundStyle(.secondary)
                Spacer()
                Text(provider.location).foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Homeowner bookings list
struct HomeownerBookingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = BookingViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading { ProgressView() }
                else if vm.bookings.isEmpty {
                    ContentUnavailableView("No Bookings Yet",
                        systemImage: "calendar.badge.plus",
                        description: Text("Your booking requests will appear here"))
                } else {
                    List(vm.bookings) { booking in
                        NavigationLink(destination: HomeownerBookingDetailView(booking: booking)) {
                            BookingRowView(booking: booking, isProvider: false)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Bookings")
            .onAppear { vm.fetchHomeownerBookings() }
        }
    }
}

// MARK: - Homeowner booking detail (with leave review option)
struct HomeownerBookingDetailView: View {
    let booking: Booking
    @StateObject private var reviewVM = ReviewViewModel()
    @State private var showReviewSheet = false
    @State private var rating: Double = 5
    @State private var comment = ""
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Provider", value: booking.providerName)
                LabeledContent("Service", value: booking.serviceType)
                LabeledContent("Status", value: booking.status.capitalized)
                LabeledContent("Description", value: booking.problemDescription)
            }

            if booking.status == "accepted" {
                Section {
                    Button("Mark as Completed & Leave Review") {
                        showReviewSheet = true
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
        .navigationTitle("Booking Detail")
        .sheet(isPresented: $showReviewSheet) {
            ReviewSheet(
                rating: $rating,
                comment: $comment,
                isLoading: reviewVM.isLoading
            ) {
                guard let bookingID = booking.id else { return }
                // Fetch provider's current stats first, then submit
                Firestore.firestore().collection("providers")
                    .document(booking.providerID).getDocument { snap, _ in
                    let currentRating = snap?.data()?["rating"] as? Double ?? 0
                    let currentCount  = snap?.data()?["reviewCount"] as? Int ?? 0
                    reviewVM.submitReview(
                        providerID: booking.providerID,
                        bookingID: bookingID,
                        homeownerName: authVM.currentUserName,
                        rating: rating,
                        comment: comment,
                        currentReviewCount: currentCount,
                        currentRating: currentRating
                    ) { showReviewSheet = false }
                }
            }
        }
    }
}

// MARK: - Review sheet
struct ReviewSheet: View {
    @Binding var rating: Double
    @Binding var comment: String
    let isLoading: Bool
    let onSubmit: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Rating") {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                                .font(.title2)
                                .onTapGesture { rating = Double(star) }
                        }
                    }
                }
                Section("Comment") {
                    TextEditor(text: $comment).frame(minHeight: 80)
                }
            }
            .navigationTitle("Leave a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") { onSubmit() }
                        .disabled(comment.isEmpty || isLoading)
                }
            }
        }
    }
}

// MARK: - Homeowner profile
struct HomeownerProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50)).foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(authVM.currentUserName).font(.headline)
                            Text("Homeowner").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                Section {
                    Button(role: .destructive) { authVM.signOut() } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Shared booking row
struct BookingRowView: View {
    let booking: Booking
    let isProvider: Bool

    var statusColor: Color {
        switch booking.status {
        case "pending":   return .orange
        case "accepted":  return .green
        case "completed": return .blue
        default:          return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isProvider ? booking.homeownerName : booking.providerName).font(.headline)
                Spacer()
                Text(booking.status.capitalized)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundStyle(statusColor).clipShape(Capsule())
            }
            Text(booking.serviceType).font(.subheadline).foregroundStyle(.secondary)
            Text(booking.problemDescription).font(.caption).foregroundStyle(.secondary).lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

// Firestore import needed for HomeownerBookingDetailView
import FirebaseFirestore
