import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ReviewViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    // MARK: - Fetch reviews for a provider
    func fetchReviews(providerID: String) {
        isLoading = true
        db.collection("reviews")
            .whereField("providerID", isEqualTo: providerID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isLoading = false
                self.reviews = snapshot?.documents.compactMap {
                    try? $0.data(as: Review.self)
                } ?? []
            }
    }

    // MARK: - Submit a review + update provider rating in a batch
    func submitReview(providerID: String, bookingID: String,
                      homeownerName: String, rating: Double,
                      comment: String, currentReviewCount: Int,
                      currentRating: Double,
                      completion: (() -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        let batch = db.batch()

        // 1. Add review document
        let reviewRef = db.collection("reviews").document()
        batch.setData([
            "providerID": providerID,
            "homeownerID": uid,
            "homeownerName": homeownerName,
            "bookingID": bookingID,
            "rating": rating,
            "comment": comment,
            "createdAt": Timestamp(date: Date())
        ], forDocument: reviewRef)

        // 2. Recalculate and update provider rating
        let newCount = currentReviewCount + 1
        let newRating = ((currentRating * Double(currentReviewCount)) + rating) / Double(newCount)

        let providerRef = db.collection("providers").document(providerID)
        batch.updateData([
            "rating": newRating,
            "reviewCount": newCount
        ], forDocument: providerRef)

        // 3. Mark booking as completed
        let bookingRef = db.collection("bookings").document(bookingID)
        batch.updateData(["status": "completed"], forDocument: bookingRef)

        batch.commit { [weak self] _ in
            self?.isLoading = false
            completion?()
        }
    }
}
