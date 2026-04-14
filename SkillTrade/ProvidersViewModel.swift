import Foundation
import FirebaseFirestore
import Combine

class ProvidersViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func fetchProviders(service: String? = nil) {
        isLoading = true
        var query: Query = db.collection("providers")
        if let service = service {
            query = query.whereField("services", arrayContains: service)
        }
        query.getDocuments { [weak self] snapshot, _ in
            guard let self = self else { return }
            self.isLoading = false
            self.providers = snapshot?.documents.compactMap {
                try? $0.data(as: Provider.self)
            } ?? []
        }
    }
}
