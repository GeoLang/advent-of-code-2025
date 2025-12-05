// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser


@main
struct aoc: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(
        commandName: "aoc",
        abstract: "Run Advent of Code challenges.",
        usage: "aoc --day <day_number>",
        discussion: "Select the day to run using the --day argument.",
        subcommands: [Day1.self, Day2.self, Day3.self, Day4.self, Day5.self]
    )
}
