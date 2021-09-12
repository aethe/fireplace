//
//  Log.swift
//  Hearth
//
//  Created by Andrey Ufimcev on 19/01/2020.
//

/// A logging destination.
public protocol Log: AnyObject {
    /// Writes a message to the log.
    /// - Parameter message: The message to write.
    func write(_ message: Message)
}
