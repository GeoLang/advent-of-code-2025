import ArgumentParser


struct Day3: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day3",
        abstract: "Run the Day 3 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 3.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    func run() throws {
        let fileContents = try String(contentsOfFile: inputFilePath)
        let rawLists = fileContents.split(separator: "\n").map { Array($0) } 
        .map { row in
            row.compactMap { Int(String($0)) }
        }

        if task == 1 {
            joltageCalculator(rawLists, target: 2)
        } else if task == 2 {
            joltageCalculator(rawLists, target: 12)
        } else {
            print("Invalid task number: '\(task)'. Should be 1 or 2.")
        }
    }

    /// Generic solver for Day 3 of Advent of Code.
    /// - Parameters:
    ///   - rawLists: An `[[Int]]` containing the power of each cell in the battery bank.
    ///   - target: The number of cells per row.
    func joltageCalculator(_ rawLists: [[Int]], target: Int = 12) {
        let CELL_TARGET = target

        var powerCount: Int = 0
        
        for row in rawLists {
            var currentCell = 1

            var cells: [Int] = []
            var cellIdxs: [Int] = []

            /// Look, I struggled alright. I tried to do it _swift~y_, but it was causing me
            /// a headache, so here's Swift code written Pythonically. Don't judge me.
            while currentCell <= CELL_TARGET {
                let startIdx = cellIdxs.last ?? 0
                let lastIdx: Int = row.count - (CELL_TARGET - currentCell)-1
                
                var highestValue = 0
                var highestIdx = 0

                for x in startIdx...lastIdx {
                    if row[x] > highestValue {
                        highestValue = row[x]
                        highestIdx = x
                    }
                }

                cells.append(highestValue)
                cellIdxs.append(highestIdx+1)

                currentCell += 1
            }

            
            var output = ""
            cells.forEach { output += String($0) }  /// Disgusting.

            powerCount += Int(output)!  /// I'm sorry.
        }

        print("Joltage: \(powerCount)")
    }
}