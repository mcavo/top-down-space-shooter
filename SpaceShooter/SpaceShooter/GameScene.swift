//
//  GameScene.swift
//  SpaceShooter
//
//  Created by María Victoria Cavo on 29/6/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None                             : UInt32 = 0
    static let All                              : UInt32 = UInt32.max
    static let PlayerShipFiredBulletCategory    : UInt32 = 0x01 << 0         // 1
    static let EnemyShipFiredBulletCategory     : UInt32 = 0x01 << 1         // 2
    static let FiredBulletCategory              : UInt32 = 0x11 << 0         // 3
    static let PlayerShipCategory               : UInt32 = 0x01 << 2         // 4
    static let EnemyShipCategory                : UInt32 = 0x01 << 3         // 8
    static let ShipCategory                     : UInt32 = 0x11 << 3         // 12
    static let AsteroidCategory                 : UInt32 = 0x01 << 4         // 16
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var map:  TilesMap!
    var cam: SKCameraNode! = SKCameraNode()
    var previousTime :TimeInterval = 0
    var player: PlayerShip!
    var enemies = Set<EnemyShip>()
    var ships = Set<SpaceShip>()
    private var lifeLabel : SKLabelNode? = nil
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        map = TilesMap(map: (scene?.childNode(withName:"AsteroidsTileMapNode"))! as! SKTileMapNode, ships: ships)
        player = PlayerShip(scene: self, map: map, mass: 10, state: PlayerShip.State.IDLE)
        player.position = CGPoint(x: 64, y: 64)
        cam.setScale(CGFloat(2.5))
        self.camera = cam
        self.camera?.position = player.position
        
        addEnemy(velocity: CGVector(dx: 0, dy: -1), position: CGPoint(x: 832, y: 448))
        addEnemy(velocity: CGVector(dx: 0, dy: 1), position: CGPoint(x: 896, y: -448))
        addEnemy(velocity: CGVector(dx: 0, dy: 1), position: CGPoint(x: -448, y: -448))
        addEnemy(velocity: CGVector(dx: 0, dy: -1), position: CGPoint(x: -832, y: 1088))
        
        addChild(player)
        ships.insert(player)
    }
    
    func addEnemy(velocity: CGVector, position: CGPoint) {
        let enemy = EnemyShip(scene: self, map: map, position: position, velocity: velocity, mass: 10, player: player, state: EnemyShip.State.WANDER)
        enemies.insert(enemy)
        addChild(enemy)
        ships.insert(enemy)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if player.life == 0 {
            showGameOver()
        }
        
        if enemies.count == 0 {
            showWonGame()
        }
        player.update(currentTime - previousTime)
        for enemy in enemies {
            enemy.update(currentTime - previousTime)
        }
        previousTime = currentTime
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        if isAsteroid(touchLocation) {
            return
        }
        
        let enemySelected = enemyShipTouched(touchLocation)
        
        if enemySelected == nil {
            player.moveTo(touchLocation)
        } else {
            player.attackTo(enemySelected!)
        }
        
    }
    
    func isAsteroid(_ point: CGPoint) -> Bool {
        let column = map.tileColumnIndex(fromPosition: point)
        let row = map.tileRowIndex(fromPosition: point)
        return map.tileDefinition(atColumn: column, row: row) != nil
    }
    
    func enemyShipTouched(_ point: CGPoint) -> EnemyShip? {
        for enemy in enemies {
            if enemy.contains(point) {
                return enemy
            }
        }
        return nil
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.FiredBulletCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.AsteroidCategory != 0)) {
            if let bullet = firstBody.node as? Bullet {
                bullet.removeFromParent()
            }
        } else if ((firstBody.categoryBitMask & PhysicsCategory.EnemyShipFiredBulletCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.PlayerShipCategory != 0)) {
            if let bullet = firstBody.node as? Bullet, let playerShip = secondBody.node as? PlayerShip {
                playerShip.life -= 10
                if (playerShip.life <= 0) {
                    for enemy in enemies {
                        enemy.state = EnemyShip.State.NONE
                    }
                    playerShip.startDeathAnimation()
                    playerShip.physicsBody?.categoryBitMask = PhysicsCategory.None
                }
                bullet.removeFromParent()
            }
        } else if ((firstBody.categoryBitMask & PhysicsCategory.PlayerShipFiredBulletCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.EnemyShipCategory != 0)) {
            if let bullet = firstBody.node as? Bullet, let enemyShip = secondBody.node as? EnemyShip {
                player.shot(enemyShip)
                enemies.remove(enemyShip)
                ships.remove(enemyShip)
                enemyShip.startDeathAnimation()
                enemyShip.physicsBody?.categoryBitMask = PhysicsCategory.None
                bullet.removeFromParent()
            }
        }
        
    }
    
    private func showGameOver() {
        let texture = SKTexture(imageNamed: "metalPanel")
        let UI = SKSpriteNode(texture: texture, color: SKColor.clear, size: texture.size())
        UI.position = convert(CGPoint(x: 0 , y: 0), to: self.camera!)
        UI.zPosition = 20
        self.camera?.addChild(UI)
        
        let panelLabel = SKLabelNode(fontNamed: "Helvetica")
        panelLabel.fontSize = 14
        panelLabel.fontColor = SKColor.black
        panelLabel.text = String("Game Over")
        panelLabel.position = convert(CGPoint(x: 0 , y: 0), to: self.camera!)
        
        self.camera?.addChild(panelLabel)
    
    }
    
    private func showWonGame() {
        let texture = SKTexture(imageNamed: "metalPanel")
        let UI = SKSpriteNode(texture: texture, color: SKColor.clear, size: texture.size())
        UI.position = convert(CGPoint(x: 0 , y: 0), to: self.camera!)
        UI.zPosition = 20
        self.camera?.addChild(UI)
        
        let panelLabel = SKLabelNode(fontNamed: "Helvetica")
        panelLabel.fontSize = 14
        panelLabel.fontColor = SKColor.black
        panelLabel.text = String("You Win!")
        panelLabel.position = convert(CGPoint(x: 0 , y: 0), to: self.camera!)
        
        self.camera?.addChild(panelLabel)
    }
    
    func addHUB() {
        
        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)
        
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: player!)
        camera.constraints = [ constraint ]
        
        lifeLabel = SKLabelNode(fontNamed: "Helvetica")
        lifeLabel!.fontSize = 14
        lifeLabel!.fontColor = SKColor.white
        lifeLabel?.text = String(format:"HP: %0.2d", 1000)
        lifeLabel!.position.y = size.height/2 - 2 * lifeLabel!.fontSize
        
        camera.addChild(lifeLabel!)
        
    }

}
