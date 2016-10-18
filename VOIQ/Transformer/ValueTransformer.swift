//
//  ValueTransformer.swift
//  tpaga
//
//  Created by Jorge Orjuela on 9/24/16.
//  Copyright © 2016 TPaga. All rights reserved.
//

import Foundation

class ValueTransformer<A: AnyObject, B: AnyObject>: Foundation.ValueTransformer {
    
    typealias Transform = (A?) -> B?
    typealias ReverseTransform = (B?) -> A?
    
    private let transform: Transform
    private let reverseTransform: ReverseTransform
    
    init(transform: @escaping Transform, reverseTransform: @escaping ReverseTransform) {
        self.transform = transform
        self.reverseTransform = reverseTransform
        super.init()
    }
    
    static func registerTransformerWithName(_ name: String, transform: @escaping Transform, reverseTransform: @escaping ReverseTransform) {
        let vt = ValueTransformer(transform: transform, reverseTransform: reverseTransform)
        Foundation.ValueTransformer.setValueTransformer(vt, forName: NSValueTransformerName(rawValue: name))
    }
    
    override static func transformedValueClass() -> AnyClass {
        return B.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return transform(value as? A)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        return reverseTransform(value as? B)
    }
}
