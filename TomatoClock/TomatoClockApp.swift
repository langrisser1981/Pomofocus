//
//  TomatoClockApp.swift
//  TomatoClock
//
//  Created by 程信傑 on 2022/11/28.
//

import SwiftUI

import Firebase
import GoogleSignIn

@main
struct TomatoClockApp: App {
    // 建立一個登入物件，注射到環境中，讓整個程式共用同一個登入物件
    @StateObject var loginModel = LoginViewModel()

    init() {
        setupAuthentication()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginModel) // 注射登入物件
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url) // 開啟登入頁面
                }
        }
    }
}

extension TomatoClockApp {
    // 初始化firebase
    func setupAuthentication() {
        FirebaseApp.configure()
    }
}
