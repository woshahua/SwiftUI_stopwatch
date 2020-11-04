//
//  ClockView.swift
//  StopWatch
//
//  Created by Hang Gao on 2020/10/18.
//

import SwiftUI

struct ClockView: View {
    var body: some View {
        ZStack {
            ForEach(0..<60 * 4) { tick in
                self.tick(at: tick)
            }
        }
    }
    
    func tick(at tick: Int) -> some View {
        VStack {
            Rectangle()
                .fill(Color.primary)
                .opacity(tick % 5 == 0 ? 1: 0.4)
                .frame(width: 3, height: 15)
                Spacer()
        }.rotationEffect(Angle.degrees(Double(tick) / 240 * 360))
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
            .background(Color.white)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
