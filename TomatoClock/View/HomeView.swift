//
//  HomeView.swift
//  TomatoClock
//
//  Created by 程信傑 on 2022/11/30.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var loginModel: LoginViewModel

    var body: some View {
        switch loginModel.state {
        case .signedIn(let user):
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Text(user.email ?? "")

                Button {
                    loginModel.signOut()
                } label: {
                    Text("登出")
                }
            }
        case .signedOut:
            Text("訪客頁面")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LoginViewModel())
    }
}
