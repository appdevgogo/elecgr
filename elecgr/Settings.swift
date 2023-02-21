import Foundation
import UIKit


struct ASearchInfo {
    
    //var id = UUID()
    var qtxt = ""
    var stid = ""
    var text = ""
    //var lat : Double = 0.0
    //var lng : Double = 0.0
}

struct BSearchInfo {
    
    //var id = UUID()
    var qtxt = ""
    var text = ""
    //var addr = ""
    var lat : Double = 0.0
    var lng : Double = 0.0
}

struct CSearchInfo {
    
    //var id = UUID()
    var qtxt = ""
    var text = ""
    //var addr = ""
    var lat : Double = 0.0
    var lng : Double = 0.0
}


//문자열에 html 태그가 있을시 제거해주는 함수
extension String {
    
    var withoutHtmlTags: String {
        
    return self.replacingOccurrences(of: "<[^>]+>", with: "", options:
    .regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with:
    "", options:.regularExpression, range: nil)
        
    }
    
}

extension UIColor {
    
    static let marker_green = UIColor(red: 30/255, green: 139/255, blue: 73/255, alpha: 1)
    static let marker_red = UIColor(red: 233/255, green: 77/255, blue: 78/255, alpha: 1)
    static let marker_gray = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
    
    static let marker_green_sub = UIColor(red: 195/255, green: 222/255, blue: 207/255, alpha: 1)
    static let marker_red_sub = UIColor(red: 246/255, green: 182/255, blue: 182/255, alpha: 1)
    static let marker_gray_sub = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    static let searchbar_gray = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
    
    static let filter_green = UIColor(red: 45/255, green: 191/255, blue: 79/255, alpha: 1)
    
    static let bookmark_yellow = UIColor(red: 255/255, green: 228/255, blue: 63/255, alpha: 1)
    
    
}

extension UISwitch {

    func set(width: CGFloat, height: CGFloat) {

        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51

        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth

        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}


func timeDiffer(time : String) -> String{
    
    let now = Date()

    let date_kr = DateFormatter()
    date_kr.locale = Locale(identifier: "ko_kr")
    date_kr.timeZone = TimeZone(abbreviation: "KST")
    date_kr.dateFormat = "yyyy-MM-dd HH:mm:ss"

    let timenow = date_kr.string(from: now)
    let timerecode = String(time.prefix(19))
    
    let diffsnow = date_kr.date(from: timenow)!
    let diffsrecode = date_kr.date(from: timerecode)!
    
    print(diffsnow)

    let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: diffsrecode, to: diffsnow)
    
    var result = ""
    
    if diffs.year! > 0 {
        
        result = String(diffs.year!) + "년전"
    
    } else if diffs.month! > 0 {
        
        result = String(diffs.month!) + "개월전"
        
    } else if diffs.day! > 0 {
        
        result = String(diffs.day!) + "일전"
        
    } else if diffs.hour! > 0 {
        
        result = String(diffs.hour!) + "시간전"
        
    } else if diffs.minute! > 0 {
        
        result = String(diffs.minute!) + "분전"
        
    } else if diffs.second! >= 0 {
        
        result = "방금전"
    
    } else {
        
        result = ""
        
    }
    
    return result
        
}

enum AppInfo: String {
    
    case id = "1619116825"
    
}
/*
func latestVersion() -> String? {
    
    let appleID = "1619116825"
    guard let url = URL(string: "http://itunes.apple.com/lookup?id=\(appleID)"),
          let data = try? Data(contentsOf: url),
          let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
          let results = json["results"] as? [[String: Any]],
          let appStoreVersion = results[0]["version"] as? String else {
        return nil
    }
    
    return appStoreVersion
}
*/

