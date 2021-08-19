//
//  Shell.swift
//  BinaryBuild
//
//  Created by Zhen,Lintie on 2020/4/17.
//

import Foundation

struct ShellResult {
    var status: Int
    var output: String
    var error: String
}

enum ShellCommand {
    
    case symbolicatecrash
    case ls
    case cp
    case rm
    case mkdir
    
    var path: String {
        switch self {
        case .symbolicatecrash:
            return "/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash"
        case .ls:
            return "/bin/ls"
        case .cp:
            return "/bin/cp"
        case .rm:
            return "/bin/rm"
        case .mkdir:
            return "/bin/mkdir"
        }
    }
    
    func isValid() -> Bool {
        return false
    }
    
}

private func getOutputString(_ pipe: Pipe) -> String {
    var output = ""
    var outputData: Data?
    if #available(OSX 10.15.4, *) {
        outputData = try? pipe.fileHandleForReading.readToEnd()
    } else {
        outputData = pipe.fileHandleForReading.readDataToEndOfFile()
    }
    if let data = outputData, let string = String(data: data, encoding: .utf8) {
        output = string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return output
}

@discardableResult
func run(_ cmd: String, _ args: [String] = [], environment: [String: String]? = nil, printError: Bool = true) -> ShellResult {
    let task = Process()
    task.launchPath = cmd
    if !args.isEmpty {
        task.arguments = args
    }
    if let environment = environment {
        task.environment = env.merging(environment) {
            $1
        }
    }
//    print("Process launch")
    
    let outputPipe = Pipe()
    task.standardOutput = outputPipe
    
    let errorPipe = Pipe()
    task.standardError = errorPipe
    
    task.launch()
    
    let output = getOutputString(outputPipe)
    let error = getOutputString(errorPipe)
    
    task.waitUntilExit()
    
    let status = Int(task.terminationStatus)
    
    if status != 0, error.count > 0 {
        if printError {
            print(error)
        }
    } else {
        print(output)
    }
    
    
//    print("Process end \(cmd)")
    
    return ShellResult(status: status, output: output, error: error)
}

@discardableResult
func run(_ cmd: ShellCommand, _ arguments: [String] = [], environment: [String: String]? = nil, printError: Bool = true) -> ShellResult {
    return run(cmd.path, arguments, environment: environment, printError: printError)
}

@discardableResult
func ls(_ arguments: [String] = []) -> ShellResult {
    run(.ls, arguments)
}

@discardableResult
func cpDir(_ fromPath: String, _ toPath: String) -> ShellResult {
    run(.cp, ["-r", fromPath, toPath])
}

@discardableResult
func rmDir(_ path: String) -> ShellResult {
    run(.rm, ["-rf", path], printError: false)
}



