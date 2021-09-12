//
//  Obscured.swift
//  Hearth
//
//  Created by Andrey Ufimcev on 19/01/2020.
//

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
