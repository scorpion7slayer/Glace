//
//  IceMenuPicker.swift
//  Ice
//

import SwiftUI

/// A reliable menu-backed picker for macOS versions where SwiftUI's menu
/// picker can expose disabled options inside remotely hosted windows.
struct IceMenuPicker<SelectionValue: Hashable, OptionLabel: View>: View {
    @Binding private var selection: SelectionValue

    private let titleKey: LocalizedStringKey
    private let options: [SelectionValue]
    private let optionLabel: (SelectionValue) -> OptionLabel

    init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        @ViewBuilder optionLabel: @escaping (SelectionValue) -> OptionLabel
    ) {
        self.titleKey = titleKey
        self._selection = selection
        self.options = options
        self.optionLabel = optionLabel
    }

    var body: some View {
        LabeledContent {
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        if selection == option {
                            Label {
                                optionLabel(option)
                            } icon: {
                                Image(systemName: "checkmark")
                            }
                        } else {
                            optionLabel(option)
                        }
                    }
                }
            } label: {
                optionLabel(selection)
            }
            .menuStyle(.button)
            .buttonStyle(.bordered)
            .labelsHidden()
            .fixedSize()
        } label: {
            Text(titleKey)
        }
    }
}
