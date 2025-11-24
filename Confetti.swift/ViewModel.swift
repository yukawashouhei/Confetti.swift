//
//  ViewModel.swift
//  Confetti.swift
//
//  Created by 湯川昇平 on 2025/11/24.
//

import SwiftUI
import Combine

@MainActor
class ConfettiViewModel: ObservableObject {
    @Published var particles: [ConfettiParticle] = []
    var animationStartTime: Date?
    
    // 定数設定
    let particleCount = 100
    let animationDuration: TimeInterval = 4.0
    
    // 色のパレット（canvas-confettiのデフォルト色に近い）
    let colors: [Color] = [
        Color(red: 1.0, green: 0.42, blue: 0.42), // 赤
        Color(red: 1.0, green: 0.82, blue: 0.4), // オレンジ
        Color(red: 1.0, green: 0.96, blue: 0.4), // 黄
        Color(red: 0.4, green: 0.96, blue: 0.4), // 緑
        Color(red: 0.4, green: 0.82, blue: 1.0), // 青
        Color(red: 0.82, green: 0.4, blue: 1.0), // 紫
        Color(red: 1.0, green: 0.4, blue: 0.82)   // ピンク
    ]
    
    // アニメーション開始
    func startAnimation(in size: CGSize) {
        let originX = size.width / 2
        let originY = size.height * 0.4 // 画面の40%の高さ（中央より少し上）
        animationStartTime = Date()
        createParticles(origin: CGPoint(x: originX, y: originY), canvasSize: size)
    }
    
    // パーティクルを生成
    func createParticles(origin: CGPoint, canvasSize: CGSize) {
        particles = []
        
        for _ in 0..<particleCount {
            // 上方向に偏った角度分布
            // -90度（上）を中心に、±90度の範囲に集中させる
            let baseAngle = -Double.pi / 2  // -90度（上方向）
            let spread = Double.pi / 2  // ±90度の範囲
            let angle = baseAngle + Double.random(in: -spread..<spread)
            
            // ゆっくりとした速度
            let speed = Double.random(in: 20...40)
            
            // 速度ベクトル（全方向に）
            let vx = cos(angle) * speed
            let vy = sin(angle) * speed
            
            // 長方形のサイズ（幅と高さを別々に設定）
            let baseSize = CGFloat.random(in: 6...14)
            let width = baseSize * CGFloat.random(in: 0.6...1.8)  // 縦長・横長のバリエーション
            let height = baseSize * CGFloat.random(in: 0.6...1.0)
            
            // ランダムな色
            let color = colors.randomElement() ?? .blue
            
            // 3D回転の初期値（ランダムな角度）
            let rotationX = Double.random(in: 0...(2 * .pi))
            let rotationY = Double.random(in: 0...(2 * .pi))
            
            // パーティクルごとに異なる回転速度（ひらひら舞う効果）
            let rotationXSpeed = Double.random(in: 0.1...0.5) // X軸回転速度
            let rotationYSpeed = Double.random(in: 0.1...1.5) // Y軸回転速度
            
            // 風の影響（ランダムな横方向の力）
            let windForce = Double.random(in: -0.3...0.3)
            
            let particle = ConfettiParticle(
                position: origin,
                velocity: CGVector(dx: vx, dy: vy),
                color: color,
                rotationX: rotationX,
                rotationY: rotationY,
                rotationXSpeed: rotationXSpeed,
                rotationYSpeed: rotationYSpeed,
                width: width,
                height: height,
                windForce: windForce
            )
            
            particles.append(particle)
        }
    }
    
    // パーティクルを更新
    func updateParticles(canvasSize: CGSize, now: Date) {
        guard let startTime = animationStartTime else { return }
        
        let deltaTime = 1.0 / 60.0 // 60FPS
        let elapsed = now.timeIntervalSince(startTime)
        
        let gravity: CGFloat = 0.5
        
        // 空気抵抗
        let drag: CGFloat = 0.998
        
        for i in particles.indices {
            var particle = particles[i]
            
            // 重力を適用
            particle.velocity.dy += gravity * deltaTime
            
            // 風の影響を適用（ひらひら舞う効果）
            // 時間に応じて風の方向が変わる（sin波で自然な揺れ）
            let windVariation = sin(elapsed * 2.0 + Double(i) * 0.1) * particle.windForce
            particle.velocity.dx += windVariation * deltaTime
            
            // 空気抵抗を適用
            particle.velocity.dx *= drag
            particle.velocity.dy *= drag
            
            // 位置を更新
            particle.position.x += particle.velocity.dx * deltaTime
            particle.position.y += particle.velocity.dy * deltaTime
            
            // 3D回転を更新（ひらひら舞う効果）
            // X軸回転（前後回転）- 落下時に回転
            let xRotationFromVelocity = particle.velocity.dy * 0.01 // 落下速度に応じた回転
            let xRotationFromWind = windVariation * 0.05 // 風の影響
            particle.rotationX += (particle.rotationXSpeed + xRotationFromVelocity + xRotationFromWind) * deltaTime
            
            // Y軸回転（左右回転）- 横方向の動きに応じて回転
            let yRotationFromVelocity = particle.velocity.dx * 0.008 // 横方向の速度に応じた回転
            let yRotationFromWind = windVariation * 0.03 // 風の影響
            particle.rotationY += (particle.rotationYSpeed + yRotationFromVelocity + yRotationFromWind) * deltaTime
            
            // 落下時に回転速度が少し速くなる（より自然な動き）
            let fallSpeed = abs(particle.velocity.dy)
            if fallSpeed > 10 {
                particle.rotationX += fallSpeed * 0.0005 * deltaTime
                particle.rotationY += fallSpeed * 0.0003 * deltaTime
            }
            
            // フェードアウト（最後の1秒で）
            if elapsed > animationDuration - 1.0 {
                let fadeProgress = (elapsed - (animationDuration - 1.0)) / 1.0
                particle.opacity = max(0, 1.0 - fadeProgress)
            }
            
            particles[i] = particle
        }
        
        // 画面外に出たパーティクルは削除しない（フェードアウトのみ）
        // 透明度が0になったパーティクルのみ削除
        particles.removeAll { particle in
            particle.opacity <= 0
        }
    }
}
