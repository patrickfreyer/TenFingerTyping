import Foundation

actor ClaudeAPIService {
    static let shared = ClaudeAPIService()

    private let apiKey: String? = {
        // Try to get API key from environment or UserDefaults
        if let key = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !key.isEmpty {
            return key
        }
        if let key = UserDefaults.standard.string(forKey: "anthropic_api_key"), !key.isEmpty {
            return key
        }
        return nil
    }()

    private let baseURL = "https://api.anthropic.com/v1/messages"

    var isConfigured: Bool {
        apiKey != nil
    }

    func generateTypingExercise(allowedKeys: Set<Character>, level: Int, lessonName: String) async throws -> String {
        guard let apiKey = apiKey else {
            throw APIError.noAPIKey
        }

        let allowedChars = String(allowedKeys.sorted())

        let prompt = """
        Generate a short typing exercise (8-15 words) using ONLY these characters: \(allowedChars)

        Rules:
        - Use ONLY lowercase letters from the allowed set
        - Spaces are allowed
        - Create real, meaningful English words and phrases
        - Make it interesting or fun to type
        - No punctuation unless it's in the allowed characters
        - This is for Level \(level): \(lessonName)

        Examples of good exercises:
        - Level 1 (home row only): "a sad lad asks dad for a flask"
        - Level 2 (with top row): "we like to explore new ideas"
        - Level 4 (all letters): "the quick brown fox jumps high"

        Return ONLY the exercise text, nothing else. No quotes, no explanation.
        """

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 100,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw APIError.apiError(message)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw APIError.parseError
        }

        // Clean and validate the response
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let validated = validateExercise(cleaned, allowedKeys: allowedKeys)

        return validated
    }

    private func validateExercise(_ text: String, allowedKeys: Set<Character>) -> String {
        // Filter out any characters that aren't in the allowed set
        let filtered = text.filter { allowedKeys.contains($0) || $0 == " " }

        // Clean up multiple spaces
        let components = filtered.components(separatedBy: .whitespaces)
        let cleaned = components.filter { !$0.isEmpty }.joined(separator: " ")

        return cleaned.isEmpty ? "the quick brown fox" : cleaned
    }

    enum APIError: LocalizedError {
        case noAPIKey
        case invalidURL
        case invalidResponse
        case httpError(Int)
        case apiError(String)
        case parseError

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No API key configured. Set ANTHROPIC_API_KEY environment variable."
            case .invalidURL:
                return "Invalid API URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .httpError(let code):
                return "HTTP error: \(code)"
            case .apiError(let message):
                return "API error: \(message)"
            case .parseError:
                return "Failed to parse response"
            }
        }
    }
}
