import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TypingViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Header with level info
            headerView

            Divider()

            if viewModel.isLoadingExercise {
                // Loading state
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating exercise...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)
            } else if viewModel.showLevelComplete {
                // Level complete overlay
                LevelCompleteView(
                    accuracy: viewModel.session.accuracy,
                    wpm: viewModel.session.wordsPerMinute,
                    time: viewModel.session.formattedTime,
                    canAdvance: viewModel.currentLevel < LessonLibrary.maxLevel,
                    onRestart: { viewModel.restartExercise() },
                    onNextExercise: { viewModel.nextExercise() },
                    onNextLevel: { viewModel.nextLevel() }
                )
            } else {
                // Typing prompt
                TypingPromptView(
                    attributedText: viewModel.attributedTargetText,
                    fingerHint: viewModel.fingerHint,
                    currentFinger: viewModel.currentFinger
                )
            }

            // Keyboard
            KeyboardView(
                highlightedKey: viewModel.currentCharacter,
                activeKeys: viewModel.activeKeys
            )

            // Legend
            FingerLegendView()

            // Stats
            StatsView(
                accuracy: viewModel.session.accuracy,
                wpm: viewModel.session.wordsPerMinute,
                time: viewModel.session.formattedTime
            )

            // Controls
            controlsView
        }
        .padding(16)
        .frame(width: 520)
        .background(keyboardInput)
        .onAppear {
            isInputFocused = true
        }
    }

    private var headerView: some View {
        HStack {
            Text("10-Finger Trainer")
                .font(.system(size: 16, weight: .bold))

            Spacer()

            // AI toggle
            Toggle(isOn: $viewModel.useAI) {
                Image(systemName: viewModel.useAI ? "sparkles" : "sparkles")
                    .font(.system(size: 10))
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            .tint(viewModel.useAI ? .purple : .gray)
            .help(viewModel.useAI ? "AI-generated exercises (on)" : "Built-in exercises (AI off)")

            Menu {
                ForEach(LessonLibrary.lessons) { lesson in
                    Button(action: { viewModel.selectLevel(lesson.level) }) {
                        HStack {
                            Text("Level \(lesson.level): \(lesson.name)")
                            if lesson.level == viewModel.currentLevel {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Level \(viewModel.currentLevel)")
                        .font(.system(size: 12, weight: .medium))
                    Text(viewModel.currentLesson.name)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.controlBackgroundColor))
                )
            }
            .menuStyle(.borderlessButton)
        }
    }

    private var controlsView: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.restartExercise() }) {
                Label("Restart", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 11))
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("r", modifiers: .command)

            Button(action: { viewModel.nextExercise() }) {
                Label("New Exercise", systemImage: "arrow.right")
                    .font(.system(size: 11))
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("n", modifiers: .command)

            Spacer()

            if viewModel.currentLevel > 1 {
                Button(action: { viewModel.previousLevel() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
            }

            if viewModel.currentLevel < LessonLibrary.maxLevel {
                Button(action: { viewModel.nextLevel() }) {
                    Label("Next Level", systemImage: "chevron.right")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var keyboardInput: some View {
        KeyboardInputView { key in
            viewModel.handleKeyPress(key)
        }
        .focused($isInputFocused)
    }
}

struct KeyboardInputView: NSViewRepresentable {
    let onKeyPress: (String) -> Void

    func makeNSView(context: Context) -> KeyInputNSView {
        let view = KeyInputNSView()
        view.onKeyPress = onKeyPress
        return view
    }

    func updateNSView(_ nsView: KeyInputNSView, context: Context) {
        nsView.onKeyPress = onKeyPress
    }
}

class KeyInputNSView: NSView {
    var onKeyPress: ((String) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard let characters = event.characters else { return }
        onKeyPress?(characters)
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }
}

#Preview {
    ContentView()
        .frame(height: 600)
}
