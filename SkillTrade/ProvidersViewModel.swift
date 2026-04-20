import Foundation
import FirebaseFirestore
import Combine

class ProvidersViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    @Published var isLoading = false
    @Published var matchedCategories: [ServiceCategory] = []

    private let db = Firestore.firestore()

    // MARK: - Category chip / single-category fetch
    func fetchProviders(service: String? = nil) {
        matchedCategories = []
        isLoading = true
        var query: Query = db.collection("providers")
        if let service = service {
            query = query.whereField("services", arrayContains: service)
        }
        query.getDocuments { [weak self] snapshot, _ in
            guard let self = self else { return }
            self.isLoading = false
            self.providers = (snapshot?.documents.compactMap {
                try? $0.data(as: Provider.self)
            } ?? []).sorted { $0.rating > $1.rating }
        }
    }

    // MARK: - AI-powered multi-category fetch
    func fetchProviders(matchingDescription description: String) async {
        await MainActor.run { isLoading = true }

        let categories = await ClassificationService.classify(description: description)

        await MainActor.run { matchedCategories = categories }

        // If Claude returned nothing, fall back to all providers
        guard !categories.isEmpty else {
            fetchProviders()
            return
        }

        // Firestore doesn't support OR queries on array fields natively,
        // so we run one query per category and merge the results.
        let serviceNames = categories.map(\.rawValue)

        await withTaskGroup(of: [Provider].self) { group in
            for service in serviceNames {
                group.addTask {
                    let snapshot = try? await self.db.collection("providers")
                        .whereField("services", arrayContains: service)
                        .getDocuments()
                    return snapshot?.documents.compactMap {
                        try? $0.data(as: Provider.self)
                    } ?? []
                }
            }

            var seen = Set<String>()
            var merged: [Provider] = []
            for await batch in group {
                for provider in batch {
                    if let id = provider.id, !seen.contains(id) {
                        seen.insert(id)
                        merged.append(provider)
                    }
                }
            }

            let sorted = merged.sorted { $0.rating > $1.rating }
            await MainActor.run {
                self.providers = sorted
                self.isLoading = false
            }
        }
    }
}
