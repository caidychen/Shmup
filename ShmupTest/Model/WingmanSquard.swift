//
//  WingmanSquard.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 13/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

class WingmanSquard {
    var targetPosition: CGPoint?
    
    var wingmans: [Wingman] = []
    weak private var motherShip: Ship?
    weak private var parentScene: SKScene?
    private var linkPositionFocused = WeaponSystemManager.shared.linkPositionFocused
    private var linkPositionUnfocused = WeaponSystemManager.shared.linkPositionUnfocused
    private var wingmanAngle = WeaponSystemManager.shared.wingmanAngle
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    
    func prepareWingman(for motherShip: Ship, parentScene: SKScene) {
        self.motherShip = motherShip
        wingmans = [
            Wingman(bulletTrackList: [BulletTrack(startPoint: NormalisedPoint(x: 0, y: 0), rotation: 0)], from: motherShip),
            Wingman(bulletTrackList: [BulletTrack(startPoint: NormalisedPoint(x: 0, y: 0), rotation: 0)], from: motherShip),
            Wingman(bulletTrackList: [BulletTrack(startPoint: NormalisedPoint(x: 0, y: 0), rotation: 0)], from: motherShip),
            Wingman(bulletTrackList: [BulletTrack(startPoint: NormalisedPoint(x: 0, y: 0), rotation: 0)], from: motherShip),
            Wingman(bulletTrackList: [BulletTrack(startPoint: NormalisedPoint(x: 0, y: 0), rotation: 0)], from: motherShip),
            Wingman(bulletTrackList: [BulletTrack(startPoint: NormalisedPoint(x: 0, y: 0), rotation: 0)], from: motherShip)
        ]
        var index = 0
        for wingman in wingmans {
            motherShip.shipNode.addChild(wingman.shipNode)
            wingman.parentScene = parentScene
            wingman.prepareShoot()
            wingman.preparingSparkAnimation()
            updateWingmanRotation(wingman: wingman, index: index)
            index += 1
        }
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            self.updateAllWingmanRotation()
            self.wingmans.forEach{$0.frameDidUpdate?(timeSinceLastUpdate, scene)}
        }
    }
    
    func updateAllWingmanRotation() {
        var index = 0
        for wingman in wingmans {
            wingman.targetPosition = targetPosition
            updateWingmanRotation(wingman: wingman, index: index)
            index += 1
        }
    }
    
    private func updateWingmanRotation(wingman: Wingman, index: Int) {
        guard let motherShip = motherShip else {return}
        let position = motherShip.shipNode.position + wingman.shipNode.position
        if motherShip.focusMode {
            if let targetPosition = targetPosition {
                let moveAction = SKAction.move(to: motherShip.shipNode.convertPosition(from: linkPositionFocused[index]), duration: modeChangeDuration)
                let rotateAction = SKAction.rotate(toAngle: -atan2(targetPosition.x - position.x,  targetPosition.y - position.y), duration: 0.01)
                wingman.shipNode.run(moveAction)
                wingman.shipNode.run(rotateAction)
            } else {
                let moveAction = SKAction.move(to: motherShip.shipNode.convertPosition(from: linkPositionFocused[index]), duration: modeChangeDuration)
                let rotateAction = SKAction.rotate(toAngle: 0, duration: modeChangeDuration)
                wingman.shipNode.run(moveAction)
                wingman.shipNode.run(rotateAction)
            }
        } else {
            let moveAction = SKAction.move(to: motherShip.shipNode.convertPosition(from: linkPositionUnfocused[index]), duration: modeChangeDuration)
            let rotateAction = SKAction.rotate(toAngle: wingmanAngle[index], duration: modeChangeDuration)
            wingman.shipNode.run(moveAction)
            wingman.shipNode.run(rotateAction)
        }
        
    }
}
