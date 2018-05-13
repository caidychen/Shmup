//
//  WingmanSquard.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 13/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

class WingmanSquard: FrameUpdateProtocol {
    var targetPosition: CGPoint? {
        didSet{
            updateAllWingmanRotation()
        }
    }
    
    var wingmans: [Wingman] = []
    private var activated = false
    weak private var motherShip: Ship?
    weak private var parentScene: SKScene?
    private var linkPositionFocused = WeaponSystemManager.shared.linkPositionFocused
    private var linkPositionUnfocused = WeaponSystemManager.shared.linkPositionUnfocused
    private var wingmanAngle = WeaponSystemManager.shared.wingmanAngle
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    
    func prepareWingman(for motherShip: Ship, parentScene: SKScene) {
        self.motherShip = motherShip
        for _ in 0..<6 {
            let bulletTrack = BulletTrack(startPoint: NormalisedPoint(x: 0, y: 0), rotation: 0)
            wingmans.append(Wingman(bulletTrackList: [bulletTrack], from: motherShip, parentScene: parentScene))
        }
        wingmans.enumerated().forEach { (index, wingman) in
            motherShip.shipNode.addChild(wingman.shipNode)
            wingman.prepare()
            wingman.parentScene = parentScene
            
            wingman.preparingSparkAnimation()
            updateWingmanRotation(wingman: wingman, index: index)
        }
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            self.wingmans.forEach{$0.frameDidUpdate?(timeSinceLastUpdate, scene)}
            self.updateAllWingmanRotation()
        }
    }
    
    func activate(_ state: Bool) {
        if !state {
            targetPosition = nil
        } else{
            updateAllWingmanRotation()
        }
        activated = state
        wingmans.forEach{$0.activate(state)}
    }
    
    private func updateAllWingmanRotation() {
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
//        wingman.thrustEmitter.targetNode = parentScene
        if motherShip.focusMode {
            if let targetPosition = targetPosition {
                let moveAction = SKAction.move(
                    to: motherShip.shipNode.convertPosition(from: linkPositionFocused[index]),
                    duration: modeChangeDuration
                )
        
                wingman.shipNode.run(moveAction)
                wingman.shipNode.zRotation = -atan2(targetPosition.x - position.x, targetPosition.y - position.y)
            } else {
                let moveAction = SKAction.move(
                    to: motherShip.shipNode.convertPosition(from: linkPositionFocused[index]),
                    duration: modeChangeDuration
                )

                wingman.shipNode.run(moveAction)
                wingman.shipNode.zRotation = 0
            }
        } else {
            let moveAction = SKAction.move(
                to: motherShip.shipNode.convertPosition(from: linkPositionUnfocused[index]),
                duration: modeChangeDuration
            )
            let rotateAction = SKAction.rotate(
                toAngle: wingmanAngle[index],
                duration: modeChangeDuration
            )
            wingman.shipNode.run(moveAction)
            wingman.shipNode.run(rotateAction)
        }
//        parentScene?.afterDelay(modeChangeDuration, runBlock: {
//            wingman.thrustEmitter.targetNode = wingman.shipNode
//        })
    }
}
