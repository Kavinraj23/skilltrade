import SwiftUI

struct ProviderDashboardView: View {
    @EnvironmentObject var vm: ProviderViewModel

    var body: some View {
        List {
            Section("Pending Requests") {
                if vm.pendingBookings.isEmpty {
                    Text("No pending requests.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.pendingBookings) { booking in
                        NavigationLink(destination: ProviderBookingDetailView(booking: booking).environmentObject(vm)) {
                            ProviderBookingRow(booking: booking, homeownerName: vm.homeownerName(for: booking))
                        }
                    }
                }
            }

            Section("Upcoming Confirmed") {
                if vm.confirmedBookings.isEmpty {
                    Text("No confirmed bookings.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.confirmedBookings) { booking in
                        NavigationLink(destination: ProviderBookingDetailView(booking: booking).environmentObject(vm)) {
                            ProviderBookingRow(booking: booking, homeownerName: vm.homeownerName(for: booking))
                        }
                    }
                }
            }
        }
    }
}

struct ProviderBookingRow: View {
    let booking: Booking
    let homeownerName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.service)
                    .font(.headline)
                Text(homeownerName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(booking.scheduledDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge(status: booking.status)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ProviderDashboardView()
            .environmentObject(ProviderViewModel())
            .navigationTitle("Dashboard")
    }
}
