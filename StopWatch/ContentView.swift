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
            .equalSize()
            // change the size when preference key changed
            .foregroundColor(.white)
        
        return foreground.frame(width: size?.width, height: size?.height)
            .background(background)
    }
    
    
}

// set a list of cgsize
struct SizeKey: PreferenceKey {
    static var defaultValue: [CGSize] = []
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}

struct CircleStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label.modifier(ButtonCircle(isPressed: configuration.isPressed))
    }
}


extension EnvironmentValues {
    var size: CGSize? {
        get { self[SizeEnvironmentKey.self] }
        set { self[SizeEnvironmentKey.self] = newValue}
    }
}


struct SizeEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGSize? = nil
}

fileprivate struct EqualSize: ViewModifier {
    @Environment(\.size) private var size
    
    func body(content: Content) -> some View {
        content.overlay(GeometryReader { proxy in
            Color.clear.preference(key: SizeKey.self, value: [proxy.size])
        })
        .frame(width: size?.width, height: size?.width)
    }
}

fileprivate struct EqualSizes: ViewModifier {
    @State var width: CGFloat?
    
    func body(content: Content) -> some View {
        content.onPreferenceChange(SizeKey.self, perform: { value in
            self.width = value.map { $0.width }.max()
        }).environment(\.size, width.map { CGSize (width: $0, height: $0)})
    }
}

extension View {
    func equalSize() -> some View {
        self.modifier(EqualSize())
    }
    
    func equalSizes() -> some View {
        self.modifier(EqualSizes())
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
        .equalSizes()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
