/*
 * Copyright (C) Yubico.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import SwiftUI

struct RootTabView: View {
    
    @State private var selectedTab = 0
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Label("Accounts", systemImage: "person.crop.circle")
                }
                .tag(0)
            
            ConfigurationView()
                .tabItem {
                    Label("Configuration", systemImage: "switch.2")
                }
                .tag(1)
                .onAppear {
                    mainViewModel.stop()
                }
                .onDisappear {
                    mainViewModel.start()
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
                .onAppear {
                    mainViewModel.stop()
                }
                .onDisappear {
                    mainViewModel.start()
                }
        }
        .environmentObject(mainViewModel)
    }
}

#Preview {
    RootTabView()
        .environmentObject(ToastPresenter())
        .environmentObject(NotificationsViewModel())
}
