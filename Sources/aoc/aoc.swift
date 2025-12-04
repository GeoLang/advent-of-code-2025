// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser


enum Day: Int, ExpressibleByArgument {
    case day1 = 1
    case day2 = 2
    case day3 = 3
    case day4 = 4
    case day5 = 5
    case day6 = 6
    case day7 = 7
    case day8 = 8
    case day9 = 9
    case day10 = 10
    case day11 = 11
    case day12 = 12
}

@main
struct aoc: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(
        commandName: "aoc",
        abstract: "Run Advent of Code challenges.",
        usage: "aoc --day <day_number>",
        discussion: "Select the day to run using the --day argument.",
        subcommands: [Day1.self, Day2.self, Day3.self, Day4.self]
    )
}
