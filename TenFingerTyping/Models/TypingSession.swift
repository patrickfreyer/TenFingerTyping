import Foundation

struct CharacterResult: Identifiable {
    let id = UUID()
    let character: Character
    let isCorrect: Bool
    let timestamp: Date
}

class TypingSession: ObservableObject {
    @Published var targetText: String
    @Published var typedText: String = ""
    @Published var characterResults: [CharacterResult] = []
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var isComplete: Bool = false

    let level: Int

    init(text: String, level: Int) {
        self.targetText = text
        self.level = level
    }

    var currentIndex: Int {
        typedText.count
    }

    var currentCharacter: Character? {
        guard currentIndex < targetText.count else { return nil }
        return targetText[targetText.index(targetText.startIndex, offsetBy: currentIndex)]
    }

    var progress: Double {
        guard !targetText.isEmpty else { return 0 }
        return Double(currentIndex) / Double(targetText.count)
    }

    var correctCount: Int {
        characterResults.filter { $0.isCorrect }.count
    }

    var incorrectCount: Int {
        characterResults.filter { !$0.isCorrect }.count
    }

    var accuracy: Double {
        guard !characterResults.isEmpty else { return 0 }
        return Double(correctCount) / Double(characterResults.count) * 100
    }

    var elapsedTime: TimeInterval {
        guard let start = startTime else { return 0 }
        let end = endTime ?? Date()
        return end.timeIntervalSince(start)
    }

    var wordsPerMinute: Double {
        guard elapsedTime > 0 else { return 0 }
        let wordCount = Double(correctCount) / 5.0 // Standard: 5 characters = 1 word
        let minutes = elapsedTime / 60.0
        return wordCount / minutes
    }

    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func processKeyPress(_ character: Character) {
        guard !isComplete else { return }

        if startTime == nil {
            startTime = Date()
        }

        guard let expected = currentCharacter else { return }

        let isCorrect = character == expected
        let result = CharacterResult(
            character: character,
            isCorrect: isCorrect,
            timestamp: Date()
        )

        characterResults.append(result)

        if isCorrect {
            typedText.append(character)
        } else {
            typedText.append(character)
        }

        if currentIndex >= targetText.count {
            isComplete = true
            endTime = Date()
        }
    }

    func processBackspace() {
        guard !typedText.isEmpty, !isComplete else { return }
        typedText.removeLast()
        if !characterResults.isEmpty {
            characterResults.removeLast()
        }
    }

    func reset() {
        typedText = ""
        characterResults = []
        startTime = nil
        endTime = nil
        isComplete = false
    }

    func newExercise() {
        targetText = LessonLibrary.randomExercise(for: level)
        reset()
    }
}
