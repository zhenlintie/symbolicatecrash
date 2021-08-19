//
//  main.swift
//  symbolicatecrash
//
//  Created by Zhen,Lintie on 2021/8/19.
//

import Foundation

/// 加载参数
let env = ProcessInfo.processInfo.environment
let arguments = CommandLine.arguments

guard arguments.count > 1 else {
    print("Needs .crash arguments.")
    exit(-1)
}

var crashPath = arguments[1]

let fileManager = FileManager.default

guard let url = URL(string: crashPath)?.resolvingSymlinksInPath(),
      fileManager.fileExists(atPath: url.absoluteString),
      crashPath.hasSuffix(".crash") else {
    print("Needs .crash arguments.")
    exit(-1)
}

crashPath = url.absoluteString
let name = url.deletingPathExtension().lastPathComponent
let folder = url.deletingLastPathComponent().absoluteString
let dSYMPath = "\(folder)\(name).dSYM"

guard fileManager.fileExists(atPath: dSYMPath) else {
    print("'\(dSYMPath)' not exists.")
    exit(-1)
}

let result = run(
    .symbolicatecrash,
    [
        crashPath,
        dSYMPath,
    ],
    environment: [
        "DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
    ],
    printError: true
)

if result.status == 0 {
    let output = "\(folder)\(name)-symbolicated.crash"
    try? result.output.write(toFile: output, atomically: true, encoding: .utf8)
}



