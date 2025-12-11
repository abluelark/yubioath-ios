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

struct SearchAccountsView: View {
    
    @EnvironmentObject var model: MainViewModel
    @EnvironmentObject var toastPresenter: ToastPresenter
    @State private var searchText: String = ""
    @State var showAccountDetails: AccountDetailsData? = nil
    
    var searchResults: [Account] {
        if searchText.isEmpty {
            return model.accounts
        } else {
            return model.accounts.filter { 
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.subTitle?.lowercased().contains(searchText.lowercased()) == true 
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if model.accountsLoaded {
                    GlassEffectContainer(spacing: 16.0) {
                        LazyVStack(spacing: 16) {
                            if searchResults.isEmpty {
                                ContentUnavailableView.search(text: searchText)
                                    .padding(.top, 100)
                            } else {
                                ForEach(searchResults, id: \.id) { account in
                                    AccountRowView(account: account, showAccountDetails: $showAccountDetails)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    ContentUnavailableView(
                        "No YubiKey Connected",
                        systemImage: "key.slash",
                        description: Text("Insert your YubiKey to search accounts")
                    )
                    .padding(.top, 100)
                }
            }
            .searchable(
                text: $searchText,
                placement: .toolbar,
                prompt: "Search accounts"
            )
            .autocorrectionDisabled(true)
            .keyboardType(.asciiCapable)
            .navigationTitle("Search")
        }
        .overlay {
            if showAccountDetails != nil {
                AccountDetailsView(data: $showAccountDetails)
            }
        }
    }
}

#Preview {
    SearchAccountsView()
        .environmentObject(MainViewModel())
        .environmentObject(ToastPresenter())
}
