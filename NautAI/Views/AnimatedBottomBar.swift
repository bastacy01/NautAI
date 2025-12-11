//
//  AnimatedBottomBar.swift
//  NautAI
//
//  Created by Ben Stacy on 11/11/25.
//


import SwiftUI

struct AnimatedBottomBar<LeadingAction: View, TrailingAction: View, MainAction: View>: View {
    var highlightWhenEmptry: Bool = true
    var hint: String
    var tint: Color = .black
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    @ViewBuilder var leadingAction: () -> LeadingAction
    @ViewBuilder var trailingAction: () -> TrailingAction
    @ViewBuilder var mainAction: () -> MainAction
    
    @State private var isHighlighting: Bool = false
    var body: some View {
        let mainLayout = isFocused ? AnyLayout(ZStackLayout(alignment: .bottomTrailing)) : AnyLayout(HStackLayout(alignment: .bottom, spacing: 10))
        let shape = RoundedRectangle(cornerRadius: isFocused ? 25 : 30)
        
        ZStack {
            mainLayout {
                let subLayout = isFocused ? AnyLayout(VStackLayout(alignment: .trailing, spacing: 20)) : AnyLayout(ZStackLayout(alignment: .trailing))
                subLayout {
                    TextField(hint, text: $text, axis: .vertical)
                        .lineLimit(isFocused ? 5 : 1)
                        .focused(_isFocused)
                        .foregroundStyle(.white) // White text
                        .tint(.white) // White cursor
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .mask {
                            Rectangle()
                                .padding(.trailing, isFocused ? 0 : 40)
                        }
                        .placeholder(when: text.isEmpty) {
                            Text(hint)
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                        }
                    
                    /// Trailing & Leading Action View
                    HStack(spacing: 10) {
                        /// Leading Actions
                        HStack(spacing: 10) {
                            ForEach(subviews: leadingAction()) { subview in
                                /// Each button max size is 35
                                subview
                                    .frame(width: 35, height: 35)
                                    .contentShape(.rect)
                            }
                        }
                        .compositingGroup()
                        /// Disabling interaction and hiding when not focused
                        .allowsHitTesting(isFocused)
                        .blur(radius: isFocused ? 0 : 6)
                        .opacity(isFocused ? 1 : 0)
                        
                        Spacer(minLength: 0)
                        
                        /// Trailing Action
                        ///  Trailing Action contains of only one button
                        trailingAction()
                            .frame(width: 35, height: 35)
                            .contentShape(.rect)
                    }
                }
                .frame(height: isFocused ? nil : 55)
                .padding(.leading, 15)
                .padding(.trailing, isFocused ? 15 : 20)
                .padding(.bottom, isFocused ? 10 : 0)
                .padding(.top, isFocused ? 20 : 0)
                .background {
                    ZStack {
                        HighlightingBackgroundView()
                    
                        // Glass effect background
                        if #available(iOS 26.0, *) {
                            Color.clear
                                .glassEffect(.regular.interactive(), in: shape)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                
                /// Main Action Button
                /// Main Action is also a single button view with a matching size of 50
                mainAction()
                    .frame(width: 50, height: 50)
                    .clipShape(.circle)
                    .background {
                        if #available(iOS 26.0, *) {
                            Circle()
                                .fill(Color.clear)
                                .glassEffect(.regular.interactive())
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    .visualEffect { [isFocused] content, proxy in
                        content
                            .offset(x: isFocused ? (proxy.size.width + 30) : 0)
                    }
            }
        }
        .geometryGroup()
        .animation(.easeInOut(duration: animationDuration), value: isFocused)
    }
    
    @ViewBuilder
    private func HighlightingBackgroundView() -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: isFocused ? 25 : 30)
            
            if !isFocused && text.isEmpty && highlightWhenEmptry {
                shape
                    .stroke(
                        tint.gradient,
                        style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .mask {
                        // Increase to count of this to increase the gradient style
                        let clearColors: [Color] = Array(repeating: .clear, count: 4)
                        
                        shape
                            .fill(AngularGradient(
                                colors: clearColors + [Color.white] + clearColors,
                                center: .center,
                                angle: .init(degrees: isHighlighting ? 360 : 0)
                            ))
                    }
                    .padding(-2)
                    .blur(radius: 2)
                    .onAppear {
                        /// Infinite Looping Effect
                        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                            isHighlighting = true
                        }
                    }
                    .onDisappear {
                        /// Disabling the effect
                        isHighlighting = false
                    }
                    .transition(.blurReplace)
            }
        }
    }
    
    var animationDuration: CGFloat {
        if #available(iOS 26, *) {
            return 0.22
        } else {
            return 0.33
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    ContentView()
}
