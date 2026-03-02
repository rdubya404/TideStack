//
//  ContentView.swift
//  TideStack
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.04, green: 0.09, blue: 0.16)
                    .ignoresSafeArea()
                
                // Game container with rounded corners
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black)
                    .frame(width: 360, height: 640)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.15), lineWidth: 3)
                    )
                    .shadow(color: Color(red: 0, green: 0.7, blue: 1.0).opacity(0.3), radius: 40, x: 0, y: 20)
                    .overlay(
                        SpriteView(scene: createGameScene(size: CGSize(width: 360, height: 640)))
                            .frame(width: 360, height: 640)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func createGameScene(size: CGSize) -> SKScene {
        let scene = TideStackGameScene()
        scene.size = size
        scene.scaleMode = .aspectFill
        return scene
    }
}

#Preview {
    ContentView()
}
