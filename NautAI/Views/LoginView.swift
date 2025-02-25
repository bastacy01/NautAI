//
//  LoginView.swift
//  NautAI
//
//  Created by Ben Stacy on 12/16/24.
//

import SwiftUI

struct LoginView: View {
    let imageName: String
    @State private var showContentView = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Image("astronautlogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .padding(.top, 50)
                            .offset(x: -160)
                        
                        Text("NAUT")
                            .font(.holtwood())
                            .foregroundColor(.white)
                            .padding(.top, 5)
                        
                        Text("V0.1.1")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.top, -25)
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                showContentView = true
                            }) {
                                HStack {
                                    Image("googleIcon")
                                        .resizable()
                                        .frame(width: 23, height: 23)
                                        .offset(x: -5)
                                    Text("Sign In")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .frame(width: 125, height: 40)
                                        .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 7)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1.5)
                                        )
                                )
                            }
                            .navigationDestination(isPresented: $showContentView) {
                                ContentView()
                            }
                            
                            Button(action: {

                            }) {
                                HStack {
                                    Image("appleIcon")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .offset(x: -5)
                                    Text("Sign In")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .frame(width: 125, height: 40)
                                        .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 7)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1.5)
                                        )
                                )
                            }
                        }
                        .padding(.bottom, 210)
                        .frame(maxWidth: .infinity)
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
    LoginView(imageName: "launchlogo")
}
