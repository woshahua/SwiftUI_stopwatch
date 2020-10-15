//
//  ContentView.swift
//  StopWatch
//
//  Created by Hang Gao on 2020/10/15.
//

import SwiftUI

struct CircleStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        Circle()
            .fill()
            .overlay(
                Circle()
                    .fill(Color.white)
                    .opacity(configuration.isPressed ? 0.3 : 0.0)
            )
            .overlay(
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.white)
                    .padding(4)
            
            )
            .overlay(
                configuration.label
                    .foregroundColor(.white)
            )
    }
}

struct ContentView: View {
    var body: some View {
        HStack {
            Button(action: {}){
                Text("Start")
            }.buttonStyle(CircleStyle())
            .foregroundColor(.green)
            
            Spacer()
            
            Button(action: {}){
                Text("Stop")
            }.buttonStyle(CircleStyle())
            .foregroundColor(.red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
