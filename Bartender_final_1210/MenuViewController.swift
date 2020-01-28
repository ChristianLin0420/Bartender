//
//  MenuViewController.swift
//  Bartender_final_1210
//
//  Created by Christian on 2019/12/14.
//  Copyright © 2019 Christian. All rights reserved.
//

import UIKit
import CoreBluetooth

class MenuCellTableViewCell: UITableViewCell {
    @IBOutlet weak var BartendingImage: UIImageView!
    @IBOutlet weak var BartendingLabe: UILabel!
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BLEDelegate {
    
    private var Peripheralobject:BlePeripheralObject!
    private var BLE_connecting = false
    private var BLE_connected = false
    private var BLE_testing = false
    private var BLE_found = false
    private var tick_count = 0
    
    private var isDone = true
    private var BartendingChoice = 0
    
    private let BartenderUD = UserDefaults.standard
    
    private var tickerTimer = Timer()

    private let imageName = ["SeaBreeze", "LongIsland", "Daiquiri", "Kamikaze", "RedScrewdriver", "GinTonic", "CubaLibra"]
    private let BartendingNames = ["SeaBreeze", "Long Island Ice Tea", "Daiquiri", "Kamikaze", "Red Screwdriver", "Gin Tonic", "Cuba Libra"]
    
    @IBOutlet weak var MenuTable: UITableView!
    @IBOutlet weak var BLE_connect: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        Peripheralobject = Shared.shared.Peripheralobject
        BLE_connecting = false
        BLE_connected = false
        BLE_testing = false
        BLE_found = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        BLE.sharedInstance().delegate = self
        
        if BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.connected{
            BLE.sharedInstance().centralManager.cancelPeripheralConnection(BLE.sharedInstance().activePeripheral!)
            BLE_connected = false
            BLE_testing = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? BartendinngDetailViewController
        
        if let row  = MenuTable.indexPathForSelectedRow?.row {
            print("choice: \(row)")
            vc?.BartendingNumber = BartendingChoice
        }
    }
    
    @IBAction func ConnectBLE(_ sender: UIButton) {
        print("connecting")
        if (BLE_testing == false) {
            BLE.sharedInstance().delegate = self;
        
            if (BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.disconnected || BLE.sharedInstance().activePeripheral == nil ) {
                BLE_connecting = true
                BLE_found = false

                BLE.sharedInstance().delegate = self

                if BLE.sharedInstance().startScanning(120) {
                    print("BLE startScanning")
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if (self.BLE_found) {
                        self.BLE_connecting = true
                        BLE.sharedInstance().delegate = self
                        if BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.disconnected{
                            print("CBPeripheralState.disconnected")
                            BLE.sharedInstance().connectToPeripheral(self.Peripheralobject.Peripheral)
                        } else if BLE.sharedInstance().activePeripheral == nil {
                            print("BLE.sharedInstance().activePeripheral == nil")
                            BLE.sharedInstance().connectToPeripheral(self.Peripheralobject.Peripheral)
                        }
                    } else {
                        self.BLE_connecting = false
                    }
                }
            } else if (BLE_connected) {
                BLE_testing = true
                tick_count = 0
            }
        }
    }
    
    private func dataWithHexstring(bytes:[UInt8]) -> NSData {
        let data = NSData(bytes: bytes, length: bytes.count)
        return data
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MenuCellTableViewCell
        let image = UIImage(named: imageName[indexPath.row])
        
        cell.backgroundColor = UIColor.black
        cell.BartendingLabe.text = "\(BartendingNames[indexPath.row])"
        cell.BartendingLabe.frame = CGRect(x: cell.frame.width * 0.07, y: 0, width: cell.frame.width * 0.84, height: cell.frame.height * 0.1)
        cell.BartendingImage.layer.cornerRadius = 20
        cell.BartendingImage.image = image
        cell.BartendingImage.frame = CGRect(x: cell.frame.width * 0.07, y: cell.frame.width * 0.1, width: cell.frame.width * 0.84, height: cell.frame.height * 0.8)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tickerTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in self.ticker()}
        
        BartendingChoice = indexPath.row
        print("Send \(BartendingChoice) to Bartending Detail VC device!!!")
        BartenderUD.set(BartendingChoice, forKey: "bartending_index")
        BartenderUD.synchronize()
        
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselect")
    }
    
    // BLE connect
    private func ticker() {
        if BLE.sharedInstance().activePeripheral?.state != CBPeripheralState.connected {
            BLE_connect.alpha = 1.0
        }
        
        if (BLE_connected == false) {
            if (BLE_connecting == false) {
                BLE_connect.alpha = 1.0
                BLE_found = false
            } else {
                BLE_connect.alpha = 0.3
            }
        } else {
            if (BLE_testing) {
                
                print("tick count = \(tick_count)")
                
                if tick_count == 20 { tick_count = 0 }
                else { tick_count = tick_count + 1 }
                
                if (tick_count == 19) {
                    BLE_connect.alpha = 1.0
                    BLE_found = false
                }
                
                if (tick_count == 10) {
                    BLE_connect.alpha = 0.3
                }
                
                if tick_count == 0 {
                    let Data: [UInt8] = [0x43, 0x59]
                
                    if BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.connected {
                        print("bleDidConnectToPeripheral - send DATA to device!")
                        BLE.sharedInstance().writeWithResponse(data: self.dataWithHexstring(bytes: Data) as Data, UUID: "FFF2")
                    }
                    
                    if isDone {
                        MenuTable.isUserInteractionEnabled = true
                        isDone = false
                        tickerTimer.invalidate()
                    }
                }
            }
        }
    }
    
    func bleDidUpdateState() {
        
    }
    
    func bleDidDiscoverDevice(_ Peripheral: CBPeripheral, _ advertisementData: [String : Any], _ rssi: NSNumber) {
        
        let ManafactureData = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataManufacturerDataKey) as? NSData
        
        if ManafactureData != nil {
            if ManafactureData?.length == 8 {
                
                let HEX_STR = Util.hexadecimalString(from: ManafactureData! as Data)
                let index = HEX_STR?.index((HEX_STR?.startIndex)!, offsetBy: 4)
                
                DispatchQueue.main.sync() {
                    let Per = BlePeripheralObject.init(Peripheral: Peripheral, Advertisement: advertisementData, MacAddress: HEX_STR?.substring(from: index!) as! NSString, Rssi: rssi)
                    
                    if (Per.Peripheral.name == "Digital_Flute") {
                        Peripheralobject = Per
                        self.BLE_found = true
                    }
                }
            }
        }
    }
    
    func bleDidConnectToPeripheral(_ Peripheral: CBPeripheral) {
        print("CBPeripheralState.connected")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let Data:[UInt8] = [0x42,0x46,0x57,0x4c,0x58] // BFWLX
            if BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.connected {
                print("bleDidConnectToPeripheral - send BFWLX command!")
                self.BLE_connect.alpha = 0.3
                BLE.sharedInstance().writeWithResponse(data: self.dataWithHexstring(bytes: Data) as Data, UUID: "FFF2")
            }
        }
    }
    
    func bleDidDisconenctFromPeripheral(_ Peripheral: CBPeripheral) {
        BLE_connecting = false
        BLE_connected = false
        BLE_found = false
        BLE_testing = false
    }
    
    func bleDidReceiveData(_ Peripheral: CBPeripheral, _ data: Data?, _ characteristic: CBCharacteristic) {
        
        var intArray = Array(repeating: 0, count: 4)
        var buffer = "00000000"
        buffer = Util.hexadecimalString(from: data)

        var twoLetters = "00"
        
        for i in 0..<3 {  // detect key
            twoLetters = buffer[2*i..<2*i+2]
            intArray[i] = Int(twoLetters, radix: 16)!
        }
        
        // "ff"
        if intArray[0] < 200 {
            if intArray[1] == 1 {
                isDone = true
            } else {
                isDone = false
                BLE_testing = true
            }
        } else {
            if intArray[0] == 255 {
                BLE_connected = true
                BLE_testing = true
                tick_count = 0
            } else if intArray[0] == 201 {
                if BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.connected{
                    BLE.sharedInstance().centralManager.cancelPeripheralConnection(BLE.sharedInstance().activePeripheral!)
                }
                
                BLE_connecting = false
                BLE_connected = false
                BLE_testing = false
            } else if intArray[0] == 202 {
                
                if BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.connected{
                    BLE.sharedInstance().centralManager.cancelPeripheralConnection(BLE.sharedInstance().activePeripheral!)
                }
                
                BLE_connecting = false
                BLE_connected = false
                BLE_testing = false
            }
        }
    }
    
    func bleDidCharacteristicsNotifyChange(_ Peripheral: CBPeripheral, _ Notify: Bool?, _ characteristic: CBCharacteristic) {
        
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}
