import ArgumentParser
import Foundation


struct Day5: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day5",
        abstract: "Run the Day 5 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 5.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    func run() throws {
        /// Save the start time to measure how long the solution took. 
        let start = DispatchTime.now()

        let fileContents = try String(contentsOfFile: inputFilePath)
        let rawLists = fileContents.split(separator: "\n")
        var ranges: [String] = []
        var ingredients: [Int] = []

        rawLists.forEach { element in
            if element.contains("-") {
                ranges.append(String(element))
            }
            else {
                if element != "" {
                    ingredients.append(Int(element)!)
                }
            }
        }

        if task == 1 {
            task1(ranges: ranges, ingredients: ingredients)
        } else if task == 2 {
            task2(ranges: ranges)
        } else {
            print("Invalid task number: '\(task)'. Should be 1 or 2.")
        }

        /// Check the end time to measure how long we took.
        let end = DispatchTime.now()
        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        let seconds = Double(nanos) / 1_000_000_000
        print("Finished in: \(seconds)s")
    }

    fileprivate func task1(ranges: [String], ingredients: [Int]) {
        let freshIngredients = ingredients.map { isFresh(ranges: ranges, ingredient: $0) }
        print("Fresh ingredients: \(freshIngredients.count(where: {$0}))")
    }

    fileprivate func task2(ranges rawRanges: [String]) {
        let ranges = rawRanges.map { stringToClosedRange($0) }

        let out = simplifyRanges(ranges: ranges).reduce(0) { $0 + $1.count }
        print("Total fresh: \(out)")
    }

    /// Find overlapping ranges, and simplify them.
    /// - Parameter ranges: A list of `ClosedRange<Int>` to simplify.
    /// - Returns: A list of `ClosedRange<Int>` with overlapping ranges combined.
    fileprivate func simplifyRanges(ranges: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
        let reducedRanges = ranges.sorted { $0.lowerBound < $1.lowerBound }
        var mergedRanges: [ClosedRange<Int>] = [reducedRanges[0]]

        var index = 1
        while index < reducedRanges.count {
            let last = mergedRanges[mergedRanges.count - 1]
            let next = reducedRanges[index]

            if last.overlaps(next) {
                mergedRanges[mergedRanges.count - 1] =
                    last.lowerBound ... max(last.upperBound, next.upperBound)
            } else {
                mergedRanges.append(next)
            }

            index += 1
        }

        return mergedRanges
    }

    /// Convert a `String`` for a range (i.e. "xxx-yyyy") into a `ClosedRange<Int>`
    /// - Parameter range: The string formatted as "xxx-yyyy"
    /// - Returns: A `ClosedRange<Int>` with lowerBound and upperBound set based on the range.
    fileprivate func stringToClosedRange(_ range: String) -> ClosedRange<Int> {
        let splitRange = range.split(separator: "-")
        let lhs = Int(splitRange[0])!
        let rhs = Int(splitRange[1])!
        return lhs...rhs
    }

    /// Check whether a specific ingredient falls wtihin any range in `ranges`
    /// - Parameters:
    ///   - ranges: A list of `[ClosedRange<Int>]` to check the ingredient falls within.
    ///   - ingredient: The specific ingredient being checked
    ///
    /// - Returns: `true` if the ingredient is in any range, otherwise `false`.
    fileprivate func isFresh(ranges rawRanges: [String], ingredient: Int) -> Bool {
        let ranges = rawRanges.map(stringToClosedRange)
        for range in ranges {
            if range.contains(ingredient) {
                return true
            }
        }
        return false
    }
}
