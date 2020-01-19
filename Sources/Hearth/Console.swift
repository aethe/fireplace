//
//  Console.swift
//  Hearth
//
//  Created by Andrey Ufimtsev on 19/01/2020.
//

import Foundation

/// A log written to the console.
public final class Console: Log {
    /// The queue on which printing to the console is performed.
    private let queue = DispatchQueue(label: "hearth-console", qos: .utility)

    /// The formatter used to format messages.
    private let formatter: Formatter

    /// Creates a new console log.
    ///
    /// - Parameter formatter: The formatter used to format messages. Defaults to the pretty formatter.
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
