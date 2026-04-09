import SwiftUI

struct BookingFormView: View {
    @EnvironmentObject var vm: HomeownerViewModel
    @Environment(\.dismiss) private var dismiss

    let provider: Provider

    @State private var selectedService: String
    @State private var description: String = ""
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var showConfirmation = false

    init(provider: Provider) {
        self.provider = provider
        _selectedService = State(initialValue: provider.services.first ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Service") {
                    Picker("Service", selection: $selectedService) {
                        ForEach(provider.services, id: \.self) { service in
                            Text(service).tag(service)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Describe Your Issue") {
                    TextField("What's going on?", text: $description, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Preferred Date") {
                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }

                Section {
                    Button {
                        vm.addBooking(
                            providerId: provider.id,
                            service: selectedService,
                            description: description,
                            date: selectedDate
                        )
                        showConfirmation = true
                    } label: {
                        Text("Submit Booking")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(description.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .navigationTitle("Book \(provider.businessName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Booking Requested!", isPresented: $showConfirmation) {
                Button("Done") { dismiss() }
            } message: {
                Text("Your request for \(selectedService) with \(provider.businessName) on \(selectedDate.formatted(date: .long, time: .omitted)) has been submitted. You'll hear back soon.")
            }
        }
    }
}

#Preview {
    BookingFormView(provider: MockDataService.shared.providers[0])
        .environmentObject(HomeownerViewModel())
}
