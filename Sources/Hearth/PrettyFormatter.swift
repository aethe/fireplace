//
//  PrettyFormatter.swift
//  Hearth
//
//  Created by Andrey Ufimtsev on 19/01/2020.
//

import Foundation

/// A formatter that converts log messages into elegantly organised strings.
public struct PrettyFormatter: Formatter {
    /// The date formatter to format message timestamps.
    private let dateFormatter = DateFormatter()

    /// Creates a new default formatter.
    public init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
    }

    /// Converts a log message to a string which includes the level, the timestamp, the location in the file, the tags, and the text of the message.
    /// - Parameter message: The message to format.
    public func string(from message: Message) -> String {
        let attributes = [
            levelComponent(from: message),
            timestampComponent(from: message),
            locationComponent(from: message),
            tagComponent(from: message)
        ]

        let attributeString = attributes
            .compactMap { $0 }
            .joined(separator: " ")

        return [attributeString, message.text].joined(separator: ": ")
    }

    /// Returns a unicode emoji representing the level of a log message.
    /// - Parameter message: The message being formatted.
    private func levelComponent(from message: Message) -> String {
        switch message.level {
        case .info: return "💬"
        case .warning: return "⚠️"
        case .error: return "⛔"
        }
    }

    /// Formats the timestamp of a log message.
    /// - Parameter message: The message being formatted.
    private func timestampComponent(from message: Message) -> String {
        return "\(dateFormatter.string(from: message.timestamp))"
    }

    /// Formats the file location of a log message.
    /// - Parameter message: The message being formatted.
    private func locationComponent(from message: Message) -> String {
        return "@\(NSString(string: NSString(string: message.file).lastPathComponent).deletingPathExtension):\(message.line)"
    }

    /// Formats the tags of a log message.
    /// - Parameter message: The message being formatted.
    private func tagComponent(from message: Message) -> String? {
        return message.tags.isEmpty ? nil : message.tags.map { "#\($0)" }.joined(separator: " ")
    }
}
