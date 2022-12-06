//
//  ContentView.swift
//  TomatoClock
//
//  Created by 程信傑 on 2022/11/28.
//

import SwiftUI

struct ContentView: View {
    // 取得環境中的登入控制器
    @EnvironmentObject var loginModel: LoginViewModel

    var body: some View {
        NavigationStack {
            VStack {
                // 檢查使用者是否已登入，是的話就直接進入首頁
                switch loginModel.state {
                case .signedIn:
                    HomeView()
                        .navigationTitle("Home")
                        .navigationBarTitleDisplayMode(.large)
                case .signedOut:
                    // 如果還沒登入就顯示登入頁面
                    LoginView()
                }
                Button("Crash") {
                    fatalError("Crash was triggered")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginViewModel())
    }
}
