//
//  LoginViewModel.swift
//  TomatoClock
//
//  Created by 程信傑 on 2022/11/30.
//

import Firebase
import FirebaseAuth
import Foundation
import GoogleSignIn
import LocalAuthentication

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var state: State

    // 用來控制是否顯示error alert，與對應的錯誤訊息
    @Published var shouldShowError = false
    @Published var errorMsg = ""

    var currentUser: User? {
        let user = Auth.auth().currentUser
        return user
    }

    init() {
        // 初始化時檢查是否已經有登入的使用者
        if let user = Auth.auth().currentUser {
            print("已登入")
            self.state = .signedIn(user)
        } else {
            print("未登入")
            self.state = .signedOut
        }
    }

    // MARK: google sign in

    func signIn() {
        // 如果之前已經登入過，就直接回復狀態，不然就執行登入流程
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in // 此為escaping closure，記得要指定weal|unowned self
                authenticateUser(for: user, with: error)
            }
        } else {
            /*
              新版的google sign in 不用底下的流程了
             // 取得app對應的clientID，並用它建立配置檔
             guard let clientID = FirebaseApp.app()?.options.clientID else { return }
             let configuration = GIDConfiguration(clientID: clientID)
              */
            // 取得rootViewController，作為跳轉頁面
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            // 開始登入流程，新版的signin不需要指定configuration(clientID)
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] auth, error in
                // print("\(auth?.user.profile?.email)")
                authenticateUser(for: auth?.user, with: error)
            }
        }
    }

    // 整合google-sign-in & firebase授權管理
    func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 檢查google-sign-in 是否有錯誤
        if let error {
            print("google-sign-in 授權失敗:\(error.localizedDescription)")
        }

        // 檢查是否取得金鑰
        guard let idToken = user?.idToken, let accessToken = user?.accessToken else {
            print("無法取得使用者金鑰")
            return
        }

        // 使用金鑰建立登入憑證
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        // 登入firebase，取得使用者
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                print("授權失敗: \(error.localizedDescription)")
            }
            guard let user = result?.user else {
                print("無法取得使用者")
                return
            }
            self.state = .signedIn(user)
        }
    }

    // 登出
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }

    // 斷開程式連結，完成後登出
    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error {
                print("與應用程式端開連結時發生錯誤: \(error)")
            }
            self.signOut()
        }
    }

    func getBioMetricStatus() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: .none)
    }

    func authenticateUser() async throws {
        let reason = "To Login Into App"
        let success = try await LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        if success {
            signIn()
        }
    }
}

extension LoginViewModel {
    enum State {
        case signedIn(User)
        case signedOut
    }
}
