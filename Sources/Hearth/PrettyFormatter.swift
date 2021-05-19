//
//  PrettyFormatter.swift
//  Hearth
//
//  Created by Andrey Ufimtsev on 19/01/2020.
//

import Foundation

/// A formatter that converts log messages into elegantly organised strings.
public struct PrettyFormatter: Formatter {
    /// The style used for formatting message levels.
    private let levelStyle: LevelStyle

    /// The style used for formatting message timestamps.
    private let timestampStyle: TimestampStyle

    /// Indicates whether locations should be included in the output.
    private let includesLocation: Bool

    /// Indicates whether tags should be included in the output.
    private let includesTags: Bool

    /// The date formatter to format message timestamps.
    private let dateFormatter = DateFormatter()

    /// Creates a new pretty formatter.
    /// - Parameters:
    ///   - levelStyle: The style used for formatting message levels. Defaults to `.none`.
    ///   - timestampStyle: The style used for formatting message timestamps. Defaults to `.none`.
    ///   - includesLocation: Indicates whether locations should be included in the output. Defaults to `false`.
    ///   - includesTags: Indicates whether tags should be included in the output. Defaults to `false`.
    public init(
        levelStyle: LevelStyle = .none,
        timestampStyle: TimestampStyle = .none,
        includesLocation: Bool = false,
        includesTags: Bool = false
    ) {
        self.levelStyle = levelStyle
        self.timestampStyle = timestampStyle
        self.includesLocation = includesLocation
        self.includesTags = includesTags
        
        switch timestampStyle {
        case .none: break
        case .time: dateFormatter.dateFormat = "HH:mm:ss"
        case .dateTime: dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        case .dateTimeOffset: dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
        }
    }

    /// Converts a log message to a string with the previously specified formatting rules.
    /// - Parameter message: The message to format.
    public func string(from message: Message) -> String {
        let levelComponent = self.levelComponent(from: message)
        let timestampComponent = self.timestampComponent(from: message)
        let locationComponent = self.locationComponent(from: message)
        let tagComponent = self.tagComponent(from: message)
        
        switch (levelComponent, timestampComponent, locationComponent, tagComponent) {
        case (.none, .none, .none, .none):
            return message.text
            
        case (.some(let levelComponent), .none, .none, .none):
            return "\(levelComponent) \(message.text)"
            
        default:
            let attributes = [
                levelComponent,
                timestampComponent,
                locationComponent,
                tagComponent
            ]

            let attributeString = attributes
                .compactMap { $0 }
                .joined(separator: " ")
            
            return [attributeString, message.text].joined(separator: ": ")
        }
    }

    /// Returns a unicode emoji representing the level of a log message.
    /// - Parameter message: The message being formatted.
    private func levelComponent(from message: Message) -> String? {
        switch levelStyle {
        case .none:
            return nil
            
        case .text:
            switch message.level {
            case .info: return "[info]"
            case .warning: return "[warning]"
            case .error: return "[error]"
            }

        case .emoji:
            switch message.level {
            case .info: return "💬"
            case .warning: return "⚠️"
            case .error: return "⛔"
            }
        }
    }

    /// Formats the timestamp of a log message.
    /// - Parameter message: The message being formatted.
    private func timestampComponent(from message: Message) -> String? {
        guard timestampStyle != .none else {
            return nil
        }
        
        return "\(dateFormatter.string(from: message.timestamp))"
    }

    /// Formats the file location of a log message.
    /// - Parameter message: The message being formatted.
    private func locationComponent(from message: Message) -> String? {
        guard includesLocation else {
            return nil
        }
        
        return "@\(NSString(string: NSString(string: message.file).lastPathComponent).deletingPathExtension):\(message.line)"
    }

    /// Formats the tags of a log message.
    /// - Parameter message: The message being formatted.
    private func tagComponent(from message: Message) -> String? {
        guard includesTags else {
            return nil
        }
        
        return message.tags.isEmpty ? nil : message.tags.map { "#\($0)" }.joined(separator: " ")
    }

    /// A style for formatting message levels.
    public enum LevelStyle {
        /// Message levels are not included in the output.
        case none
        
        /// Message levels are represented with text.
        case text
        
        /// Message levels are represented with emojis.
        case emoji
    }

    /// A style for formatting message timestamps.
    public enum TimestampStyle {
        /// Timestamps are not included in the output.
        case none
        
        /// Timestamps are represented as time.
        case time
        
        /// Timestamps are represented as a date and time.
        case dateTime
        
        /// Timestamps are represented as a date, time and a time offset.
        case dateTimeOffset
    }
}
