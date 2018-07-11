
import UIKit
import CoreBluetooth

let svcLight = CBUUID.init(string: "F000AA70-0451-4000-B000-000000000000")
let charLightConfig = CBUUID.init(string: "F000AA72-0451-4000-B000-000000000000")

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            print ("scanning...")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.contains("SensorTag") == true {
            print (peripheral.name ?? "no name")
            centralManager.stopScan()
            print (advertisementData)
            central.connect(peripheral, options: nil)
            myPeripheral = peripheral
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print ("connected \(peripheral.name)")
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for svc in services {
                if svc.uuid == svcLight {
                    print (svc.uuid.uuidString)
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let chars = service.characteristics {
            for char in chars {
                print (char.uuid.uuidString)
                if char.uuid == charLightConfig {
                    if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
                    }
                    else {
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print ("wrote value")
    }

    var centralManager : CBCentralManager!
    var myPeripheral : CBPeripheral?
}

//import UIKit
//import CoreBluetooth
//
//let svcLight = CBUUID.init()
//
//class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == CBManagerState.poweredOn{
//            central.scanForPeripherals(withServices: nil, options: nil)
//            print("Scaneando")
//        }
//    }
//
//    //Callback para quendo peripheral é descoberto
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        if peripheral.name?.contains("SensorTag") == true{
//        print(peripheral.name ?? "no name")
//        centralManager.stopScan()
//        print(advertisementData)
//        //Para conectar:
//        central.connect(peripheral, options: nil)
//        myPeripheral = peripheral
//       }
//
//    }
//    //Quando peripheral desconectar
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        central.scanForPeripherals(withServices: nil, options: nil)
//        peripheral.discoverServices(nil)
//        peripheral.delegate = self
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services{
//            for svc in services{
//                print(svc.uuid.uuidString)
//            }
//        }
//    }
//
//
//    var centralManager : CBCentralManager!
//    var myPeripheral : CBPeripheral?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        centralManager = CBCentralManager.init(delegate: self, queue: nil)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//        }
//
//    }
