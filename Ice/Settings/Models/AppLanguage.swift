//
//  AppLanguage.swift
//  Ice
//

import SwiftUI

/// A language that Glace can apply independently of the system language.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"

    var id: String { rawValue }

    /// The locale injected into Glace's SwiftUI scenes.
    var locale: Locale {
        Locale(identifier: rawValue)
    }

    /// A native language name that remains understandable before switching.
    var displayName: String {
        switch self {
        case .english: "English"
        case .french: "Français"
        }
    }

    /// Localizes an AppKit string using Glace's selected language.
    func localized(_ key: String) -> String {
        guard self == .french else {
            return key
        }
        guard
            let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    /// Returns the persisted language, defaulting to English.
    static var stored: AppLanguage {
        Defaults.string(forKey: .appLanguage)
            .flatMap(AppLanguage.init(rawValue:))
            ?? .english
    }
}
