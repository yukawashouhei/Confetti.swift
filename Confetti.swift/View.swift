//
//  View.swift
//  Confetti.swift
//
//  Created by 湯川昇平 on 2025/11/24.
//

import SwiftUI

struct MinimalConfettiView: View {
    @StateObject private var viewModel = ConfettiViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Canvasでパーティクルを描画
                Canvas { context, size in
                    for particle in viewModel.particles {
                        // 3D効果：Y軸回転に応じてサイズを調整（奥行き効果）
                        // cos(rotationY)が1の時は正面、-1の時は裏面（小さく見える）
                        let depthScale = 0.5 + 0.5 * abs(cos(particle.rotationY)) // 0.5〜1.0の範囲
                        let scaledWidth = particle.width * depthScale
                        let scaledHeight = particle.height * depthScale
                        
                        // 長方形を描画
                        let rect = CGRect(
                            x: particle.position.x - scaledWidth / 2,
                            y: particle.position.y - scaledHeight / 2,
                            width: scaledWidth,
                            height: scaledHeight
                        )
                        
                        var path = Path(rect)
                        
                        // 3D効果：X軸回転に応じてわずかなZ軸回転を適用（ひらひら舞う効果）
                        // X軸回転が大きいほど、Z軸回転も大きくなる
                        let zRotation = sin(particle.rotationX) * 0.3 // 最大30度のZ軸回転
                        
                        let center = CGPoint(x: rect.midX, y: rect.midY)
                        let transform = CGAffineTransform(translationX: center.x, y: center.y)
                            .rotated(by: zRotation)
                            .translatedBy(x: -center.x, y: -center.y)
                        path = path.applying(transform)
                        
                        // 3D効果：X軸回転に応じて透明度を調整（奥行き感）
                        // X軸回転が90度や270度の時（横から見た時）は少し透明に
                        let xRotationOpacity = 0.7 + 0.3 * abs(cos(particle.rotationX))
                        context.opacity = particle.opacity * xRotationOpacity
                        
                        // 色を適用して描画
                        context.fill(path, with: .color(particle.color))
                    }
                }
                
                // TimelineViewでアニメーションを駆動
                TimelineView(.animation) { timeline in
                    let now = timeline.date
                    
                    // 状態更新はTask内で行う（ビュー更新サイクル外）
                    Task { @MainActor in
                        guard let startTime = viewModel.animationStartTime else { return }
                        
                        // 4秒経過したらアニメーション終了
                        if now.timeIntervalSince(startTime) > viewModel.animationDuration {
                            if !viewModel.particles.isEmpty {
                                viewModel.particles.removeAll()
                            }
                            return
                        }
                        
                        viewModel.updateParticles(canvasSize: geometry.size, now: now)
                    }
                    
                    // 空のView（描画はCanvasで処理）
                    return Color.clear
                }
                
                // トリガーボタン
                VStack {
                    Spacer()
                    Button("Confetti!") {
                        // 画面中央から放出
                        let originX = geometry.size.width / 2
                        let originY = geometry.size.height * 0.4 // 画面の40%の高さ（中央より少し上）
                        viewModel.animationStartTime = Date()
                        viewModel.createParticles(origin: CGPoint(x: originX, y: originY), canvasSize: geometry.size)
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.42),
                                Color(red: 1.0, green: 0.82, blue: 0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

#Preview {
    MinimalConfettiView()
}
