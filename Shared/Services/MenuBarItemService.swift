//
//  MenuBarItemService.swift
//  Shared
//

import Foundation

enum MenuBarItemService {
    #if DEBUG
    static let name = "com.theo.Glace.debug.MenuBarItemService"
    #else
    static let name = "com.theo.Glace.MenuBarItemService"
    #endif
}

extension MenuBarItemService {
    enum Request: Codable {
        case start
        case sourcePID(WindowInfo)
    }

    enum Response: Codable {
        case start
        case sourcePID(pid_t?)
    }
}
