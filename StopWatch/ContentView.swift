//
//  ContentView.swift
//  StopWatch
//
//  Created by Hang Gao on 2020/10/15.
//

import SwiftUI

struct ButtonCircle: ViewModifier {
    @State var size: CGSize? = nil
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        let background = Circle()
                .fill()
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .opacity(isPressed ? 0.3 : 0.0)
                )
                .overlay(
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                        .padding(4)
                )
            
        let foreground = content
            .padding(20)
            .overlay(GeometryReader { proxy in
                Color.clear.preference(key: SizeKey.self, value: proxy.size)
            })
            // change the size when preference key changed
            .onPreferenceChange(SizeKey.self, perform: { value in
                self.size = value
            })
            .foregroundColor(.white)
        
        return foreground.frame(width: size?.width, height: size?.height)
            .background(background)
    }
    
    
}

struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize? = nil
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}

struct CircleStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label.modifier(ButtonCircle(isPressed: configuration.isPressed))
    }
}

struct ContentView: View {
    var body: some View {
        HStack {
            Button(action: {}){
                Text("Start")
            }.foregroundColor(.green)
            
            Button(action: {}){
                Text("Reset")
            }.foregroundColor(.red)
        }
        .padding()
        .buttonStyle(CircleStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
