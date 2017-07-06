//
//  MovementManager.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

protocol IBoid
{
    func getVelocity() -> CGVector;
    func getMaxVelocity() -> CGFloat;
    func getPosition() -> CGPoint;
    func getMass() -> CGFloat;
}

class MovementManager {
    public var steering: CGVector;
    public var host: IBoid;
    
    let MAX_FORCE: CGFloat = 300
    let CIRCLE_DISTANCE: CGFloat = 200
    let CIRCLE_RADIUS: CGFloat = 64
    let ANGLE_CHANGE: CGFloat = 15 * .pi / 180
    
    // The constructor
    init(host: IBoid) {
        self.host = host
        self.steering = CGVector(dx:0, dy:0)
    }
    
    // The public API (one method for each behavior)
    func seek(target :CGPoint, slowingRadius :CGFloat) { steering = steering + doSeek(target: target, slowingRadius) }
    
    func wander() { steering = steering + doWander() }
    
    func pursuit(target :IBoid) { steering = steering + doPursuit(target: target) }
    
    /*func collisionAvoidance() { steering = steering + doCollisionAvoidance() }*/
    
    
    // Should be called after all behaviors have been invoked
    func steer() -> CGVector {
        steering = steering.truncate(MAX_FORCE)
        steering = steering.scaleBy(1 / host.getMass());
        return steering
    }
    
    // Reset the internal steering force.
    func reset() {
        self.steering = CGVector(dx:0, dy:0)
    }
    
    // The internal API
    private func doSeek(target :CGPoint, _ slowingRadius :CGFloat) -> CGVector {
        var force :CGVector
        var distance :CGFloat
        var desired :CGVector
        
        desired = CGVector(dx: target.x - host.getPosition().x, dy: target.y - host.getPosition().y)
        
        distance = desired.length();
        desired = desired.normalized();
        
        if (distance <= slowingRadius) {
            desired = desired.scaleBy(host.getMaxVelocity() * distance/slowingRadius);
        } else {
            desired = desired.scaleBy(host.getMaxVelocity());
        }
        
        force = desired - host.getVelocity();
        
        print(force)
        
        return force;
    }
    
    private func doWander() -> CGVector {
        var circleCenter :CGVector;
        circleCenter = host.getVelocity().clone();
        circleCenter = circleCenter.normalized();
        circleCenter = circleCenter.scaleBy(CIRCLE_DISTANCE);
        
        var displacement :CGVector;
        displacement = CGVector(dx: 0, dy:-1);
        displacement = displacement.scaleBy(CIRCLE_RADIUS);
        
        var wanderAngle = host.getVelocity().getAngle()
        //
        // Randomly change the vector direction
        // by making it change its current angle
        displacement = displacement.setAngle(wanderAngle);
        //
        // Change wanderAngle just a bit, so it
        // won't have the same value in the
        // next game frame.
        wanderAngle += (random() * ANGLE_CHANGE) - (ANGLE_CHANGE * 0.5);
        
        var wanderForce :CGVector;
        wanderForce = circleCenter + displacement;
        return wanderForce;
    }
    
    private func doPursuit(target :IBoid) -> CGVector {
        
        let updatesNeeded :CGFloat = target.getPosition().distance(point: host.getPosition()) / host.getMaxVelocity();
        
        var tv :CGVector = target.getVelocity().clone();
        tv = tv.scaleBy(updatesNeeded);
        
        let targetFuturePosition = target.getPosition().clone() + tv.toCGPoint();
        
        return doSeek(target: targetFuturePosition, 0);
    }
    
    //No lo pude implementar porque spritekit no tiene raycast, y no encontre nada parecido
    private func doCollisionAvoidance() {
    
    }
    
    private func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
}
