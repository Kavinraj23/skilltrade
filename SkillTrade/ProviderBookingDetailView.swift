import SwiftUI

struct ProviderBookingDetailView: View {
    @EnvironmentObject var vm: ProviderViewModel
    @Environment(\.dismiss) private var dismiss

    let booking: Booking

    // Keep a local live copy so UI updates when status changes
    @State private var currentStatus: BookingStatus

    init(booking: Booking) {
        self.booking = booking
        _currentStatus = State(initialValue: booking.status)
    }

    var body: some View {
        List {
            Section("Booking Info") {
                LabeledContent("Service", value: booking.service)
                LabeledContent("Customer", value: vm.homeownerName(for: booking))
                LabeledContent("Date", value: booking.scheduledDate.formatted(date: .long, time: .omitted))
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadge(status: currentStatus)
                }
            }

            Section("Issue Description") {
                Text(booking.description)
                    .font(.subheadline)
            }

            if currentStatus == .pending {
                Section {
                    Button {
                        vm.confirm(booking)
                        currentStatus = .confirmed
                    } label: {
                        Label("Confirm Booking", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.green)

                    Button(role: .destructive) {
                        vm.decline(booking)
                        currentStatus = .completed
                        dismiss()
                    } label: {
                        Label("Decline", systemImage: "xmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle("Booking Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProviderBookingDetailView(booking: MockDataService.shared.bookings[1])
            .environmentObject(ProviderViewModel())
    }
}
