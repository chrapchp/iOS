//
//  ViewController.swift
//  BLE-iOS
//
//  Created by Fernando Reynoso on 6/15/15.
//  Copyright (c) 2015 Fernando Reynoso. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BLEDelegate {

    @IBOutlet var connectButton: UIButton!
    @IBOutlet var textField:     UITextField!
    @IBOutlet var messageLabel:  UILabel!
    @IBOutlet var sendButton:    UIButton!
    
    var connected = false
    
    var ble = BLE()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ble.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction methods
    @IBAction func connectButtonPressed(sender: UIButton) {
        
        if self.connected {
            self.connected = false
            
            self.ble.disconnectFromPeripheral(ble.peripherals[0])
            
            self.connectButton.setTitle("Connect", forState: .Normal)
            return
        }
        
        self.connected = true
        
        self.connectButton.setTitle("Disconnect", forState: .Normal)
        self.ble.connectToPeripheral(ble.peripherals[0])
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        
        if let data = (self.textField.text as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
            ble.write(data: data)
        }
    }

    // MARK: BLE delegate
    func bleDidUpdateState(state: BLEState) {
        
        if state == .PoweredOn {
            self.ble.startScanning(8)
        }
    }
    
    func bleDidConnectToPeripheral() {
        
    }
    
    func bleDidDisconenctFromPeripheral() {
        
        if self.connected {
            self.connected = false
            self.connectButton.setTitle("Connect", forState: .Normal)
        }
    }
    
    func bleDidReceiveData(data: NSData?) {
        if let theData = data {
            
            let string = NSString(data: theData, encoding: NSUTF8StringEncoding) as! String
            
            if string.hasSuffix("\0") {
                string.substringToIndex(string.endIndex.predecessor())
            }
            
            println("[MESSAGE] \(string) lenght: \(count(string))")
            
            self.messageLabel.text = string
        }
        
        self.ble.readRSSI { (RSSI, error) -> () in
            if let value = RSSI {
                println("[DEBUG] RSSI: \(value)")
            }
        }
    }
}

