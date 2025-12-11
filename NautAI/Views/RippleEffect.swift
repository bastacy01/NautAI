//
//  RippleEffect.swift
//  NautAI
//
//  Created by Ben Stacy on 11/22/25.
//

import SwiftUI

struct RippleModifier: ViewModifier {
    var origin: CGPoint
 
    var elapsedTime: TimeInterval
 
    var duration: TimeInterval
 
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double
 
    func body(content: Content) -> some View {
        let shader = ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsedTime),
 
            // Parameters
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )
 
        let maxSampleOffset = maxSampleOffset
        let elapsedTime = elapsedTime
        let duration = duration
 
        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }
 
    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }
}

struct RippleEffect<T: Equatable>: ViewModifier {
     
    var origin: CGPoint
    var trigger: T
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double
 
    init(at origin: CGPoint, trigger: T, amplitude: Double = 12, frequency: Double = 15, decay: Double = 8, speed: Double = 1200) {
        self.origin = origin
        self.trigger = trigger
        self.amplitude = amplitude
        self.frequency = frequency
        self.decay = decay
        self.speed = speed
    }
 
    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration
        let amplitude = amplitude
        let frequency = frequency
        let decay = decay
        let speed = speed
 
        content.keyframeAnimator(
            initialValue: 0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(RippleModifier(
                origin: origin,
                elapsedTime: elapsedTime,
                duration: duration,
                amplitude: amplitude,
                frequency: frequency,
                decay: decay,
                speed: speed
            ))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
 
    var duration: TimeInterval { 4 }
}


struct RippleEffectView: View {
    @State private var counter: Int = 0
    @State private var origin: CGPoint = .zero
    @State private var amplitude: Double = 12
    @State private var frequency: Double = 15
    @State private var decay: Double = 8
    @State private var speed: Double = 1200
    
    private let gradientColors: [Color] = [.red, .yellow, .green, .blue, .purple, .red]
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(AngularGradient(gradient: Gradient(colors: gradientColors), center: .center))
                .modifier(RippleEffect(at: origin, trigger: counter, amplitude: amplitude, frequency: frequency, decay: decay, speed: speed))
                .onTapGesture { location in
                    origin = location
                    counter += 1
                }
                .frame(width: 320, height: 320)
            Text("Touch into space").font(.footnote).foregroundStyle(.secondary)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Amplitude: \(amplitude, specifier: "%.0f")")
                    Spacer()
                    Slider(value: $amplitude, in: 1...50, step: 1) {
                        Text("Amplitude")
                    }
                    .frame(width: 240)
                }
                Text("Controls the power of the ripple waves.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("frequency: \(frequency, specifier: "%.0f")")
                    Spacer()
                    Slider(value: $frequency, in: 1...30, step: 1) {
                        Text("Frequency")
                    }
                    .frame(width: 240)
                }
                Text("Controls the number of waves in the ripple effect.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("Decay: \(decay, specifier: "%.0f")")
                    Spacer()
                    Slider(value: $decay, in: 2...20, step: 1) {
                        Text("Decay")
                    }
                    .frame(width: 240)
                }
                Text("Controls how quickly the ripple effect fades.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("Speed: \(speed, specifier: "%.0f")")
                    Spacer()
                    Slider(value: $speed, in: 200...1500, step: 100) {
                        Text("Speed")
                    }
                    .frame(width: 240)
                }
                Text("Controls the speed of the ripple propogation")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 4)
                
                Button("Ripple center") {
                    origin = .init(x: 320 / 2, y: 320 / 2)
                    counter = counter + 1
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .font(.caption)
            .padding()
        }
    }
}

#Preview {
    VStack {
        Text("Ripple effect SwiftUI").font(.largeTitle).bold()
        Text("using metal shade text").foregroundStyle(.secondary)
            .font(.footnote)
        RippleEffectView()
    }
}
