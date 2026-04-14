import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Provider tab
struct ProviderTabView: View {
    var body: some View {
        TabView {
            ProviderRequestsView()
                .tabItem { Label("Requests", systemImage: "bell.fill") }
            ProviderInboxView()
                .tabItem { Label("Messages", systemImage: "message") }
            ProviderProfileEditorView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

// MARK: - Provider requests
struct ProviderRequestsView: View {
    @StateObject private var vm = BookingViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading { ProgressView() }
                else if vm.bookings.isEmpty {
                    ContentUnavailableView("No Requests Yet", systemImage: "tray",
                        description: Text("Booking requests from homeowners will appear here"))
                } else {
                    List(vm.bookings) { booking in
                        VStack(alignment: .leading, spacing: 10) {
                            BookingRowView(booking: booking, isProvider: true)

                            if booking.status == "pending", let id = booking.id {
                                HStack(spacing: 12) {
                                    Button {
                                        vm.acceptBooking(booking: booking)
                                    } label: {
                                        Label("Accept", systemImage: "checkmark")
                                            .frame(maxWidth: .infinity).padding(8)
                                            .background(Color.green)
                                            .foregroundStyle(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    Button {
                                        vm.updateStatus(bookingID: id, status: "cancelled")
                                    } label: {
                                        Label("Decline", systemImage: "xmark")
                                            .frame(maxWidth: .infinity).padding(8)
                                            .background(Color.red.opacity(0.85))
                                            .foregroundStyle(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Requests")
            .onAppear { vm.fetchProviderBookings() }
        }
    }
}

// MARK: - Provider inbox
struct ProviderInboxView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = MessagingViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading { ProgressView() }
                else if vm.conversations.isEmpty {
                    ContentUnavailableView("No Messages", systemImage: "message",
                        description: Text("Conversations appear here after you accept a booking"))
                } else {
                    List(vm.conversations) { convo in
                        NavigationLink(destination: ChatView(conversation: convo,
                                                             currentUserID: authVM.currentUserID)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Booking: \(convo.bookingID)")
                                    .font(.subheadline.bold())
                                Text("Tap to open chat")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Messages")
            .onAppear { vm.fetchConversations(role: "provider") }
        }
    }
}

// MARK: - Provider profile editor
struct ProviderProfileEditorView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var name = ""
    @State private var bio = ""
    @State private var location = ""
    @State private var selectedServices: Set<String> = []
    @State private var availability: [String: DayAvailability] = [:]
    @State private var isSaving = false
    @State private var saveSuccess = false

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Display Name", text: $name)
                    TextField("Location (e.g. Austin, TX)", text: $location)
                }
                Section("Bio") {
                    TextEditor(text: $bio).frame(minHeight: 80)
                }
                Section("Services") {
                    ForEach(ServiceCategory.allCases, id: \.self) { cat in
                        Toggle(cat.rawValue, isOn: Binding(
                            get: { selectedServices.contains(cat.rawValue) },
                            set: { on in
                                if on { selectedServices.insert(cat.rawValue) }
                                else  { selectedServices.remove(cat.rawValue) }
                            }
                        ))
                    }
                }
                Section("Availability") {
                    ForEach(daysOfWeek, id: \.self) { day in
                        AvailabilityRow(day: day, availability: $availability)
                    }
                }
                Section {
                    Button { saveProfile() } label: {
                        if isSaving { ProgressView() }
                        else { Text("Save Profile").frame(maxWidth: .infinity) }
                    }
                    .disabled(isSaving)
                }
                Section {
                    Button(role: .destructive) { authVM.signOut() } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("My Profile")
            .onAppear { loadProfile() }
            .alert("Saved!", isPresented: $saveSuccess) { Button("OK") {} }
        }
    }

    private func loadProfile() {
        guard !authVM.currentUserID.isEmpty else { return }
        db.collection("providers").document(authVM.currentUserID).getDocument { snap, _ in
            guard let data = snap?.data() else { return }
            name     = data["name"]     as? String ?? ""
            bio      = data["bio"]      as? String ?? ""
            location = data["location"] as? String ?? ""
            selectedServices = Set((data["services"] as? [String]) ?? [])

            // Parse availability map
            if let avMap = data["availability"] as? [String: [String: String]] {
                var parsed: [String: DayAvailability] = [:]
                for (day, hours) in avMap {
                    if let open = hours["open"], let close = hours["close"] {
                        parsed[day] = DayAvailability(open: open, close: close)
                    }
                }
                availability = parsed
            }
        }
    }

    private func saveProfile() {
        guard !authVM.currentUserID.isEmpty else { return }
        isSaving = true

        // Convert availability to Firestore-compatible dict
        var avDict: [String: [String: String]] = [:]
        for (day, hours) in availability {
            avDict[day] = ["open": hours.open, "close": hours.close]
        }

        db.collection("providers").document(authVM.currentUserID).updateData([
            "name": name, "bio": bio, "location": location,
            "services": Array(selectedServices),
            "availability": avDict
        ]) { [self] _ in
            isSaving = false
            saveSuccess = true
        }
    }
}

// MARK: - Availability row (toggle + time pickers per day)
struct AvailabilityRow: View {
    let day: String
    @Binding var availability: [String: DayAvailability]

    var isEnabled: Bool { availability[day] != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(day.capitalized, isOn: Binding(
                get: { isEnabled },
                set: { on in
                    if on { availability[day] = DayAvailability(open: "08:00", close: "17:00") }
                    else  { availability.removeValue(forKey: day) }
                }
            ))

            if isEnabled {
                HStack {
                    Text("Open")
                        .font(.caption).foregroundStyle(.secondary).frame(width: 40)
                    TextField("08:00", text: Binding(
                        get: { availability[day]?.open ?? "08:00" },
                        set: { availability[day]?.open = $0 }
                    ))
                    .textFieldStyle(.roundedBorder).frame(width: 80)

                    Text("Close")
                        .font(.caption).foregroundStyle(.secondary).frame(width: 45)
                    TextField("17:00", text: Binding(
                        get: { availability[day]?.close ?? "17:00" },
                        set: { availability[day]?.close = $0 }
                    ))
                    .textFieldStyle(.roundedBorder).frame(width: 80)
                }
            }
        }
    }
}
