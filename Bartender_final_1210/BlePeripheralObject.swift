//
//  BlePeripheralObject.swift
//  Bluetooth Gatt
//
//  Created by CHIA HAO HSU on 2018/5/2.
//  Copyright © 2018年 CHIA HAO HSU. All rights reserved.
//

import UIKit
import CoreBluetooth

class BlePeripheralObject: NSObject {
    
    var Peripheral: CBPeripheral
    var Advertisement: [String : Any]
    var MacAddress:NSString
    var Rssi:NSNumber
    
    init(Peripheral: CBPeripheral, Advertisement: [String : Any], MacAddress:NSString, Rssi: NSNumber) {
        
        self.Peripheral = Peripheral
        self.Advertisement = Advertisement
        self.MacAddress = MacAddress
        self.Rssi = Rssi
        
    }
}
