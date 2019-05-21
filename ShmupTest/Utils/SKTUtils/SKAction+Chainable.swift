//
//  SKAction+Chainable.swift
//  ActionChainingTest
//
//  Created by KD Chen on 14/5/18.
//  Copyright © 2018 Quest Payment Systems. All rights reserved.
//

import SpriteKit

class SKChainableAction {
    private var actionSequence: [SKAction] = []
    private var repeatedActionSequence: [SKAction] = []
    private var completionBlock: ((SKSpriteNode)->Void)?
    private weak var node: SKSpriteNode?
    
    init(_ node: SKSpriteNode) {
        node.removeAllActions()
        self.node = node
    }
    
    // Action Chains Setup
    func run(_ action: SKAction) -> Self {
        actionSequence.append(action)
        return self
    }
    
    func wait(_ duration: CFTimeInterval) -> Self {
        actionSequence.append(SKAction.wait(forDuration: duration))
        return self
    }
    
    func `repeat`(_ count: Int) -> Self {
        if actionSequence.count == 0 {return self}
        if count == 0 {return self}
        repeatedActionSequence = repeatedActionSequence + [SKAction.repeat(SKAction.sequence(actionSequence).copy() as! SKAction, count: count)]
        actionSequence.removeAll()
        return self
    }
    
    // Finisher
    func start() {
        let allActions = repeatedActionSequence + actionSequence
        execute(SKAction.sequence(allActions))
    }
    
    func startWithCompletion(_ completion: @escaping ((SKSpriteNode) -> Void)){
        completionBlock = completion
        start()
    }
    
    func startAndRepeatForever() {
        let allActions = repeatedActionSequence + actionSequence
        execute(SKAction.repeatForever(SKAction.sequence(allActions)))
    }
    
    
    func removeAllAction() {
        actionSequence.removeAll()
        node?.removeAllActions()
    }
    
    private func execute(_ action: SKAction) {
        node?.run(action, completion: {
            if let node = self.node {
                self.completionBlock?(node)
            }
        })
    }
    
}
