//
//  Logger.swift
//  BeforeTCA
//
//  Created by Celan on 2023/08/05.
//

import Foundation

struct Logger {
    internal enum LogStyle {
        case create
        case read
        case delete
        case update
    }
    
    static public func _printData(
        _ style: LogStyle,
        _ data: Any
    ) {
        print("--------------------")
        
        switch style {
        case .create:
            print("\(data) CREATED: ")
        case .read:
            print("\(data) FETCHED: ")
        case .delete:
            print("\(data) DELETED: ")
        case .update:
            print("\(data) UPDATED: ")
        }
        
        print("--------------------")
    }
    
    static public func dashedPrint(completionPrinter: @escaping () -> ()) {
        print("--------------------")
        completionPrinter()
        print("--------------------")
    }
    
    static public func methodExecTimePrint(_ start: Date) {
        print("--------------------")
        print("ENDED IN: ", Date().timeIntervalSince(start))
        print("--------------------")
    }
}
