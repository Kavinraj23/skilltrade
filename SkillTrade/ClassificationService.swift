import Foundation

struct ClassificationService {

    // MARK: - API config
    private static var apiKey: String {
        guard
            let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key  = dict["ANTHROPIC_API_KEY"] as? String
        else {
            fatalError("Config.plist missing or ANTHROPIC_API_KEY not set")
        }
        return key
    }

    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    // MARK: - Classification
    /// Returns up to 2 matching ServiceCategory values for the given description.
    /// Falls back to an empty array (caller should show all providers) on any error.
    static func classify(description: String) async -> [ServiceCategory] {
        let validCategories = ServiceCategory.allCases.map(\.rawValue).joined(separator: ", ")

        let prompt = """
        You are a home services classifier. A homeowner has described a problem they need help with.
        Your job is to return the 1 or 2 most relevant service categories from this exact list:
        \(validCategories)

        Rules:
        - Return ONLY a JSON array of strings, e.g. ["Plumber"] or ["Roofer", "Handyman"]
        - Only use category names exactly as listed above
        - Return at most 2 categories
        - If nothing matches, return []
        - Do not include any explanation or extra text, just the JSON array

        Homeowner's problem: "\(description)"
        """

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json",    forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,                forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",          forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 64,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return []
        }
        request.httpBody = httpBody

        guard
            let (data, _) = try? await URLSession.shared.data(for: request),
            let json      = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content   = (json["content"] as? [[String: Any]])?.first,
            let text      = content["text"] as? String
        else {
            return []
        }

        // Parse the JSON array Claude returns
        guard
            let arrayData  = text.data(using: .utf8),
            let rawStrings = try? JSONSerialization.jsonObject(with: arrayData) as? [String]
        else {
            return []
        }

        // Map strings → ServiceCategory, dropping any unrecognised values
        return rawStrings.compactMap { raw in
            ServiceCategory.allCases.first { $0.rawValue == raw }
        }
    }
}
