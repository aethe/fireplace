//
//  Fireplace.swift
//  Fireplace
//
//  Created by Andrey Ufimtsev on 05/06/2019.
//  Copyright © 2019 Andrey Ufimtsev. All rights reserved.
//

import Foundation
import os

/// A logging destination.
public protocol Log: AnyObject {
    /// Writes a message to the log.
    /// - Parameter message: The message to write.
    func write(_ message: Message)
}

/// A log written to the console.
public final class ConsoleLog: Log {
    /// The queue on which printing to the console is performed.
    private let queue = DispatchQueue(label: "fireplace-console", qos: .utility)

    /// The formatter used to format messages.
    private let formatter: Formatter

    /// Creates a new console log.
    ///
    /// - Parameter formatter: The formatter used to format messages.
    public init(formatter: Formatter = PrettyFormatter()) {
        self.formatter = formatter
    }

    /// Prints a message to the console.
    ///
    /// - Parameter message: The message to print.
    public func write(_ message: Message) {
        queue.sync {
            print(formatter.string(from: message))
        }
    }
}

/// A log written to a file.
public final class FileLog: Log {
    /// The system log for reporting errors related to file log initialisation.
    private static let systemLog = OSLog(subsystem: "io.github.aethe.fireplace", category: "file-logging")

    /// A URL representing the default directory of log files.
    ///
    /// Logs are stored in the caches directory by default. It is recommended to use another directory on macOS, since the caches directory is system-wide.
    public static var defaultDirectoryURL: URL? {
        return FileManager
            .default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("fireplace")
    }

    /// An automatically generated file name based on the current date and time.
    private static var defaultFileName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ssZ"
        return "\(dateFormatter.string(from: Date())).txt"
    }

    /// The URL representing the location of the associated file.
    public let url: URL

    /// The handle for the associated file.
    private let fileHandle: FileHandle

    /// The formatter used to format messages.
    private let formatter: Formatter

    /// Creates a new file log at a specified URL.
    /// - Parameter url: The URL representing the file location.
    /// - Parameter formatter: The formatter used to format messages.
    public init?(url: URL, formatter: Formatter = PrettyFormatter()) {
        if !FileManager.default.fileExists(atPath: url.path) {
            guard FileManager.default.createFile(atPath: url.path, contents: nil) else {
                os_log("Could not create a file at %{public}@.", log: FileLog.systemLog, type: .error, url.path)
                return nil
            }
        }

        guard let fileHandle = try? FileHandle(forWritingTo: url) else {
            os_log("Could not open a file for writing at %{public}@.", log: FileLog.systemLog, type: .error, url.path)
            return nil
        }

        self.url = url
        self.fileHandle = fileHandle
        self.formatter = formatter
    }

    /// Creates a new file log with a specified name at the default directory.
    /// - Parameter fileName: The name of the file.
    /// - Parameter formatter: The formatter used to format messages.
    public convenience init?(fileName: String, formatter: Formatter = PrettyFormatter()) {
        guard let directoryURL = FileLog.defaultDirectoryURL else {
            os_log("Could not get the default directory.", log: FileLog.systemLog, type: .error)
            return nil
        }

        guard let _ = try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true) else {
            os_log("Could not create a directory at %{public}@.", log: FileLog.systemLog, type: .error, directoryURL.path)
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)
        self.init(url: fileURL, formatter: formatter)
    }

    /// Creates a new file log with an automatically generated file name at a specified directory.
    /// - Parameter directoryURL: The URL representing the directory.
    /// - Parameter formatter: The formatter used to format messages.
    public convenience init?(directoryURL: URL, formatter: Formatter = PrettyFormatter()) {
        guard directoryURL.hasDirectoryPath else {
            os_log("The path %{public}@ does not represent a directory.", log: FileLog.systemLog, type: .error, directoryURL.path)
            return nil
        }

        self.init(url: directoryURL.appendingPathComponent(FileLog.defaultFileName), formatter: formatter)
    }

    /// Creates a new file log with an automatically generated file name at the default directory.
    /// - Parameter formatter: The formatter used to format messages.
    public convenience init?(formatter: Formatter = PrettyFormatter()) {
        self.init(fileName: FileLog.defaultFileName, formatter: formatter)
    }

    /// Writes a message to the associated file.
    /// - Parameter message: The message to write.
    public func write(_ message: Message) {
        guard let data = "\(formatter.string(from: message))\n".data(using: .utf8) else { return }
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
    }
}

public enum Level: String, CaseIterable {
    case debug
    case info
    case warning
    case error
}

public struct Message {
    public let text: String
    public let level: Level
    public let tags: [String]
    public let timestamp: Date
    public let file: String
    public let line: Int

    public init(text: String, level: Level, tags: [String], timestamp: Date = Date(), file: String = #file, line: Int = #line) {
        self.text = text
        self.level = level
        self.tags = tags
        self.timestamp = timestamp
        self.file = file
        self.line = line
    }
}

public protocol Formatter {
    func string(from message: Message) -> String
}

public struct PrettyFormatter: Formatter {
    private let dateFormatter = DateFormatter()

    public init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
    }

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

    private func levelComponent(from message: Message) -> String {
        switch message.level {
        case .debug: return "🚧"
        case .info: return "💬"
        case .warning: return "⚠️"
        case .error: return "⛔"
        }
    }

    private func timestampComponent(from message: Message) -> String {
        return "\(dateFormatter.string(from: message.timestamp))"
    }

    private func locationComponent(from message: Message) -> String {
        return "@\(NSString(string: NSString(string: message.file).lastPathComponent).deletingPathExtension):\(message.line)"
    }

    private func tagComponent(from message: Message) -> String? {
        return message.tags.isEmpty ? nil : message.tags.map { "#\($0)" }.joined(separator: " ")
    }
}

public enum Filter<T: Hashable> {
    case include(Set<T>)
    case exclude(Set<T>)
    case all

    public func test(_ element: T) -> Bool {
        switch self {
        case .include(let set): return set.contains(element)
        case .exclude(let set): return !set.contains(element)
        case .all: return true
        }
    }

    public func test(_ elements: [T]) -> Bool {
        switch self {
        case .include(let set): return elements.contains { set.contains($0) }
        case .exclude(let set): return !elements.contains { set.contains($0) }
        case .all: return true
        }
    }
}

/// A value which is erased in production.
public struct Obscured: CustomStringConvertible {
    /// A string representation of the value.
    public let description: String

    /// Creates a new obscured value. In a debug environment, the value is converted into a string. In a release environment, the value is replaced with ********.
    /// - Parameter value: The value to obscure.
    public init(_ value: Any) {
        #if DEBUG
        description = "\(value)"
        #else
        description = "********"
        #endif
    }
}

/// A logger for writing messages to logs.
public final class Logger {
    /// The queue all logging operations are performed on.
    private let queue = DispatchQueue(label: "fireplace-logger", qos: .utility)

    /// An array of associated logs.
    private var logs = [(log: Log, levels: Filter<Level>, tags: Filter<String>)]()

    /// Writes a new message to the associated logs.
    ///
    /// - Parameter message: The message to write.
    public func write(_ message: Message) {
        #if !DEBUG
        guard message.level != .debug else { return }
        #endif
        
        queue.sync {
            logs
                .filter { $0.levels.test(message.level) && $0.tags.test(message.tags) }
                .map { $0.log }
                .forEach { $0.write(message) }
        }
    }

    /// Writes a new message to the associated logs.
    ///
    /// - Parameters:
    ///   - text: The text of the message.
    ///   - level: The level of the message.
    ///   - tags: The tags of the message.
    ///   - file: The file where the write function was called from.
    ///   - line: The line where the write function was called from.
    public func write(_ text: String, level: Level = .info, tags: [String] = [], file: String = #file, line: Int = #line) {
        write(Message(text: text, level: level, tags: tags, file: file, line: line))
    }

    /// Writes a new message to the associated logs.
    ///
    /// - Parameters:
    ///   - text: The text of the message.
    ///   - level: The level of the message.
    ///   - tags: The tags of the message.
    ///   - file: The file where the write function was called from.
    ///   - line: The line where the write function was called from.
    public func write(_ text: String, level: Level = .info, tags: String..., file: String = #file, line: Int = #line) {
        write(text, level: level, tags: tags, file: file, line: line)
    }

    /// Adds a new log to the logger.
    ///
    /// - Parameters:
    ///   - log: The log to add.
    ///   - levels: The levels to filter messages by before writing to the log.
    ///   - tags: The tags to filter the messages by before writing to the log.
    public func addLog(_ log: Log, levels: Filter<Level> = .all, tags: Filter<String> = .all) {
        queue.sync {
            logs.append((log, levels, tags))
        }
    }

    /// Removes a specific log from the logger.
    ///
    /// - Parameter log: The log to remove.
    public func removeLog(_ log: Log) {
        queue.sync {
            logs.removeAll { $0.log === log }
        }
    }

    /// Removes all logs from the logger.
    public func removeAllLogs() {
        queue.sync {
            logs.removeAll()
        }
    }
}
