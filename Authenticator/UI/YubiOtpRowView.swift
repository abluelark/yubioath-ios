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


struct YubiOtpRowView: View {

    @EnvironmentObject var toastPresenter: ToastPresenter
    var otp: String
    
    var body: some View {
        HStack(spacing: 12) {
            // YubiKey icon
            Image("yubikey")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .frame(width: 50, height: 50)
                .background(Color.accentColor)
                .clipShape(Circle())
            
            // OTP value
            VStack(alignment: .leading, spacing: 2) {
                Text("Yubico OTP")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(otp)
                    .font(.system(size: 13, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Copy indicator
            Image(systemName: "doc.on.doc")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .modifier(OTPRowGlassModifier())
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .onTapGesture {
            toastPresenter.copyToClipboard(otp)
        }
        .onLongPressGesture {
            toastPresenter.copyToClipboard(otp)
        }
    }
}

// MARK: - Glass Effect Modifier with Fallback

/// Applies Liquid Glass effect to OTP row with fallback for iOS < 26
struct OTPRowGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(in: .rect(cornerRadius: 16))
        } else {
            content
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.regularMaterial)
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(.separator.opacity(0.2), lineWidth: 0.5)
                    }
                )
        }
    }
}
