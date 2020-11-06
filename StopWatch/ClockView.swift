//
//  ClockView.swift
//  StopWatch
//
//  Created by Hang Gao on 2020/10/18.
//

import SwiftUI

struct ClockView: View {
    var time: TimeInterval = 10
    var lapTime: TimeInterval?
    
    var body: some View {
        ZStack {
            ForEach(0..<60 * 4) { tick in
                self.tick(at: tick)
            }
            
            if lapTime != nil {
                Pointer()
                    .stroke(Color.blue, lineWidth: 2)
                    .rotationEffect(Angle.degrees(Double(lapTime!) * 360 / 60))
            }
            
            Pointer()
                .stroke(Color.orange, lineWidth: 2)
                .rotationEffect(Angle.degrees(Double(time) * 360 / 60))
            Color.clear
        }
    }
    
    func tick(at tick: Int) -> some View {
        VStack {
            Rectangle()
                .fill(Color.primary)
                .opacity(tick % 5 == 0 ? 1: 0.4)
                .frame(width: 2, height: tick % 4 == 0 ? 15 : 7)
                Spacer()
        }.rotationEffect(Angle.degrees(Double(tick) / 240 * 360))
    }
}

struct Pointer: Shape {
    // rect is the space
    var circleRadius: CGFloat = 3
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.midY - circleRadius))
            p.addEllipse(in: CGRect(center: rect.center, radius: circleRadius))
            p.move(to: CGPoint(x: rect.midX, y: rect.midY + circleRadius))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.midY + rect.height / 7))
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
        
    }
    
    init(center: CGPoint, radius: CGFloat) {
        self = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
            .background(Color.white)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}

