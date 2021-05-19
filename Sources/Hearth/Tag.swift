//
//  Tag.swift
//  Hearth
//
//  Created by Andrey Ufimcev on 19/05/2021.
//

/// A tag used for message classification.
///
/// String literals can be passed wherever a tag is expected.
///
/// ```
/// logger.write("Hello World!", tags: "greeting")
/// ```
///
/// Alternatively, it's possible to create an extension for the `Tag` struct and use it with a shorthand syntax.
///
/// ```
/// extension Tag {
///    static var greeting: Tag {
///        "greeting"
///    }
/// }
///
/// logger.write("Hello World!", tags: .greeting)
/// ```
public struct Tag: Hashable, ExpressibleByStringLiteral, CustomStringConvertible {
    public typealias StringLiteralType = String

    /// The textual representation of the tag.
    public let name: String

    /// Creates a new tag.
    /// - Parameter name: The textual representation of the tag.
    public init(name: String) {
        self.name = name
    }

    public init(stringLiteral: String) {
        self.init(name: stringLiteral)
    }

    public var description: String {
        name
    }
}
