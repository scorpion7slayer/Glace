//
//  LayoutBar.swift
//  Ice
//

import SwiftUI

struct LayoutBar: View {
    private struct Representable: NSViewRepresentable {
        let appState: AppState
        let section: MenuBarSection
        let spacing: CGFloat

        func makeNSView(context: Context) -> LayoutBarScrollView {
            LayoutBarScrollView(appState: appState, section: section, spacing: spacing)
        }

        func updateNSView(_ nsView: LayoutBarScrollView, context: Context) {
            nsView.spacing = spacing
        }
    }

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var imageCache: MenuBarItemImageCache

    let section: MenuBarSection
    let spacing: CGFloat

    private var backgroundShape: some InsettableShape {
        RoundedRectangle(cornerRadius: 9, style: .circular)
    }

    init(section: MenuBarSection, spacing: CGFloat = 0) {
        self.section = section
        self.spacing = spacing
    }

    var body: some View {
        conditionalBody
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .layoutBarStyle(appState: appState, averageColorInfo: nil)
            .clipShape(backgroundShape)
            .overlay {
                backgroundShape
                    .stroke(.quaternary)
            }
    }

    @ViewBuilder
    private var conditionalBody: some View {
        if imageCache.cacheFailed(for: section.name) {
            Text("Unable to display menu bar items")
                .foregroundStyle(.primary)
        } else {
            Representable(appState: appState, section: section, spacing: spacing)
        }
    }
}
