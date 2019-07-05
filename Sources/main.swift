//
//  main.swift
//  Fireplace
//
//  Created by Andrey Ufimtsev on 05/06/2019.
//  Copyright © 2019 Andrey Ufimtsev. All rights reserved.
//

import Foundation

// Create a logger
let logger = Logger()

// Link the logger to the console
logger.addLog(ConsoleLog())

// Link the logger to a new temporary file
if let log = FileLog() {
    logger.addLog(log)
}

// Link warnings and errors to a special temporary file
if let log = FileLog(fileName: "bad-things.txt") {
    logger.addLog(log, levels: .include([.warning, .error]))
}

// Like very bad errors to another special temporary file
if let log = FileLog(fileName: "very-bad-things.txt") {
    logger.addLog(log, levels: .include([.error]), tags: .include(["verybad"]))
}

// Here you will find the files
if let defaultDirectory = FileLog.defaultDirectoryURL {
    print("Default log directory: \(defaultDirectory.path)")
}

// Write some messages
logger.write("Write debug messages that won't appear in production, like the app is running on John's iPhone Xs.", level: .debug)
logger.write("Write info messages, like the user has permitted the app to access their current location.", level: .info)
logger.write("Write warning messages, like the app has no connection to the internet.", level: .warning)
logger.write("Write error messages, like the app has failed to load an image from the app's bundle, gotta fix that bug.", level: .error)
logger.write("Add tags to your messages for better categorisation.", level: .info, tags: "likeoninstagram", "ortwitter")
logger.write("Obscure sensitive information in production because you don't want your users to share their \(Obscured("SUPER-SECRET-TOKENS")) with you.", level: .info, tags: "oauth")
