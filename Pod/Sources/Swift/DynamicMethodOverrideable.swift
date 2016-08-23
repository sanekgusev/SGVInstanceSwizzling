

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
            generatedSubclass = objc_allocateClassPair(objectClass, generatedSubclassName(className), 0) else {
                throw DynamicMethodOverrideError.ClassAllocationFailure
        }
        
        do {
            try performMethodOverride(objectClass: objectClass,
                                      subclass: generatedSubclass,
                                      selector: selector,
                                      implementationBlockProvider: implementationBlockProvider)
        } catch let error as DynamicMethodOverrideError {
            objc_disposeClassPair(generatedSubclass)
            throw error
        }
        
        objc_registerClassPair(generatedSubclass)
        
        object_setClass(self, generatedSubclass)
    }
    
    public func undoLastMethodOverride() -> Bool {
        return undoPerformer.undoLastMethodOverride()
    }
    
    public func undoAllMethodOverrides() -> Bool {
        return undoPerformer.undoAllMethodOverrides()
    }
    
    private func performMethodOverride(objectClass objectClass: AnyClass,
                                                   generatedSubclass: AnyClass,
                                                   selector: Selector,
                                                   @noescape implementationBlockProvider: (original: Self) -> AnyObject) throws {
        let method = class_getInstanceMethod(objectClass, selector)
        guard method != nil,
            let typeEncoding = String.fromCString(method_getTypeEncoding(method)) else {
                throw DynamicMethodOverrideError.MethodLookupFailure
        }
        
        let implementationBlock = implementationBlockProvider(original: unsafeBitCast(SuperMessagingProxy(object: self), Self.self))
        let implementation = imp_implementationWithBlock(implementationBlock)
        
        guard implementation != nil else {
            throw DynamicMethodOverrideError.ImplementationCreationFailure
        }
        
        guard class_addMethod(generatedSubclass, selector, implementation, typeEncoding) else {
            imp_removeBlock(implementation)
            throw DynamicMethodOverrideError.MethodAdditionFailure
        }
        
        undoPerformer.pushUndoItemFor(originalClass: objectClass, object: self, implementation: implementation)
    }
    
    private var undoPerformer: MethodOverrideUndoPerformer {
        get {
            if let undoPerformer = objc_getAssociatedObject(self, &methodOverrideUndoPerformerKey) as? MethodOverrideUndoPerformer {
                return undoPerformer
            }
            self.undoPerformer = MethodOverrideUndoPerformer()
            return undoPerformer
        }
        set {
            objc_setAssociatedObject(self, &methodOverrideUndoPerformerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var methodOverrideUndoPerformerKey: Int = 0

private func generatedSubclassName(className: String) -> String {
    return "sgv_\(className)_\(NSUUID().UUIDString)"
}
