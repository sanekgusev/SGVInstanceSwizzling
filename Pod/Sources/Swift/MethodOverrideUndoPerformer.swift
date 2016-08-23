//
//  MethodOverrideUndoers.swift
//  Pods
//
//  Created by Aleksandr Gusev on 8/20/16.
//
//

class MethodOverrideUndoPerformer {
    private var array: [MethodOverrideUndoItem] = []
    
    func pushUndoItemFor(originalClass originalClass: AnyClass,
                                       object: AnyObject,
                                    i   mplementation: IMP) {
        array.append(MethodOverrideUndoItem(originalClass: originalClass,
            object: object,
            implementation: implementation))
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

private class MethodOverrideUndoItem {
    
    private let originalClass: AnyClass
    
    private weak var object: AnyObject?
    
    private let implementation: IMP
    
    init(originalClass: AnyClass, object: AnyObject, implementation: IMP) {
        self.originalClass = originalClass
        self.object = object
        self.implementation = implementation
    }
    
    deinit {
        undoMethodOverride()
    }
    
    func undoMethodOverride() {
        guard let object = object,
            objectClass = object_getClass(object) where class_getSuperclass(objectClass) == originalClass else {
                return
        }
        
        object_setClass(object, originalClass)
        imp_removeBlock(implementation)
        objc_disposeClassPair(objectClass)
    }
}

