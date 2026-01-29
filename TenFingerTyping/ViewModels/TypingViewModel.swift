import SwiftUI
import Combine

class TypingViewModel: ObservableObject {
    @Published var currentLevel: Int = 1
    @Published var session: TypingSession
    @Published var showLevelComplete: Bool = false
    @Published var isLoadingExercise: Bool = false
    @Published var useAI: Bool = true

    private var timerCancellable: AnyCancellable?

    var currentLesson: Lesson {
        LessonLibrary.lesson(for: currentLevel)
    }

    var activeKeys: Set<Character> {
        currentLesson.allowedKeys
    }

    var currentCharacter: Character? {
        session.currentCharacter
    }

    var fingerHint: String {
        guard let char = currentCharacter else {
            return "Exercise complete!"
        }
        return FingerMap.fingerHint(for: char)
    }

    var currentFinger: Finger? {
        guard let char = currentCharacter else { return nil }
        return FingerMap.finger(for: char)
    }

    var isAPIConfigured: Bool {
        get async {
            await ClaudeAPIService.shared.isConfigured
        }
    }

    init() {
        let lesson = LessonLibrary.lesson(for: 1)
        let exercise = lesson.exercises.first ?? "a sad lad falls"
        self.session = TypingSession(text: exercise, level: 1)
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    func handleKeyPress(_ key: String) {
        guard let char = key.first else { return }

        // Handle backspace
        if key == "\u{7F}" || key == "\u{08}" {
            session.processBackspace()
            return
        }

        // Only process if key is in allowed set (case insensitive for letters)
        let lowerChar = Character(char.lowercased())
        guard activeKeys.contains(lowerChar) || activeKeys.contains(char) else {
            return
        }

        session.processKeyPress(lowerChar)

        if session.isComplete {
            showLevelComplete = true
        }
    }

    func restartExercise() {
        session.reset()
        showLevelComplete = false
    }

    func nextExercise() {
        showLevelComplete = false

        if useAI {
            fetchAIExercise()
        } else {
            session.newExercise()
        }
    }

    func nextLevel() {
        guard currentLevel < LessonLibrary.maxLevel else { return }
        currentLevel += 1
        showLevelComplete = false

        if useAI {
            fetchAIExercise()
        } else {
            let exercise = LessonLibrary.randomExercise(for: currentLevel)
            session = TypingSession(text: exercise, level: currentLevel)
        }
    }

    func previousLevel() {
        guard currentLevel > 1 else { return }
        currentLevel -= 1
        showLevelComplete = false

        if useAI {
            fetchAIExercise()
        } else {
            let exercise = LessonLibrary.randomExercise(for: currentLevel)
            session = TypingSession(text: exercise, level: currentLevel)
        }
    }

    func selectLevel(_ level: Int) {
        guard level >= 1 && level <= LessonLibrary.maxLevel else { return }
        currentLevel = level
        showLevelComplete = false

        if useAI {
            fetchAIExercise()
        } else {
            let exercise = LessonLibrary.randomExercise(for: currentLevel)
            session = TypingSession(text: exercise, level: currentLevel)
        }
    }

    private func fetchAIExercise() {
        isLoadingExercise = true

        Task {
            do {
                let exercise = try await ClaudeAPIService.shared.generateTypingExercise(
                    allowedKeys: currentLesson.allowedKeys,
                    level: currentLevel,
                    lessonName: currentLesson.name
                )

                await MainActor.run {
                    self.session = TypingSession(text: exercise, level: self.currentLevel)
                    self.isLoadingExercise = false
                }
            } catch {
                print("AI exercise generation failed: \(error.localizedDescription)")
                // Fallback to built-in exercises
                await MainActor.run {
                    let exercise = LessonLibrary.randomExercise(for: self.currentLevel)
                    self.session = TypingSession(text: exercise, level: self.currentLevel)
                    self.isLoadingExercise = false
                }
            }
        }
    }

    var attributedTargetText: [(character: Character, state: CharacterState)] {
        var result: [(Character, CharacterState)] = []
        let targetChars = Array(session.targetText)
        let typedChars = Array(session.typedText)

        for (index, char) in targetChars.enumerated() {
            if index < typedChars.count {
                let isCorrect = session.characterResults[index].isCorrect
                result.append((char, isCorrect ? .correct : .incorrect))
            } else if index == typedChars.count {
                result.append((char, .current))
            } else {
                result.append((char, .pending))
            }
        }

        return result
    }

    enum CharacterState {
        case pending
        case current
        case correct
        case incorrect
    }
}
