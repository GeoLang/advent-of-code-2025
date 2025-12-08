import ArgumentParser
import Foundation


struct Day8Old: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "day8",
        abstract: "Run the Day 8 Advent of Code challenge."
    )

    @Argument(help: "Path to the input file for Day 8.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The task to run, 1 or 2.")
    var task: Int

    func run() throws {
        /// Save the start time to measure how long the solution took. 
        let start = DispatchTime.now()

        let fileContents = try String(contentsOfFile: inputFilePath)
        let junctionBoxes = fileContents.split(separator: "\n")
            .map { String($0) }
            .map { $0.split(separator: ",") }
            .map { JunctionBox(x: Int($0[0])!, y: Int($0[1])!, z: Int($0[2])!) }

        if task == 1 {
            task1(junctionBoxes)
        } else if task == 2 {
            task2(junctionBoxes)
        } else {
            print("Invalid task number: '\(task)'. Should be 1 or 2.")
        }

        /// Check the end time to measure how long we took.
        let end = DispatchTime.now()
        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        let seconds = Double(nanos) / 1_000_000_000
        print("Finished in: \(seconds)s")
    }

    func task1(_ rawList: [JunctionBox]) {
        var collection = JunctionBoxCollection(boxes: rawList)

        collection.networkify()

        let longestNetworks = collection.findNetworks().map { row in
            row.count
        }.sorted{ $0 > $1 }
        print(longestNetworks)
        print(longestNetworks[0] * longestNetworks[1] * longestNetworks[2])
    }

    func task2(_ rawList: [JunctionBox]) {
        var collection = JunctionBoxCollection(boxes: rawList)

        let (box1, box2) = collection.networkifyUntilConnected()
        print(box1.x * box2.x)
    }
}

struct JunctionBoxCollection {
    var boxes: [JunctionBox]
    var distances: [[Int]] // The distance between each box
    var closestBoxIndices: [Int] = []

    init(boxes: [JunctionBox]) {
        /// Assemble the list of `JunctionBox` and their distances array
        self.boxes = boxes
        self.distances = (0..<boxes.count).map { _ in
            var row = [Int]()
            row.reserveCapacity(boxes.count)
            return row
        }

        /// Iterate through each box, and calculate the distance to others.
        _ = self.boxes.enumerated().map { idx, box in
            self.distances[idx] = self.boxes.map { otherBox in
                // JunctionBox.absolute(box - otherBox).magnitude
                box.distanceTo(otherBox)
            }
            // remove 0 values
            _ = self.distances[idx].enumerated().map { distIdx, distValue in
                if distValue == 0 {
                    self.distances[idx][distIdx] = 999999
                }
            }
        }

        self.closestBoxIndices = distances.enumerated().map { idx, val in
            return Int(val.firstIndex(of: val.min() ?? 0) ?? 0)
        }
    }

    func findNetworks() -> [[JunctionBox]] {
        var networks: [[JunctionBox]] = []
        var visited = Set<UUID>()

        for box in boxes {
            if visited.contains(box.id) {
                continue
            }

            let component = box.obtainNetwork(from: nil)

            for b in component {
                visited.insert(b.id)
            }

            networks.append(component)
        }

        return networks
    }

    /// Calculate the networks in a `JunctionBoxCollection`
    mutating func networkify(iterations: Int = 1000) {
        /// Find the shortest distance between any nodes
        for iteration in 0..<iterations {
            let shortestDistances = self.distances.map { distance in
                distance.min() ?? 999999
            }
            let shortestIndex = shortestDistances.firstIndex(
                of: shortestDistances.min() ?? 0
            )!
            

            /// Using the `shortestIndex`, connect the nodes
            if let otherBoxIndex = self.distances[shortestIndex].firstIndex(of: shortestDistances[shortestIndex]) {
                self.boxes[shortestIndex].connectedBoxes.append(self.boxes[otherBoxIndex])
                self.boxes[otherBoxIndex].connectedBoxes.append(self.boxes[shortestIndex])
                self.distances[shortestIndex][otherBoxIndex] = 9999999
                self.distances[otherBoxIndex][shortestIndex] = 9999999
            }
        }
    }

    mutating func networkifyUntilConnected() -> (JunctionBox, JunctionBox) {
        var lastA: JunctionBox? = nil
        var lastB: JunctionBox? = nil

        while findNetworks().count > 1 {
            let shortestDistances = self.distances.map { $0.min() ?? 999999 }
            let shortestIndex = shortestDistances.firstIndex(of: shortestDistances.min()!)!

            if let otherIndex = self.distances[shortestIndex]
                .firstIndex(of: shortestDistances[shortestIndex]) {

                let a = self.boxes[shortestIndex]
                let b = self.boxes[otherIndex]

                // record these as the last pair
                lastA = a
                lastB = b

                // connect them
                a.connectedBoxes.append(b)
                b.connectedBoxes.append(a)

                // mark distance as used
                self.distances[shortestIndex][otherIndex] = 9999999
                self.distances[otherIndex][shortestIndex] = 9999999
            }
        }

        return (lastA!, lastB!)
    }
}

final class JunctionBox: Identifiable, CustomStringConvertible {
    let id: UUID = UUID()
    /// This is literally just a Vector3
    let x: Int
    let y: Int
    let z: Int

    var connectedBoxes: [JunctionBox] = []

    var network: Int? = nil

    var magnitude: Int {
        return abs(self.x) + abs(self.y) + abs(self.z)
    }

    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    static func -(lhs: JunctionBox, rhs: JunctionBox) -> JunctionBox {
        return JunctionBox (
            x: lhs.x-rhs.x,
            y: lhs.y-rhs.y,
            z: lhs.z-rhs.z
        )
    }

    func obtainNetwork(from origin: JunctionBox?) -> [JunctionBox] {
        var visited = Set<UUID>()
        var result: [JunctionBox] = []

        func dfs(_ box: JunctionBox, _ cameFrom: JunctionBox?) {
            if visited.contains(box.id) {
                return
            }

            visited.insert(box.id)
            result.append(box)

            let next = box.connectedBoxes.filter { other in
                if let from = cameFrom {
                    return other.id != from.id
                }
                return true
            }

            for n in next {
                dfs(n, box)
            }
        }

        dfs(self, origin)
        return result
    }

    func distanceTo(_ other: JunctionBox) -> Int {
        let xDist = Double(self.x - other.x)
        let yDist = Double(self.y - other.y)
        let zDist = Double(self.z - other.z)

        return Int(((xDist * xDist) + (yDist * yDist) + (zDist * zDist)).squareRoot())
    }

    static func absolute(_ box: JunctionBox) -> JunctionBox {
        var x = box.x
        if box.x < 0 {
            x = -box.x
        }
        var y = box.y
        if box.y < 0 {
            y = -box.y
        }
        var z = box.z
        if box.z < 0 {
            z = -box.z
        }

        return JunctionBox (
            x: x,
            y: y,
            z: z,
        )
    }

    var description: String {
        "(x: \(self.x), y: \(self.y), z: \(self.z))"
    }
}