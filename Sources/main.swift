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

// Add a console log
logger.addLog(ConsoleLog())

// Write a debug message
// Debug messages don't appear in production
logger.write("App is running on iPhone Xs.", level: .debug)

// Write an info message
// Info messages describe generic events
logger.write("User allowed permission to access location.", level: .info)
logger.write("If you don't specify level, info is assumed.")

// Write a warning message
// Warning messages describe non-bug problems
logger.write("No internet connection.", level: .warning)

// Write an error message
// Error messages describe bugs
logger.write("Failed to find image in app's bundle.", level: .error)
