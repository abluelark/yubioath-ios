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
import YubiKit

@main
struct AuthenticatorApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject var toastPresenter = ToastPresenter()
    @StateObject var notificationsViewModel = NotificationsViewModel()
    @StateObject var mainViewModel = MainViewModel()
    
    init() {
        // Configure Navigation Bar appearance BEFORE views are created
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 0.094, green: 0.188, blue: 0.161, alpha: 1.0)
        
        // Set text colors to WHITE for visibility against forest green
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // Also set button/icon tint to white
        navBarAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Make buttons white too
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // CRITICAL: Also set this to ensure the appearance is fully adopted
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = navBarAppearance
        }
        
        // Configure Tab Bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 0.094, green: 0.188, blue: 0.161, alpha: 1.0)
        
        let yubiGreen = UIColor(named: "YubiGreen") ?? UIColor.systemGreen
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .secondaryLabel
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        itemAppearance.selected.iconColor = yubiGreen
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: yubiGreen]
        
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = yubiGreen
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MainView()
                    .tabItem {
                        Label("Accounts", systemImage: "person.crop.circle")
                    }
                
                ConfigurationView()
                    .tabItem {
                        Label("Configuration", systemImage: "gearshape.2")
                    }
                
                AboutView()
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
            }
            .preferredColorScheme(.dark)
            .toast(isPresenting: $toastPresenter.isPresenting, message: toastPresenter.message)
            .fullScreenCover(isPresented: $notificationsViewModel.showPIVTokenView) {
                TokenRequestView(userInfo: notificationsViewModel.userInfo)
            }
            .transaction { transaction in
                transaction.disablesAnimations = notificationsViewModel.showPIVTokenView
            }
            .environmentObject(toastPresenter)
            .environmentObject(notificationsViewModel)
            .environmentObject(mainViewModel)
            .onAppear {
                YubiKitExternalLocalization.nfcScanAlertMessage = String(localized: "Scan your YubiKey", comment: "iOS NFC alert scan")
                YubiKitExternalLocalization.nfcScanSuccessAlertMessage = String(localized: "Success", comment: "iOS NFC alert default success message")
            }
        }
    }
}

