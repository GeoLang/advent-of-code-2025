import ArgumentParser


struct Day4: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day4",
        abstract: "Run the Day 4 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 4.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    func run() throws {
        let fileContents = try String(contentsOfFile: inputFilePath)
        let rawLists = fileContents.split(separator: "\n").map { Array($0) } 
        .map { row in
            row.compactMap { String($0) }
        }

        if task == 1 {
            task1(rawLists)
        } else if task == 2 {
            task2(rawLists)
        } else {
            print("Invalid task number: '\(task)'. Should be 1 or 2.")
        }
    }

    fileprivate func task1(_ input: [[String]]) {
        let ROW_LENGTH = input.first!.count
        let flatInput = input.flatMap{$0}

        let MAX_LENGTH = flatInput.count
        var accessibleCount = 0
        var accessibleIndexes: [Int] = []
        for (position, value) in flatInput.enumerated() {
            if value != "@" {
                continue
            }

            let directions = cardinalDirections(
                position: position,
                length: ROW_LENGTH,
                maxLength: MAX_LENGTH
            )

            var rollCount: Int = 0
            for direction in directions {
                if flatInput[direction] == "@" {
                    rollCount += 1
                }
            }

            if rollCount <= 3 {
                accessibleCount += 1
                accessibleIndexes.append(position)
            }
        }

        print(accessibleCount)
    }

    fileprivate func task2(_ input: [[String]]) {
        // input.forEach { print($0) }
        let ROW_LENGTH = input.first!.count
        var flatInput = input.flatMap{$0}

        let MAX_LENGTH = flatInput.count
        var accessibleCount = 0
        var accessibleIndexes: [Int] = []


        var can_extract_rolls: Bool = true

        while can_extract_rolls {
            accessibleIndexes = []

            for (position, value) in flatInput.enumerated() {
                if value != "@" {
                    continue
                }

                let directions = cardinalDirections(
                    position: position,
                    length: ROW_LENGTH,
                    maxLength: MAX_LENGTH
                )

                var rollCount: Int = 0
                for direction in directions {
                    if flatInput[direction] == "@" {
                        rollCount += 1
                    }
                }

                if rollCount <= 3 {
                    accessibleCount += 1
                    accessibleIndexes.append(position)
                }
            }

            if accessibleIndexes.count == 0 {
                can_extract_rolls = false
            }
            // Remove extractable rolls
            accessibleIndexes.forEach { flatInput[$0] = "." }
        }
        
        print(accessibleCount)
    }

    func cardinalDirections(position: Int, length: Int, maxLength: Int) -> [Int] {
        var returnArrayRaw = [ position - length - 1,  position - length, position - length + 1,
                    position - 1, position + 1,
                    position + length - 1, position + length, position + length + 1
        ]

        if position == 0 { // Top left corner, remove invalid positions
            returnArrayRaw.removeAll(where: { $0 == position - Direction.upLeft.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.up.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.upRight.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.left.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position + Direction.downLeft.offset(rowLength: length)})
        }

        if position == length { // Top right corner
            returnArrayRaw.removeAll(where: { $0 == position - Direction.right.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.downRight.offset(rowLength: length)})
        }

        if position % length == 0 { // Right edge
            returnArrayRaw.removeAll(where: { $0 == position - Direction.upRight.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.right.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.downRight.offset(rowLength: length)})
        }

        if position % length == length-1 { // Left edge
            returnArrayRaw.removeAll(where: { $0 == position - Direction.upLeft.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.left.offset(rowLength: length)})
            returnArrayRaw.removeAll(where: { $0 == position - Direction.downLeft.offset(rowLength: length)})
        }

        var returnArray: [Int] = []
        returnArrayRaw.forEach { pos in
            if pos >= 0 && pos < maxLength {
                returnArray.append(pos)
            }
        }

        return returnArray
    }
}

enum Direction {
    case upLeft
    case up
    case upRight
    case left
    case right
    case downLeft
    case down
    case downRight

    func offset(rowLength: Int) -> Int {
        switch self {
        case .upLeft:     return -rowLength - 1
        case .up:         return -rowLength
        case .upRight:    return -rowLength + 1
        case .left:       return -1
        case .right:      return 1
        case .downLeft:   return rowLength - 1
        case .down:       return rowLength
        case .downRight:  return rowLength + 1
        }
    }
}