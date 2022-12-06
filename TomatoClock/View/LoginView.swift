//
//  LoginView.swift
//  TomatoClock
//
//  Created by 程信傑 on 2022/11/30.
//

import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginModel: LoginViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State private var useFaceId = false

    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.5)
                .fill(.red)
                .frame(width: 50)
                .rotationEffect(.degrees(-90))
                .offset(x: -25)
                .hLeading()

            Text("Pomofocus\nLogin")
                .font(.largeTitle.bold())
                .foregroundColor(.red)
                .hLeading()

            // 帳號欄位
            TextField("Email", text: $email)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(email == "" ? Color.black.opacity(0.05) : Color.orange)
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .scenePadding(.top)

            // 密碼欄位
            SecureField("Password", text: $password)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(password == "" ? Color.black.opacity(0.05) : Color.orange)
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .scenePadding(.top)

            // MARK: 臉部辨識

            // 先檢查裝置是否支援生物辨識，如果有支援才繼續
            if loginModel.getBioMetricStatus() {
                Group {
                    if useFaceId {
                        VStack(alignment: .leading) {
                            Button {
                                // 執行臉部辨識流程，為非同步執行
                                Task {
                                    do {
                                        try await loginModel.authenticateUser()
                                    } catch {
                                        loginModel.errorMsg = error.localizedDescription
                                        loginModel.shouldShowError.toggle()
                                    }
                                }
                            } label: {
                                Label("Use FaceId to Login", systemImage: "faceid")
                            }

                            // deeplink打開app的設定頁面
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("You can disable FaceID in settings")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .hLeading()

                    } else {
                        Toggle(isOn: $useFaceId) {
                            Text("Use FaceID To Login")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top)
            }

            // MARK: 帳號密碼登入按鈕

            Button {
                // 非同步執行登入動作，
            } label: {
                Text("Login")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .hCenter()
                    .background {
                        Capsule()
                            .fill(.purple)
                    }
            }
            .frame(width: 210)
            .padding(.top)
            // 如果帳號或密碼欄位還尚未輸入，就暫時取消按鈕行為
            .disabled(email == "" || password == "")
            .opacity(email == "" || password == "" ? 0.5 : 1)

            // MARK: google-sign-in按鈕

            GoogleSignInButton {
                // 登入
                loginModel.signIn()
            }
            .frame(width: 200)
            .hCenter()
            .padding(.top)

            // MARK: 匿名登入

            // 也提供訪客試用，不用帳密登入直接進入首頁使用功能
            // TODO: 應該使用firebase auth的匿名登入
            NavigationLink {
                HomeView()
            } label: {
                Text("Skip Now")
                    .foregroundColor(.gray)
            }
            .padding(.top)
        }
        .padding()
        .alert(loginModel.errorMsg, isPresented: $loginModel.shouldShowError) {}
    }
}

// MARK: 排版用途，可以將元件齊左、齊右、置中

extension View {
    func hLeading()->some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }

    func hCenter()->some View {
        self.frame(maxWidth: .infinity, alignment: .center)
    }

    func hTrailing()->some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginViewModel())
    }
}
