//
//  ContentView.swift
//  TomatoClock
//
//  Created by 程信傑 on 2022/11/28.
//

import SwiftUI

struct ContentView: View {
    @State var loginStatus: Bool = true

    var body: some View {
        VStack {
            if loginStatus {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
