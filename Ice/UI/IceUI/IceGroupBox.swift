//
//  IceGroupBox.swift
//  Ice
//

import SwiftUI

struct IceGroupBox<Header: View, Content: View, Footer: View>: View {
    private let header: Header
    private let content: Content
    private let footer: Footer
    private let padding: EdgeInsets

    private var backgroundShape: some InsettableShape {
        if #available(macOS 26.0, *) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
        } else {
            RoundedRectangle(cornerRadius: 7, style: .circular)
        }
    }

    private var borderStyle: some ShapeStyle {
        if #available(macOS 26.0, *) {
            AnyShapeStyle(Color.clear)
        } else {
            AnyShapeStyle(Color.primary.quaternary)
        }
    }

    init(
        padding: EdgeInsets = .iceGroupBoxDefaultPadding,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.padding = padding
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    init(
        padding: CGFloat,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(padding: EdgeInsets(all: padding)) {
            header()
        } content: {
            content()
        } footer: {
            footer()
        }
    }

    init(
        padding: EdgeInsets = .iceGroupBoxDefaultPadding,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) where Header == EmptyView {
        self.init(padding: padding) {
            EmptyView()
        } content: {
            content()
        } footer: {
            footer()
        }
    }

    init(
        padding: CGFloat,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) where Header == EmptyView {
        self.init(padding: padding) {
            EmptyView()
        } content: {
            content()
        } footer: {
            footer()
        }
    }

    init(
        padding: EdgeInsets = .iceGroupBoxDefaultPadding,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) where Footer == EmptyView {
        self.init(padding: padding) {
            header()
        } content: {
            content()
        } footer: {
            EmptyView()
        }
    }

    init(
        padding: CGFloat,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) where Footer == EmptyView {
        self.init(padding: padding) {
            header()
        } content: {
            content()
        } footer: {
            EmptyView()
        }
    }

    init(
        padding: EdgeInsets = .iceGroupBoxDefaultPadding,
        @ViewBuilder content: () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(padding: padding) {
            EmptyView()
        } content: {
            content()
        } footer: {
            EmptyView()
        }
    }

    init(
        padding: CGFloat,
        @ViewBuilder content: () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(padding: padding) {
            EmptyView()
        } content: {
            content()
        } footer: {
            EmptyView()
        }
    }

    init(
        _ title: LocalizedStringKey,
        padding: EdgeInsets = .iceGroupBoxDefaultPadding,
        @ViewBuilder content: () -> Content
    ) where Header == Text, Footer == EmptyView {
        self.init(padding: padding) {
            Text(title).font(.headline)
        } content: {
            content()
        }
    }

    init(
        _ title: LocalizedStringKey,
        padding: CGFloat,
        @ViewBuilder content: () -> Content
    ) where Header == Text, Footer == EmptyView {
        self.init(padding: padding) {
            Text(title).font(.headline)
        } content: {
            content()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            header
                .accessibilityAddTraits(.isHeader)
                .padding([.top, .leading], 8)
                .padding(.bottom, 2)

            styledContent

            footer
                .padding([.bottom, .leading], 8)
                .padding(.top, 2)
        }
        .focusSection()
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var contentStack: some View {
        VStack { content }
    }

    @ViewBuilder
    private var styledContent: some View {
        if #available(macOS 26.0, *) {
            contentStack
                .padding(padding)
                .glassEffect(.regular, in: backgroundShape)
                .overlay {
                    backgroundShape
                        .strokeBorder(Color.primary.opacity(0.10), lineWidth: 0.5)
                }
                .containerShape(backgroundShape)
        } else {
            contentStack
                .padding(padding)
                .background {
                    backgroundShape
                        .fill(Color.primary.quinary)
                        .strokeBorder(borderStyle)
                }
                .containerShape(backgroundShape)
        }
    }
}

extension EdgeInsets {
    /// The default padding for an ``IceGroupBox``.
    static let iceGroupBoxDefaultPadding = EdgeInsets(all: 12)
}
