//
//  Environment.swift
//  Hearth
//
//  Created by Andrey Ufimtsev on 19/01/2020.
//

/// An environment the app is running in.
public enum Environment {
    /// A debug environment.
    case debug

    /// A release environment.
    case release

    /// Any environment.
    case any

    /// Executes a block of code if matches the current environment.
    /// - Parameter block: The block of code to execute.
    internal func execute(_ block: () -> Void) {
        switch self {
        case .debug:
            #if DEBUG
            block()
            #else
            break
            #endif

        case .release:
            #if !DEBUG
            block()
            #else
            break
            #endif

        case .any:
            block()
        }
    }
}
