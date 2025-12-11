//
//  LoginView.swift
//  NautAI
//
//  Created by Ben Stacy on 12/16/24.
//


import SwiftUI

@available(iOS 26.0, *)
struct LoginView: View {
    let imageName: String
    @State private var showContentView = false
    @State private var rippleCounter: Int = 0
    @State private var rippleOrigin: CGPoint = .zero
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .modifier(RippleEffect(
                            at: rippleOrigin,
                            trigger: rippleCounter,
                            amplitude: 15,
                            frequency: 20,
                            decay: 10,
                            speed: 1400
                        ))
                        .onTapGesture { location in
                            rippleOrigin = location
                            rippleCounter += 1
                        }
                    
                    VStack {
                        Button(action: {
                            // Trigger ripple at button location
                            let buttonY: CGFloat = 690 + geometry.size.height / 2
                            let buttonX: CGFloat = geometry.size.width / 2
                            rippleOrigin = CGPoint(x: buttonX, y: buttonY)
                            rippleCounter += 1
                            
                            // Delay navigation to show ripple effect
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                showContentView = true
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                                .padding(15)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.clear)
                                        .glassEffect(.clear.interactive())
                                        .frame(width: 85, height: 50)
                                        .shadow(color: .white, radius: 10, x: 0, y: 4)
                                )
                        }
                        .navigationDestination(isPresented: $showContentView) {
                            ContentView1()
                        }
                        .offset(y: 690)
                        
                        VStack {
                            Text("NAUT")
                                .font(.holtwood())
                                .foregroundColor(.white)
                                .padding(.top, 5)
                            
                            Text("Ask the Cosmos")
                                .font(.subheadline).monospaced()
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.top, -5)
                        }
                        .padding(.top, 65)
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        LoginView(imageName: "launchlogo")
    } else {
        // Fallback on earlier versions
    }
}
