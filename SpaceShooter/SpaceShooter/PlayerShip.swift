//
//  Player.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerShip : SpaceShip, IBoid {
    
    enum State { case PURSUIT, SHOOT, IDLE, PATH_FOLLOWING }
    
    var life = 1000
    
    var state: State?
    var pathToFollow: [CGPoint] = [CGPoint]()
    var kScene :SKScene!
    
    var aStar: AStarAlgorithm!
    var movementManager: MovementManager!
    var enemy :EnemyShip!
    
    var timeCounter :TimeInterval = 0
    
    let RANGE_ATTACK :CGFloat = 300
    let MAX_VELOCITY : CGFloat = 100
    let CHECKPOINT_RADIUS :CGFloat = 20
    let TIME_BETWEEN_SHOTS :TimeInterval = 1
    
    init(scene: SKScene, map: TilesMap, mass: CGFloat, state: State) {
        let texture = SKTexture(imageNamed: "spaceShip1")
        let size = CGSize(width: map.tileSize.width * 0.5, height: map.tileSize.height * 0.5)
        super.init(texture: texture, color: UIColor.clear, size: size)
        self.kScene = scene
        self.position = CGPoint(x: 0, y:0)
        self.zPosition = 1
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.mass = mass
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.movementManager = MovementManager(host: self);
        self.state = state
        self.aStar = AStarAlgorithm(map: map)
        self.physicsBody?.categoryBitMask = PhysicsCategory.PlayerShipCategory
        self.physicsBody?.contactTestBitMask = PhysicsCategory.AsteroidCategory | PhysicsCategory.EnemyShipFiredBulletCategory
        self.physicsBody?.collisionBitMask = PhysicsCategory.AsteroidCategory | PhysicsCategory.ShipCategory
        self.physicsBody?.usesPreciseCollisionDetection = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shot(_ enemyShip : EnemyShip) {
        if enemy! == enemyShip {
            movementManager!.reset()
            state = State.IDLE
        }
    }
    
    func moveTo(_ point: CGPoint ) {
        movementManager!.reset()
        pathToFollow = aStar.getPath(fromPoint: position, toPoint: point)
        state = State.PATH_FOLLOWING
    }
    
    func attackTo(_ enemy: EnemyShip) {
        state = State.PURSUIT
        self.enemy = enemy
        
    }
    
    func update(_ deltaTime :TimeInterval) {
        
        fixRotation(self.getVelocity())
        
        switch(state!) {
        case State.IDLE:
            break
        case State.SHOOT:
            if !isNearEnemyShip() {
                state = State.PURSUIT
                movementManager!.reset()
                break
            }
            fixShootRotation()
            timeCounter += deltaTime
            shoot()
            break
        case State.PURSUIT:
            if isNearEnemyShip() {
                self.physicsBody?.velocity = CGVector.zero
                movementManager!.reset()
                timeCounter = TIME_BETWEEN_SHOTS
                self.state = State.SHOOT
                break
            }
            movementManager?.pursuit(target: enemy)
            self.physicsBody?.applyForce(movementManager!.steer() * 150)
            break
        case State.PATH_FOLLOWING:
            if pathToFollow.count == 0 {
                self.physicsBody?.velocity = CGVector.zero
                state = State.IDLE
                movementManager!.reset()
                break
            }
            if position.distance(point: pathToFollow.first!) < CHECKPOINT_RADIUS {
                pathToFollow.removeFirst()
                break
            }
            if pathToFollow.count == 1 {
                movementManager!.seek(target: pathToFollow[0], slowingRadius: 40)
            } else {
                movementManager!.seek(target: pathToFollow[0], slowingRadius: 0)
            }
            self.physicsBody?.applyForce(movementManager!.steer() * 100)
        }
    }
    
    private func isNearEnemyShip() -> Bool {
        return enemy.position.distance(point: self.position) < RANGE_ATTACK
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
    
    private func fixShootRotation() {
        let targetDirection = (enemy.position - self.position).toCGVector()
        fixRotation(targetDirection)
    }
    
    private func shoot() {
        if timeCounter < TIME_BETWEEN_SHOTS { return }
        timeCounter = 0
        let velocity : CGVector = CGVector(dx:1 , dy: 0).setAngle(self.zRotation + 270 * .pi / 180)
        let bullet :Bullet = Bullet(imageNamed: "playerBullet", velocity: velocity * 300)
        bullet.position = self.position + velocity.toCGPoint() * 60
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.PlayerShipFiredBulletCategory
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.AsteroidCategory | PhysicsCategory.EnemyShipCategory
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.AsteroidCategory
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        kScene.addChild(bullet)
    }
}
