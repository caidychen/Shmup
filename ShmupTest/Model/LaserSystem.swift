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
    
    var targetPosition: CGPoint?
    var targetRange:CGFloat = 0.0
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    
    private weak var motherShip: Ship?
    private weak var parentScene: SKScene?
    private var activated = false
    private var laserNode: SKSpriteNode!
    private var laserSparkNode = SKSpriteNode()
    private var laserHitSpartNode = SKSpriteNode()
    private var laserHitSparkEmitter: SKEmitterNode!
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
            let background = SKSpriteNode(texture: SKTexture(imageNamed: "laser.png"), size: CGSize(width: laserThickness, height: parentScene.size.height))
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
                self.laserHitSpartNode.alpha = 1.0
                if self.currentLaserRange < self.targetRange - 50 {
                    self.currentLaserRange += 50
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
            targetPosition = nil
            motherShip?.targetPosition = nil
            laserHitSparkEmitter.particleBirthRate = 0.0
        } else {
            laserHitSparkEmitter.particleBirthRate = 100.0
        }
    }
    
    func toggleLaserHitting(oldValue: Bool) {
        if laserHitting == oldValue {return}
        if self.laserHitting {
            self.laserHitSpartNode.run(SKAction.repeatForever(
                SKAction.animate(with: TextureManager.shared.laserHitSparkFrames, timePerFrame: 0.05, resize: true, restore: true)
            ))
        } else {
            self.laserHitSpartNode.run(SKAction.repeatForever(
                SKAction.animate(with: [TextureManager.shared.laserHeadTexture], timePerFrame: 0.05, resize: true, restore: true)
            ))
        }
    }
    
    private func checkLineOfSight() {
        guard let parentScene = parentScene else {return}
        guard let motherShip = motherShip else {return}
        if let targetPoint = isTargetVisibleAtAngle(distance: parentScene.size.height) {
            let range = targetPoint - motherShip.shipNode.position - CGPoint(x: 0, y: 20)
            targetRange = range.y
            if activated {
                targetPosition = parentScene.childNode(withName: Constants.SpriteName.lockTarget)?.position
                motherShip.targetPosition = targetPoint
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
        var targetPoint: CGPoint? = nil
        
        parentScene.physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, point, vector, _) in
            if body.categoryBitMask == Constants.Collision.enemyHitCategory{
                targetPoint = point
                body.node?.name = Constants.SpriteName.lockTarget
            }
        }
        
        return targetPoint
    }
    
    // Starting point
    private func prepareLaserSparkAnimation() {
        guard let motherShip = motherShip else {return}
        let firstSparkFrameTexture = TextureManager.shared.laserSparkFrames[0]
        laserSparkNode = SKSpriteNode(texture: firstSparkFrameTexture)
        laserSparkNode.position = motherShip.shipNode.convertPosition(from: NormalisedPoint(x: 0, y: 1))
        laserSparkNode.zPosition = Constants.zPosition.player - 1
        laserSparkNode.xScale = 1.7
        laserSparkNode.yScale = 1.4
        motherShip.shipNode.addChild(laserSparkNode)
        laserSparkNode.alpha = 0.0
        laserSparkNode.run(SKAction.repeatForever(
            SKAction.animate(with: TextureManager.shared.laserSparkFrames, timePerFrame: 0.05, resize: true, restore: true)
        ))
    }
    
    // Hit point
    private func prepareLaserHitSparkAnimation() {
        guard let motherShip = motherShip else {return}
        let firstSparkFrameTexture = TextureManager.shared.laserHitSparkFrames[0]
        laserHitSpartNode = SKSpriteNode(texture: firstSparkFrameTexture)
        laserHitSpartNode.zPosition = Constants.zPosition.player - 1
        motherShip.shipNode.addChild(laserHitSpartNode)
        laserHitSpartNode.xScale = 1.4
        laserHitSpartNode.yScale = 1.6
        laserHitSpartNode.alpha = 0.0
        laserHitSpartNode.run(SKAction.repeatForever(
            SKAction.animate(with: TextureManager.shared.laserHitSparkFrames, timePerFrame: 0.05, resize: true, restore: true)
        ))
        let laserHitSparkPath = Bundle.main.path(forResource: "LaserHitSpark", ofType: "sks")!
        laserHitSparkEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: laserHitSparkPath)
            as! SKEmitterNode
        laserHitSparkEmitter.targetNode = parentScene
        laserHitSparkEmitter.position = CGPoint(x: 0, y: 0)
        laserHitSpartNode.addChild(laserHitSparkEmitter)
        laserHitSparkEmitter.particleBirthRate = 0.0
    }
}
