//
//  FrameUpdateProtocol.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 13/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

protocol FrameUpdateProtocol {
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)? {get}
}
