//
//  SearchAccountsView.swift
//  Authenticator
//
//  Created by Asher Clark on 12/10/25.
//  Copyright © 2025 Yubico. All rights reserved.
//


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
            Group {
                if !model.accountsLoaded {
                    ContentUnavailableView(
                        "No YubiKey Connected",
                        systemImage: "",
                        description: Text("Insert your YubiKey to search accounts")
                    )
                } else if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Accounts",
                        systemImage: "magnifyingglass",
                        description: Text("Type to search your accounts")
                    )
                } else if searchResults.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(searchResults, id: \.id) { account in
                                AccountRowView(account: account, showAccountDetails: $showAccountDetails)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search accounts")
            .autocorrectionDisabled(true)
            .keyboardType(.asciiCapable)
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