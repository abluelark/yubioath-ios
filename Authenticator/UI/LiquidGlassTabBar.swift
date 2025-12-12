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

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    @Binding var scrollOffset: CGFloat
    @GestureState private var isPressed = false
    
    private var tabBarHeight: CGFloat {
        let minHeight: CGFloat = 49
        let maxHeight: CGFloat = 80
        let shrinkPoint: CGFloat = 100
        
        if scrollOffset <= 0 {
            return maxHeight
        } else if scrollOffset >= shrinkPoint {
            return minHeight
        } else {
            return maxHeight - (scrollOffset / shrinkPoint) * (maxHeight - minHeight)
        }
    }
    
    private var labelOpacity: Double {
        let shrinkPoint: CGFloat = 100
        if scrollOffset <= 0 {
            return 1.0
        } else if scrollOffset >= shrinkPoint {
            return 0.0
        } else {
            return 1.0 - (scrollOffset / shrinkPoint)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                TabBarButton(
                    title: "Accounts",
                    icon: "person.crop.circle",
                    isSelected: selectedTab == 0,
                    showLabel: labelOpacity > 0,
                    labelOpacity: labelOpacity,
                    action: { withAnimation(.spring(response: 0.3)) { selectedTab = 0 } }
                )
                
                TabBarButton(
                    title: "Configuration",
                    icon: "gearshape.2",
                    isSelected: selectedTab == 1,
                    showLabel: labelOpacity > 0,
                    labelOpacity: labelOpacity,
                    action: { withAnimation(.spring(response: 0.3)) { selectedTab = 1 } }
                )
                
                TabBarButton(
                    title: "About",
                    icon: "info.circle",
                    isSelected: selectedTab == 2,
                    showLabel: labelOpacity > 0,
                    labelOpacity: labelOpacity,
                    action: { withAnimation(.spring(response: 0.3)) { selectedTab = 2 } }
                )
            }
            .background(alignment: .bottom) {
                // Liquid Glass morphing indicator
                Capsule()
                    .fill(.tint)
                    .frame(width: geometry.size.width / 3 * 0.6, height: 3)
                    .offset(x: CGFloat(selectedTab) * (geometry.size.width / 3) + (geometry.size.width / 6) - (geometry.size.width / 3 * 0.3))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2), value: selectedTab)
            }
        }
        .frame(height: tabBarHeight)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            // Subtle separator with lensing effect
            Rectangle()
                .fill(.separator.opacity(0.2))
                .frame(height: 0.5)
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: scrollOffset)
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let showLabel: Bool
    let labelOpacity: Double
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: showLabel ? 24 : 28))
                    .symbolEffect(.bounce, value: isSelected)
                    .symbolRenderingMode(.hierarchical)
                    .contentTransition(.symbolEffect(.replace))
                
                if showLabel {
                    Text(title)
                        .font(.caption2)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .opacity(labelOpacity)
                }
            }
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.95 : 1.0)
            // Internal Glow - Liquid Glass signature effect
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor.opacity(glowOpacity * 0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .opacity(glowOpacity)
            )
        }
        .buttonStyle(GlassButtonStyle(isPressed: $isPressed))
        .onChange(of: isPressed) { pressed in
            withAnimation(.easeOut(duration: pressed ? 0.15 : 0.4)) {
                glowOpacity = pressed ? 1.0 : 0.0
            }
        }
    }
}

struct GlassButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { pressed in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = pressed
                }
            }
    }
}

#Preview {
    VStack {
        Spacer()
        LiquidGlassTabBar(selectedTab: .constant(0), scrollOffset: .constant(0))
    }
}
