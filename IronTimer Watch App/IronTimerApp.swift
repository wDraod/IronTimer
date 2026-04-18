//
//  IronTimerApp.swift
//  IronTimer Watch App
//
//  Created by OliveZ on 18/04/2026.
//

import SwiftUI

@main
struct IronTimer_Watch_AppApp: App {

    init() {
        // 启动时申请 HealthKit 授权
        Task {
            await HealthKitManager.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
