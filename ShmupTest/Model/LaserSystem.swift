//
//  LaserSystem.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 13/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import SceneKit
class LaserSystem: FrameUpdateProtocol {
    
    var target: SKSpriteNode?
    var targetRange:CGFloat = 0.0
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    var laserDidHitTarget: ((EWKEnemy) -> Void)?
    
    private weak var motherShip: Ship?
    private weak var parentScene: SKScene?
    private var activated = false
    private var laserNode: SKSpriteNode!
    private var laserSparkNode = SKSpriteNode()
    private var laserHitSpartNode = SKSpriteNode()
    private var laserHitSparkEmitter: SKEmitterNode!
    private var laserHitSparkEmitter2: SKEmitterNode!
    private var laserThrustEmitter: SKEmitterNode!
    
    private var laserThickness: CGFloat = 350
    private var currentLaserRange: CGFloat = 0.0
    private var laserHitting = false {
        didSet{
            toggleLaserHitting(oldValue: oldValue)
        }
    }
    
    func prepareLaser(for motherShip: Ship, parentScene: SKScene) {
        self.motherShip = motherShip
        self.parentScene = parentScene
        let cropNode = SKCropNode()
        cropNode.position = motherShip.shipNode.convertPosition(from: NormalisedPoint(x: 0, y: 1)) + CGPoint(x: 0, y: parentScene.size.height )
        cropNode.maskNode = SKSpriteNode(color: .white, size: .zero)
        laserNode = cropNode.maskNode as! SKSpriteNode
        
        for i in 0 ... 2 {
            let background = SKSpriteNode(texture: SKTexture(imageNamed: "laser.png"), size: CGSize(width: laserThickness * 1.5, height: parentScene.size.height))
            background.position = CGPoint(x: 0, y: (-background.size.height * CGFloat(i)) + CGFloat(1 * i))
            cropNode.addChild(background)
            let moveUp = SKAction.moveBy(x: 0, y: background.size.height , duration: laserTravelDuration)
            let moveReset = SKAction.moveBy(x: 0, y: -background.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveUp, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
        cropNode.zPosition = Constants.zPosition.player - 2
        motherShip.shipNode.addChild(cropNode)
        prepareLaserSparkAnimation()
        prepareLaserHitSparkAnimation()
        
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            if self.activated {
                self.checkLineOfSight()
                self.laserHitSpartNode.alpha = 0.6
                if self.currentLaserRange < self.targetRange - 80 {
                    self.currentLaserRange += 80
                } else {
                    self.currentLaserRange = self.targetRange
                }
                self.laserHitting = self.currentLaserRange == self.targetRange
                self.laserHitSpartNode.position = CGPoint(
                    x: self.laserSparkNode.position.x,
                    y: self.laserSparkNode.position.y + self.currentLaserRange
                )
            } else {
                self.laserHitSpartNode.alpha = 0.0
            }
            self.laserNode.size = CGSize(width: self.laserThickness, height: self.currentLaserRange)
            self.laserNode.position.y = -(parentScene.size.height - self.laserNode.size.height/2)
        }
    }
    
    func activate(_ state: Bool) {
        activated = state
        laserSparkNode.alpha = state ? 1.0 : 0.0
        if !state {
            currentLaserRange = 0
            targetRange = 0
            target = nil
            motherShip?.targetPosition = nil
            laserHitSparkEmitter.particleBirthRate = 0.0
            laserHitSparkEmitter2.particleBirthRate = 0.0
            laserThrustEmitter.particleBirthRate = 0.0
            parentScene?.children.forEach({ (node) in
                let name = node.name ?? ""
                if name.contains(Constants.SpriteName.lockTarget) {
                    node.name? = String(name.dropLast(Constants.SpriteName.lockTarget.count))
                }
            })
        } else {
            laserHitSparkEmitter.particleBirthRate = 100
            laserHitSparkEmitter2.particleBirthRate = 2500
            laserThrustEmitter.particleBirthRate = 1500
        }
    }
    
    func toggleLaserHitting(oldValue: Bool) {
        if self.laserHitting {
            if let target = getTargetLockEnemy() {
                laserDidHitTarget?(target)
            }
        }
        if laserHitting == oldValue {return}
        
        if self.laserHitting {
            self.laserHitSpartNode.run(SKAction.repeatForever(
                SKAction.animate(with: TextureManager.shared.laserHitSparkFrames, timePerFrame: 0.01, resize: true, restore: true)
            ))
        } else {
            self.laserHitSpartNode.run(SKAction.repeatForever(
                SKAction.animate(with: [TextureManager.shared.laserHeadTexture], timePerFrame: 0.05, resize: true, restore: true)
            ))
        }
    }
    
    private func getTargetLockEnemy() -> EWKEnemy? {
        guard let parentScene = parentScene else {return nil}
        return parentScene.children.first{($0.name ?? "").contains(Constants.SpriteName.lockTarget)} as? EWKEnemy
    }
    
    private func checkLineOfSight() {
        guard let parentScene = parentScene else {return}
        guard let motherShip = motherShip else {return}
        if let targetPoint = isTargetVisibleAtAngle(distance: parentScene.size.height) {
            let lockedTarget = getTargetLockEnemy()
            let range = targetPoint - motherShip.shipNode.position - CGPoint(x: 0, y: (lockedTarget?.size.height ?? 0)/10)
            targetRange = range.y
            if activated {
                target = lockedTarget
                motherShip.targetPosition = target?.position
            }
        } else {
            targetRange = parentScene.size.height
        }
    }
    
    private func isTargetVisibleAtAngle(distance: CGFloat) -> CGPoint? {
        guard let parentScene = parentScene else {return nil}
        guard let motherShip = motherShip else {return nil}
        
        let rayStart = motherShip.shipNode.position
        let rayEnd = CGPoint(x: motherShip.shipNode.position.x,
                             y: motherShip.shipNode.position.y + distance)
        
        let rayStartLeft = motherShip.shipNode.position - CGPoint(x: laserNode.size.width/2, y: 0)
        let rayStartRight = motherShip.shipNode.position + CGPoint(x: laserNode.size.width/2, y: 0)
        let rayEndLeft = CGPoint(x: motherShip.shipNode.position.x,
                                 y: motherShip.shipNode.position.y + distance) - CGPoint(x: laserNode.size.width/2, y: 0)
        let rayEndRight = CGPoint(x: motherShip.shipNode.position.x,
                                  y: motherShip.shipNode.position.y + distance) + CGPoint(x: laserNode.size.width/2, y: 0)
        var targetPoint: CGPoint? = nil
        
        parentScene.physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, point, vector, _) in
            if body.categoryBitMask == Constants.Collision.enemyHitCategory{
                targetPoint = point
                if self.target == nil || (self.target == body.node) {
                    if !(body.node?.name ?? "").contains(Constants.SpriteName.lockTarget) {
                        body.node?.name = (body.node?.name ?? "") + Constants.SpriteName.lockTarget
                    }
                }
            }
        }
        
        parentScene.physicsWorld.enumerateBodies(alongRayStart: rayStartLeft, end: rayEndLeft) { (body, point, vector, _) in
            if body.categoryBitMask == Constants.Collision.enemyHitCategory{
                targetPoint = point
                if self.target == nil || (self.target == body.node) {
                    if !(body.node?.name ?? "").contains(Constants.SpriteName.lockTarget) {
                        body.node?.name = (body.node?.name ?? "") + Constants.SpriteName.lockTarget
                    }
                }
            }
        }
        parentScene.physicsWorld.enumerateBodies(alongRayStart: rayStartRight, end: rayEndRight) { (body, point, vector, _) in
            if body.categoryBitMask == Constants.Collision.enemyHitCategory{
                targetPoint = point
                if self.target == nil || (self.target == body.node) {
                    if !(body.node?.name ?? "").contains(Constants.SpriteName.lockTarget) {
                        body.node?.name = (body.node?.name ?? "") + Constants.SpriteName.lockTarget
                    }
                }
            }
        }
        return targetPoint
    }
    
    // Starting point
    private func prepareLaserSparkAnimation() {
        guard let motherShip = motherShip else {return}
        let firstSparkFrameTexture = TextureManager.shared.laserSparkFrames[0]
        laserSparkNode = SKSpriteNode(texture: firstSparkFrameTexture)
        laserSparkNode.anchorPoint = CGPoint(x: 0.5, y: 0.75)
        laserSparkNode.position = motherShip.shipNode.convertPosition(from: NormalisedPoint(x: 0, y: 1))
        laserSparkNode.zPosition = Constants.zPosition.player - 1
        laserSparkNode.xScale = 2.0
        laserSparkNode.yScale = 2.8
        motherShip.shipNode.addChild(laserSparkNode)
        laserSparkNode.alpha = 0.0
        laserSparkNode.run(SKAction.repeatForever(
            SKAction.animate(with: TextureManager.shared.laserSparkFrames, timePerFrame: 0.05, resize: true, restore: true)
        ))
    }
    
    // Hit point
    private func prepareLaserHitSparkAnimation() {
        guard let motherShip = motherShip else {return}
        
        laserHitSpartNode = SKSpriteNode()
        laserHitSpartNode.zPosition = Constants.zPosition.player - 1
        motherShip.shipNode.addChild(laserHitSpartNode)
        laserHitSpartNode.anchorPoint = CGPoint(x: 0.5, y: 0.7)
        laserHitSpartNode.xScale = 1.25
        laserHitSpartNode.yScale = 1.4
        laserHitSpartNode.alpha = 0.0
        
        laserHitSparkEmitter = TextureManager.shared.getEmitter(named: "LaserSpark")
        laserHitSparkEmitter2 = TextureManager.shared.getEmitter(named: "LaserHitSpark")
        laserThrustEmitter = TextureManager.shared.getEmitter(named: "LaserThrust")
        
        laserHitSparkEmitter.position = CGPoint(x: 0, y: 0)
        laserHitSpartNode.addChild(laserHitSparkEmitter)
        laserHitSparkEmitter2.targetNode = parentScene
        laserHitSparkEmitter2.position = CGPoint(x: 0, y: 0)
        laserHitSpartNode.addChild(laserHitSparkEmitter2)
        
        laserThrustEmitter.position = CGPoint(x: 0, y: 0)
        laserSparkNode.addChild(laserThrustEmitter)
    }
}
