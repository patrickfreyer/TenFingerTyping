import SwiftUI

struct TypingPromptView: View {
    let attributedText: [(character: Character, state: TypingViewModel.CharacterState)]
    let fingerHint: String
    let currentFinger: Finger?

    var body: some View {
        VStack(spacing: 12) {
            // Target text with character coloring - using wrapping flow layout
            FlowLayout(spacing: 0) {
                ForEach(Array(attributedText.enumerated()), id: \.offset) { index, item in
                    Text(String(item.character))
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(color(for: item.state))
                        .background(
                            item.state == .current ?
                            RoundedRectangle(cornerRadius: 2)
                                .fill(currentFinger?.color.opacity(0.3) ?? Color.blue.opacity(0.3))
                                .padding(.horizontal, -2)
                                .padding(.vertical, -1)
                            : nil
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )

            // Finger hint
            HStack(spacing: 8) {
                if let finger = currentFinger {
                    Circle()
                        .fill(finger.color)
                        .frame(width: 12, height: 12)
                }

                Text(fingerHint)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(currentFinger?.color ?? .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(currentFinger?.color.opacity(0.1) ?? Color.gray.opacity(0.1))
            )
        }
    }

    private func color(for state: TypingViewModel.CharacterState) -> Color {
        switch state {
        case .pending:
            return .secondary.opacity(0.6)
        case .current:
            return .primary
        case .correct:
            return .green
        case .incorrect:
            return .red
        }
    }
}

struct StatsView: View {
    let accuracy: Double
    let wpm: Double
    let time: String

    var body: some View {
        HStack(spacing: 24) {
            statItem(label: "Accuracy", value: String(format: "%.0f%%", accuracy))
            statItem(label: "WPM", value: wpm > 0 ? String(format: "%.0f", wpm) : "--")
            statItem(label: "Time", value: time)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
        )
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}

struct LevelCompleteView: View {
    let accuracy: Double
    let wpm: Double
    let time: String
    let canAdvance: Bool
    let onRestart: () -> Void
    let onNextExercise: () -> Void
    let onNextLevel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Exercise Complete!")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.green)

            StatsView(accuracy: accuracy, wpm: wpm, time: time)

            HStack(spacing: 12) {
                Button(action: onRestart) {
                    Label("Restart", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)

                Button(action: onNextExercise) {
                    Label("New Exercise", systemImage: "arrow.right")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)

                if canAdvance {
                    Button(action: onNextLevel) {
                        Label("Next Level", systemImage: "arrow.up.right")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
    }
}

// MARK: - Flow Layout for text wrapping

struct FlowLayout: Layout {
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(subviews[index].sizeThatFits(.unspecified))
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // Check if we need to wrap to next line
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))

            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalWidth = max(totalWidth, currentX)
        }

        return (CGSize(width: totalWidth, height: currentY + lineHeight), positions)
    }
}

#Preview {
    VStack(spacing: 20) {
        TypingPromptView(
            attributedText: [
                ("a", .correct),
                ("s", .correct),
                ("d", .current),
                ("f", .pending),
                (" ", .pending),
                ("j", .pending),
                ("k", .pending),
                ("l", .pending)
            ],
            fingerHint: "Press 'D' with LEFT MIDDLE finger",
            currentFinger: .leftMiddle
        )

        StatsView(accuracy: 95.5, wpm: 42, time: "1:23")

        LevelCompleteView(
            accuracy: 98.0,
            wpm: 45,
            time: "0:45",
            canAdvance: true,
            onRestart: {},
            onNextExercise: {},
            onNextLevel: {}
        )
    }
    .padding()
    .frame(width: 500)
    .background(Color(.windowBackgroundColor))
}
