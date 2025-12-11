//
//  SideBarView.swift
//  NautAI
//
//  Created by Ben Stacy on 7/11/25.
//

import SwiftUI

struct SearchCapsule: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
            TextField("Search", text: .constant(""))
                .foregroundStyle(.white)
                .textFieldStyle(PlainTextFieldStyle())
                .submitLabel(.search)
                .accentColor(.white) // Ensures cursor and other accents are white
                .placeholder(when: true) {
                    Text("Search").foregroundColor(.white) // Placeholder color
                }
        }
//        .padding(.vertical, 8)
//        .padding(.horizontal, 10)
//        .background(Color.gray.opacity(0.3))
//        .cornerRadius(20)
//        .frame(width: 200, height: 36)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(20)
        .frame(width: 215, height: 36)
        .offset(x: 10, y: 2)
    }
}

@available(iOS 26.0, *)
struct SidebarView: View {
    @Binding var isVisible: Bool
    let userName: String = "Ben S"
//    let resetChat: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        // Search bar with "Create" button
                        HStack(spacing: 10) {
                            SearchCapsule()
                                .frame(width: 250) // You can adjust this width
                                .padding(.top, 15)
                                .padding(.leading, -10)
                            
                            Button(action: {
//                                resetChat()
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.top, 15)
                            }
                        }
                        .padding(.top, 50)
                        
                        // Text items
                        VStack(alignment: .leading, spacing: 25) {
                            Text("Cartoon Style Request")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            Text("App Icon Design Request")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            Text("How Spotify Makes Money")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            Text("Image to Animated Character")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            Text("Diploma Icon Request")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            Text("Hey how can I help")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                        }
                        .font(.headline)
                        .padding(.top, 40)
                        .padding(.leading, 10)
                        
                        Spacer()
                        
                        // User profile
//                        HStack {
//                            Circle()
//                                .fill(Color.blue)
//                                .frame(width: 30, height: 30)
//                            Text(userName)
//                                .foregroundColor(.white)
//                                .font(.system(size: 16, weight: .medium))
//                            Spacer()
//                        }
//                        .padding(.bottom, 40)
//                        .padding(.leading, 30)
                        HStack {
                            Circle()
                                .fill(.clear)
                                .glassEffect(.clear)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "gearshape")
                                        .foregroundStyle(.white)
                                        .font(.title3)
                                )
                            Text(userName)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                        .padding(.bottom, 40)
                        .padding(.leading, 30)
                    }
                    .frame(width: 310)
                    .offset(x: isVisible ? 0 : -250)
                    .transition(.move(edge: .leading))
                    .background(Color.gray.opacity(0.2))
                    
                    Spacer()
                }
            }
            .offset(x: isVisible ? 0 : -geometry.size.width)
            .animation(.easeInOut, value: isVisible)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        SidebarView(isVisible: .constant(true))
    } else {
        // Fallback on earlier versions
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}
