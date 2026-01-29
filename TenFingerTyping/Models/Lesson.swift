import Foundation

struct Lesson: Identifiable {
    let id: Int
    let name: String
    let description: String
    let allowedKeys: Set<Character>
    let exercises: [String]

    var level: Int { id }
}

struct LessonLibrary {
    static let lessons: [Lesson] = [
        Lesson(
            id: 1,
            name: "Home Row",
            description: "Master the foundation - ASDF JKL;",
            allowedKeys: Set("asdf jkl;"),
            exercises: [
                "a sad lad falls",
                "dad asks a lass",
                "all lads add salads",
                "a flask falls flat",
                "ask dad for a salad",
                "alas a sad fall",
                "dad had a flask",
                "lass asks all dads"
            ]
        ),
        Lesson(
            id: 2,
            name: "Home + Top Row",
            description: "Add QWER and UIOP",
            allowedKeys: Set("asdf jkl;qweruiop"),
            exercises: [
                "we like to explore ideas",
                "please read our profile",
                "our people work well",
                "Europe is a safe paradise",
                "take a quick tour outside",
                "please upload your files",
                "quiet folks prefer solitude",
                "work requires deep focus"
            ]
        ),
        Lesson(
            id: 3,
            name: "Home + Bottom Row",
            description: "Add ZXCV and NM,.",
            allowedKeys: Set("asdf jkl;zxcvbnm,."),
            exercises: [
                "calm jazz band",
                "a blank canvas stands",
                "find balance in calm",
                "dance and clap along",
                "black sand beach",
                "snack on a banana",
                "valid claims stand firm",
                "man can plan and act"
            ]
        ),
        Lesson(
            id: 4,
            name: "All Letters",
            description: "Full alphabet practice",
            allowedKeys: Set("abcdefghijklmnopqrstuvwxyz "),
            exercises: [
                "the quick brown fox jumps over the lazy dog",
                "pack my box with five dozen liquor jugs",
                "how vexingly quick daft zebras jump",
                "sphinx of black quartz judge my vow",
                "the five boxing wizards jump quickly",
                "crazy frederick bought many very exquisite opal jewels",
                "we promptly judged antique ivory buckles for the next prize",
                "a quick movement of the enemy will jeopardize six gunboats"
            ]
        ),
        Lesson(
            id: 5,
            name: "Letters + Numbers",
            description: "Add number row",
            allowedKeys: Set("abcdefghijklmnopqrstuvwxyz 1234567890"),
            exercises: [
                "i have 2 cats and 3 dogs at home",
                "the year 2024 marks a new beginning",
                "order 15 pizzas for the 30 guests",
                "flight 747 departs at gate 22",
                "save 50 percent on all items today",
                "chapter 7 starts on page 142",
                "the password is 8675309",
                "mix 2 cups flour with 3 eggs"
            ]
        ),
        Lesson(
            id: 6,
            name: "Full Keyboard",
            description: "All keys including symbols",
            allowedKeys: Set("abcdefghijklmnopqrstuvwxyz 1234567890`-=[]\\;',./"),
            exercises: [
                "hello, world. how are you today?",
                "the price is 29.99 per item",
                "use the path/to/your/file.txt format",
                "arrays start at index [0] in most languages",
                "my email is test.user@mail.com",
                "the meeting is at 3;30 pm, don't be late",
                "use single quotes like 'this' for strings",
                "the formula is a = b + c - d"
            ]
        )
    ]

    static func lesson(for level: Int) -> Lesson {
        guard level >= 1 && level <= lessons.count else {
            return lessons[0]
        }
        return lessons[level - 1]
    }

    static func randomExercise(for level: Int) -> String {
        let lesson = lesson(for: level)
        return lesson.exercises.randomElement() ?? lesson.exercises[0]
    }

    static func generatePracticeText(for level: Int, wordCount: Int = 8) -> String {
        let lesson = lesson(for: level)
        var words: [String] = []

        for _ in 0..<wordCount {
            if let word = lesson.exercises.randomElement()?.components(separatedBy: " ").randomElement() {
                words.append(word)
            }
        }

        return words.joined(separator: " ")
    }

    static var maxLevel: Int {
        lessons.count
    }
}
