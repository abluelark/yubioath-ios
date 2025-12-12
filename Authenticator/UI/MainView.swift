/*
 * Copyright (C) Yubico.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import SwiftUI
import Combine

struct MainView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var toastPresenter: ToastPresenter
    @EnvironmentObject var notificationsViewModel: NotificationsViewModel
    
    @EnvironmentObject var model: MainViewModel
    @State var showAccountDetails: AccountDetailsData? = nil
    @State var showAddAccount: Bool = false
    @State var addAccountCancellable: AnyCancellable?
    @State var addAccountSubject = PassthroughSubject<(YKFOATHCredentialTemplate?, Bool), Never>()
    @State var password: String = ""
    @State var searchText: String = ""
    @State var didEnterBackground = true
    @State var otp: String? = nil
    @State var oathURL: URL? = nil
    @State var isSearching: Bool = false // Initial state is FALSE (hidden)
    @State var shakeAddButton: Bool = false
    @State var shakeSearchButton: Bool = false
    
    var insertYubiKeyMessage = {
        if YubiKitDeviceCapabilities.supportsISO7816NFCTags {
            String(localized: "Insert YubiKey") + " " + "\(!UIAccessibility.isVoiceOverRunning ? String(localized: "or pull down to activate NFC") : String(localized: "or scan a NFC YubiKey"))"
        } else {
            String(localized: "Insert YubiKey")
        }
    }()
    
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                List {
                    // --- REPLACED COMPLEX LOGIC WITH NEW HELPER VIEW ---
                    AccountListView(
                        searchText: $searchText,
                        showAccountDetails: $showAccountDetails,
                        otp: otp,
                        insertYubiKeyMessage: insertYubiKeyMessage,
                        listHeight: reader.size.height
                    )
                    .environmentObject(model)
                    // --- END HELPER VIEW ---
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.background))
            .accessibilityHidden(showAccountDetails != nil)
            .if(isSearching) { view in
                view
                    .searchable(text: $searchText, isPresented: $isSearching, placement: .navigationBarDrawer, prompt: "Search accounts")
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
            }
            .refreshable(enabled: YubiKitDeviceCapabilities.supportsISO7816NFCTags) {
                otp = nil
                model.updateAccountsOverNFC()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if UIAccessibility.isVoiceOverRunning {
                        Button("Scan NFC YubiKey") {
                            otp = nil
                            model.updateAccountsOverNFC()
                        }
                    } else if !model.accountsLoaded {
                        Image("NavbarLogo")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 18)
                            .foregroundColor(Color("YubiGreen"))
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                
                // --- CUSTOM TOP-RIGHT TOOLBAR ITEMS ---
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // 1. Search Button (Toggles Search Bar Visibility)
                    Button {
                        if model.accountsLoaded {
                            isSearching.toggle()
                            if !isSearching {
                                searchText = "" // Clear search when closing
                            }
                        } else {
                            // No accounts loaded - show haptic feedback and shake
                            let haptic = UIImpactFeedbackGenerator(style: .medium)
                            haptic.impactOccurred()
                            withAnimation(.default.repeatCount(3).speed(6)) {
                                shakeSearchButton = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                shakeSearchButton = false
                            }
                        }
                    } label: {
                        Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                    }
                    .offset(x: shakeSearchButton ? 5 : 0)
                    
                    // 2. Add Account (+) Button
                    Button {
                        if YubiKitDeviceCapabilities.supportsISO7816NFCTags || model.isKeyPluggedIn {
                            showAddAccount.toggle()
                        } else {
                            // No YubiKey detected - show haptic feedback and shake
                            let haptic = UINotificationFeedbackGenerator()
                            haptic.notificationOccurred(.warning)
                            withAnimation(.default.repeatCount(3).speed(6)) {
                                shakeAddButton = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                shakeAddButton = false
                            }
                        }
                    } label: {
                        Label("Add account", systemImage: "plus")
                    }
                    .offset(x: shakeAddButton ? 5 : 0)
                }
            }
            // --- END CUSTOM TOP-RIGHT TOOLBAR ITEMS ---
            
            .navigationTitle(model.accountsLoaded ? String(localized: "Accounts", comment: "Navigation title in main view.") : "")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background(Color(UIColor.background).ignoresSafeArea())
        }
        .accessibilityHidden(showAccountDetails != nil)
        .overlay {
            if showAccountDetails != nil {
                AccountDetailsView(data: $showAccountDetails)
            }
        }
        .sheet(isPresented: $showAddAccount) {
            AddAccountView(showAddCredential: $showAddAccount, accountSubject: addAccountSubject, oathURL: oathURL)
        }
        .fullScreenCover(isPresented: $model.presentDisableOTP) {
            DisableOTPView()
                .onAppear {
                    model.stop()
                }.onDisappear {
                    model.start()
                }
        }
        .alert(String(localized: "Enter password", comment: "Password alert"), isPresented: $model.presentPasswordEntry) {
            SecureField(String(localized: "Password", comment: "Password alert"), text: $password)
            Button(String(localized: "Cancel", comment: "Password alert"), role: .cancel) { password = "" }
            Button(String(localized: "Ok", comment: "Password alert")) {
                model.password.send(password)
                password = ""
            }
        } message: {
            Text(model.passwordEntryMessage)
        }
        .alertOrConfirmationDialog(String(localized: "Save password?", comment: "Save password alert"), isPresented: $model.presentPasswordSaveType) {
            Button(String(localized: "Save password", comment: "Save password alert.")) { model.passwordSaveType.send(.some(.save)) }
            let authenticationType = PasswordPreferences.evaluatedAuthenticationType()
            if authenticationType != .none {
                Button(String(localized: "Save and protect with \(authenticationType.title)")) { model.passwordSaveType.send(.some(.lock)) }
            }
            Button(String(localized: "Never for this YubiKey", comment: "Save password alert.")) { model.passwordSaveType.send(.some(.never)) }
            Button(String(localized: "Not now", comment: "Save passsword alert"), role: .cancel) { model.passwordSaveType.send(nil) }
        }
        .errorAlert(error: $model.sessionError)
        .errorAlert(error: $model.connectionError) { model.start() }
        .onAppear {
            if ApplicationSettingsViewModel().isNFCOnAppLaunchEnabled {
                model.updateAccountsOverNFC()
            }
            addAccountCancellable = addAccountSubject.sink { (template, requiresTouch) in
                oathURL = nil
                if let template {
                    model.addAccount(template, requiresTouch: requiresTouch)
                }
            }
        }
        .onOpenURL(perform: { url in
            guard url.scheme == "otpauth" else { return }
            oathURL = url
            showAddAccount.toggle()
        })
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
            guard let otp = userActivity.webpageURL?.yubiOTP else { return }
            self.otp = otp
            if ApplicationSettingsViewModel().isNFCOnOTPLaunchEnabled {
                model.updateAccountsOverNFC()
            }
        })
        .onChange(of: otp) { otp in
            if let otp, SettingsConfig.isCopyOTPEnabled {
                toastPresenter.copyToClipboard(otp)
            }
        }
        .onChange(of: scenePhase) { phase in
            // Both the NFC and the Face ID scanning alerts make the app enter the `.inactive` state
            // and in that situation we don't want to call model.stop() nor model.closeConnections()
            if phase == .active && didEnterBackground {
                didEnterBackground = false

                model.start() // This is called when app becomes active
            } else if phase == .background {
                didEnterBackground = true

                let _ = UIApplication.shared.beginBackgroundTask { }
                model.stop()
                model.closeConnections()
            }
        }
        .onChange(of: model.showTouchToast) { showToast in
            if showToast {
                toastPresenter.toast(message: "Touch your YubiKey")
            }
        }
        .onChange(of: notificationsViewModel.showPIVTokenView) { showPIVTokenview in
            if showPIVTokenview {
                showAddAccount = false
                showAccountDetails = nil
            }
        }
        .onChange(of: model.isKeyPluggedIn) { isKeyPluggedIn in
            if !isKeyPluggedIn {
                // If the user removes the YubiKey while adding a new account we dismiss the add account modal.
                if showAddAccount {
                    showAddAccount = false
                }
                // If the user removes the YubiKey while viewing account details, dismiss the detail view.
                if showAccountDetails != nil {
                    showAccountDetails = nil
                }
                // *** FIX for search bar persistence ***
                if isSearching {
                    isSearching = false
                    searchText = ""
                }
                // *************************************
                
                // Restart the session monitoring to be ready for the next YubiKey insertion
                model.start()
            }
        }
        .environmentObject(model)
    }
}

// MARK: - AccountListView (Helper Struct to reduce compile time complexity)

private struct AccountListView: View {
    @EnvironmentObject var model: MainViewModel
    @Binding var searchText: String
    @Binding var showAccountDetails: AccountDetailsData?
    let otp: String?
    let insertYubiKeyMessage: String
    let listHeight: CGFloat
    
    // Helper property for filtering accounts
    var searchResults: [Account] {
        if searchText.isEmpty {
            return []
        } else {
            return model.accounts.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.subTitle?.lowercased().contains(searchText.lowercased()) == true
            }
        }
    }

    var body: some View {
        Group {
            if let otp {
                Section(header: Text("Yubico OTP").frame(maxWidth: .infinity, alignment: .leading).font(.title3.bold()).foregroundColor(Color("ListSectionHeaderColor"))) {
                    YubiOtpRowView(otp: otp)
                }
            }
            if !model.accountsLoaded {
                ListStatusView(image: Image("yubikey"), message: insertYubiKeyMessage, height: listHeight)
            } else if !searchText.isEmpty {
                if searchResults.isEmpty {
                    ListStatusView(image: Image(systemName: "magnifyingglass"), message: "No results for \"\(searchText)\"", height: listHeight)
                } else {
                    ForEach(searchResults, id: \.id) { account in
                        AccountRowView(account: account, showAccountDetails: $showAccountDetails)
                    }
                }
            } else if model.pinnedAccounts.count > 0 {
                Section(header: Text("Pinned").frame(maxWidth: .infinity, alignment: .leading).font(.title3.bold()).foregroundColor(Color("ListSectionHeaderColor"))) {
                    ForEach(model.pinnedAccounts, id: \.id) { account in
                        AccountRowView(account: account, showAccountDetails: $showAccountDetails)
                    }
                }
                if model.otherAccounts.count > 0 {
                    Section(header: Text("Other").frame(maxWidth: .infinity, alignment: .leading).font(.title3.bold()).foregroundColor(Color("ListSectionHeaderColor"))) {
                        ForEach(model.otherAccounts, id: \.id) { account in
                            AccountRowView(account: account, showAccountDetails: $showAccountDetails)
                        }
                    }
                }
            } else if model.accounts.count > 0 && otp != nil {
                Section(header: Text("Accounts").frame(maxWidth: .infinity, alignment: .leading).font(.title3.bold()).foregroundColor(Color("ListSectionHeaderColor"))) {
                    ForEach(model.otherAccounts, id: \.id) { account in
                        AccountRowView(account: account, showAccountDetails: $showAccountDetails)
                    }
                }
            } else if model.accounts.count > 0 {
                ForEach(model.accounts, id: \.id) { account in
                    AccountRowView(account: account, showAccountDetails: $showAccountDetails)
                }
            } else {
                ListStatusView(image: Image(systemName: "person.crop.circle"), message: String(localized: "No accounts on YubiKey"), height: listHeight)
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Conditionally applies a modifier to a view
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func alertOrConfirmationDialog<A>(_ title: String, isPresented: Binding<Bool>, @ViewBuilder actions: () -> A) -> some View where A : View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return AnyView(erasing: self.alert(title, isPresented: isPresented, actions: actions))
        } else {
            return AnyView(erasing: self.confirmationDialog(title, isPresented: isPresented, titleVisibility: .visible, actions: actions))
        }
    }
}

extension URL {
    
    var yubiOTP: String? {
        if self.scheme == "https" && self.host == "my.yubico.com" {
            var otp: String
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
            if let fragment = components?.fragment {
                otp = fragment
            } else {
                otp = self.lastPathComponent
            }
            return otp
        } else {
            return nil
        }
    }
}
