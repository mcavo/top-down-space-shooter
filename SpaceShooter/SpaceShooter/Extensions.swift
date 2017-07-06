//
//  Extensions.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit

extension CGPoint: Hashable {
    public var hashValue: Int {
        return hash()
    }
    
    func distance(point: CGPoint) -> CGFloat {
        let dx = CGFloat(x - point.x)
        let dy = CGFloat(y - point.y)
        return sqrt((dx * dx) + (dy * dy))
    }
    
    func hash() -> Int {
        // iOS Swift Game Development Cookbook
        // https://books.google.se/books?id=QQY_CQAAQBAJ&pg=PA304&lpg=PA304&dq=swift+CGpoint+hashvalue&source=bl&ots=1hp2Fph274&sig=LvT36RXAmNcr8Ethwrmpt1ynMjY&hl=sv&sa=X&ved=0CCoQ6AEwAWoVChMIu9mc4IrnxgIVxXxyCh3CSwSU#v=onepage&q=swift%20CGpoint%20hashvalue&f=false
        return x.hashValue << 32 ^ y.hashValue
    }
    
    static func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.distance(point: rhs) < 0.000001 //CGPointEqualToPoint(lhs, rhs)
    }
    
    func reverse() -> CGPoint {
        return CGPoint(x: y, y: x)
    }
    
    func toCGVector() -> CGVector {
        return CGVector(dx: self.x, dy: self.y)
    }
    
    func clone() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
    
    func toMapCoords(map: SKTileMapNode) -> CGPoint {
        let row = map.tileRowIndex(fromPosition: self)
        let column = map.tileColumnIndex(fromPosition: self)
        return CGPoint(x: row, y: column)
    }
    
    func toScreenCoords(map: SKTileMapNode) -> CGPoint {
        return map.centerOfTile(atColumn: Int(y), row: Int(x))
    }
    
    static public func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    static public func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static public func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
}

extension CGVector {
    
    func reverse() -> CGVector {
        return CGVector(dx: dy, dy: dx)
    }
    
    func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector {
        return self / length()
    }
    
    func scaleBy(_ scale: CGFloat) -> CGVector {
        return self * scale
    }
    
    func getAngle() -> CGFloat {
        return atan2(dy, dx)
    }
    
    func setAngle(_ angle: CGFloat) -> CGVector {
        return CGVector(dx: cos(angle), dy: sin(angle))
    }
    
    func toCGPoint() -> CGPoint {
        return CGPoint(x: self.dx, y: self.dy)
    }
    
    func clone() -> CGVector {
        return CGVector(dx: self.dx, dy: self.dy)
    }
    
    func truncate(_ max: CGFloat) -> CGVector {
        var i :CGFloat
        i = max / self.length();
        i = i < 1.0 ? i : 1.0;
        return self.scaleBy(i);
    }
    
    static public func - (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
    }
    static public func + (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }
    
    static public func * (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(dx: left.dx * right, dy: left.dy * right)
    }
    static public func / (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }
}

extension SKTileMapNode {


}

