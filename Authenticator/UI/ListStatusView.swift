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

struct ListStatusView: View {
    
    let image: Image
    let message: String
    let height: CGFloat
    @State var showWhatsNew = false
    @State private var glowOpacity: Double = 0.6
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 20) {
                Spacer()
                
                // Liquid Glass container for icon
                ZStack {
                    // Floating particles (ambient effect from HTML)
                    ForEach(0..<12, id: \.self) { index in
                        Circle()
                            .fill(Color("YubiGreen").opacity(0.3))
                            .frame(width: 3, height: 3)
                            .modifier(AmbientParticleModifier(index: index))
                    }
                    
                    // Glass background (lighter, more prominent)
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 180, height: 180)
                    
                    // Breathing glow animation
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color("YubiGreen").opacity(0.25 * glowOpacity),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                    
                    // Border for definition with subtle pulse
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15 * glowOpacity), lineWidth: 1)
                        .frame(width: 180, height: 180)
                    
                    image
                        .font(.system(size: 100.0))
                        .foregroundColor(Color("YubiGreen"))
                        .accessibilityHidden(true)
                }
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                    ) {
                        glowOpacity = 1.0
                    }
                }
                
                VStack(spacing: 8) {
                    Text(message)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                if SettingsConfig.showWhatsNewText {
                    WhatsNewView(showWhatsNew: $showWhatsNew)
                }
            }
            Spacer()
        }
        .frame(height: height - 100)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .sheet(isPresented: $showWhatsNew) {
            NavigationView {
                VersionHistoryView(presentedFromMainView: true)
                    .navigationTitle(String(localized: "What's new", comment: "About navigation title"))

            }
        }
    }
}

// MARK: - Ambient Particle Animation (from HTML mockup)

struct AmbientParticleModifier: ViewModifier {
    let index: Int
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0.3
    
    private var animationDelay: Double {
        Double(index) * 0.3
    }
    
    private var animationDuration: Double {
        3.0 + Double.random(in: 0...2)
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: offsetX, y: offsetY)
            .opacity(opacity)
            .onAppear {
                // Random starting position
                offsetX = CGFloat.random(in: -100...100)
                offsetY = CGFloat.random(in: -100...100)
                
                withAnimation(
                    .easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true)
                    .delay(animationDelay)
                ) {
                    offsetX = CGFloat.random(in: -100...100)
                    offsetY = CGFloat.random(in: -120...(-80))
                    opacity = 0.6
                }
            }
    }
}

struct WhatsNewView: View {
    
    var text: AttributedString {
        var see = AttributedString(localized: "See ", comment: "Substring in \"See what's new in this version\"")
        see.foregroundColor = .secondaryLabel
        var whatsNew = AttributedString(localized: "what's new", comment: "Substring in \"See what's new in this version\"")
        whatsNew.foregroundColor = .label
        var inThisVersion = AttributedString(localized: " in this version", comment: "Substring in \"See what's new in this version\"")
        inThisVersion.foregroundColor = .secondaryLabel
        return see + whatsNew + inThisVersion
    }
    
    @Binding var showWhatsNew: Bool

    var body: some View {
        Button {
            showWhatsNew.toggle()
        } label: {
            Text(text).font(.footnote)
        }
    }
}

struct ListStatusViewView_Previews: PreviewProvider {
    static var previews: some View {
        ListStatusView(image: Image(systemName: "figure.surfing"), message: "Gone surfing, will be back tomorrow", height: 300)
    }
}
