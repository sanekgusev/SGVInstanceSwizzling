//
//  MethodOverrideUndoer.swift
//  Pods
//
//  Created by Aleksandr Gusev on 8/20/16.
//
//

class MethodOverrideUndoer {
    
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
