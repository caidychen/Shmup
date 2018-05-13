//
//  Ship.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import SceneKit

class Ship: Shootable {
    static let shared = Ship()
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    var focusMode = false {
        didSet{
            toggleFocusMode()
        }
    }
    var targetPosition: CGPoint? {
        didSet {
            wingmanSqard.targetPosition = targetPosition
            wingmanSqard.updateAllWingmanRotation()
        }
    }
    // Base node without texture
    let shipNode = SKSpriteNode(
        color: .clear,
        size: CGSize(
            width: TextureManager.shared.shipTexture.size().width,
            height: TextureManager.shared.shipTexture.size().height
        )
    )
    
    var bulletTrackList = WeaponSystemManager.shared.bulletTrackList
    private let textureNode = SKSpriteNode(texture: TextureManager.shared.shipTexture)

    private let wingmanSqard = WingmanSquard()
    
    private var shootSparkNode = SKSpriteNode()
    private var laserNode: SKSpriteNode!
    private var laserSparkNode = SKSpriteNode()
    private var laserHitSpartNode = SKSpriteNode()
    private var laserHitSparkEmitter: SKEmitterNode!
    
    private var currentLaserRange: CGFloat = 0.0
    private var targetRange:CGFloat = 0.0
    private var laserThickness: CGFloat = 350
    private var laserHitting = false {
        didSet{
            toggleLaserHitting(oldValue: oldValue)
        }
    }
    
    private var timeSinceLastBulletShoot: CFTimeInterval = 0
    private var parentSceneSize: CGSize = .zero
    weak private var parentScene: SKScene?
    
    
    func prepare(parentScene: SKScene) {
        self.parentScene = parentScene
        parentSceneSize = parentScene.size
        AmmoManager.shared.loadAmmo(capacity: 200)
        shipNode.addChild(textureNode)
        textureNode.zPosition = Constants.zPosition.player
        prepareWingman()
        prepareLaser(parentScene: parentScene)
        prepareShoot()
        
    }
    
    private func toggleFocusMode() {
        laserSparkNode.alpha = focusMode ? 1.0 : 0.0
        if !focusMode {
            currentLaserRange = 0
            targetRange = 0
            targetPosition = nil
            laserHitSparkEmitter.particleBirthRate = 0.0
        } else {
            laserHitSparkEmitter.particleBirthRate = 100.0
        }
        wingmanSqard.updateAllWingmanRotation()
    }
    
    private func toggleLaserHitting(oldValue: Bool) {
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

    private func prepareWingman() {
        wingmanSqard.prepareWingman(for: self, parentScene: parentScene!)
    }
    
    private func prepareShoot() {
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            self.checkLineOfSight()
            self.wingmanSqard.frameDidUpdate?(timeSinceLastUpdate, scene)
            if self.focusMode {
                self.laserHitSpartNode.alpha = 1.0
                if self.currentLaserRange < self.targetRange - 50 {
                    self.currentLaserRange += 50
                } else {
                    self.currentLaserRange = self.targetRange
                }
                self.laserHitting = self.currentLaserRange == self.targetRange
                self.laserHitSpartNode.position = CGPoint(x: self.laserSparkNode.position.x, y: self.laserSparkNode.position.y + self.currentLaserRange)
            } else {
                self.laserHitSpartNode.alpha = 0.0
                self.timeSinceLastBulletShoot += timeSinceLastUpdate
                if self.timeSinceLastBulletShoot > bulletReloadTime {
                    self.timeSinceLastBulletShoot = 0
                    for bulletTrack in self.bulletTrackList {
                        self.shoot(parentNode: scene, range: scene.size.height, from: bulletTrack, from: .zero, parentRotation: nil)
                    }
                    
                }
            }
            self.laserNode.size = CGSize(width: self.laserThickness, height: self.currentLaserRange)
            self.laserNode.position.y = -(self.parentSceneSize.height - self.laserNode.size.height/2)
        }
    }
    
    private func prepareLaser(parentScene: SKScene) {
        let cropNode = SKCropNode()
        cropNode.position = shipNode.convertPosition(from: NormalisedPoint(x: 0, y: 1)) + CGPoint(x: 0, y: parentScene.size.height )
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
        shipNode.addChild(cropNode)
        prepareLaserSparkAnimation()
        prepareLaserHitSparkAnimation()
    }
    
    private func isTargetVisibleAtAngle(distance: CGFloat) -> CGPoint? {
        guard let parentScene = parentScene else {return nil}
        let rayStart = shipNode.position
        let rayEnd = CGPoint(x: shipNode.position.x,
                             y: shipNode.position.y + distance)
        var targetPoint: CGPoint? = nil
        
        parentScene.physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, point, vector, _) in
            if body.categoryBitMask == Constants.Collision.enemyHitCategory{
                targetPoint = point
                body.node?.name = Constants.SpriteName.lockTarget
            }
        }
        
        return targetPoint
    }
    
    private func checkLineOfSight() {
        guard let parentScene = parentScene else {return}
        if let targetPoint = isTargetVisibleAtAngle(distance: parentScene.size.height) {
            let range = targetPoint - shipNode.position - CGPoint(x: 0, y: 20)
            targetRange = range.y
            if focusMode {
                targetPosition = parentScene.childNode(withName: Constants.SpriteName.lockTarget)?.position
            }
            print("\(range.y) Line of sight detected")
        } else {
            targetRange = parentScene.size.height
        }
    }
    
    
}

// Setup Animations
extension Ship {

    private func prepareLaserSparkAnimation() {
        let firstSparkFrameTexture = TextureManager.shared.laserSparkFrames[0]
        laserSparkNode = SKSpriteNode(texture: firstSparkFrameTexture)
        laserSparkNode.position = shipNode.convertPosition(from: NormalisedPoint(x: 0, y: 1))
        laserSparkNode.zPosition = Constants.zPosition.player - 1
        laserSparkNode.xScale = 1.7
        laserSparkNode.yScale = 1.4
        shipNode.addChild(laserSparkNode)
        laserSparkNode.alpha = 0.0
        laserSparkNode.run(SKAction.repeatForever(
            SKAction.animate(with: TextureManager.shared.laserSparkFrames, timePerFrame: 0.05, resize: true, restore: true)
        ))
    }
    
    private func prepareLaserHitSparkAnimation() {
        let firstSparkFrameTexture = TextureManager.shared.laserHitSparkFrames[0]
        laserHitSpartNode = SKSpriteNode(texture: firstSparkFrameTexture)
        laserHitSpartNode.zPosition = Constants.zPosition.player - 1
        shipNode.addChild(laserHitSpartNode)
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

