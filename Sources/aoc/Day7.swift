import ArgumentParser
import Foundation


struct Day7: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day7",
        abstract: "Run the Day 7 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 7.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    func run() throws {
        /// Save the start time to measure how long the solution took. 
        let start = DispatchTime.now()

        let fileContents = try String(contentsOfFile: inputFilePath)
        let rawLists = fileContents.split(separator: "\n").map{ String($0) }

        if task == 1 {
            task1(rawLists)
        } else if task == 2 {
            task2(rawLists)
        } else {
            print("Invalid task number: '\(task)'. Should be 1 or 2.")
        }

        /// Check the end time to measure how long we took.
        let end = DispatchTime.now()
        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        let seconds = Double(nanos) / 1_000_000_000
        print("Finished in: \(seconds)s")
    }

    func task1(_ rawRows: [String]) {
        var rows = rawRows
        rows[0] = rows.first!.replacingOccurrences(of: "S", with: "|")
        var splits = 0
        (0..<rows.count-1).forEach { idx in
            let beam = processTachyonBeam(from: rows[idx], to: rows[idx+1])
            rows[idx+1] = beam.beam
            splits += beam.splitCount
        }

        print(splits)
    }

    func task2(_ rawRows: [String]) {
        var rows = rawRows
        rows[0] = rows.first!.replacingOccurrences(of: "S", with: "|")

        /// Create the initial dictionary of potential timelines
        var timelinePositions: [Int: Int] = [:]
        for pos in findBeamIndices(of: rows.first!) {
            timelinePositions[pos] = 1
        }

        /// Split strings into `[[Character]]` for faster indexing
        let grid: [[Character]] = rows.map { Array($0) }
        var totalTimelineCount = 1

        /// For each row in the original input
        for rowIndex in 0..<(rows.count - 1) {
            var nextTimelinePositions: [Int: Int] = [:]

            /// For each position that has timelines
            for (position, timelineCount) in timelinePositions {
                if grid[rowIndex + 1][position] == "^" {
                    /// Beam splits, add 1 to each position on the left and right
                    nextTimelinePositions[position - 1, default: 0] += timelineCount
                    nextTimelinePositions[position + 1, default: 0] += timelineCount
                } else {
                    /// Continue straight
                    nextTimelinePositions[position, default: 0] += timelineCount
                }
            }

            // Calculate total timeline count
            let previousTotal = timelinePositions.values.reduce(0, +)
            let newTotal = nextTimelinePositions.values.reduce(0, +)
            totalTimelineCount += (newTotal - previousTotal)

            timelinePositions = nextTimelinePositions
        }

        print(totalTimelineCount)
    }

    /// A processed tachyon beam's metadata: The processedRow, the number of splits,
    /// and the indices of new splits
    fileprivate struct processedTachyonBeam {
        var beam: String
        var splitCount: Int
        var beamIndices: [Int]

        init(beam: String, splitCount: Int, beamIndices: [Int]) {
            self.beam = beam
            self.splitCount = splitCount
            self.beamIndices = beamIndices
        }
    }
    
    /// Analyse 2 rows, and decide how the beam should move.
    /// - Parameters:
    ///   - startRow: The origin row of the beam.
    ///   - _endRow: The row the beam is travelling into
    ///
    /// - Returns: A `processedTachyonBeam` containing the metadata of the beam's movement.
    fileprivate func processTachyonBeam(from startRow: String, to _endRow: String) -> processedTachyonBeam {
        var endRow: String = _endRow // We want to modify the end row
        let startBeamIndices: [Int] = findBeamIndices(of: startRow)

        var splitCount: Int = 0

        startBeamIndices.forEach { idx in
            if endRow[endRow.index(endRow.startIndex, offsetBy: idx)] == "^" {
                endRow = endRow.setChar(at: idx-1, with: "|")
                endRow = endRow.setChar(at: idx+1, with: "|")
                splitCount += 1
            } else {
                endRow = endRow.setChar(at: idx, with: "|")
            }
        }
        
        let indicies = findBeamIndices(of: endRow)
        return processedTachyonBeam(beam: endRow, splitCount: splitCount, beamIndices: indicies)
    }

    /// Quickly identifiy the indices that a beam currently falls within.
    /// - Parameter row: The row to be analysed.
    /// - Returns: A list of indices as an `[Int]`.
    func findBeamIndices(of row: String) -> [Int] {
        return row.enumerated().compactMap { index, char in
            char == "|" ? index : nil
        }
    }
}