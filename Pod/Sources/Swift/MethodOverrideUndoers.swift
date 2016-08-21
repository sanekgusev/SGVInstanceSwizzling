//
//  MethodOverrideUndoers.swift
//  Pods
//
//  Created by Aleksandr Gusev on 8/20/16.
//
//

class MethodOverrideUndoers {
    private var array: [MethodOverrideUndoer] = []
    
    func appendUndoer(undoer: MethodOverrideUndoer) {
        array.append(undoer)
    }
    
    func undoLastMethodOverride() -> Bool {
        guard let undoer = array.popLast() else {
            return false
        }
        undoer.undoMethodOverride()
        return true
    }
    
    func undoAllMethodOverrides() -> Bool {
        if !undoLastMethodOverride() {
            return false
        }
        while undoLastMethodOverride() {}
        return true
    }
    
    deinit {
        undoAllMethodOverrides()
    }
}
