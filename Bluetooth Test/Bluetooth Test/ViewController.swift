//
//  ViewController.swift
//  Bluetooth Test
//
//  Created by Han on 10/4/15.
//  Copyright © 2015 Han. All rights reserved.
//

//import UIKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//}


import UIKit
import CoreBluetooth
class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    @IBOutlet weak var tableView: UITableView!
    //添加属性
        var manager: CBCentralManager!
        var peripheral: CBPeripheral!
        var writeCharacteristic: CBCharacteristic!
    
    //保存收到的蓝牙设备
        var deviceList:NSMutableArray = NSMutableArray()
    //服务和特征的UUID
        let kServiceUUID = [CBUUID(string:"2220")]
        let kCharacteristicUUID = [CBUUID(string:"2221")]
    
    override
    func viewDidLoad() {
        super.viewDidLoad()
        //创建一个中央对象
        self.manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //检查运行这个App的设备是不是支持BLE。代理方法
    func centralManagerDidUpdateState(central: CBCentralManager){
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            //扫描周边蓝牙外设.
            //写nil表示扫描所有蓝牙外设，如果传上面的kServiceUUID,那么只能扫描出FFEO这个服务的外设。
            //CBCentralManagerScanOptionAllowDuplicatesKey为true表示允许扫到重名，false表示不扫描重名的。
            self.manager.scanForPeripheralsWithServices(kServiceUUID, options:[CBCentralManagerScanOptionAllowDuplicatesKey:false])
            print("Bluetooth Open, Start Scan")
        case CBCentralManagerState.Unauthorized:
            print("这个应用程序是无权使用蓝牙低功耗")
        case CBCentralManagerState.PoweredOff:
            print("蓝牙目前已关闭")
        default :
            print("中央管理器没有改变状态")
        }
    }

    //查到外设后，停止扫描，连接设备
    //广播、扫描的响应数据保存在advertisementData中，可以通过CBAdvertisementData 来访问它。
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
            print(peripheral.description);
            if(!self.deviceList.containsObject(peripheral)){
                    self.deviceList.addObject(peripheral)
                    self.manager.connectPeripheral(peripheral, options: nil)
            }
   //         self.tableView.reloadData()
    }

    //连接外设成功，开始发现服务
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!){
            //停止扫描外设
            self.manager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            self.peripheral.discoverServices(kServiceUUID)
    }

    //连接外设失败
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!){
            print("连接外设失败===(error)")
    }

    //请求周边去寻找它的服务所列出的特征
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
            if error != nil {
                    print("错误的服务特征:(error.localizedDescription)")
                    return
                }
            var i:Int = 0
            for service in peripheral.services! {      //@han insert '!' here
                print("Find Service:" + service.description)
                    i++
                    //发现给定格式的服务的特性
                    //
//                    if (service.UUID == kServiceUUID) {
//                        //
//                        peripheral.discoverCharacteristics(kCharacteristicUUID, forService: service as CBService)
//                        //
//                    }
                    peripheral.discoverCharacteristics(kCharacteristicUUID, forService: service as! CBService)
            }
    }

    //已搜索到Characteristics
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!){
            //
            print("Find Services with Chracteristics:" + service.description)
            if (error != nil){
                print("发现错误的特征：(error.localizedDescription)")
                    return
            }
        
            for  characteristic in service.characteristics!  {
                    //罗列出所有特性，看哪些是notify方式的，哪些是read方式的，哪些是可写入的。
                    print("Service:" + peripheral.name! + " ; Characteristics:" + characteristic.UUID.description);
                    //特征的值被更新，用setNotifyValue:forCharacteristic
//                    self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
                    self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    switch characteristic.UUID.description {
//                    case "FFE1" :
//                        //如果以通知的形式读取数据，则直接发到didUpdateValueForCharacteristic方法处理数据。
//                        self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    case "2A37" :
//                        //通知关闭，read方式接受数据。则先发送到didUpdateNotificationStateForCharacteristic方法，再通过readValueForCharacteristic发到didUpdateValueForCharacteristic方法处理数据。
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                    case "2A38" :
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                    case "Battery Level":
//                        self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    case "Manufacturer Name String":
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                    case "6E400003-B5A3-F393-E0A9-E50E24DCCA9E":
//                        self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    case "6E400002-B5A3-F393-E0A9-E50E24DCCA9E":
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                        self.writeCharacteristic = characteristic as! CBCharacteristic
//                        let heartRate: NSString = "ZhuHai XY"
//                        let dataValue: NSData = heartRate.dataUsingEncoding(NSUTF8StringEncoding)!
//                        //写入数据
//                        self.writeValue(service.UUID.description, characteristicUUID: characteristic.UUID.description, peripheral: self.peripheral, data: dataValue)
//                    default :
//                        break
//                    }
            }
    }

    //获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!,error: NSError!){
            if(error != nil){
                print("发送数据错误的特性是：(characteristic.UUID)     错误信息：(error.localizedDescription)       错误数据：(characteristic.value)")
                    return
            }
            var dataValue: UInt8 = 0
            characteristic.value!.getBytes(&dataValue, range:NSRange(location: 0, length: 1)) //@han intert !
            print(dataValue)

        
//            switch characteristic.UUID.description {
//            case "FFE1":
//                print("=(characteristic.UUID)特征发来的数据是:(characteristic.value)=")
//            case "2A37":
//                print("=(characteristic.UUID.description):(characteristic.value)=")
//            case "2A38":
//                var dataValue: Int = 0
//                characteristic.value!.getBytes(&dataValue, range:NSRange(location: 0, length: 1)) //@han intert !
//                print("2A38的值为:(dataValue)")
//            case "Battery Level":
//                //如果发过来的是Byte值，在Objective-C中直接.getBytes就是Byte数组了，在swift目前就用这个方法处理吧！
//                var batteryLevel: Int = 0
//                characteristic.value!.getBytes(&batteryLevel, range:NSRange(location:0, length:1 )) //@han intert !
//                print("当前为你检测了(batteryLevel)秒")
//            case "Manufacturer Name String":
//                //如果发过来的是字符串，则用NSData和NSString转换函数
//                let manufacturerName: NSString = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
//                print("制造商名称为:(manufacturerName)")
//            case "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" :
//                print("=(characteristic.UUID)特征发来的数据是:(characteristic.value)=")
//            case "6E400002-B5A3-F393-E0A9-E50E24DCCA9E":
//                print("返回的数据是:(characteristic.value)")
//            default :
//                break
//            }
    }
    
    //这个是接收蓝牙通知，很少用。读取外设数据主要用上面那个方法didUpdateValueForCharacteristic。
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!){
            if error != nil {
                print("更改通知状态错误：(error.localizedDescription)")
            }
            print("收到的特性数据：(characteristic.value)")
            //如果它不是传输特性,退出.
            //
            if characteristic.UUID.isEqual(kCharacteristicUUID) {
                return
            }
            //开始通知
            if characteristic.isNotifying {
                print("开始的通知(characteristic)")
                    peripheral.readValueForCharacteristic(characteristic)
            }
            else
            {
                //通知已停止
                //所有外设断开
                print("通知(characteristic)已停止设备断开连接")
                self.manager.cancelPeripheralConnection(self.peripheral)
            }
    }
    
    //写入数据
        func writeValue(serviceUUID: String, characteristicUUID: String, peripheral: CBPeripheral!, data: NSData!){
            peripheral.writeValue(data, forCharacteristic: self.writeCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            print("手机向蓝牙发送的数据为:(data)")
        }
    
    //用于检测中心向外设写数据是否成功
        func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!){
            if(error != nil){
                 print("发送数据失败!error信息:(error)")
            }
            else
            {
                print("发送数据成功(characteristic)")
            }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView)->Int {
            //#warning Potentially incomplete method implementation.
            //Return the number of sections.
            return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)->Int {
            //#warning Incomplete method implementation.
            //Return the number of rows in the section.
            return self.deviceList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
            //PCell,确定单元格的样式
            let cell = tableView.dequeueReusableCellWithIdentifier("FhrCell", forIndexPath: indexPath) as!UITableViewCell
            var device:CBPeripheral=self.deviceList.objectAtIndex(indexPath.row) as! CBPeripheral
            //主标题
                cell.textLabel?.text = device.name
            //副标题
                cell.detailTextLabel?.text = device.identifier.UUIDString
            return cell
    }
    
//    //通过选择来连接和断开外设
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if(self.peripheralList.containsObject(self.deviceList.objectAtIndex(indexPath.row))){
//                self.manager.cancelPeripheralConnection(self.deviceList.objectAtIndex(indexPath.row) as! CBPeripheral)
//                self.peripheralList.removeObject(self.deviceList.objectAtIndex(indexPath.row))
//                print("蓝牙已断开")
//        }
//        else
//        {
//                self.manager.connectPeripheral(self.deviceList.objectAtIndex(indexPath.row) as! CBPeripheral, options: nil)
//                self.peripheralList.addObject(self.deviceList.objectAtIndex(indexPath.row))
//                print("蓝牙已连接！ (self.peripheralList.count)")
//        }
//    }
}