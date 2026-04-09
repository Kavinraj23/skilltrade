import SwiftUI

struct HomeownerHomeView: View {
    @EnvironmentObject var vm: HomeownerViewModel
    @State private var navigateToResults = false

    var body: some View {
        List {
            // Search
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Describe your problem...", text: $vm.searchQuery)
                        .submitLabel(.search)
                        .onSubmit {
                            vm.search()
                            navigateToResults = true
                        }
                    if !vm.searchQuery.isEmpty {
                        Button {
                            vm.searchQuery = ""
                            vm.searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            // Search button
            Section {
                Button {
                    vm.search()
                    navigateToResults = true
                } label: {
                    Text("Find Help")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            // My Bookings
            Section("My Bookings") {
                if vm.bookings.isEmpty {
                    Text("No bookings yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.bookings) { booking in
                        BookingSummaryRow(booking: booking, providerName: vm.providerName(for: booking))
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            SearchResultsView()
                .environmentObject(vm)
        }
    }
}

struct BookingSummaryRow: View {
    let booking: Booking
    let providerName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.service)
                    .font(.headline)
                Text(providerName)
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

struct StatusBadge: View {
    let status: BookingStatus

    var label: String {
        switch status {
        case .pending:   return "Pending"
        case .confirmed: return "Confirmed"
        case .completed: return "Completed"
        }
    }

    var color: Color {
        switch status {
        case .pending:   return .yellow
        case .confirmed: return .green
        case .completed: return .gray
        }
    }

    var body: some View {
        Text(label)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        HomeownerHomeView()
            .environmentObject(HomeownerViewModel())
            .navigationTitle("SkillTrade")
    }
}
