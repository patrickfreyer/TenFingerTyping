import SwiftUI

struct KeyView: View {
    let key: String
    let finger: Finger
    let isHighlighted: Bool
    let isActive: Bool
    let isHomeKey: Bool

    private let keyWidth: CGFloat = 32
    private let keyHeight: CGFloat = 32

    var body: some View {
        ZStack {
            // Key background
            RoundedRectangle(cornerRadius: 5)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(borderColor, lineWidth: isHighlighted ? 2 : 1)
                )
                .shadow(color: isHighlighted ? finger.color.opacity(0.6) : .clear, radius: 6)

            // Key label
            Text(displayKey)
                .font(.system(size: 12, weight: isHomeKey ? .bold : .medium, design: .monospaced))
                .foregroundColor(textColor)

            // Home key indicator (small dot)
            if isHomeKey {
                Circle()
                    .fill(Color.primary.opacity(0.3))
                    .frame(width: 4, height: 4)
                    .offset(y: 10)
            }
        }
        .frame(width: keyWidth, height: keyHeight)
        .opacity(isActive ? 1.0 : 0.4)
        .animation(.easeInOut(duration: 0.15), value: isHighlighted)
    }

    private var displayKey: String {
        if key.count == 1 {
            return key.uppercased()
        }
        return key
    }

    private var backgroundColor: Color {
        if isHighlighted {
            return finger.color.opacity(0.8)
        }
        return finger.color.opacity(0.2)
    }

    private var borderColor: Color {
        if isHighlighted {
            return finger.color
        }
        return finger.color.opacity(0.5)
    }

    private var textColor: Color {
        if isHighlighted {
            return .white
        }
        return .primary
    }
}

struct SpaceBarView: View {
    let isHighlighted: Bool
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(borderColor, lineWidth: isHighlighted ? 2 : 1)
                )
                .shadow(color: isHighlighted ? Finger.thumbs.color.opacity(0.6) : .clear, radius: 6)

            Text("SPACE")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(textColor)
        }
        .frame(width: 200, height: 32)
        .opacity(isActive ? 1.0 : 0.4)
        .animation(.easeInOut(duration: 0.15), value: isHighlighted)
    }

    private var backgroundColor: Color {
        if isHighlighted {
            return Finger.thumbs.color.opacity(0.8)
        }
        return Finger.thumbs.color.opacity(0.15)
    }

    private var borderColor: Color {
        if isHighlighted {
            return Finger.thumbs.color
        }
        return Finger.thumbs.color.opacity(0.4)
    }

    private var textColor: Color {
        if isHighlighted {
            return .white
        }
        return .primary
    }
}

#Preview {
    VStack(spacing: 10) {
        HStack {
            KeyView(key: "F", finger: .leftIndex, isHighlighted: true, isActive: true, isHomeKey: true)
            KeyView(key: "J", finger: .rightIndex, isHighlighted: false, isActive: true, isHomeKey: true)
            KeyView(key: "Q", finger: .leftPinky, isHighlighted: false, isActive: false, isHomeKey: false)
        }
        SpaceBarView(isHighlighted: false, isActive: true)
    }
    .padding()
    .background(Color(.windowBackgroundColor))
}
