

import Foundation
import SGVSuperMessagingProxy

public protocol DynamicMethodOverrideable: class {}

public enum DynamicMethodOverrideError: ErrorType {
    case ClassAllocationFailure
    case MethodLookupFailure
    case ImplementationCreationFailure
    case MethodAdditionFailure
}

public extension DynamicMethodOverrideable {
    
    public func overrideDynamicMethod(selector selector: Selector,
                                               @noescape implementationBlockProvider: (original: Self) -> AnyObject /* @convention(block) */) throws {
        
        guard let objectClass = object_getClass(self),
            className = String.fromCString(class_getName(objectClass)),
            subclass = objc_allocateClassPair(self.dynamicType, generatedSubclassName(className), 0) else {
                throw DynamicMethodOverrideError.ClassAllocationFailure
        }
        
        do {
            try performMethodOverride(objectClass: objectClass,
                                      subclass: subclass,
                                      selector: selector,
                                      implementationBlockProvider: implementationBlockProvider)
        } catch let error as DynamicMethodOverrideError {
            objc_disposeClassPair(subclass)
            throw error
        }
        
        objc_registerClassPair(subclass)
        
        object_setClass(self, subclass)
    }
    
    public func undoLastMethodOverride() -> Bool {
        return undoers.undoLastMethodOverride()
    }
    
    public func undoAllMethodOverrides() -> Bool {
        return undoers.undoAllMethodOverrides()
    }
    
    private func performMethodOverride(objectClass objectClass: AnyClass,
                                                   subclass: AnyClass,
                                                   selector: Selector,
                                                   @noescape implementationBlockProvider: (original: Self) -> AnyObject) throws {
        let method = class_getInstanceMethod(self.dynamicType, selector)
        guard method != nil,
            let typeEncoding = String.fromCString(method_getTypeEncoding(method)) else {
                throw DynamicMethodOverrideError.MethodLookupFailure
        }
        
        let implementationBlock = implementationBlockProvider(original: unsafeBitCast(SuperMessagingProxy(object: self), Self.self))
        let implementation = imp_implementationWithBlock(implementationBlock)
        
        guard implementation != nil else {
            throw DynamicMethodOverrideError.ImplementationCreationFailure
        }
        
        guard class_addMethod(subclass, selector, implementation, typeEncoding) else {
            imp_removeBlock(implementation)
            throw DynamicMethodOverrideError.MethodAdditionFailure
        }
        
        undoers.appendUndoer(MethodOverrideUndoer(originalClass: objectClass, object: self, implementation: implementation))
    }
    
    private var undoers: MethodOverrideUndoers {
        get {
            if let undoers = objc_getAssociatedObject(self, &associatedObjectKey) as? MethodOverrideUndoers {
                return undoers
            }
            self.undoers = MethodOverrideUndoers()
            return undoers
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var associatedObjectKey: Int = 0

private func generatedSubclassName(className: String) -> String {
    return "sgv_\(className)_\(NSUUID().UUIDString)"
}
