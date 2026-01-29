import SwiftUI

enum Finger: String, CaseIterable {
    case leftPinky = "Left Pinky"
    case leftRing = "Left Ring"
    case leftMiddle = "Left Middle"
    case leftIndex = "Left Index"
    case rightIndex = "Right Index"
    case rightMiddle = "Right Middle"
    case rightRing = "Right Ring"
    case rightPinky = "Right Pinky"
    case thumbs = "Thumbs"

    var color: Color {
        switch self {
        case .leftPinky: return Color(red: 0.9, green: 0.3, blue: 0.3)   // Red
        case .leftRing: return Color(red: 1.0, green: 0.6, blue: 0.2)    // Orange
        case .leftMiddle: return Color(red: 1.0, green: 0.85, blue: 0.2) // Yellow
        case .leftIndex: return Color(red: 0.3, green: 0.8, blue: 0.4)   // Green
        case .rightIndex: return Color(red: 0.3, green: 0.6, blue: 0.9)  // Blue
        case .rightMiddle: return Color(red: 0.6, green: 0.4, blue: 0.8) // Purple
        case .rightRing: return Color(red: 0.7, green: 0.7, blue: 0.75)  // Light gray
        case .rightPinky: return Color(red: 0.4, green: 0.4, blue: 0.45) // Dark gray
        case .thumbs: return Color(red: 0.5, green: 0.5, blue: 0.5)      // Gray
        }
    }

    var shortName: String {
        switch self {
        case .leftPinky: return "L Pinky"
        case .leftRing: return "L Ring"
        case .leftMiddle: return "L Middle"
        case .leftIndex: return "L Index"
        case .rightIndex: return "R Index"
        case .rightMiddle: return "R Middle"
        case .rightRing: return "R Ring"
        case .rightPinky: return "R Pinky"
        case .thumbs: return "Thumbs"
        }
    }

    var isLeftHand: Bool {
        switch self {
        case .leftPinky, .leftRing, .leftMiddle, .leftIndex:
            return true
        default:
            return false
        }
    }
}

struct FingerMap {
    static let keyToFinger: [Character: Finger] = [
        // Number row
        "`": .leftPinky, "1": .leftPinky, "q": .leftPinky, "a": .leftPinky, "z": .leftPinky,
        "2": .leftRing, "w": .leftRing, "s": .leftRing, "x": .leftRing,
        "3": .leftMiddle, "e": .leftMiddle, "d": .leftMiddle, "c": .leftMiddle,
        "4": .leftIndex, "r": .leftIndex, "f": .leftIndex, "v": .leftIndex,
        "5": .leftIndex, "t": .leftIndex, "g": .leftIndex, "b": .leftIndex,

        "6": .rightIndex, "y": .rightIndex, "h": .rightIndex, "n": .rightIndex,
        "7": .rightIndex, "u": .rightIndex, "j": .rightIndex, "m": .rightIndex,
        "8": .rightMiddle, "i": .rightMiddle, "k": .rightMiddle, ",": .rightMiddle,
        "9": .rightRing, "o": .rightRing, "l": .rightRing, ".": .rightRing,
        "0": .rightPinky, "p": .rightPinky, ";": .rightPinky, "/": .rightPinky,
        "-": .rightPinky, "[": .rightPinky, "'": .rightPinky,
        "=": .rightPinky, "]": .rightPinky,
        "\\": .rightPinky,

        // Space bar
        " ": .thumbs
    ]

    static func finger(for character: Character) -> Finger {
        let lowercased = Character(character.lowercased())
        return keyToFinger[lowercased] ?? .thumbs
    }

    static func fingerHint(for character: Character) -> String {
        let finger = finger(for: character)
        let charDisplay = character == " " ? "SPACE" : String(character).uppercased()
        return "Press '\(charDisplay)' with \(finger.rawValue.uppercased()) finger"
    }
}

struct KeyboardLayout {
    static let numberRow: [String] = ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="]
    static let topRow: [String] = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\"]
    static let homeRow: [String] = ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'"]
    static let bottomRow: [String] = ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"]

    static let homeKeys: Set<Character> = ["a", "s", "d", "f", "j", "k", "l", ";"]

    static func isHomeKey(_ key: String) -> Bool {
        homeKeys.contains(Character(key.lowercased()))
    }
}
