//
//  model.swift
//  Confetti.swift
//
//  Created by 湯川昇平 on 2025/11/24.
//
import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var color: Color
    var rotationX: Double     // X軸回転（前後）
    var rotationY: Double     // Y軸回転（左右）
    var rotationXSpeed: Double
    var rotationYSpeed: Double
    var width: CGFloat
    var height: CGFloat
    var opacity: Double = 1.0
    var windForce: Double
}
