//
//  TextureManager.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 8/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

class TextureManager {
    static let shared = TextureManager()
    let shipTexture = SKTexture(imageNamed: "shooter.png")
    let laserHeadTexture = SKTexture(imageNamed: "laserHead.png")
    private(set) var shootSparkFrames: [SKTexture] = []
    private(set) var laserSparkFrames: [SKTexture] = []
    private(set) var laserHitSparkFrames: [SKTexture] = []
    
    func prepareTextures() {
        
        let shootSparkAtlas = SKTextureAtlas(named: "shootSpark")
        shootSparkFrames = shootSparkAtlas.textureNames.map({ (name) -> SKTexture in
            return shootSparkAtlas.textureNamed(name)
        })
        
        let laserSparkAtlas = SKTextureAtlas(named: "laserSpark")
        laserSparkFrames = laserSparkAtlas.textureNames.map({ (name) -> SKTexture in
            return laserSparkAtlas.textureNamed(name)
        })
        
        let laserHitSparkAtlas = SKTextureAtlas(named: "laserHitSpark")
        laserHitSparkFrames = laserHitSparkAtlas.textureNames.map({ (name) -> SKTexture in
            return laserHitSparkAtlas.textureNamed(name)
        })
    }
    
}
