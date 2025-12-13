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
            ZStack {
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
                .task {
                    // Start immediately when the view appears - task runs on MainActor
                    mainViewModel.start()
                }
                .onAppear {
                    YubiKitExternalLocalization.nfcScanAlertMessage = String(localized: "Scan your YubiKey", comment: "iOS NFC alert scan")
                    YubiKitExternalLocalization.nfcScanSuccessAlertMessage = String(localized: "Success", comment: "iOS NFC alert default success message")
                }
                
                // Full-screen overlay when no accounts are loaded
                if !mainViewModel.accountsLoaded {
                    InsertYubiKeyOverlay()
                        .environmentObject(mainViewModel)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: mainViewModel.accountsLoaded)
            .onChange(of: scenePhase) { newPhase in
                // Handle app lifecycle at the top level
                if newPhase == .background {
                    mainViewModel.stop()
                    mainViewModel.closeConnections()
                } else if newPhase == .active {
                    // Restart monitoring when app becomes active
                    Task {
                        mainViewModel.start()
                    }
                }
            }
        }
    }
}

// MARK: - Insert YubiKey Overlay

struct InsertYubiKeyOverlay: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var glowOpacity = 0.6
    
    var insertYubiKeyMessage: String {
        if YubiKitDeviceCapabilities.supportsISO7816NFCTags {
            let nfcMessage = UIAccessibility.isVoiceOverRunning
                ? String(localized: "or scan a NFC YubiKey")
                : String(localized: "or pull down to activate NFC")
            return String(localized: "Insert YubiKey") + " " + nfcMessage
        } else {
            return String(localized: "Insert YubiKey")
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.background)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated YubiKey icon
                ZStack {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color("YubiGreen").opacity(0.3))
                            .frame(width: 4, height: 4)
                            .modifier(InsertKeyParticleModifier(index: index))
                    }
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color("YubiGreen").opacity(0.25 * glowOpacity),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15 * glowOpacity), lineWidth: 1)
                        .frame(width: 140, height: 140)
                    
                    Image("yubikey")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("YubiGreen"))
                }
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        glowOpacity = 1.0
                    }
                }
                
                // Message
                VStack(spacing: 8) {
                    Text(insertYubiKeyMessage)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    if YubiKitDeviceCapabilities.supportsISO7816NFCTags {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Pull down to scan with NFC")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .opacity(0.8)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .conditionalRefreshable(enabled: YubiKitDeviceCapabilities.supportsISO7816NFCTags) {
            mainViewModel.updateAccountsOverNFC()
        }
    }
}

// MARK: - Particle Animation for Insert Key Overlay

struct InsertKeyParticleModifier: ViewModifier {
    let index: Int
    @State private var isAnimating = false

    private var angle: Double {
        Double(index) * (360.0 / 8.0)
    }

    private var radius: CGFloat {
        isAnimating ? 90 : 70
    }

    private var opacity: Double {
        isAnimating ? 0.0 : 0.6
    }

    func body(content: Content) -> some View {
        content
            .offset(
                x: cos(angle * .pi / 180) * radius,
                y: sin(angle * .pi / 180) * radius
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
                    .delay(Double(index) * 0.15)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Conditional Refreshable Extension

extension View {
    func conditionalRefreshable(enabled: Bool, action: @escaping () async -> Void) -> some View {
        if enabled {
            return AnyView(self.refreshable { await action() })
        } else {
            return AnyView(self)
        }
    }
}
