//
//  BartendinngDetailViewController.swift
//  Bartender_final_1210
//
//  Created by Christian on 2019/12/16.
//  Copyright © 2019 Christian. All rights reserved.
//

import UIKit
import CoreBluetooth

class BartendinngDetailViewController: UIViewController, BLEDelegate {
    
    func bleDidUpdateState() {}
    
    func bleDidDiscoverDevice(_ Peripheral: CBPeripheral, _ advertisementData: [String : Any], _ rssi: NSNumber) {}
    
    func bleDidConnectToPeripheral(_ Peripheral: CBPeripheral) {}
    
    func bleDidDisconenctFromPeripheral(_ Peripheral: CBPeripheral) {}
    
    func bleDidReceiveData(_ Peripheral: CBPeripheral, _ data: Data?, _ characteristic: CBCharacteristic) {}
    
    func bleDidCharacteristicsNotifyChange(_ Peripheral: CBPeripheral, _ Notify: Bool?, _ characteristic: CBCharacteristic) {}
    
    @IBOutlet weak var BartendingName: UILabel!
    @IBOutlet weak var BartendingImage: UIImageView!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var IngredientsLabel: UILabel!
    @IBOutlet weak var Ingredients: UITextView!
    @IBOutlet weak var SendBtn: UIButton!
    
    @IBOutlet weak var PopView: UIView!
    @IBOutlet weak var PopViewLabel: UILabel!
    @IBOutlet weak var BartendingOption: UILabel!
    @IBOutlet weak var Canceal_btn: UIButton!
    @IBOutlet weak var Confirm_btn: UIButton!
    
    private let BartenderUD = UserDefaults.standard
    public var BartendingNumber = 0
    
    // Bartendings Information
    private let BartendingImagesName = ["SeaBreeze", "LongIsland", "Daiquiri", "Kamikaze", "RedScrewdriver", "GinTonic", "CubaLibra"]
    private let BartendingNames = ["SeaBreeze", "Long Island Ice Tea", "Daiquiri", "Kamikaze", "Red Screwdriver", "Gin Tonic", "Cuba Libra"]
    private let BartendingHistorys = [
        "The cocktail was born in the late 1920s, but the recipe was different from the one used today, as gin and grenadine were used in the original Sea Breeze. This was near the end of the Prohibition era. In the 1930s, a Sea Breeze had gin, apricot brandy, grenadine, and lemon juice.",
        "Robert 'Rosebud' Butt claims to have invented the Long Island iced tea as an entry in a contest to create a new mixed drink with triple sec in 1972 while he worked at the Oak Beach Inn on Long Island, New York.",
        "Daiquirí is also the name of a beach and an iron mine near Santiago de Cuba, and is a word of Taíno origin. The drink was supposedly invented by an American mining engineer, named Jennings Cox",
        "According to cocktail historian David Wondrich, the Kamikaze shot first appeared in 1976 and may have been the original 'shooter' cocktail.The Kamikaze was invented on a Monday night in Canoga Park California in 1975. The shot was named after a doorman named Peter who was “Oriental”.",
        "The screwdriver is mentioned in 1944: 'A Screwdriver—a drink compounded of vodka and orange juice and supposedly invented by interned American fliers'; and in 1949: the latest Yankee concoction of vodka and orange juice, called a ‘screwdriver'",
        "The cocktail was introduced by the army of the British East India Company in India. In India and other tropical regions, malaria was a persistent problem. In the 1700s Scottish doctor George Cleghorn studied how quinine, a traditional cure for malaria, could be used to prevent the disease.",
        "The drink was created in Cuba in the early 1900s. It became popular shortly after 1900, when bottled Coca-Cola was first imported into Cuba from the United States. Its origin is associated with the heavy U.S. presence in Cuba following the Spanish–American War of 1898; the drink's traditional name, 'Cuba Libre', was the slogan of the Cuban independence movement."]
    private let BartendingIngridients = [
        "Vodka    Cranberry Juice \n Lemon Juice",
        "Rim    Vodka    Gin    Tequila \n Lemon Juice    Coca Cola",
        "Rim    Lemon Juice",
        "Vodka    Lemon Juice",
        "Vodka    Cranberry Juice",
        "Gin    Lemon Juice",
        "Rim    Coca Cola    Lemon Juice"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = BartenderUD.object(forKey: "bartending_index") {
            BartendingNumber = index as! Int
        } else {
            BartendingNumber = 0
        }

        print("fetch = \(BartendingNumber)")
        
        BartendingImage.layer.cornerRadius = 10
        BartendingImage.image = UIImage(named: BartendingImagesName[BartendingNumber])
        BartendingImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.9, height: self.view.frame.height * 0.26)
        BartendingImage.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY * 0.76)
        BartendingName.text = BartendingNames[BartendingNumber]
        BartendingName.alpha = 0
        BartendingImage.alpha = 0
        Description.text = BartendingHistorys[BartendingNumber]
        Ingredients.text = BartendingIngridients[BartendingNumber]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { self.animation() })
        
        addTapGesture()
    }
    
    @objc private func SendMsg(gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            SendBtn.setImage(UIImage(named: "send_on"), for: .normal)
        } else if gesture.state == .ended {
            SendBtn.setImage(UIImage(named: "send_off"), for: .normal)
            self.view.alpha = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.showPopView()
            })
        }
    }
    
    private func addTapGesture() {
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(SendMsg))
        tap.minimumPressDuration = 0
        SendBtn.addGestureRecognizer(tap)
        SendBtn.isUserInteractionEnabled = true
        
        let tap_canceal = UILongPressGestureRecognizer(target: self, action: #selector(Canceal))
        tap_canceal.minimumPressDuration = 0.0
        Canceal_btn.addGestureRecognizer(tap_canceal)
        Canceal_btn.isUserInteractionEnabled = true
        
        let tap_confirm = UILongPressGestureRecognizer(target: self, action: #selector(Confirm))
        tap_confirm.minimumPressDuration = 0.0
        Confirm_btn.addGestureRecognizer(tap_confirm)
        Confirm_btn.isUserInteractionEnabled = true
    }
    
    @objc private func Canceal(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .began:
            Canceal_btn.setImage(UIImage(named: "Canceal_on"), for: .normal)
        case .ended:
            Canceal_btn.setImage(UIImage(named: "Canceal_off"), for: .normal)
            print("Canceal making Bartending!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { self.resetBartendingDetailView() })
        default:
            print("Canceal btn Default status!!!!")
        }
    }
    
    @objc private func Confirm(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .began:
            Confirm_btn.setImage(UIImage(named: "Confirm_on"), for: .normal)
        case .ended:
            Confirm_btn.setImage(UIImage(named: "Confirm_off"), for: .normal)
            print("Start making \(BartendingNames[BartendingNumber]) Bartending!!!")
            
            var Data:[UInt8] = [0x44,0xFF]
            Data[1] = UInt8(BartendingNumber)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { self.resetBartendingDetailView()
                if BLE.sharedInstance().activePeripheral?.state == CBPeripheralState.connected {
                    print("bleDidConnectToPeripheral - send DATA to device!")
                    BLE.sharedInstance().writeWithResponse(data: self.dataWithHexstring(bytes: Data) as Data, UUID: "FFF2")
                }
            })
            
            print("current bartending index = \(BartendingNumber)")
        default:
            print("Confirm btn Default status!!!!")
        }
    }
    
    private func dataWithHexstring(bytes:[UInt8]) -> NSData {
        let data = NSData(bytes: bytes, length: bytes.count)
        return data
    }
    
    private func resetBartendingDetailView() {
        self.PopView.alpha = 0.0
        self.PopViewLabel.alpha = 0.0
        self.BartendingOption.alpha = 0.0
        self.Canceal_btn.alpha = 0.0
        self.Confirm_btn.alpha = 0.0
        self.Canceal_btn.isEnabled = false
        self.Confirm_btn.isEnabled = false
        
        self.BartendingName.alpha = 1.0
        self.BartendingImage.alpha = 1.0
        self.DescriptionLabel.alpha = 1.0
        self.Description.alpha = 1.0
        self.IngredientsLabel.alpha = 1.0
        self.Ingredients.alpha = 1.0
        self.SendBtn.alpha = 1.0
        self.SendBtn.isEnabled = true
    }
    
    private func showPopView() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0.2,
            options: .curveLinear,
            animations: {
                self.BartendingName.alpha = 0.3
                self.BartendingImage.alpha = 0.3
                self.DescriptionLabel.alpha = 0.3
                self.Description.alpha = 0.3
                self.IngredientsLabel.alpha = 0.3
                self.Ingredients.alpha = 0.3
                self.SendBtn.alpha = 0.3
                self.SendBtn.isEnabled = false
            },
            completion: {position in
                self.BartendingOption.text = self.BartendingNames[self.BartendingNumber]
                self.PopView.alpha = 1.0
                self.PopViewLabel.alpha = 1.0
                self.BartendingOption.alpha = 1.0
                self.Canceal_btn.alpha = 1.0
                self.Confirm_btn.alpha = 1.0
                self.Canceal_btn.isEnabled = true
                self.Confirm_btn.isEnabled = true
        })
    }
    
    private func animation() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.BartendingName.alpha = 1.0
                self.BartendingImage.alpha = 0
            },
            completion: { position in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: 0.3,
                    options: .curveLinear,
                    animations: {
                        self.BartendingImage.alpha = 1.0
                        self.BartendingImage.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY * 0.65)
                    },
                    completion: { position in
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.5,
                            delay: 0,
                            options: .curveEaseIn,
                            animations: {
                                self.DescriptionLabel.alpha = 1.0
                                self.Description.alpha = 1.0
                            },
                            completion: { position in
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.5,
                                    delay: 0,
                                    options: .curveEaseIn,
                                    animations: {
                                        self.IngredientsLabel.alpha = 1.0
                                        self.Ingredients.alpha = 1.0
                                    },
                                    completion: { position in
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.5,
                                            delay: 0,
                                            options: .curveEaseIn,
                                            animations: {
                                                self.SendBtn.alpha = 1.0
                                            },
                                            completion: nil)
                                })
                        })
                })
        })
    }
}
