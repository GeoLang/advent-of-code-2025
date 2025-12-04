import ArgumentParser


struct Day1: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day1",
        abstract: "Run the Day 1 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 1.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    var dialSize: Int = 100;

    func run() throws {
        let fileContents = try String(contentsOfFile: inputFilePath)
        let lines = fileContents.split(separator: "\n").map { String($0) }

        let steps = lines.map { mapSteps($0) }

        if task == 1 {
            try task1(steps)
        } else if task == 2 {
            task2(steps)
        } else {
            print("Task \(task) is not implemented yet.")
        }
    }

    /// Day 1 Task 1 of Advent of Code.
    /// - Parameter steps: A list of each rotation that needs to be taken, as a positive or negative integer.
    fileprivate func task1(_ steps: [Int]) throws {
        var dial: Int = 50;
        let dialSize: Int = 100;
        var zeroCount: Int = 0;

        for step in steps {
            dial = (dial + step) % dialSize
            if dial < 0 {
                while dial < 0 {
                    dial += dialSize
                }
            }
            if dial == 0 {
                zeroCount += 1
            }
            print("Dial: \(dial)")
        }
        print("Zero Count: \(zeroCount)")
    }

    /// Day 1 Task 2 of Advent of Code.
    /// - Parameter steps: A list of each rotation that needs to be taken, as a positive or negative integer.
    fileprivate func task2(_ steps: [Int]) {
        var dial: Int = 50;
        var clicks: Int = 0;
        var currentStep: Int;

        func click(_ label: String = "") {
            clicks += 1
            print("Click! \(label), total clicks: \(clicks)")
        }

        for step in steps {
            if step % dialSize != step { // The step is over 100/-100, reduce it and add clicks
                let extraClicks = abs(step) / dialSize
                clicks += extraClicks
                currentStep = step % dialSize
            } else {
                currentStep = step
            }

            var newDial: Int = dial + currentStep

            if newDial == 0 {
                clicks += 1
                print("newDial == 0 click")
            } else {
                if newDial < 0 {
                    newDial += dialSize
                    newDial = newDial % dialSize
                    if newDial == 0 { clicks += 1 }
                    if dial != 0 {
                        clicks += 1
                        print("newDial < 0 Click")
                    }
                } else if newDial >= dialSize {
                    newDial = newDial - dialSize
                    // if newDial == 0 { clicks += 1; print("newDial == 0 click") }
                    clicks += 1
                    print("newDial >= dialSize click")
                }
            }

            print("Start: \(dial), step: \(step), newDial: \(newDial), clicks: \(clicks)")
            dial = newDial
        }

        print("Clicks: \(clicks)")
    }
    
    fileprivate func mapDirection(_ direction: String) -> Int {
        switch direction {
        case "L":
            return -1
        case "R":
            return 1
        default:
            fatalError("Invalid direction")
        }
    }

    fileprivate func mapSteps(_ step: String) -> Int {
        let stepChar = step[step.startIndex]
        let magnitude = Int(step.dropFirst())!
        return magnitude * mapDirection(String(stepChar))
    }
}