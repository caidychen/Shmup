//
//  SKNodeExtension.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 6/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

struct NormalisedPoint {
    var x: CGFloat  // -1 ~ 1
    var y: CGFloat  // -1 ~ 1
}

extension SKSpriteNode {
    func convertPosition(from normalisedPoint: NormalisedPoint) -> CGPoint {
        return CGPoint(x: normalisedPoint.x * size.width/2, y: normalisedPoint.y * size.height/2)
    }
}
