//
//  SpinningWheelView.swift
//  ParPerks
//
//  Created by Thomas Ho on 10/30/25
//
//  Full-screen spinning wheel overlay that randomly selects a perk reward.
//

import SwiftUI

// Spinning wheel used to randomly choose one perk from the provided list
struct SpinningWheelView: View {
    let perks: [String]
    @Binding var isPresented: Bool
    
    @State private var rotation: Double = 0
    @State private var selectedPerk: String?
    
    private let wheelSize: CGFloat = 320
    // How far out from the center labels are drawn, as a fraction of radius
    private let labelRadiusRatio: CGFloat = 0.62
    // Color gradients for each wheel segment
    private let segmentColors: [LinearGradient] = [
        LinearGradient(colors: [.green, .green.opacity(0.6)], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [.blue, .blue.opacity(0.6)], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [.purple, .purple.opacity(0.6)], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [.orange, .orange.opacity(0.6)], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [.mint, .mint.opacity(0.6)], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [.pink, .pink.opacity(0.6)], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [.teal, .teal.opacity(0.6)], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [.indigo, .indigo.opacity(0.6)], startPoint: .top, endPoint: .bottom)
    ]
    
    var body: some View {
        ZStack {
            // Dark gradient backdrop for the modal
            LinearGradient(colors: [.black.opacity(0.9), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 28) {
                Text(selectedPerk == nil ? "Spin for a Perk!" : "You Earned a Perk!")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                
                ZStack {
                    // Outer glow behind the wheel
                    Circle()
                        .fill(.black.opacity(0.15))
                        .frame(width: wheelSize + 18, height: wheelSize + 18)
                    ZStack {
                        // Draw each wedge and label around the wheel
                        ForEach(0..<perks.count, id: \.self) { i in
                            let step = 360.0 / Double(perks.count)
                            let start = -90 + step * Double(i)
                            let end = start + step
                            let center = start + step / 2
                            Wedge(startAngle: start, endAngle: end)
                                .fill(segmentColors[i % segmentColors.count])
                                .frame(width: wheelSize, height: wheelSize)
                            SegmentLabel(
                                text: perks[i],
                                centerAngle: center,
                                arcAngle: step,
                                wheelSize: wheelSize,
                                radiusRatio: labelRadiusRatio
                            )
                        }
                        // Inner ring and center hub styling
                        Circle()
                            .strokeBorder(.white.opacity(0.2), lineWidth: 2)
                            .frame(width: wheelSize * 0.92, height: wheelSize * 0.92)
                        Circle()
                            .strokeBorder(
                                LinearGradient(colors: [.white.opacity(0.7), .white.opacity(0.2)],
                                               startPoint: .top, endPoint: .bottom),
                                lineWidth: 10
                            )
                            .frame(width: wheelSize, height: wheelSize)
                        Circle()
                            .fill(LinearGradient(colors: [.white, .gray.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 64, height: 64)
                            .overlay(Circle().stroke(.black.opacity(0.2), lineWidth: 2))
                    }
                    .rotationEffect(.degrees(rotation))
                    
                    // Pointer that indicates the winning segment at the top
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.yellow)
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 4)
                        .offset(y: -(wheelSize/2) - 6)
                }
                
                // Show the selected perk once the spin finishes
                if let perk = selectedPerk {
                    Text(perk)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                        .padding()
                        .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .transition(.scale.combined(with: .opacity))
                    Button("Awesome!") { isPresented = false }
                        .buttonStyle(CompactGreenCTA())
                        .padding(.top, 10)
                }
            }
            .foregroundStyle(.white)
            .padding()
        }
        .onAppear(perform: spinTheWheel)
    }
    
    // Randomizes the total spin and then computes which perk lands under the pointer
    private func spinTheWheel() {
        guard !perks.isEmpty else { return }
        let spins = Double.random(in: 4...6)
        // Spin several full rotations plus a random extra offset
        let terminal = spins * 360.0 + Double.random(in: 0..<360)
        
        withAnimation(.spring(response: 4.5, dampingFraction: 0.55)) {
            rotation = terminal
        }
        
        // After animation finishes, determine the winning segment
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.7) {
            let idx = indexUnderPointer(rotation: rotation, count: perks.count)
            selectedPerk = perks[idx]
        }
    }
    
    // Converts the final rotation into a segment index under the top pointer
    private func indexUnderPointer(rotation: Double, count: Int) -> Int {
        let step = 360.0 / Double(count)
        var r = rotation.truncatingRemainder(dividingBy: 360)
        if r < 0 { r += 360 }
        var angle = -90.0 - r
        angle.formTruncatingRemainder(dividingBy: 360)
        if angle < 0 { angle += 360 }
        let shifted = (angle + 90.0).truncatingRemainder(dividingBy: 360)
        return Int(floor(shifted / step)) % count
    }
    
    // Pie slice shape for a single segment of the wheel
    private struct Wedge: Shape {
        var startAngle: Double
        var endAngle: Double
        func path(in rect: CGRect) -> Path {
            let c = CGPoint(x: rect.midX, y: rect.midY)
            let r = min(rect.width, rect.height) / 2
            var p = Path()
            p.move(to: c)
            p.addArc(center: c,
                     radius: r,
                     startAngle: .degrees(startAngle),
                     endAngle: .degrees(endAngle),
                     clockwise: false)
            p.closeSubpath()
            return p
        }
    }
    
    // Label positioned along the arc of a wedge, rotated to stay upright
    private struct SegmentLabel: View {
        let text: String
        let centerAngle: Double
        let arcAngle: Double
        let wheelSize: CGFloat
        let radiusRatio: CGFloat
        
        var body: some View {
            let radius = wheelSize / 2 * radiusRatio
            let width = 2 * radius * CGFloat(sin((arcAngle * .pi / 180) / 2)) * 0.9
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
                .frame(width: max(width, 40))
                .rotationEffect(.degrees(-centerAngle))
                .offset(x: cos(centerAngle * .pi / 180) * radius,
                        y: sin(centerAngle * .pi / 180) * radius)
        }
    }
}
