import SwiftUI;

struct ContentView: View {
    private let rows = 32
    private let cols = 32
    
    @State private var tiles: [Bool] = []
    @State private var colors : [Color] = []
    @State private var lineWidth: CGFloat = 2.0
    
    private let palette: [Color] = [.black, .blue, .purple, .orange, .pink]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Week3assignment")
                .font(.headline)
            
            week3_assignmentView(rows:rows, cols:cols, tiles:tiles, colors:colors, lineWidth:lineWidth)
                    .frame(width: 360, height: 360)
                    .background(Color(white: 0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            HStack {
                Button("Randomize"){generate()}
                    .buttonStyle(.borderedProminent)
                
                Slider(value: $lineWidth, in: 1...6) {
                    Text("Line Width")
                }
                .frame(width: 180)
                Text(String(format:"Width: %.1f, lineWidth"))
                    .font(.caption)
                    .monospaced()
            }
                
            
        }
        .padding()
        .onAppear{generate()}
    }
    private func generate() {
        var newTiles: [Bool] = []
        var newColors: [Color] = []

        for _ in 0..<(rows * cols) {
            newTiles.append(Bool.random())
            newColors.append(palette.randomElement() ?? .black)
        }
        tiles = newTiles
        colors = newColors
    }
}


struct week3_assignmentView: View {
    let rows: Int
    let cols: Int
    let tiles: [Bool]
    let colors: [Color]
    let lineWidth: CGFloat

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cellW = size / CGFloat(cols)
            let cellH = size / CGFloat(rows)

            ZStack {
                ForEach(0..<rows, id: \.self) { r in
                    ForEach(0..<cols, id: \.self) { c in
                        let idx = r * cols + c
                        let color = (idx < colors.count) ? colors[idx] : .black
                        Path { p in
                            let x = CGFloat(c) * cellW
                            let y = CGFloat(r) * cellH
                            let rect = CGRect(x: x, y: y, width: cellW, height: cellH)

                            if idx < tiles.count && tiles[idx] {
                                p.move(to: CGPoint(x: rect.minX, y: rect.minY))
                                p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                            } else {
                                p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                                p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                            }
                        }
                        .stroke(color, lineWidth: lineWidth)
                    }
                }
            }
            .frame(width: size, height: size, alignment: .center)
        }
    }
}
