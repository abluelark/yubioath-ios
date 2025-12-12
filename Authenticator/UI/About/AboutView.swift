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

struct AboutView: View {
    
    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .center) {
                        Image(.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .padding(15)
                            .accessibilityHidden(true)
                        Text("Yubico Authenticator")
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Text("\(UIApplication.appVersion) (build \(UIApplication.appBuildNumber))")
                            .font(.body)
                        AboutLanguageView()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                Section("Application") {
                    NavigationLink {
                        TutorialView()
                    } label: {
                        ListIconView(image: Image(systemName: "lightbulb"), color: Color(.systemOrange))
                        Text("How does it work")
                    }
                    .liquidGlassListRowButton()
                    
                    NavigationLink {
                        VersionHistoryView(presentedFromMainView: false)
                            .navigationTitle(String(localized: "Version history", comment: "About navigation title"))
                    } label: {
                        ListIconView(image: Image(systemName: "list.clipboard"), color: Color(.systemGreen))
                        Text("Version history")
                    }
                    .liquidGlassListRowButton()
                    
                    Button {
                        UIApplication.shared.open(URL(string: "https://www.yubico.com/support/terms-conditions/yubico-license-agreement/")!)
                    } label: {
                        HStack {
                            ListIconView(image: Image(systemName: "doc.text"), color: Color(.secondaryLabel))
                            Text("Terms of use")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .liquidGlassListRowButton()
                    
                    Button {
                        UIApplication.shared.open(URL(string: "https://www.yubico.com/support/terms-conditions/privacy-notice/")!)
                    } label: {
                        HStack {
                            ListIconView(image: Image(systemName: "person.badge.shield.checkmark"), color: Color(.secondaryLabel))
                            Text("Privacy policy")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .liquidGlassListRowButton()
                    
                    NavigationLink {
                        LicensingView()
                    } label: {
                        HStack {
                            ListIconView(image: Image(systemName: "doc.text"), color: Color(.secondaryLabel))
                            Text("Licensing")
                        }
                    }
                    .liquidGlassListRowButton()
                }
                Section("Support") {
                    Button {
                        UIApplication.shared.open(URL(string: "https://docs.yubico.com/software/yubikey/tools/authenticator/auth-guide/index.html")!)
                    } label: {
                        HStack {
                            ListIconView(image: Image(systemName: "book"), color: Color(.systemPink))
                            Text("User guide")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .liquidGlassListRowButton()
                    
                    Button {
                        UIApplication.shared.open(URL(string: "https://support.yubico.com/support/tickets/new")!)
                    } label: {
                        HStack {
                            ListIconView(image: Image(systemName: "person.crop.circle.badge.questionmark"), color: Color(.systemRed))
                            Text("Contact support")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .liquidGlassListRowButton()
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.background))
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct AboutLanguageView: View {
    
    var shouldShowLanguageNote: Bool {
        guard let langCode = Bundle.main.preferredLocalizations.first else { return false }
        return langCode.lowercased() == "sk"
    }
    
    var body: some View {
        if shouldShowLanguageNote {
            Text("This translation is a community effort, please visit [crowdin.com](https://crowdin.com/project/yubico-authenticator-ios) to contribute.")
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 15)
        } else {
            EmptyView()
        }
    }
    
}
