//
//  HomeView.swift
//  NautAI
//
//  Created by Ben Stacy on 9/5/25.
//

import SwiftUI

enum theviews{
    case profile,setting,notifications,chatView
}

struct HomeVeiw: View {
    @State var xoffset:CGFloat = 0
    @State var SidePosition:CGFloat = 0
    @State var currentView: theviews = .chatView
    @State var enablePushButton = true
    @FocusState var iskeyboardOpen: Bool
    @State var show = false
    var body: some View {
        GeometryReader { geo in
            ZStack{
                Group{
                    switch currentView {
                    case .profile:
                        ProfileView( )
                    case .setting:
                        SettingsView()
                    case .notifications:
                        NotificationsView()
                    case .chatView:
                        ChatView(enable: $enablePushButton,isFocused: _iskeyboardOpen , Open: {
                            SidePosition += geo.size.width / 1.5
                        })
                    }
                }
                // We offset the main view based on drag position + saved position
                // After the drag ends, xoffset resets to 0, so we keep track of the final position using SidePosition
                
                .offset(x: xoffset + SidePosition)
                // We apply a slight blur while dragging, to give a feeling of depth
                // Dividing by 10 keeps the blur subtle even when the drag value is large
                .blur(radius: (xoffset + SidePosition) / 10)
                
//                SideView(currentView: $currentView, enable: $enablePushButton,Close: {
//                    show.toggle()
//                    SidePosition -= geo.size.width / 1.5
//                })
                // We position the SideView off-screen by default, then move it based on drag and position
                .offset(x: -geo.size.width / 1.5 + xoffset + SidePosition)
                // Gradually fade in the side menu as it enters the screen
                // Subtracting 40 shifts the fade-in to start a bit after it's begun sliding in
                // Dividing by 100 gives a slow, smooth transition from opacity 0 to 1
                .opacity(max(0, min(1, (Double(xoffset + SidePosition) - 40) / 100)))
                // Add a reverse blur effect: sharp when fully open, blurred when hidden
                // This gives the SideView a soft, fading presence as it slides away
                .blur(radius: max(0, 10 - (xoffset + SidePosition) / 20))
                
                .zIndex(1)
            }
            .gesture(
                CustomGesture { gesture in
                    let rawDrag = gesture.translation(in: gesture.view).x
                    let threshold = geo.size.width / 1.5
                    let drag: CGFloat

                    if abs(rawDrag) <= threshold {
                        drag = rawDrag
                    } else {
                        let excess = abs(rawDrag) - threshold
                        let slowedExcess = excess / 10
                        drag = rawDrag > 0 ? threshold + slowedExcess : -threshold - slowedExcess
                    }
                    
                    switch gesture.state {
                    case .changed:
                        
                        //  this mark ( || )mean or
                        if (SidePosition == 0 && drag >= 0) || (SidePosition > 0 && drag <= 0) {
                            xoffset = drag
                            iskeyboardOpen = false
                            enablePushButton = false
                        } else {
                            xoffset = 0
                        }
                    case .ended:
                        withAnimation(.spring(duration: 0.2))  {
                            if drag > 100 && SidePosition == 0 {
                                SidePosition += geo.size.width / 1.5
                            } else if drag < -100 && SidePosition > 0 {
                                SidePosition -= geo.size.width / 1.5
                            }
                            enablePushButton = true
                            xoffset = 0
                        }
                    default:
                        break
                    }
                }
            )
            
            .onChange(of: currentView) { oldValue, newValue in
                withAnimation (.spring(duration: 0.2)) {
                    SidePosition -= geo.size.width / 1.5
                }
            }
        }
        
    }
}

#Preview {
    HomeVeiw()
}

struct CustomGesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> ()
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        return gesture
    }
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
    }
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
}
