import ArgumentParser


struct Day2: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day2",
        abstract: "Run the Day 2 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 2.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    func run() throws {
        let fileContents = try String(contentsOfFile: inputFilePath)
        let rawRanges = fileContents.split(separator: ",").map { String($0) }.map{ (Int($0.split(separator: "-").first!)!,  Int($0.split(separator: "-").last!)!) }

        if task == 1 {
            task1(rawRanges)
        } else if task == 2 {
            task2(rawRanges)
        } else {
            print("Invalid task number: '\(task)'. Should be 1 or 2.")
        }
    }

    fileprivate func task2checkInvalid(_ id: String) -> Int {
        let midIdx = id.count / 2

        // Simple guard to avoid a strange edgecase. Dw about it xoxo.
        if midIdx == 0 {
            return 0
        }

        /// Loop through rages from 1 to the mid-point for generating substrings.
        for idx in 1...midIdx {
            /// Get the center point being used to split the string.
            let _prefix = id.index(id.startIndex, offsetBy: idx)
            /// Assign `lhs` to the start characters of the string, from idx 0 to the current idx.
            let lhs = id[..<_prefix]
            /// assign rhs to the remainder of the string
            let rhs = id[_prefix...]

            if (rhs.count % lhs.count) == 0 {
                let comparisonString = String(repeating: String(lhs), count: rhs.count/lhs.count)
                if rhs == comparisonString {
                    return Int(id)!
                }
            }
        }

        return 0
    }

    fileprivate func task2(_ ranges: [(Int, Int)]) {
        var invalidCounter: Int = 0
        for (lhsIdx, rhsIdx) in ranges {
            let range: ClosedRange<Int> = lhsIdx...rhsIdx
            range.forEach { id in
                let currentID: String = String(id)
                invalidCounter += task2checkInvalid(currentID)
            }
        }

        print("InvalidID count: \(invalidCounter)")
    }

    fileprivate func task1(_ ranges: [(Int, Int)]) {
        var invalidCounter: Int = 0
        for (lhsIdx, rhsIdx) in ranges {
            let range: ClosedRange<Int> = lhsIdx...rhsIdx
            range.forEach { id in
                var currentID: String = String(id)
                if currentID.count % 2 == 0 {
                    let midIdx = currentID.count / 2
                    let splitIdx = currentID.index(currentID.startIndex, offsetBy: midIdx)
                    let lhs = currentID[..<splitIdx]
                    let rhs = currentID[splitIdx...]
                    if lhs == rhs {
                        invalidCounter += id
                    }
                }
            }
        }

        print("InvalidID count: \(invalidCounter)")
    }
}