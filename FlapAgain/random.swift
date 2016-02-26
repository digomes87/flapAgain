//
//  random.swift
//  FlapAgain
//
//  Created by Diego Gomes on 18/12/2015.
//  Copyright © 2015 Nylon. All rights reserved.
//

import Foundation
import CoreGraphics


public extension CGFloat{

    public static func random()->CGFloat{
        
        return CGFloat(CGFloat(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min min:CGFloat,max:CGFloat)->CGFloat{
    
        return CGFloat.random() * (max - min) + min
    }
    
}