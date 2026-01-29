import SwiftUI

struct KeyboardView: View {
    let highlightedKey: Character?
    let activeKeys: Set<Character>

    private let rowSpacing: CGFloat = 4
    private let keySpacing: CGFloat = 4

    var body: some View {
        VStack(spacing: rowSpacing) {
            // Number row
            HStack(spacing: keySpacing) {
                ForEach(KeyboardLayout.numberRow, id: \.self) { key in
                    keyView(for: key)
                }
            }

            // Top row (QWERTY)
            HStack(spacing: keySpacing) {
                Spacer().frame(width: 16)
                ForEach(KeyboardLayout.topRow, id: \.self) { key in
                    keyView(for: key)
                }
            }

            // Home row (ASDF)
            HStack(spacing: keySpacing) {
                Spacer().frame(width: 24)
                ForEach(KeyboardLayout.homeRow, id: \.self) { key in
                    keyView(for: key)
                }
                Spacer().frame(width: 24)
            }

            // Bottom row (ZXCV)
            HStack(spacing: keySpacing) {
                Spacer().frame(width: 40)
                ForEach(KeyboardLayout.bottomRow, id: \.self) { key in
                    keyView(for: key)
                }
                Spacer().frame(width: 40)
            }

            // Space bar
            SpaceBarView(
                isHighlighted: highlightedKey == " ",
                isActive: activeKeys.contains(" ")
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.windowBackgroundColor).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private func keyView(for key: String) -> some View {
        let char = Character(key.lowercased())
        let finger = FingerMap.finger(for: char)
        let isHighlighted = highlightedKey?.lowercased() == key.lowercased()
        let isActive = activeKeys.contains(char)
        let isHomeKey = KeyboardLayout.isHomeKey(key)

        KeyView(
            key: key,
            finger: finger,
            isHighlighted: isHighlighted,
            isActive: isActive,
            isHomeKey: isHomeKey
        )
    }
}

struct FingerLegendView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                ForEach([Finger.leftPinky, .leftRing, .leftMiddle, .leftIndex], id: \.self) { finger in
                    legendItem(for: finger)
                }
                Text("Left")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                ForEach([Finger.rightIndex, .rightMiddle, .rightRing, .rightPinky], id: \.self) { finger in
                    legendItem(for: finger)
                }
                Text("Right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func legendItem(for finger: Finger) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(finger.color)
                .frame(width: 10, height: 10)
            Text(finger.shortName.replacingOccurrences(of: "L ", with: "").replacingOccurrences(of: "R ", with: ""))
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        KeyboardView(
            highlightedKey: "f",
            activeKeys: Set("asdf jkl;")
        )
        FingerLegendView()
    }
    .padding()
    .frame(width: 500)
    .background(Color(.windowBackgroundColor))
}
