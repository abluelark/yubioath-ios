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


struct AccountRowView: View {

    @EnvironmentObject var toastPresenter: ToastPresenter
    @ObservedObject var account: Account
    @Binding var showAccountDetails: AccountDetailsData?
    @State private var contentSize: CGSize = .zero
    @State private var estimatedCodeFrame: CGRect = .zero
    @State private var codeFrame: CGRect = .zero
    @State private var statusIconFrame: CGRect = .zero
    @State private var cellFrame: CGRect = .zero
    @State private var titleFrame: CGRect = .zero
    @State private var subTitleFrame: CGRect = .zero

    @State private var pillScaling: CGFloat = 1.0
    @State private var pillOpacity: Double

    @State private var animate: Bool = true

    private let pillColor = Color(.secondaryLabel)
    
    init(account: Account, showAccountDetails: Binding<AccountDetailsData?>) {
        self.account = account
        self._showAccountDetails = showAccountDetails
        if account.state == .expired || account.otp == nil {
            self.pillOpacity = 0.5
        } else {
            self.pillOpacity = 1.0
        }
    }

    var body: some View {
            HStack(spacing: 12) {
                // Icon
                Text(String(account.title.first ?? "?"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(account.iconColor)
                    .clipShape(Circle())
                    .accessibilityHidden(true)
                
                // Account info
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.title)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                        .readFrame($titleFrame)
                    
                    account.subTitle.map {
                        Text($0)
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                            .readFrame($subTitleFrame)
                    }
                }
                
                Spacer(minLength: 8)
                
                // Code pill bubble
                HStack(spacing: 8) {
                    // Status icon
                    switch(account.state) {
                    case .requiresCalculation, .expired:
                        if !account.requiresTouch {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 20))
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.secondary)
                                .readFrame($statusIconFrame)
                                .accessibilityHidden(true)
                        } else {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 18))
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.secondary)
                                .readFrame($statusIconFrame)
                                .accessibilityHidden(true)
                        }
                    case .countingdown(let remaining):
                        PieProgressView(progress: remaining,
                                        color: .secondary,
                                        animate: animate)
                            .frame(width: 20, height: 20)
                            .readFrame($statusIconFrame)
                            .accessibilityHidden(true)
                    }
                    
                    // Code text
                    ZStack {
                        if let otp = account.formattedCode {
                            Text(otp)
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.primary)
                                .readFrame($codeFrame)
                        } else {
                            Text("*** ***")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        Text("888 888")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.clear)
                            .readFrame($estimatedCodeFrame)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .modifier(CodePillGlassModifier())
                .opacity(pillOpacity)
                .scaleEffect(pillScaling)
                .accessibilityElement()
                .accessibilityLabel(account.state == .expired ? String(localized: "Code expired", comment: "Accessibility label") : account.formattedCode ?? String(localized: "Code not calculated", comment: "Accessibility label"))
                .accessibilityAddTraits(.isButton)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .modifier(RowGlassModifier())
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .onTapGesture {
                let data = AccountDetailsData(account: account,
                                              estimatedCodeFrame: estimatedCodeFrame,
                                              codeFrame: codeFrame,
                                              statusIconFrame: statusIconFrame,
                                              cellFrame: cellFrame,
                                              titleFrame: titleFrame,
                                              subTitleFrame: subTitleFrame)
                showAccountDetails = data
            }
            .onChange(of: account.state) { state in
                // Not sure why we have to schedule this in the next runloop
                DispatchQueue.main.async {
                    withAnimation {
                        if state == .expired || account.otp == nil {
                            pillOpacity = 0.5
                        } else {
                            pillOpacity = 1.0
                        }
                    }
                }
            }
            .onLongPressGesture {
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.1)) {
                        pillScaling = 1.4
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            pillScaling = 1.0
                        }
                    }
                }

                if account.state != .expired, let otp = account.otp?.code {
                    toastPresenter.copyToClipboard(otp)
                } else {
                    account.calculate { otp in
                        toastPresenter.copyToClipboard(otp.code)
                    }
                }
            }
            .onAppear() {
                animate = true
            }
            .onDisappear {
                animate = false
            }
            .readFrame($cellFrame)
    }
}

struct PieProgressView: View {
    
    let progress: Double
    let color: Color
    let animate: Bool

    init(progress: Double, color: Color, animate: Bool = true) {
        self.progress = progress
        self.color = color
        self.animate = animate
    }

    var body: some View {
        var duration = progress >= 1.0 ? 0.0 : 1.0
        duration = animate ? duration : 0.0
        return PieShape(progress: self.progress)
            .foregroundColor(color)
            .animation(.linear(duration: duration), value: self.progress)
    }
}

private struct PieShape: Shape {

    var animatableData: Double {
        get { self.progress }
        set { self.progress = newValue }
    }
    
    var progress: Double = 0.0
    private let start: Double = Double.pi * 1.5
    private var end: Double {
        get {
            return self.start - Double.pi * 2 * self.progress
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center =  CGPoint(x: rect.size.width / 2, y: rect.size.width / 2)
        let radius = rect.size.width / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: Angle(radians: start), endAngle: Angle(radians: end), clockwise: true)
        path.closeSubpath()
        return path
    }
}

// MARK: - Glass Effect Modifiers with Fallback

/// Applies Liquid Glass effect to row container with fallback for iOS < 26
struct RowGlassModifier: ViewModifier {
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

/// Applies Liquid Glass effect to code pill with fallback for iOS < 26
struct CodePillGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(in: .capsule)
        } else {
            content
                .background(
                    ZStack {
                        Capsule()
                            .fill(.regularMaterial)
                        Capsule()
                            .strokeBorder(.separator.opacity(0.3), lineWidth: 0.5)
                    }
                )
        }
    }
}
