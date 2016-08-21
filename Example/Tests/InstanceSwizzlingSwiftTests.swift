//
//  InstanceSwizzlingSwiftTests.swift
//  InstanceSwizzlingSwiftTests
//
//  Created by Aleksandr Gusev on 11/06/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import XCTest
import SGVInstanceSwizzling
import UIKit

extension NSObject: DynamicMethodOverrideable {}

class InstanceSwizzlingSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUIButtonBackgroundRectForBounds() {
        let button: UIButton = UIButton(type: .System)
        
        let testBounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        let testInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        let originalBackgroundRect = button.backgroundRectForBounds(testBounds)
        do {
            try button.overrideDynamicMethod(selector: #selector(UIButton.backgroundRectForBounds),
                                             implementationBlockProvider: { original in
                                                let replacementBlock: @convention(block) (UIButton, CGRect) -> CGRect = { _, bounds in
                                                    let originalRect = original.backgroundRectForBounds(bounds)
                                                    XCTAssertTrue(CGRectEqualToRect(originalRect, originalBackgroundRect))
                                                    return UIEdgeInsetsInsetRect(originalRect, testInsets)
                                                }
                                                return unsafeBitCast(replacementBlock, AnyObject.self)
            })
        } catch let error as DynamicMethodOverrideError {
            XCTFail("error thrown: \(error)")
        } catch { }
        
        let modifiedBackgroundRect = button.backgroundRectForBounds(testBounds)
        XCTAssertTrue(CGRectEqualToRect(UIEdgeInsetsInsetRect(originalBackgroundRect, testInsets), modifiedBackgroundRect))
        
        let undoResult = button.undoAllMethodOverrides()
        XCTAssertTrue(undoResult)
        let backgoundRectAfterUndo = button.backgroundRectForBounds(testBounds)
        XCTAssertTrue(CGRectEqualToRect(originalBackgroundRect, backgoundRectAfterUndo))
    }
}
