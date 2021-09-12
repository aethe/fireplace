//
//  Message.swift
//  Hearth
//
//  Created by Andrey Ufimtsev on 19/01/2020.
//

import Foundation

/// A log message.
public struct Message {
    /// The text of the message.
    public let text: String

    /// The level of the message.
    public let level: Level

    /// The tags of the message.
    public let tags: [Tag]

    /// The timestamp when the message was recorded.
    public let timestamp: Date

    /// The name of the file where the message was recorded.
    public let file: String

    /// The line in the file where the message was recorded.
    public let line: Int

    /// Creates a new log message.
    /// - Parameter text: The text of the message.
    /// - Parameter level: The level of the message.
    /// - Parameter tags: The tags of the message.
    /// - Parameter timestamp: The timestamp when the message was recorded. Defaults to the current timestamp.
    /// - Parameter file: The name of the file where the message was recorded. Defaults to the current file.
    /// - Parameter line: The line in the file where the message was recorded. Defaults to the current line.
    public init(text: String, level: Level, tags: [Tag], timestamp: Date = Date(), file: String = #file, line: Int = #line) {
        self.text = text
        self.level = level
        self.tags = tags
        self.timestamp = timestamp
        self.file = file
        self.line = line
    }
}
