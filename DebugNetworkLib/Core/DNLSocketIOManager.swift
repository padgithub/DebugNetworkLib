//
//  SocketIOManager.swift
//  DebugNetworkLib
//
//  Created by Phung Anh Dung on 11/5/20.
//  Copyright © 2020 Anh Dung. All rights reserved.
//

import SocketIO

class SocketIOManager {
    static let shared = SocketIOManager()
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000/")!, config: [.log(false), .reconnects(true), .compress])
        socket = manager.defaultSocket
    }
    
    init(ip: String) {
        manager = SocketManager(socketURL: URL(string: ip)!, config: [.log(false), .reconnects(true), .compress])
        socket = manager.defaultSocket
    }
    
    func connect() {
        socket.connect()
    }
    
    func send(data: [String: Any]) {
        socket.emit("on", data)
    }
    
    func isSocketConnected() -> Bool {
        return socket.status == .connected
    }
}
