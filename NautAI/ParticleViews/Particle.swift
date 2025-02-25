//
//  Particle.swift
//  NautAI
//
//  Created by Ben Stacy on 12/19/24.
//

import Foundation
import UIKit.UIImage

struct EmitterConfiguration {
    let birthRate: Float
    let lifeTime: Float
    
    let velocity: CGFloat
    let velocityRange: CGFloat
    let xAcceleration: CGFloat
    let yAcceleration: CGFloat
    let emissionRange: CGFloat
    
    let spin: CGFloat
    let spinRange: CGFloat
    let scale: CGFloat
    let scaleRange: CGFloat
    
    let content: CGImage? = UIImage(named: FillRandomiser.getRandomFill().rawValue)?.cgImage
}
