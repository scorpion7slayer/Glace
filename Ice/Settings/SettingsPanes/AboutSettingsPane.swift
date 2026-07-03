//
//  AboutSettingsPane.swift
//  Ice
//

import SwiftUI

struct AboutSettingsPane: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var updatesManager: UpdatesManager
    @Environment(\.openURL) private var openURL

    private var acknowledgementsURL: URL {
        // swiftlint:disable:next force_unwrapping
        Bundle.main.url(forResource: "Acknowledgements", withExtension: "pdf")!
    }

    private var contributeURL: URL {
        guard let url = URL(string: "https://github.com/scorpion7slayer/Glace") else {
            preconditionFailure("Invalid Glace repository URL")
        }
        return url
    }

    private var originalProjectURL: URL {
        guard let url = URL(string: "https://github.com/jordanbaird/Ice") else {
            preconditionFailure("Invalid Ice repository URL")
        }
        return url
    }

    private var issuesURL: URL {
        contributeURL.appendingPathComponent("issues")
    }

    private var donateURL: URL {
        guard let url = URL(string: "https://icemenubar.app/Donate") else {
            preconditionFailure("Invalid donation URL")
        }
        return url
    }

    private var lastUpdateCheckString: String {
        if let date = updatesManager.lastUpdateCheckDate {
            date.formatted(date: .abbreviated, time: .standard)
        } else {
            "Never"
        }
    }

    private var updateCheckStatusForegroundStyle: some ShapeStyle {
        updatesManager.updateCheckStatus.isError ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary)
    }

    var body: some View {
        if #available(macOS 26.0, *) {
            contentForm(cornerStyle: .continuous)
        } else {
            contentForm(cornerStyle: .circular)
        }
    }

    @ViewBuilder
    private func contentForm(cornerStyle: RoundedCornerStyle) -> some View {
        IceForm(spacing: 0) {
            mainContent(containerShape: RoundedRectangle(cornerRadius: 20, style: cornerStyle))
            Spacer(minLength: 10)
            bottomBar(containerShape: Capsule(style: cornerStyle))
        }
    }

    @ViewBuilder
    private func mainContent(containerShape: some InsettableShape) -> some View {
        IceSection(spacing: 0, options: .plain) {
            appIconAndCopyrightSection
                .layoutPriority(1)

            Spacer(minLength: 0)
                .frame(maxHeight: 20)

            updatesSection
                .layoutPriority(1)
        }
        .padding(.top, 5)
        .padding([.horizontal, .bottom], 30)
        .frame(maxHeight: 500)
        .background(.quinary, in: containerShape)
        .containerShape(containerShape)
    }

    @ViewBuilder
    private var appIconAndCopyrightSection: some View {
        IceSection(options: .plain) {
            HStack(spacing: 10) {
                if let nsImage = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 230)
                }

                VStack(alignment: .leading) {
                    Text("Glace")
                        .font(.system(size: 80))
                        .foregroundStyle(.primary)

                    Text("Version \(Constants.versionString)")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    Text(Constants.copyrightString)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary.opacity(0.67))

                    Text("Glace is a fork of Ice by Jordan Baird.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)

                    Button("Original Ice project") {
                        openURL(originalProjectURL)
                    }
                    .buttonStyle(.link)
                }
                .fontWeight(.medium)
            }
        }
    }

    @ViewBuilder
    private var updatesSection: some View {
        IceSection(options: .hasDividers) {
            automaticallyCheckForUpdates
            automaticallyDownloadUpdates
            checkForUpdates
        }
        .frame(maxWidth: 600)
    }

    @ViewBuilder
    private var automaticallyCheckForUpdates: some View {
        Toggle(
            "Automatically check for updates",
            isOn: $updatesManager.automaticallyChecksForUpdates
        )
    }

    @ViewBuilder
    private var automaticallyDownloadUpdates: some View {
        Toggle(
            "Automatically download updates",
            isOn: $updatesManager.automaticallyDownloadsUpdates
        )
    }

    @ViewBuilder
    private var checkForUpdates: some View {
        HStack {
            Button("Check for Updates") {
                updatesManager.checkForUpdates()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Last checked: \(lastUpdateCheckString)")
                if let status = updatesManager.updateCheckStatus.displayString {
                    Text(status)
                        .foregroundStyle(updateCheckStatusForegroundStyle)
                }
            }
            .font(.caption)
        }
    }

    @ViewBuilder
    private func bottomBar(containerShape: some InsettableShape) -> some View {
        HStack {
            Button("Quit Glace") {
                NSApp.terminate(nil)
            }
            Spacer()
            Button("Acknowledgements") {
                NSWorkspace.shared.open(acknowledgementsURL)
            }
            Button("Contribute") {
                openURL(contributeURL)
            }
            Button("Report a Bug") {
                openURL(issuesURL)
            }
            Button("Support Glace", systemImage: "heart.circle.fill") {
                openURL(donateURL)
            }
        }
        .padding(8)
        .buttonStyle(BottomBarButtonStyle())
        .background(.quinary, in: containerShape)
        .containerShape(containerShape)
        .frame(height: 40)
    }
}

private struct BottomBarButtonStyle: ButtonStyle {
    @State private var isHovering = false

    private var borderShape: some InsettableShape {
        ContainerRelativeShape()
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background {
                borderShape
                    .fill(configuration.isPressed ? .tertiary : .quaternary)
                    .opacity(isHovering ? 1 : 0)
            }
            .contentShape([.focusEffect, .interaction], borderShape)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}
