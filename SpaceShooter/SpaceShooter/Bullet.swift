//
//  Bullet.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet : SKSpriteNode {
    
    init(imageNamed: String, velocity: CGVector) {
        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: UIColor.clear, size: imageTexture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: imageTexture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.isResting = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.angularDamping = 0.0
        self.physicsBody?.velocity = velocity
        self.zRotation = velocity.getAngle() + 270 * .pi / 180
        self.name = "bullet"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
