//
//  EnemyShip.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyShip : SpaceShip, IBoid {
    
    let MAX_VELOCITY: CGFloat = 150
    let RANGE_VIEW: CGFloat = 300
    var movementManager :MovementManager?;
    var state :State?
    var timeCounter :TimeInterval = 0
    
    let RANGE_ATTACK :CGFloat = 150
    let TIME_BETWEEN_SHOTS :TimeInterval = 1.5
    
    enum State { case NONE, SHOOT, PURSUIT, WANDER }
    
    var player: PlayerShip!
    var kScene :SKScene!
    
    init(scene: SKScene, map: TilesMap, position: CGPoint, velocity: CGVector, mass: CGFloat, player: PlayerShip, state: State) {
        let size = CGSize(width: map.tileSize.width * 0.5, height: map.tileSize.height * 0.5)
        let texture = SKTexture(imageNamed: "spaceShip2")
        super.init(texture: texture, color: UIColor.clear, size: size)
        self.kScene = scene
        self.position = position
        self.zPosition = 1
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.mass = mass
        self.physicsBody?.velocity = velocity
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.movementManager = MovementManager(host: self);
        self.state = state
        self.player = player
        self.physicsBody?.categoryBitMask = PhysicsCategory.EnemyShipCategory
        self.physicsBody?.contactTestBitMask = PhysicsCategory.AsteroidCategory | PhysicsCategory.PlayerShipFiredBulletCategory
        self.physicsBody?.collisionBitMask = PhysicsCategory.AsteroidCategory | PhysicsCategory.ShipCategory
        self.physicsBody?.usesPreciseCollisionDetection = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Below are the methods the interface IBoid requires.
    
    func getVelocity() -> CGVector {
        return physicsBody!.velocity
    }
    
    func getMaxVelocity() -> CGFloat {
        return MAX_VELOCITY
    }
    
    func getPosition() ->CGPoint {
        return position
    }
    
    func getMass() ->CGFloat {
        return physicsBody!.mass
    }
    
    func update(_ deltaTime: TimeInterval) {
        
        print(state!)
        
        fixRotation(self.getVelocity())
        
        switch(state!) {
        case State.NONE:
            self.physicsBody?.velocity = CGVector.zero
            movementManager!.reset()
            break
        case State.SHOOT:
            if !isInRangeToAttack() {
                state = State.PURSUIT
                movementManager!.reset()
                break
            }
            fixShootRotation()
            timeCounter += deltaTime
            shoot()
            break
        case State.WANDER:
            if isNearPlayerShip() {
                state = State.PURSUIT
                break
            }
            movementManager?.wander()
            print(movementManager!.steer())
            self.physicsBody?.applyForce(movementManager!.steer() * 100)
            break
        case State.PURSUIT:
            if isInRangeToAttack() {
                self.physicsBody?.velocity = CGVector.zero
                movementManager!.reset()
                timeCounter = TIME_BETWEEN_SHOTS
                self.state = State.SHOOT
                break
            }
            if !isNearPlayerShip() {
                self.state = State.WANDER
                
            }
            movementManager?.pursuit(target: player)
            self.physicsBody?.applyForce(movementManager!.steer() * 200)

        }
    }
    
    private func isNearPlayerShip() -> Bool {
        return player.position.distance(point: self.position) < RANGE_VIEW
    }
    
    private func isInRangeToAttack() -> Bool {
        return player.position.distance(point: self.position) < RANGE_ATTACK
    }
    
    private func fixShootRotation() {
        let targetDirection = (player.position - self.position).toCGVector()
        fixRotation(targetDirection)
    }
    
    private func shoot() {
        if timeCounter < TIME_BETWEEN_SHOTS { return }
        timeCounter = 0
        let velocity : CGVector = CGVector(dx:1 , dy: 0).setAngle(self.zRotation + 270 * .pi / 180)
        let bullet :Bullet = Bullet(imageNamed: "enemyBullet", velocity: velocity * 300)
        bullet.position = self.position + velocity.toCGPoint() * 60
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.EnemyShipFiredBulletCategory
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.AsteroidCategory | PhysicsCategory.PlayerShipCategory
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        kScene.addChild(bullet)
    }
}
