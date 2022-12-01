//
//  LoginView.swift
//  TomatoClock
//
//  Created by 程信傑 on 2022/11/30.
//

import SwiftUI

struct LoginView: View {
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
            
            // 臉部辨識
            // 先檢查裝置是否支援生物辨識，如果有支援才繼續
            Group {
                if useFaceId {
                    Button {
                        // 執行臉部辨識流程
                    } label: {
                        VStack(alignment: .leading) {
                            Label("Use FaceId to Login", systemImage: "faceid")
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
            
            // 登入按鈕
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
            .scenePadding(.vertical)
            // 如果帳號或密碼欄位還尚未輸入，就暫時取消按鈕行為
            .disabled(email == "" || password == "")
            .opacity(email == "" || password == "" ? 0.5 : 1)
            
            // 也提供訪客試用，不用帳密登入直接進入首頁使用功能
            Button {} label: {
                Text("Skip Now")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

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
        LoginView()
    }
}
