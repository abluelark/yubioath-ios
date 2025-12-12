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

// MARK: - Liquid Glass List Row Button Style
/// A button style for list rows that implements Liquid Glass design principles.
/// Use for navigation-style buttons in Lists (like in Configuration and About screens).
struct LiquidGlassListRowButtonStyle: ButtonStyle {
    @State private var isPressed = false
    @State private var glowOpacity: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                // Internal glow effect
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor.opacity(0.15),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .opacity(glowOpacity)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                withAnimation(.easeOut(duration: pressed ? 0.12 : 0.35)) {
                    isPressed = pressed
                    glowOpacity = pressed ? 1.0 : 0.0
                }
            }
    }
}

// MARK: - Liquid Glass Primary Action Button Style
/// A prominent button style for primary actions with Liquid Glass effects.
/// Use for important actions like "Add Account", "Save", "Continue", etc.
struct LiquidGlassPrimaryButtonStyle: ButtonStyle {
    @State private var isPressed = false
    @State private var glowIntensity: Double = 0.0
    var tintColor: Color = .accentColor
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Base gradient
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    tintColor,
                                    tintColor.opacity(0.85)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Internal glow on press
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4 * glowIntensity),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                    
                    // Highlight overlay
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: tintColor.opacity(0.3), radius: 8, y: 4)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                withAnimation(.easeOut(duration: pressed ? 0.1 : 0.4)) {
                    isPressed = pressed
                    glowIntensity = pressed ? 1.0 : 0.0
                }
            }
    }
}

// MARK: - Liquid Glass Secondary Button Style
/// A subtle button style for secondary actions with Liquid Glass material.
/// Use for less prominent actions like "Cancel", "Skip", etc.
struct LiquidGlassSecondaryButtonStyle: ButtonStyle {
    @State private var isPressed = false
    @State private var glowOpacity: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Glass material base
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.regularMaterial)
                    
                    // Internal glow
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.accentColor.opacity(0.2 * glowOpacity),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                    
                    // Border with lensing
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.separator.opacity(0.5), lineWidth: 1)
                }
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                withAnimation(.easeOut(duration: pressed ? 0.1 : 0.4)) {
                    isPressed = pressed
                    glowOpacity = pressed ? 1.0 : 0.0
                }
            }
    }
}

// MARK: - Liquid Glass Destructive Button Style
/// A button style for destructive actions with Liquid Glass effects.
/// Use for dangerous actions like "Delete", "Reset", "Remove", etc.
struct LiquidGlassDestructiveButtonStyle: ButtonStyle {
    @State private var isPressed = false
    @State private var glowIntensity: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Base gradient
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.red,
                                    Color.red.opacity(0.85)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Internal glow on press
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4 * glowIntensity),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                    
                    // Highlight overlay
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: Color.red.opacity(0.3), radius: 8, y: 4)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                withAnimation(.easeOut(duration: pressed ? 0.1 : 0.4)) {
                    isPressed = pressed
                    glowIntensity = pressed ? 1.0 : 0.0
                }
            }
    }
}

// MARK: - View Extensions for Easy Application
extension View {
    /// Applies Liquid Glass list row button style
    func liquidGlassListRowButton() -> some View {
        self.buttonStyle(LiquidGlassListRowButtonStyle())
    }
    
    /// Applies Liquid Glass primary action button style
    func liquidGlassPrimaryButton(tintColor: Color = .accentColor) -> some View {
        self.buttonStyle(LiquidGlassPrimaryButtonStyle(tintColor: tintColor))
    }
    
    /// Applies Liquid Glass secondary button style
    func liquidGlassSecondaryButton() -> some View {
        self.buttonStyle(LiquidGlassSecondaryButtonStyle())
    }
    
    /// Applies Liquid Glass destructive button style
    func liquidGlassDestructiveButton() -> some View {
        self.buttonStyle(LiquidGlassDestructiveButtonStyle())
    }
}

// MARK: - Previews
#Preview("List Row Buttons") {
    List {
        Section("Navigation Buttons") {
            Button {
                // Action
            } label: {
                HStack {
                    Image(systemName: "gear")
                        .foregroundStyle(.blue)
                    Text("Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .liquidGlassListRowButton()
            
            Button {
                // Action
            } label: {
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(.purple)
                    Text("Manage Password")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .liquidGlassListRowButton()
        }
    }
}

#Preview("Action Buttons") {
    VStack(spacing: 16) {
        Button("Add Account") { }
            .liquidGlassPrimaryButton()
        
        Button("Cancel") { }
            .liquidGlassSecondaryButton()
        
        Button("Delete Account") { }
            .liquidGlassDestructiveButton()
    }
    .padding()
}
