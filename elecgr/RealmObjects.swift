import Foundation
import RealmSwift


class MarkersInfoLDB: Object {
    
    @objc dynamic var stid = ""
    @objc dynamic var busiid = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var stat: Int8 = 0
    @objc dynamic var type: Int8 = 0
    
}

class AreaInfoLDB: Object {
    
    //@objc dynamic var level : Int8 = 0
    @objc dynamic var name = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    
}

class LocationCameraLDB: Object {
    
    @objc dynamic var latcmr = 0.0
    @objc dynamic var lngcmr = 0.0

}

class RecentSearchLDB: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var dist: Int = 0
    @objc dynamic var text = ""
 // dynamic var addr = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var stid = ""
    @objc dynamic var time: Date = Date()
    
}

class FilterLDB: Object {
    
    @objc dynamic var filteron = false
    @objc dynamic var cgrable = false
    @objc dynamic var typefstr = ""
    @objc dynamic var companyfstr = ""
    let cgrtype = List<ChargerType>()
    let cgrcompany = List<ChargerCompany>()
    
    
}

class ChargerType: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var value = true

}

class ChargerCompany: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var value = true

}


class BookmarkLDB: Object {
    
    @objc dynamic var stid = ""
    @objc dynamic var name = ""
    @objc dynamic var addr = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    //@objc dynamic var time: Date = Date()
    
}


class DetailInfoLDB: Object {
    
    @objc dynamic var statnm = ""
    @objc dynamic var statid = ""
    @objc dynamic var chgerid: Int8 = 0
    @objc dynamic var chgertype: Int8 = 0
    @objc dynamic var addr = ""
    
    @objc dynamic var location = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var addcd = ""
    @objc dynamic var usetime = ""
    
    @objc dynamic var busiid = ""
    @objc dynamic var bnm = ""
    @objc dynamic var businm = ""
    @objc dynamic var busicall = ""
    @objc dynamic var stat: Int8 = 0
    
    @objc dynamic var statupddt = ""
    @objc dynamic var lasttsdt = ""
    @objc dynamic var lasttedt = ""
    @objc dynamic var nowtsdt = ""
    @objc dynamic var output: Int = 0
    
    @objc dynamic var method = ""
    @objc dynamic var zcode: Int8 = 0
    @objc dynamic var parkingfree = ""
    @objc dynamic var note = ""
    @objc dynamic var limityn = ""
    
    @objc dynamic var limitdetail = ""
    @objc dynamic var delyn = ""
    @objc dynamic var deldetail = ""

}
