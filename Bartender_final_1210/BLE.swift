//
//  BLE.swift
//  Bluetooth Gatt
//
//  Created by CHIA HAO HSU on 2018/5/2.
//  Copyright © 2018年 CHIA HAO HSU. All rights reserved.
//

import UIKit
import CoreBluetooth

var thisCentralManager : BLE?

protocol BLEDelegate {
    
    func bleDidUpdateState()
    func bleDidDiscoverDevice(_ Peripheral: CBPeripheral , _ advertisementData: [String : Any],_ rssi: NSNumber)
    
    func bleDidConnectToPeripheral(_ Peripheral: CBPeripheral)
    func bleDidDisconenctFromPeripheral(_ Peripheral: CBPeripheral)
    func bleDidReceiveData(_ Peripheral: CBPeripheral ,_ data: Data?,_ characteristic: CBCharacteristic)
    func bleDidCharacteristicsNotifyChange(_ Peripheral: CBPeripheral ,_ Notify: Bool?,_ characteristic: CBCharacteristic)
    
}

class BLE: NSObject ,CBCentralManagerDelegate,CBPeripheralDelegate{
    
    
    var selectedPeripheral:CBPeripheral?
    
    let BLE_SERVICE_UUID = "FFF0"
    let BATTERY_SERVICE_UUID = "180F"
    let BLE_CHAR_RX_UUID = "FFF2"
    let BLE_CHAR_TX_UUID = "FFF1"
    
    let BLE_CHAR_SERIAL_UUID = "2A25"
    let BLE_CHAR_TIME_UUID = "2A2B"
    let OTA_SERVICE_UUID = "FEBA"
    let OTA_CHAR_CMD_UUID = "FA11"
    let OTA_CHAR_DATA_UUID = "FA10"
    let OTA_CHAR_STATUS_UUID = "FA12"
    
    let BLE_NAME = "BLE to UART1"
    
    private let centralQueue = DispatchQueue(label: "com.besmed.flowguard.bluetooth")
    
    var centralManager:CBCentralManager!
    var activePeripheral: CBPeripheral?
    
    var UserDef:UserDefaults!
    var retrieveUUIDString: NSString!
    
    var delegate: BLEDelegate?
    var timer: Timer!
    
    var bleWriteBuffer:NSMutableArray!
    
    var MacAddress: NSString?
    
    fileprivate      var characteristics = [String : CBCharacteristic]()
    fileprivate      var data:             NSMutableData?
    fileprivate(set) var peripherals     = [CBPeripheral]()
    fileprivate      var RSSICompletionHandler: ((NSNumber?, NSError?) -> ())?
    
    
    public class func sharedInstance() -> BLE {
        
        if thisCentralManager == nil {
            
            thisCentralManager = BLE()
            
            
        }
        return thisCentralManager!
    }
    
    override init() {
        
        super.init()
        
        self.centralManager = CBCentralManager(delegate:self, queue:self.centralQueue)
        self.bleWriteBuffer = NSMutableArray()
        self.MacAddress = ""
    }
    
    // MARK: Public methods
    
    //scanner-------------------
    @objc fileprivate func scanTimeout() {
        
        print("[DEBUG] Scanning stopped")
        self.centralManager.stopScan()
    }
    
    func startScanning(_ timeout: Double) -> Bool {
        if self.centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t start scanning")
            return false
        }
        print("[DEBUG] Scanning started")
        
        self.data = NSMutableData()
        self.peripherals  = [CBPeripheral]()
        
        timer=Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(BLE.scanTimeout), userInfo: nil, repeats: false)
        
        //   let services:[CBUUID] = [CBUUID(string: BATTERY_SERVICE_UUID)]
        
        self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        return true
        
    }
    func CheckScanning () -> Bool {
        
        return self.centralManager.isScanning
    }
    func StopScanning() -> Bool {
        if self.centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t start scanning")
            return false
        }
        
        
        if(!self.centralManager.isScanning)
        {
            
            return false
        }
        
        print("[DEBUG] Stop Scanning")
        
        timer.invalidate()
        
        self.centralManager.stopScan()
        
        return true
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            print("BT ON")
            break
        case .poweredOff:
            print("BT OFF")
            break
        case .resetting:
            print("BT RESSTING")
            break
        case .unknown:
            print("BT UNKNOW")
            break
        case .unauthorized:
            print("BT UNAUTHORIZED")
            break
        case .unsupported:
            print("BT UNSUPPORTED")
            break
        @unknown default:
            print("DEFAULT STATE")
            break
        }
        self.delegate?.bleDidUpdateState()
    }
    
    func retrievePeripheral() {
        self.UserDef =  UserDefaults.standard
        
        if UserDef.string(forKey: "UUIDString") == nil {
            
            return
        }
        
        if UserDef.string(forKey: "DeviceMac") == nil {
            
            return
        }
        
        self.retrieveUUIDString = UserDef.string(forKey: "UUIDString")! as NSString
        self.MacAddress = UserDef.string(forKey: "DeviceMac")! as NSString as String as NSString
        
        let uuisStr:UUID = UUID(uuidString: retrieveUUIDString as String)!
        
        for p:AnyObject in centralManager.retrievePeripherals(withIdentifiers: [uuisStr]) {
            
            if p is CBPeripheral {
                
                if connectToPeripheral(p as! CBPeripheral){
                    
                    print("[DEBUG] Try to connect with device")
                }
                return
            }
        }
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let temp = peripherals.filter { (pl) -> Bool in
            return pl.identifier.uuidString == peripheral.identifier.uuidString
            
        }
        if temp.count == 0 {
            peripherals.append(peripheral)
            
            self.delegate?.bleDidDiscoverDevice(peripheral, advertisementData, RSSI)
            
            
        }
        
        
        
    }
    
    
    //connect------------------
    
    func connectToPeripheral(_ peripheral: CBPeripheral) -> Bool {
        
        if self.centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t connect to peripheral")
            return false
        }
        
        print("[DEBUG] Connecting to peripheral: \(peripheral.identifier.uuidString)")
        
        self.activePeripheral = peripheral
        self.activePeripheral?.delegate = self
        self.centralManager.connect(self.activePeripheral!, options:  [CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(value: true as Bool)])
        //  centralManager.connect(activePeripheral!,options: nil)
        
        return true
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //print("[DEBUG] Connected to peripheral \(peripheral.identifier.uuidString)")
        self.activePeripheral = peripheral
        
        self.activePeripheral?.delegate = self
        self.activePeripheral?.discoverServices(nil)
        
        self.delegate?.bleDidConnectToPeripheral(peripheral)
        
        print("[DEBUG]didConnect peripheral")
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("[DEBUG] Disconnected to peripheral \(peripheral.identifier.uuidString)")
        
        if error != nil {
            
        }
        
        self.activePeripheral?.delegate = nil
        self.activePeripheral = nil
        self.characteristics.removeAll(keepingCapacity: false)
        
        self.delegate?.bleDidDisconenctFromPeripheral(peripheral)
        
        
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("[DEBUG]didUpdateNotificationStateFor \(characteristic.uuid.uuidString) Notify: \(characteristic.isNotifying)")
        
        self.delegate?.bleDidCharacteristicsNotifyChange(peripheral ,characteristic.isNotifying,characteristic)
    }
    
    // MARK: CBPeripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("[ERROR] Error discovering services. \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            
            
            //  print("[DEBUG] Found services : \(service.uuid.uuidString)")
            //let theCharacteristics = [CBUUID(string: BLE_CHAR_RX_UUID), CBUUID(string: BLE_CHAR_TX_UUID)]
            
            peripheral.discoverCharacteristics(nil, for: service)
        }
        //print("Discovered Services: \(services)")
        // print("[DEBUG]didDiscoverServices yaya")
        //   self.delegate?.bleDidDiscoverServices(peripheral, didDiscoverServices: error)
        
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            return
        }
        
        
        for characteristic in service.characteristics! {
            
            // print("[DEBUG] Found characteristics : \(characteristic.uuid.uuidString)")
            self.characteristics[characteristic.uuid.uuidString] = characteristic
            
            if characteristic.uuid.uuidString == "FFF1" {
                SetNotify(enable: true, UUID: characteristic.uuid.uuidString)
            }
            else if characteristic.uuid.uuidString == "2A2B" {
                SetNotify(enable: true, UUID: characteristic.uuid.uuidString)
            }
            if characteristic.uuid.uuidString == "FFE1" {
                SetNotify(enable: true, UUID: characteristic.uuid.uuidString)
            }
        }
        
        // self.delegate?.bleDidDiscoverCharacteristicsFor(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            
            //  print("[ERROR] Error updating value. \(error!.description)")
            return
        }
        
        self.delegate?.bleDidReceiveData(peripheral,characteristic.value,characteristic)
    }
    
    
    
    //Write
    func ReadDataFromCharacteristics(UUID: String) {
        
        guard let char = self.characteristics[UUID] else { return }
        
        self.activePeripheral?.readValue(for: char)
    }
    
    //Write
    func writeWithResponse(data: Data ,UUID: String) {
        
        guard let char = self.characteristics[UUID] else { return }
        
        self.activePeripheral?.writeValue(data, for: char, type: .withResponse)
    }
    
    func writeWithNoResponse(data: Data ,UUID: String) {
        
        guard let char = self.characteristics[UUID] else { return }
        
        self.activePeripheral?.writeValue(data, for: char, type: .withoutResponse)
    }
    
    //Write
    func write(data: Data) {
        
        guard let char = self.characteristics[BLE_SERVICE_UUID] else { return }
        
        self.activePeripheral?.writeValue(data, for: char, type: .withResponse)
    }
    
    func SetNotify(enable: Bool , UUID: String ) {
        
        guard let char = self.characteristics[UUID] else { return }
        
        self.activePeripheral?.setNotifyValue(enable, for: char)
        
    }
    
    func OTA_CMD_write(data: Data) {
        
        guard let char = self.characteristics[OTA_CHAR_CMD_UUID] else { return }
        
        self.activePeripheral?.writeValue(data, for: char, type: .withResponse)
    }
    
    func OTA_DATA_write(data: Data) {
        
        guard let char = self.characteristics[OTA_CHAR_DATA_UUID] else { return }
        
        self.activePeripheral?.writeValue(data, for: char, type: .withoutResponse)
    }
    
    func dataWithHexstring(bytes:[UInt8]) -> NSData {
        let data = NSData(bytes: bytes, length: bytes.count)
        return data
    }
    
    func hexadecimalString(data:NSData) -> String {
        
        var p = [UInt8](repeating: 0, count: data.length/MemoryLayout<UInt8>.size)
        
        data.getBytes(&p, length:data.length)
        
        let len = data.length
        var str: String = String()
        for i in 0...len-1 {
            str += String(format: "%02.2X", p[i])
        }
        return str
    }
}
