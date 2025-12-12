/*
 * Copyright (C) 2022 Yubico.
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

struct ConfigurationView: View {
    @StateObject var model = ConfigurationViewModel()
    @State var showInsertYubiKey = false
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
        NavigationStack {
            List {
                if model.deviceInfo == nil {
                    VStack(spacing: 16) {
                        ZStack {
                            ForEach(0..<8, id: \.self) { index in
                                Circle()
                                    .fill(Color("YubiGreen").opacity(0.3))
                                    .frame(width: 4, height: 4)
                                    .modifier(ParticleModifier(index: index))
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
                        .accessibilityHidden(true)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                glowOpacity = 1.0
                            }
                        }

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
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                
                if let deviceInfo = model.deviceInfo {
                    Section(" ") {
                        VStack(alignment: .center) {
                            if let image = deviceInfo.deviceImage {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 150)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        if let deviceInfo = model.deviceInfo {
                            HStack {
                                ListIconView(image: Image("yubikey"), color: Color(.systemGray))
                                Text("Device type")
                                Spacer()
                                Text(deviceInfo.deviceName).foregroundStyle(.secondary)
                            }
                            HStack {
                                ListIconView(image: Image(systemName: "number"), color: Color(.systemGray), padding: 7)
                                Text("Serial number")
                                Spacer()
                                Text(String(deviceInfo.serialNumber)).foregroundStyle(.secondary)
                            }
                            HStack {
                                ListIconView(image: Image(systemName: "cpu"), color: Color(.systemGray), padding: 5)
                                Text("Firmware version")
                                Spacer()
                                Text(deviceInfo.version.description).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section("GENERAL") {
                    NavigationLink {
                        OTPConfigurationView()
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle("Toggle One-Time Password")
                            .onDisappear {
                                model.start()
                            }
                    } label: {
                        ListIconView(image: Image(systemName: "ellipsis.rectangle"), color: Color(.systemBlue))
                        Text("Toggle One-Time Password")
                    }
                    .liquidGlassListRowButton()
                    
                    if YubiKitDeviceCapabilities.supportsNFCScanning {
                        NavigationLink {
                            NFCSettingsView()
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationTitle("NFC settings")
                                .onDisappear {
                                    model.start()
                                }
                        } label: {
                            ListIconView(image: Image(systemName: "dot.radiowaves.left.and.right"), color: Color(.systemBlue))
                            Text("NFC settings")
                        }
                        .liquidGlassListRowButton()
                    }
                }
                Section("OATH") {
                    NavigationLink {
                        OATHPasswordView()
                            .onDisappear {
                                model.start()
                            }
                    } label: {
                        ListIconView(image: Image(systemName: "lock.shield"), color: Color(.systemPurple))
                        Text("Manage password")
                    }
                    .liquidGlassListRowButton()
                    
                    NavigationLink {
                        OATHSavedPasswordsView()
                    } label: {
                        ListIconView(image: Image(systemName: "xmark.circle"), color: Color(.systemPink), padding: 5)
                        Text("Clear saved passwords")
                    }
                    .liquidGlassListRowButton()
                    
                    NavigationLink {
                        OATHResetView()
                            .onDisappear {
                                model.start()
                            }
                    } label: {
                        ListIconView(image: Image(systemName: "trash"), color: Color(.systemRed), padding: 5)
                        Text("Reset OATH application")
                    }
                    .liquidGlassListRowButton()
                }
                if YubiKitDeviceCapabilities.supportsMFIAccessoryKey || YubiKitDeviceCapabilities.supportsISO7816NFCTags {
                    Section("FIDO") {
                        NavigationLink {
                            FIDOPINView()
                                .onDisappear {
                                    model.start()
                                }
                        } label: {
                            ListIconView(image: Image(systemName: "lock.shield"), color: Color(.systemPurple))
                            Text("Manage PIN")
                        }
                        .liquidGlassListRowButton()
                        
                        NavigationLink {
                            FIDOResetView {
                                Task.detached { @MainActor in
                                    model.start()
                                }
                            }
                        } label: {
                            ListIconView(image: Image(systemName: "trash"), color: Color(.systemRed), padding: 5)
                            Text("Reset FIDO application")
                        }
                        .liquidGlassListRowButton()
                    }
                }
                Section("PIV") {
                    NavigationLink {
                        SmartCardConfigurationView()
                            .onDisappear {
                                model.start()
                            }
                    } label: {
                        ListIconView(image: Image(systemName: "creditcard"), color: Color(.systemOrange))
                        Text("Smart card extension")
                    }
                    .liquidGlassListRowButton()
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.background))
            .navigationTitle(String(localized: "Configuration", comment: "Configuration navigation title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if UIAccessibility.isVoiceOverRunning {
                        Button("Scan NFC YubiKey") {
                            model.scanNFC()
                        }
                    }
                }
            }
        }
        .onChange(of: model.deviceInfo) { _ in
            withAnimation {
                showInsertYubiKey = model.deviceInfo == nil
            }
        }
        .onAppear {
            withAnimation {
                showInsertYubiKey = model.deviceInfo == nil
            }

            model.start()
        }
        .refreshable(enabled: YubiKitDeviceCapabilities.supportsISO7816NFCTags) {
            model.scanNFC()
        }
    }
}

// MARK: - Particle Animation

struct ParticleModifier: ViewModifier {
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

// MARK: - List Icon View

struct ListIconView: View {
    var image: Image
    var color: Color
    var padding: CGFloat = 4.3

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .font(Font.title.weight(.semibold))
            .padding(padding)
            .frame(width: 29, height: 29)
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(10)
            .padding(.leading, 0)
    }
}

extension YKFManagementDeviceInfo {
    var deviceName: String {

        let deviceName: String
        switch formFactor {
        case .usbaKeychain:
            let name: String
            if version.major == 5 { name = "5" } else
            if version.major < 4 { name = "NEO" }
            else { name = "" }
            deviceName = "YubiKey \(name) NFC"
            break
        case .usbcKeychain:
            deviceName = "YubiKey 5C NFC"
        case .usbcLightning:
            deviceName = "YubiKey 5Ci"
        case .usbcBio, .usbaBio:
            deviceName = "YubiKey Bio"
        case .usbcNano:
            deviceName = "YubiKey Nano"
        default:
            return "Unknown key"
        }

        if (isFIPSCapable != 0) || isFips {
            return deviceName + " FIPS"
        } else {
            return deviceName
        }
    }
    
    var deviceImage: Image? {
        switch formFactor {
        case .usbaKeychain:
            return Image("yk5nfc")
        case .usbcKeychain:
            return Image("yk5cnfc")
        case .usbcLightning:
            return Image("yk5ci")
        case .usbcBio:
            return Image("ykbioc")
        case .usbaBio:
            return Image("ykbioa")
        default:
            return nil
        }
    }
}
