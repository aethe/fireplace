//
//  File.swift
//  Hearth-iOS
//
//  Created by Andrey Ufimtsev on 19/01/2020.
//

import Foundation
import os

/// A log written to a file.
public final class File: Log {
    /// The system log for reporting errors related to file log initialisation.
    private static let systemLog = OSLog(subsystem: "io.github.aethe.hearth", category: "file-logging")

    /// A URL representing the default directory of log files.
    ///
    /// Logs are stored in the caches directory by default. It is recommended to use another directory on macOS, since the cache directory is system-wide.
    public static var defaultDirectoryURL: URL? {
        return FileManager
            .default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("io.github.aethe.hearth")
    }

    /// An automatically generated file name based on the current date and time.
    private static var defaultName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ssZ"
        return "\(dateFormatter.string(from: Date())).txt"
    }

    /// The URL representing the location of the associated file.
    public let url: URL

    /// The handle for the associated file.
    private let handle: FileHandle

    /// The formatter used to format messages.
    private let formatter: Formatter

    /// Creates a new file log at a specified URL.
    /// - Parameter url: The URL representing the file location.
    /// - Parameter formatter: The formatter used to format messages.
    public init?(url: URL, formatter: Formatter = PrettyFormatter()) {
        if !FileManager.default.fileExists(atPath: url.path) {
            guard FileManager.default.createFile(atPath: url.path, contents: nil) else {
                os_log("Could not create a file at %{public}@.", log: File.systemLog, type: .error, url.path)
                return nil
            }
        }

        guard let handle = try? FileHandle(forWritingTo: url) else {
            os_log("Could not open a file for writing at %{public}@.", log: File.systemLog, type: .error, url.path)
            return nil
        }

        self.url = url
        self.handle = handle
        self.formatter = formatter
    }

    /// Creates a new file log with a specified name at the default directory.
    /// - Parameter name: The name of the file.
    /// - Parameter formatter: The formatter used to format messages.
    public convenience init?(name: String, formatter: Formatter = PrettyFormatter()) {
        guard let directoryURL = File.defaultDirectoryURL else {
            os_log("Could not get the default directory.", log: File.systemLog, type: .error)
            return nil
        }

        guard let _ = try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true) else {
            os_log("Could not create a directory at %{public}@.", log: File.systemLog, type: .error, directoryURL.path)
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(name)
        self.init(url: fileURL, formatter: formatter)
    }

    /// Creates a new file log with an automatically generated file name at a specified directory.
    /// - Parameter directoryURL: The URL representing the directory.
    /// - Parameter formatter: The formatter used to format messages.
    public convenience init?(directoryURL: URL, formatter: Formatter = PrettyFormatter()) {
        guard directoryURL.hasDirectoryPath else {
            os_log("The path %{public}@ does not represent a directory.", log: File.systemLog, type: .error, directoryURL.path)
            return nil
        }

        self.init(url: directoryURL.appendingPathComponent(File.defaultName), formatter: formatter)
    }

    /// Creates a new file log with an automatically generated file name at the default directory.
    /// - Parameter formatter: The formatter used to format messages.
    public convenience init?(formatter: Formatter = PrettyFormatter()) {
        self.init(name: File.defaultName, formatter: formatter)
    }

    /// Writes a message to the associated file.
    /// - Parameter message: The message to write.
    public func write(_ message: Message) {
        guard let data = "\(formatter.string(from: message))\n".data(using: .utf8) else { return }
        handle.seekToEndOfFile()
        handle.write(data)
    }
}
