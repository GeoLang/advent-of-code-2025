import ArgumentParser
import Foundation


struct Day6: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day6",
        abstract: "Run the Day 6 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 6.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    enum Operator: String {
        case Multiply
        case Add
        case None

        static func from(char: String) -> Operator {
            switch char {
            case "+": return .Add
            case "*": return .Multiply
            default: return .None
            }
        }

        /// Apply the specified operator to a list of Integers
        /// - Parameters:
        ///   - list: The list of integers to apply this operation to.
        ///
        func apply(list: [Int]) -> Int {
            switch self {
            case .None: return 0   // No-op
            case .Add: return list.reduce(0, +)
            case .Multiply: return list.reduce(1, *)
            }
        }
    }

    func run() throws {
        let fileContents = try String(contentsOfFile: inputFilePath)
        let rawLists = fileContents.split(separator: "\n").map{ String($0) }

        let iterations = 100

        var total: Int = 0

        /// Save the start time to measure how long the solution took.
        let start = DispatchTime.now()

        for _ in 0...iterations {
            if task == 1 {
                total = task1(rawLists)
            } else if task == 2 {
                total = task2(rawLists)
            } else {
                print("Invalid task number: '\(task)'. Should be 1 or 2.")
            }
        }

        /// Check the end time to measure how long we took.
        let end = DispatchTime.now()
        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        let seconds = Double(nanos) / 1_000_000_000
        print("Grand total: \(total)")
        print("Ran \(iterations) iterations.")
        print("Finished in an average of: \(seconds / Double(iterations))s")
    }

    func task1(_ rawLists: [String]) -> Int {
        /// Format the data into a more usable format
        let regex = " +"
        var rawValues: [[String]] = []
        for line in rawLists {
            let tmp = line.trimmingCharacters(in: .whitespacesAndNewlines)
              .replacingOccurrences(of: regex, with: "|", options: [.regularExpression])
              .split(separator: "|")
              .map{ String($0) }
            rawValues.append(tmp)
        }

        // Extract just the instructions
        let instructions = rawValues.popLast()!.map { Operator.from(char: $0)  }

        // Convert the values into integers
        let formattedValues = rawValues.map { row in
            row.map { Int($0)! }
        }

        let instructionCount = instructions.count
        var sumBins: [[Int]] = Array(repeating: [Int](), count: instructionCount)

        for index in 0..<instructionCount {
            formattedValues.forEach { sumBins[index].append($0[index]) }
        }

        var grandTotal = 0

        for (index, row) in sumBins.enumerated() {
            grandTotal += instructions[index].apply(list: row)
        }

        return grandTotal
        // print("DEBUG: Grand total is correct: \(grandTotal == 6295830249262)")

    }

    func task2(_ _rawLists: [String]) -> Int {
        var rawLists = _rawLists
        let rawInstructions = rawLists.popLast()!

        /// Get the indicies of all instructions for, for identifying columns
        var instructionIndices: [Int] = []
        for (index, value) in rawInstructions.enumerated() {
            if value == "+" || value == "*" {
                instructionIndices.append(index)
            }
        }

        // Convert the instructions string into a list of instructions
        var tmp = rawInstructions
        for index in instructionIndices {
            if index != 0 {
                // tmp.setChar("|", at: index-1)
                tmp = tmp.setChar(at: index-1, with: "|")
            }
        }
        let instructions = tmp.split(separator: "|").map { Operator.from(char: String($0.first!)) }
        let instructionCount = instructions.count

        // Replace the columns with | characters to split them later
        tmp = rawLists.first!
        var rawRows: [[String]] = []
        for row in rawLists {
            tmp = row
            for index in instructionIndices {
                if index != 0 {
                    tmp = tmp.setChar(at: index-1, with: "|")
                    // tmp.setChar("|", at: index-1)
                }
            }
            rawRows.append(tmp.split(separator: "|").map { String($0) })
        }

        // Take the original rawRows and transpose them.
        let transposed = (0..<instructionCount).map { i in
            rawRows.map { $0[i] }
        }
        .map { translateColumn($0) }

        // Apply the operation to each row and add them all together.
        let grandTotal = zip(transposed, instructions)
            .map { row, op in
                op.apply(list: row)
            }
            .reduce(0, +)
        
        return grandTotal
    }

    /// Convert a list of Strings into right-aligned column-digits.
    /// - Parameter column: The column to be right aligned.
    /// - Returns: A list of right alined Integers.
    func translateColumn(_ column: [String]) -> [Int] {
        let maxLength = column.map{ $0.count }.max()!

        var newStrings: [String] = []
        for _ in 1...maxLength {
            newStrings.append("")
        }
        
        for index in stride(from: maxLength-1, through: 0, by: -1) {
            column.forEach { item in
                let char = item[item.index(item.startIndex, offsetBy: index)]
                if char != " " {
                    newStrings[index].append(char)
                }
            }
        }

        return newStrings.map { Int($0)! }
    }
}

extension String {
    ///  Modify a string by replacing a character at a specified index
    /// - Parameters:
    ///   - index: The position of the character to be replaced.
    ///   - char: The character being added to the string.
    ///
    /// - Returns: The modified string
    func setChar(at index: Int, with char: Character) -> String {
        var copy = self
        let idx = copy.index(copy.startIndex, offsetBy: index)
        copy.replaceSubrange(idx...idx, with: String(char))
        return copy
    }
}