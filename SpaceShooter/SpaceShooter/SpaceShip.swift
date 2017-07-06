//
//  SpaceShip.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

class SpaceShip : SKSpriteNode {
    
    var deathFrames  : [SKTexture] = [SKTexture(imageNamed: "bum_1"), SKTexture(imageNamed: "bum_2"), SKTexture(imageNamed: "bum_3")]
    
    let MAX_ANGLE_ROT: CGFloat = 5 * .pi / 180
    
    func fixRotation(_ velocity: CGVector) {
        
        if (velocity == CGVector.zero) { return }
        
        let diff = self.zRotation - velocity.getAngle() + 270 * .pi / 180
        
        if diff > 0 {
            self.zRotation = self.zRotation - diff
        } else {
            self.zRotation = self.zRotation + diff
        }
    }
    
    func startDeathAnimation() {
        self.removeAllActions()
        let actionShowExplotion = SKAction.animate(with: deathFrames, timePerFrame: 0.2)
        //let actionSoundExplotion = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
        let actionRemove = SKAction.removeFromParent()
        //let actionExplotion = SKAction.group([actionShowExplotion, actionSoundExplotion])
        self.run(SKAction.sequence([actionShowExplotion, actionRemove]))
    }
}
