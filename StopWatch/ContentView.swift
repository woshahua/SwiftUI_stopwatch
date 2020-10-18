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
    @ObservedObject var stopwatch = StopWatch()
    
    var body: some View {
        VStack {
            Text("\(stopwatch.total.formatted)").font(.system(size: 64))
            HStack {
                ZStack {
                    Button(action: {
                        self.stopwatch.stop()
                    }){
                        Text("Stop")
                    }.foregroundColor(.red)
                    .visible(stopwatch.isRunning)
                    
                    Button(action: {
                        self.stopwatch.start()
                    }){
                        Text("Start")
                    }.foregroundColor(.green)
                    .visible(!stopwatch.isRunning)
                }
                
                Spacer()
                
                ZStack {
                    Button(action: {
                        self.stopwatch.lap()
                    }){
                        Text("lab")
                    }.foregroundColor(.gray)
                    .visible(stopwatch.isRunning)
                    
                    Button(action: {
                        self.stopwatch.reset()
                    }){
                        Text("Reset")
                    }.foregroundColor(.gray)
                    .visible(!stopwatch.isRunning)
                }
            }
            .padding(.horizontal)
            .equalSizes()
            .padding()
            .buttonStyle(CircleStyle())
            
            List {
                ForEach (stopwatch.laps.enumerated().reversed(), id: \.offset) { value in
                    HStack {
                        Text(" Lap \(value.offset + 1)")
                        Text(value.element.0.formatted)
                            .font(Font.body.monospacedDigit())
                    }.foregroundColor(value.element.1.color)
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func visible(_ v: Bool) -> some View {
        self.opacity(v ? 1 : 0)
    }
}

final class StopWatch: ObservableObject {
    @Published private var data: StopWatchData = StopWatchData()
    private var timer: Timer?
    
    var isRunning: Bool {
        self.data.absoluteStartTime != nil
    }
    
    var total: TimeInterval {
        data.totalTime
    }
    
    var laps: [(TimeInterval, LapType)] {
        return data.labs
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {
            [unowned self] timer in
            self.data.currentTime = Date().timeIntervalSinceReferenceDate
        })
        data.start(at: Date().timeIntervalSinceReferenceDate)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        data.stop()
    }
    
    func reset() {
        stop()
        data = StopWatchData()
    }
    
    func lap() {
        data.lap()
    }
    
    deinit {
        stop()
    }
}

struct StopWatchData {
    var absoluteStartTime: TimeInterval?
    var currentTime: TimeInterval = 0
    var additionalTime : TimeInterval = 0
    var _labs: [(TimeInterval, LapType)] = []
    var currentLapTime: TimeInterval {
        totalTime - lastLapEnd
    }
    
    var labs: [(TimeInterval, LapType)] {
        guard totalTime > 0 else { return [] }
        return _labs + [(currentLapTime, .regular)]
    }
    var lastLapEnd: TimeInterval = 0
    
    var totalTime: TimeInterval {
        guard let start = absoluteStartTime else { return additionalTime }
        return additionalTime + currentTime - start
    }
    
    mutating func start (at time: TimeInterval) {
        currentTime = time
        absoluteStartTime = time
    }
    
    mutating func stop() {
        additionalTime = totalTime
        absoluteStartTime  = nil
    }
    
    mutating func lap() {
        let lapTimes = _labs.map { $0.0 } + [currentLapTime]
        if let shortest = lapTimes.min(), let logest = lapTimes.max(), shortest != logest {
            _labs = lapTimes.map { ($0, $0 == shortest ? .shortest : ($0 == logest ? .logest : .regular))}
        } else {
            _labs = lapTimes.map( { ($0, .regular)} )
        }
        lastLapEnd = totalTime
    }
}

let formater: DateComponentsFormatter = {
    let f = DateComponentsFormatter()
    f.allowedUnits = [.minute, .second]
    f.zeroFormattingBehavior = .pad
    return f
}()


let numberFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.maximumFractionDigits = 1
    f.minimumFractionDigits = 1
    f.maximumIntegerDigits = 0
    f.alwaysShowsDecimalSeparator = true
    return f
}()

extension TimeInterval {
    var formatted: String {
        let ms = self.truncatingRemainder(dividingBy: 1)
        return formater.string(from: self)! + numberFormatter.string(from: NSNumber(value: ms))!
    }
}

enum LapType {
    case logest
    case shortest
    case regular
    
    var color: Color {
        switch self {
        case .regular:
            return .black
        case .shortest:
            return .green
        case .logest:
            return .red
        }
    }
}
