//
//  Filter.swift
//  Hearth
//
//  Created by Andrey Ufimcev on 19/01/2020.
//

/// A filter to test inclusion to or exclusion from a set.
public enum Filter<T: Hashable> {
    /// All values included in the set.
    case include(Set<T>)

    /// All values which are not included in the set.
    case exclude(Set<T>)

    /// All possible values.
    case all

    /// Tests the value against the filter.
    /// - Parameter value: The value to test.
    public func test(_ value: T) -> Bool {
        switch self {
        case .include(let set): return set.contains(value)
        case .exclude(let set): return !set.contains(value)
        case .all: return true
        }
    }

    /// Tests values against the filter.
    /// - Parameter values: The values to test.
    public func test(_ values: [T]) -> Bool {
        switch self {
        case .include(let set): return values.contains { set.contains($0) }
        case .exclude(let set): return !values.contains { set.contains($0) }
        case .all: return true
        }
    }
}
