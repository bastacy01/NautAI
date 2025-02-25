//
//  EmitterView.swift
//  NautAI
//
//  Created by Ben Stacy on 12/19/24.
//

import SwiftUI

struct EmitterView: UIViewRepresentable {
    
    // MARK: - Variables
    let emitterConfiguration: [EmitterConfiguration] = [
        EmitterConfiguration(
            birthRate: 500,
            lifeTime: 4,
            velocity: 500.0,
            velocityRange: 200,
            xAcceleration: 0,
            yAcceleration: 0,
            emissionRange: 360 * (.pi / 180.0),
            spin: 0,
            spinRange: 0,
            scale: 0.01,
            scaleRange: 0.02
        ),
        
        EmitterConfiguration(
            birthRate: 300,
            lifeTime: 3,
            velocity: 400,
            velocityRange: 150,
            xAcceleration: 0,
            yAcceleration: 0,
            emissionRange: 360 * (.pi / 180.0),
            spin: 0,
            spinRange: 0,
            scale: 0.015,
            scaleRange: 0.025
        )
    ]
    
    // MARK: - Functions
    func makeUIView(context: Context) -> UIView {
        let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height) // Changed to full screen
        let containerView = UIView(frame: CGRect(origin: .zero, size: size))
        containerView.backgroundColor = .black
        
        var emitterCells: [CAEmitterCell] = []
        
        let particlesLayer = CAEmitterLayer()
        particlesLayer.frame = containerView.frame
        
        containerView.layer.addSublayer(particlesLayer)
        containerView.layer.masksToBounds = true
        
        particlesLayer.emitterShape = .point
        particlesLayer.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        particlesLayer.emitterSize = CGSize(width: 1.0, height: 1.0)
        particlesLayer.emitterMode = .outline
        particlesLayer.renderMode = .additive
        
        for configuration in emitterConfiguration {
            let emitterCell = CAEmitterCell()
            
            emitterCell.contents = configuration.content
            emitterCell.birthRate = configuration.birthRate
            emitterCell.lifetime = configuration.lifeTime
            emitterCell.velocity = configuration.velocity
            emitterCell.velocityRange = configuration.velocityRange
            emitterCell.xAcceleration = configuration.xAcceleration
            emitterCell.yAcceleration = configuration.yAcceleration
            emitterCell.emissionRange = configuration.emissionRange
            emitterCell.spinRange = configuration.spinRange
            emitterCell.spin = configuration.spin
            emitterCell.scale = configuration.scale
            emitterCell.scaleRange = configuration.scaleRange
            emitterCell.alphaRange = 0.3
            emitterCell.alphaSpeed = -0.2
            emitterCell.scaleSpeed = 0.04
            
            emitterCells.append(emitterCell)
        }
        
        particlesLayer.emitterCells = emitterCells
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

#Preview {
    EmitterView()
        .edgesIgnoringSafeArea(.all)
}
