# Confetti.swift - @Observable版

このリポジトリは、SwiftUIの最新の`@Observable`マクロを使用した紙吹雪アニメーションの実装です。

## 比較用リポジトリ

このリポジトリは、従来の`ObservableObject`を使用した実装と比較するためのものです。

- **このリポジトリ**: `@Observable`マクロを使用（最新実装）
- **比較対象**: [Confetti-ObservableObject.swift](https://github.com/yukawashouhei/Confetti-ObservableObject.swift) - `ObservableObject` + `@Published`を使用

## 実装の違い

### Observable版（このリポジトリ）

```swift
import SwiftUI
import Observation

@MainActor
@Observable
class ConfettiViewModel {
    var particles: [ConfettiParticle] = []
    
    @ObservationIgnored
    var animationStartTime: Date?
    // ...
}
```

**特徴:**
- `Observation`フレームワークを使用
- マクロで自動的に変更検知を実装
- `@State`でビューにバインド
- `@ObservationIgnored`で不要な更新を防止（bodyの更新頻度を制御）

### ObservableObject版（比較対象）

```swift
import SwiftUI
import Combine

@MainActor
class ConfettiViewModel: ObservableObject {
    @Published var particles: [ConfettiParticle] = []
    var animationStartTime: Date?
    // ...
}
```

**特徴:**
- `Combine`フレームワークを使用
- `@Published`プロパティラッパーで変更を検知
- `@StateObject`でビューにバインド

## 主な改善点

1. **`@ObservationIgnored`の使用**: `animationStartTime`や定数プロパティを観測対象外にすることで、意図しないbodyの更新を防止
2. **Combineフレームワークの不要化**: `Observation`フレームワークのみで実装
3. **コードの簡潔化**: `@Published`が不要になり、コードがよりシンプルに

## パフォーマンス比較

詳細な比較については、[OBSERVABLE_VS_OBSERVABLEOBJECT.md](./OBSERVABLE_VS_OBSERVABLEOBJECT.md)を参照してください。

## 使用方法

1. Xcodeでプロジェクトを開く
2. シミュレーターまたは実機で実行
3. "Confetti!"ボタンをタップして紙吹雪アニメーションを開始

## 要件

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## マイグレーションガイド

`ObservableObject`から`@Observable`へのマイグレーション手順：

1. `ObservableObject`を`@Observable`マクロに変更
2. `@Published`を削除
3. `import Combine`を`import Observation`に変更
4. `@StateObject`を`@State`に変更
5. トラッキング不要なプロパティに`@ObservationIgnored`を追加

詳細は、Apple公式ドキュメントを参照してください。

