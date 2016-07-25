

import Foundation
import SGVSuperMessagingProxy

public protocol DynamicMethodReplaceable: class {}

private var associatedObjectKey: Int = 0

public extension DynamicMethodReplaceable {
    
    private static func generatedSubclassName(className: String) -> String {
        return "sgv_\(className)_\(NSUUID())"
    }
    
    private var undoers: ReplaceMethodUndoers {
        get {
            if let undoers = objc_getAssociatedObject(self, &associatedObjectKey) as? ReplaceMethodUndoers {
                return undoers
            }
            let undoers = ReplaceMethodUndoers()
            self.undoers = undoers
            return undoers
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func replaceDynamicMethod(selector selector: Selector,
                                              replacement: (original: Self) -> @convention(block) AnyObject -> Void) -> Bool {
        
        guard let objectClass = object_getClass(self),
            className = String.fromCString(class_getName(objectClass)),
            subclass = objc_allocateClassPair(self.dynamicType, self.dynamicType.generatedSubclassName(className), 0) else {
                return false
        }
        do {
            guard let typeEncoding = String.fromCString(method_getTypeEncoding(class_getInstanceMethod(self.dynamicType, selector))) else {
                throw ClassCreationError()
            }
            
            let implementationBlock = replacement(original: unsafeBitCast(SuperMessagingProxy(object: self), Self.self))
            let implementation = imp_implementationWithBlock(unsafeBitCast(implementationBlock, AnyObject.self))
            
            guard class_addMethod(subclass, selector, implementation, typeEncoding) else {
                throw ClassCreationError()
            }
            
            objc_registerClassPair(subclass)
            
            object_setClass(self, subclass)
            
            undoers.array.append(ReplaceMethodUndoer(originalClass: objectClass, object: self))
            
            return true
        }
        catch _ {
            objc_disposeClassPair(subclass)
            return false
        }
    }
    
    public func undoLastMethodReplacement() -> Bool {
        return undoers.undoLastMethodReplacement()
    }
    
    public func undoAllMethodReplacements() -> Bool {
        return undoers.undoAllMethodReplacements()
    }
}

private struct ClassCreationError: ErrorType {}

private class ReplaceMethodUndoer {
    
    let originalClass: AnyClass
    
    weak var object: AnyObject?
    
    init(originalClass: AnyClass, object: AnyObject) {
        self.originalClass = originalClass
        self.object = object
    }
    
    deinit {
        undoMethodReplace()
    }
    
    func undoMethodReplace() {
        guard let object = object,
        objectClass = object_getClass(object) where class_getSuperclass(objectClass) == originalClass else {
            return
        }
        
        object_setClass(object, originalClass)
        objc_disposeClassPair(objectClass)
    }
}

private class ReplaceMethodUndoers {
    var array: [ReplaceMethodUndoer] = []
    
    func undoLastMethodReplacement() -> Bool {
        guard let undoer = array.popLast() else {
            return false
        }
        undoer.undoMethodReplace()
        return true
    }
    
    func undoAllMethodReplacements() -> Bool {
        if !undoLastMethodReplacement() {
            return false
        }
        while undoLastMethodReplacement() {}
        return true
    }
    
    deinit {
        undoAllMethodReplacements()
    }
}
