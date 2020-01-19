//
//  Level.swift
//  Hearth
//
//  Created by Andrey Ufimtsev on 19/01/2020.
//

/// A level of a message written to a log.
public enum Level: String, CaseIterable {
    /// Info messages represent neutral events and generic information. Use tags for further message classification.
    case info

    /// Warning messages represent faults caused by the user or external systems, therefore not considered as bugs of the application.
    case warning

    /// Error messages represent faults which are triggered by bugs in the application.
    case error
}
