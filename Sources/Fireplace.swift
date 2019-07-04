//
//  Fireplace.swift
//  Fireplace
//
//  Created by Andrey Ufimtsev on 05/06/2019.
//  Copyright © 2019 Andrey Ufimtsev. All rights reserved.
//

import Foundation

public protocol Log: AnyObject {
    func write(_ message: Message)
}

public final class ConsoleLog: Log {
    private let queue = DispatchQueue(label: "fireplace-console", qos: .utility)
    private let formatter: Formatter
    
    init(formatter: Formatter = PrettyFormatter()) {
        self.formatter = formatter
    }
    
    public func write(_ message: Message) {
        queue.sync {
            print(formatter.string(from: message))
        }
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
    public let file: String
    public let line: Int
    public let timestamp: Date
    
    public init(text: String, level: Level, tags: [String], file: String = #file, line: Int = #line, timestamp: Date = Date()) {
        self.text = text
        self.level = level
        self.tags = tags
        self.file = file
        self.line = line
        self.timestamp = timestamp
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
        let components = [
            levelComponent(from: message),
            timestampComponent(from: message),
            locationComponent(from: message),
            tagComponent(from: message),
            textComponent(from: message)
        ]
        
        return components.joined()
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
        return " \(dateFormatter.string(from: message.timestamp))"
    }
    
    private func locationComponent(from message: Message) -> String {
        return " @\(NSString(string: NSString(string: message.file).lastPathComponent).deletingPathExtension):\(message.line)"
    }
    
    private func tagComponent(from message: Message) -> String {
        return message.tags.isEmpty ? "" : " \(message.tags.map { "#\($0)" }.joined(separator: " "))"
    }
    
    private func textComponent(from message: Message) -> String {
        return ": \(message.text)"
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

public final class Logger {
    private let queue = DispatchQueue(label: "fireplace-logger", qos: .utility)
    private var logs = [(log: Log, levels: Filter<Level>, tags: Filter<String>)]()
    
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
    
    public func write(_ text: String, level: Level = .info, tags: [String] = [], file: String = #file, line: Int = #line) {
        write(Message(text: text, level: level, tags: tags, file: file, line: line))
    }
    
    public func write(_ text: String, level: Level = .info, tags: String..., file: String = #file, line: Int = #line) {
        write(text, level: level, tags: tags, file: file, line: line)
    }
    
    public func addLog(_ log: Log, levels: Filter<Level> = .all, tags: Filter<String> = .all) {
        queue.sync {
            logs.append((log, levels, tags))
        }
    }
    
    public func removeLog(_ log: Log) {
        queue.sync {
            logs.removeAll { $0.log === log }
        }
    }
    
    public func removeAllLogs() {
        queue.sync {
            logs.removeAll()
        }
    }
}
