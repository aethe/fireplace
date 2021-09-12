//
//  Formatter.swift
//  Hearth
//
//  Created by Andrey Ufimcev on 19/01/2020.
//

/// A formatter that converts log messages to strings.
public protocol Formatter {
    /// Converts a log message to a string.
    /// - Parameter message: The message to format.
    func string(from message: Message) -> String
}
