import SwiftUI

struct ProviderDetailView: View {
    let provider: Provider
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var bookingVM = BookingViewModel()
    @StateObject private var reviewVM  = ReviewViewModel()
    @State private var showBookingSheet = false
    @State private var problemDescription = ""
    @State private var selectedService = ""
    @State private var scheduledDate = Date().addingTimeInterval(86400)
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(provider.name).font(.title2.bold())
                    Text(provider.location).foregroundStyle(.secondary)
                    HStack {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text(String(format: "%.1f", provider.rating))
                        Text("(\(provider.reviewCount) reviews)").foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    Text(provider.bio).foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Services
                VStack(alignment: .leading, spacing: 10) {
                    Text("Services").font(.headline)
                    HStack(spacing: 8) {
                        ForEach(provider.services, id: \.self) { service in
                            Text(service)
                                .font(.subheadline)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue).clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Availability
                if !provider.availability.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Availability").font(.headline)
                        ForEach(daysOfWeek, id: \.self) { day in
                            if let hours = provider.availability[day] {
                                HStack {
                                    Text(day.capitalized)
                                        .frame(width: 100, alignment: .leading)
                                    Text("\(hours.open) – \(hours.close)")
                                        .foregroundStyle(.secondary)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Reviews
                if !reviewVM.reviews.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reviews").font(.headline)
                        ForEach(reviewVM.reviews) { review in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(review.homeownerName).font(.subheadline.bold())
                                    Spacer()
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow).font(.caption)
                                        Text(String(format: "%.0f", review.rating))
                                            .font(.caption)
                                    }
                                }
                                Text(review.comment).font(.caption).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Book button
                Button {
                    if authVM.isLoggedIn {
                        selectedService = provider.services.first ?? ""
                        showBookingSheet = true
                    } else {
                        authVM.beginBookingLogin(for: provider)
                    }
                } label: {
                    Text("Request Booking")
                        .fontWeight(.semibold).frame(maxWidth: .infinity).padding()
                        .background(Color.blue).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Provider Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { reviewVM.fetchReviews(providerID: provider.uid) }
        .sheet(isPresented: $showBookingSheet) {
            BookingRequestSheet(
                provider: provider,
                selectedService: $selectedService,
                problemDescription: $problemDescription,
                scheduledDate: $scheduledDate,
                isLoading: bookingVM.isLoading
            ) {
                bookingVM.createBooking(
                    provider: provider,
                    serviceType: selectedService,
                    problemDescription: problemDescription,
                    scheduledDate: scheduledDate,
                    homeownerName: authVM.currentUserName
                ) {
                    showBookingSheet = false
                    showSuccess = true
                }
            }
        }
        .alert("Booking Sent!", isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text("Your request has been sent to \(provider.name).")
        }
    }
}

struct DeferredBookingRequestView: View {
    let provider: Provider
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var bookingVM = BookingViewModel()
    @State private var problemDescription = ""
    @State private var selectedService: String
    @State private var scheduledDate = Date().addingTimeInterval(86400)

    init(provider: Provider) {
        self.provider = provider
        _selectedService = State(initialValue: provider.services.first ?? "")
    }

    var body: some View {
        BookingRequestSheet(
            provider: provider,
            selectedService: $selectedService,
            problemDescription: $problemDescription,
            scheduledDate: $scheduledDate,
            isLoading: bookingVM.isLoading
        ) {
            bookingVM.createBooking(
                provider: provider,
                serviceType: selectedService,
                problemDescription: problemDescription,
                scheduledDate: scheduledDate,
                homeownerName: authVM.currentUserName
            ) {
                authVM.clearPendingBooking()
                dismiss()
            }
        }
        .onDisappear {
            if !bookingVM.isLoading {
                authVM.clearPendingBooking()
            }
        }
    }
}

// MARK: - Booking request sheet
struct BookingRequestSheet: View {
    let provider: Provider
    @Binding var selectedService: String
    @Binding var problemDescription: String
    @Binding var scheduledDate: Date
    let isLoading: Bool
    let onSubmit: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Service") {
                    Picker("Service Type", selection: $selectedService) {
                        ForEach(provider.services, id: \.self) { Text($0).tag($0) }
                    }
                }
                Section("Describe Your Problem") {
                    TextEditor(text: $problemDescription).frame(minHeight: 80)
                }
                Section("Preferred Date") {
                    DatePicker("Date", selection: $scheduledDate,
                               in: Date()...,
                               displayedComponents: [.date, .hourAndMinute])
                }

                // Show provider availability as a hint
                if !provider.availability.isEmpty {
                    Section("Provider works on") {
                        ForEach(daysOfWeek, id: \.self) { day in
                            if let hours = provider.availability[day] {
                                HStack {
                                    Text(day.capitalized)
                                    Spacer()
                                    Text("\(hours.open) – \(hours.close)")
                                        .foregroundStyle(.secondary)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Request Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { onSubmit() }
                        .disabled(problemDescription.isEmpty || isLoading)
                }
            }
        }
    }
}
