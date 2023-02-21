import UIKit
import NMapsMap
import Combine
import SideMenu
import RealmSwift

class Main: UIViewController, CLLocationManagerDelegate, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
    
    let mapView = NMFMapView(frame : CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let group = DispatchGroup()
    
    //마커관련 변수
    var markers: [NMFMarker] = [] //마커배열
    var markersOld: [NMFMarker] = [] //마커배열 old
    var markersCL: [NMFMarker] = [] //마커배열 현재위치
    let markerAble = NMFOverlayImage(name: "marker_able")
    let markerDisable = NMFOverlayImage(name: "marker_disable")
    let markerNo = NMFOverlayImage(name: "marker_no")
    let markerSquare = NMFOverlayImage(name: "marker_sq_green")
    
    //위치 관련 변수선언
    var locationManager: CLLocationManager!
    var cLocationIs: Bool = false
    //var initLoading: Bool = false
    var latori: Double = 0.0
    var lngori: Double = 0.0
    
    override func viewDidLoad() {
        
        checkVersion()
        
        //테스트 용도로 ream local db 를 삭제하는 코딩
        /*
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        
        let realmURLs = [
          realmURL,
          realmURL.appendingPathExtension("lock"),
          realmURL.appendingPathExtension("note"),
          realmURL.appendingPathExtension("management")
        ]
        _ = FileManager.default
        for URL in realmURLs {
          do {
            try FileManager.default.removeItem(at: URL)
          } catch {
            
          }
        }
        */
        
        //print(Realm.Configuration.defaultConfiguration.fileURL!)

        super.viewDidLoad()
        
        //필터 초기값 로딩
        Filter().initLoading()
        
        //첫페이지 로딩시 네비게이션바의 공통적인 세팅
        self.navigationController?.navigationBar.barTintColor = .white
        
        //네이버 지도 기본 설정들(네이버지도 설명서 참고)
        mapView.addCameraDelegate(delegate: self)
        mapView.logoAlign = .rightBottom
        mapView.logoMargin = .init(top: 0, left: 0, bottom: 30, right: 0)
        mapView.isTiltGestureEnabled = false
        mapView.isRotateGestureEnabled = false
        mapView.minZoomLevel = 6.0
        mapView.maxZoomLevel = 19.0
        
        //네이버 맵뷰 세팅
        view.addSubview(mapView)
        
        self.setMainBtns()
        
        //gps 함수 설정
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters or kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //초기위치 Map 위치 설정
        initLocation()
        
        /*
        let (cameraRtop, cameraRbottom, cameraRright, cameraRleft) = cameraRange()
        self.getMarkersInfo(t: cameraRtop, b: cameraRbottom, r: cameraRright, l: cameraRleft)
        
        DispatchQueue.main.async {
            self.getMarkersfromLocalDB()
        }
         */
        
        NotificationCenter.default.addObserver(self, selector: #selector(callCameraUpdate(_:)), name: Notification.Name(rawValue: "callCameraUpdate"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(callMarkersFromLocalDB(_:)), name: Notification.Name(rawValue: "callMarkersFromLocalDB"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    @objc func sideMenuAction(sender: UIButton!) {
             
        //사이드메뉴 뷰컨트롤러 객채 생성 및 커스텀 네이게이션 뷰컨트롤러(사이드메뉴 속성설정) 연결
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sideMenu: SideMenu = storyboard.instantiateViewController(withIdentifier: "SideMenu") as! SideMenu
        let menu = SideMenuNavigation(rootViewController: sideMenu)
            
        //메뉴보여주기
        present(menu, animated: true, completion: nil)
        
    }
    
    @objc func searchAction(sender: UIButton!) {

        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Search"){
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
                
    }
    
    @objc func filterAction(sender: UIButton!) {

        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Filter"){
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
                
    }
    
    @objc func bookMarkAction(sender: UIButton!) {

        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "BookMark"){
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
                
    }
    
    @objc func changeMapAction(sender: UIButton!) {
        
        let rBtnsImgConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .default)
        let iconChangeMap1 = UIImage(systemName: "square.on.square", withConfiguration: rBtnsImgConfig)
        let iconChangeMap2 = UIImage(systemName: "square.filled.on.square", withConfiguration: rBtnsImgConfig)
        
        switch sender.tag {
            
        case 0:
            sender.setImage(iconChangeMap2, for: .normal)
            mapView.mapType = .hybrid
            sender.tag = 1
            
        default:
            mapView.mapType = .basic
            sender.setImage(iconChangeMap1, for: .normal)
            sender.tag = 0

        }
        
        /*
        let realm = try! Realm()
        let toAdd = ChangeMapLDB()
        
        if let initMap = realm.objects(ChangeMapLDB.self).first {
            
            switch initMap.type {
            
            case "normal":
                sender.setImage(iconChangeMap2, for: .normal)
                mapView.mapType = .hybrid
                toAdd.type = "statellite"
                
                
            case "statellite":
                sender.setImage(iconChangeMap1, for: .normal)
                mapView.mapType = .basic
                toAdd.type = "normal"
            
            default:
                mapView.mapType = .hybrid
                
            }
            
            try! realm.write {
                 realm.delete(initMap)
            }
            
        } else {
            sender.setImage(iconChangeMap2, for: .normal)
            mapView.mapType = .satellite
            toAdd.type = "statellite"
            
        }
        
        try! realm.write {
            realm.add(toAdd)
        }
        */
        
    }
    
    @objc func cLocationAction(sender: UIButton!) {
        
        cLocationIs = true
        locationManager.startUpdatingLocation()
        //print("현재위치 버튼 클릭됨")

    }
    
    @objc func detailAction(sender: String) {

        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as? Detail{
            
            controller.statId = sender
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
                
    }
    
    //외부 Class에서 카메라 업데이트를 부를때 사용
    @objc func callCameraUpdate(_ notification: Notification) {
        
        //zoom은 기본 14.0으로 설정됨
        cameraUpdatingwithzoom(lat: notification.userInfo?["lat"] as! Double, lng: notification.userInfo?["lng"] as! Double, zto: 14.0)

    }
    
    @objc func callMarkersFromLocalDB(_ notification: Notification) {
        
        getMarkersfromLocalDB()
        
    }
    
    func checkVersion() {
        
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=\(AppInfo.id.rawValue)"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let appStoreVersion = results[0]["version"] as? String else {
            return ()
        }

        let installedVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String //현재기기에 설치되어 있는 App버젼
        let compareResult = installedVersion.compare(appStoreVersion, options: .numeric)
        
        print(installedVersion)
        print(appStoreVersion)
        
        switch compareResult {
            
        case .orderedAscending:
            
            print("설치된 App이 최신버젼이 아닙니다. 업데이트 필요합니다.")
            updateVersion()
            
        case .orderedDescending:
            print("설치된 App이 최신버젼 입니다.")
            
        case .orderedSame:
            print("설치된 App이 최신버젼 입니다. ")
        }
        
    }
    
    func updateVersion() {
        
        let alert = UIAlertController(title: "알림", message: "원활한 사용을 위해 최신버젼의 앱(App) 업데이트가 필요합니다.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "업데이트 하러가기", style: .default) { action in

            let url = "itms-apps://itunes.apple.com/app/" + AppInfo.id.rawValue;
            
            if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            }

        })
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //버튼 구성
    func setMainBtns() {
        
        let screenWidth = view.frame.width //또는 let screenSize = UIScreen.main.bounds.width
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let topSafeArea: CGFloat = (windowScene?.windows.first?.safeAreaInsets.top)!
        
        let rBtnsTMargin: CGFloat = 50 + topSafeArea
        let rBtnsSMargin: CGFloat = 5
        let rBtnsWidth: CGFloat = 50
        let rBtnsHeight: CGFloat = 40
        let rBtnsSpacing: CGFloat = 15
        
        var rBtnsConfig = UIButton.Configuration.plain()
        
        rBtnsConfig.background.backgroundColor = .white
        rBtnsConfig.background.strokeColor = UIColor.systemGray5
        rBtnsConfig.background.strokeWidth = 1
        rBtnsConfig.background.cornerRadius = 20
        rBtnsConfig.baseForegroundColor = UIColor.darkGray

        let rBtnsImgConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .default)
        
        let iconSearch = UIImage(systemName: "magnifyingglass", withConfiguration: rBtnsImgConfig)
        let iconFilter = UIImage(systemName: "slider.horizontal.3", withConfiguration: rBtnsImgConfig)
        let iconBookMark = UIImage(systemName: "star", withConfiguration: rBtnsImgConfig)
        let iconChangeMap = UIImage(systemName: "square.on.square", withConfiguration: rBtnsImgConfig)
        let iconCLocation = UIImage(systemName: "smallcircle.fill.circle", withConfiguration: rBtnsImgConfig)
        
        
        
        //let bottomSafeArea = window.safeAreaInsets.bottom
        
        /*
        let topBtnsTMargin = 50 + topSafeArea
        let topBtnsSMargin = 25
        let topBtnsSWidth = 50
        let topBtnsHeight = 40
        
        let topBtnsConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .default)
        let iconMenu = UIImage(systemName: "text.justify", withConfiguration: topBtnsConfig)
        let iconSearch = UIImage(systemName: "magnifyingglass", withConfiguration: topBtnsConfig)
        let iconFilter = UIImage(systemName: "slider.horizontal.3", withConfiguration: topBtnsConfig)
        */
        
        /*
        let topLBtn = UIButton(frame: CGRect(x: topBtnsSMargin, y: topBtnsTMargin, width: topBtnsSWidth, height: topBtnsHeight))
        topLBtn.backgroundColor = .white
        topLBtn.clipsToBounds = true
        topLBtn.layer.cornerRadius = 10
        topLBtn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner] //버튼 왼쪽방향 라운드처리
        topLBtn.setImage(iconMenu, for: .normal)
        topLBtn.tintColor = UIColor.systemGray
        topLBtn.addTarget(self, action: #selector(sideMenuAction), for: .touchUpInside)
        
        self.view.addSubview(topLBtn)
        
        
        let topMBtn = UIButton(frame: CGRect(x: topBtnsSMargin + topBtnsSWidth, y: topBtnsTMargin, width: screenWidth - (topBtnsSMargin*2 + topBtnsSWidth*2), height: topBtnsHeight))
        topMBtn.backgroundColor = .white
        topMBtn.setTitle("충전소이름, 장소, 주소 검색", for: .normal)
        topMBtn.contentHorizontalAlignment = .left
        topMBtn.titleLabel?.font = .systemFont(ofSize: 16)
        topMBtn.setTitleColor(UIColor.systemGray4, for: .normal)
        topMBtn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        
        self.view.addSubview(topMBtn)
        
        
        let topRBtn = UIButton(frame: CGRect(x: screenWidth - (topBtnsSMargin + topBtnsSWidth), y: topBtnsTMargin, width:  topBtnsSWidth, height: topBtnsHeight))
        topRBtn.backgroundColor = .white
        topRBtn.clipsToBounds = true
        topRBtn.layer.cornerRadius = 10
        topRBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner] //버튼 오른쪽방향 라운드처리
        topRBtn.setImage(iconSearch, for: .normal)
        topRBtn.tintColor = UIColor.systemGray
        topRBtn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        
        self.view.addSubview(topRBtn)
        */
        
        let searchBtn = UIButton(configuration: rBtnsConfig, primaryAction: nil)
        searchBtn.frame = CGRect(x: screenWidth - (rBtnsSMargin + rBtnsWidth), y: rBtnsTMargin, width:  rBtnsWidth, height: rBtnsHeight)
        searchBtn.setImage(iconSearch, for: .normal)
        searchBtn.layer.shadowOpacity = 0.1
        searchBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBtn.layer.shadowRadius = 2
        searchBtn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        
        self.view.addSubview(searchBtn)
        
        
        let filterBtn = UIButton(configuration: rBtnsConfig, primaryAction: nil)
        filterBtn.frame = CGRect(x: screenWidth - (rBtnsSMargin + rBtnsWidth), y: rBtnsTMargin + rBtnsHeight + rBtnsSpacing, width:  rBtnsWidth, height: rBtnsHeight)
        filterBtn.setImage(iconFilter, for: .normal)
        filterBtn.layer.shadowOpacity = 0.1
        filterBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        filterBtn.layer.shadowRadius = 2
        filterBtn.addTarget(self, action: #selector(filterAction), for: .touchUpInside)
        
        self.view.addSubview(filterBtn)
        
        
        let bookmarkBtn = UIButton(configuration: rBtnsConfig, primaryAction: nil)
        bookmarkBtn.frame = CGRect(x: screenWidth - (rBtnsSMargin + rBtnsWidth), y: rBtnsTMargin + rBtnsHeight*2 + rBtnsSpacing*2, width:  rBtnsWidth, height: rBtnsHeight)
        bookmarkBtn.setImage(iconBookMark, for: .normal)
        bookmarkBtn.layer.shadowOpacity = 0.1
        bookmarkBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        bookmarkBtn.layer.shadowRadius = 2
        bookmarkBtn.addTarget(self, action: #selector(bookMarkAction), for: .touchUpInside)
        
        self.view.addSubview(bookmarkBtn)
        
        
        let changeMapBtn = UIButton(configuration: rBtnsConfig, primaryAction: nil)
        changeMapBtn.frame = CGRect(x: screenWidth - (rBtnsSMargin + rBtnsWidth), y: rBtnsTMargin + rBtnsHeight*3 + rBtnsSpacing*3, width:  rBtnsWidth, height: rBtnsHeight)
        changeMapBtn.setImage(iconChangeMap, for: .normal)
        changeMapBtn.layer.shadowOpacity = 0.1
        changeMapBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        changeMapBtn.layer.shadowRadius = 2
        changeMapBtn.tag = 0
        changeMapBtn.addTarget(self, action: #selector(changeMapAction), for: .touchUpInside)
        
        self.view.addSubview(changeMapBtn)
        
        
        let cLocationBtn = UIButton(configuration: rBtnsConfig, primaryAction: nil)
        cLocationBtn.frame = CGRect(x: screenWidth - (rBtnsSMargin + rBtnsWidth), y: rBtnsTMargin + rBtnsHeight*4 + rBtnsSpacing*4, width:  rBtnsWidth, height: rBtnsHeight)
        cLocationBtn.setImage(iconCLocation, for: .normal)
        cLocationBtn.layer.shadowOpacity = 0.1
        cLocationBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        cLocationBtn.layer.shadowRadius = 2
        cLocationBtn.addTarget(self, action: #selector(cLocationAction), for: .touchUpInside)
        
        self.view.addSubview(cLocationBtn)
        
    }
    
    //초기로딩시 위치 설정해주는 함수(현재 실제위치로 설정 OR 과거 맵뷰 위치로)
    func initLocation(){
                           
        let realm = try! Realm()
        
        if let initLocation = realm.objects(LocationCameraLDB.self).first {
            
            //print(initLocation.latcmr as Double)
            //print(initLocation.lngcmr as Double)
            
            cameraUpdating(lat: initLocation.latcmr as Double, lng: initLocation.lngcmr as Double)
            
        } else {
            
            print("초기 이동시 LocationCameraLDB에 값이 업어 현재 위치로 이동")
            locationManager.startUpdatingLocation()
        }
        
    }
    
    //카메라 이동 또는 축소확대 직후 실행되는 함수(마커, 생성 삭제 포함)
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        
       // print("mapViewCameraIdle실행 == 카메라 이동됨")
        
        let realm = try! Realm()
        
        let toDel = realm.objects(LocationCameraLDB.self)
        
        try! realm.write {
             realm.delete(toDel)
        }
        
        //최신 카메라위치 정보(위경도)를 로컬db에 저장함
        let lastcmr = LocationCameraLDB()
        lastcmr.latcmr = mapView.cameraPosition.target.lat
        lastcmr.lngcmr = mapView.cameraPosition.target.lng
        
        try! realm.write {
            realm.add(lastcmr)
        }
        
        //네이버지도에 보여진 마커 모두 삭제
        for marker in markers{
            marker.mapView = nil
        }

        //markers 배열에 있는 마커 모두 삭제
        markers.removeAll()
        
        
        let zoom = mapView.cameraPosition.zoom
        
       // print(zoom)
        
        //카메라 이동후 변경된 카메라 범위정보(위경도)를 받아오는 함수
        let (cameraRtop, cameraRbottom, cameraRright, cameraRleft) = cameraRange()
        
       // print(cameraRtop, cameraRbottom, cameraRright, cameraRleft)
        
        if zoom > 13.0 {
            
            //변경된 카메라 범위를 AWS에 재요청하여 범위내 충전소 정보(id,위경도,충전기상태)를 받아오는 함수
            getMarkersInfo(t: cameraRtop, b: cameraRbottom, r: cameraRright, l: cameraRleft)
            
            //로컬db에 저장된 자료를 불러와 지도에 마커 등을 보여주는 함수
            getMarkersfromLocalDB()
            
        } else if zoom > 12.0 {
            
            print("동표시")
            let level : Int8 = 3
            
            getAreaInfo(t: cameraRtop, b: cameraRbottom, r: cameraRright, l: cameraRleft, level: level)
            getAreafromLocalDB(level: level)
            
        } else if zoom > 10.0 {
            
            print("시군구표시")
            let level : Int8 = 2
            
            getAreaInfo(t: cameraRtop, b: cameraRbottom, r: cameraRright, l: cameraRleft, level: level)
            getAreafromLocalDB(level: level)
            
        } else {
            
            print("특별시도표시")
            let level : Int8 = 1
            
            getAreaInfo(t: cameraRtop, b: cameraRbottom, r: cameraRright, l: cameraRleft, level: level)
            getAreafromLocalDB(level: level)
        }

    }
    
    //사용자의 실제 현재위치(GPS연동)에 대한 정보를 가져오는 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        //print("@@현재 위치 정보 : \(locValue.latitude) \(locValue.longitude)")
        
        latori = locValue.latitude
        lngori = locValue.longitude
        
        cameraUpdating(lat: latori, lng: lngori)
        
        locationManager.stopUpdatingLocation()
        
        
        if cLocationIs {
            
            let locationOverlay = mapView.locationOverlay
            locationOverlay.location = NMGLatLng(lat: latori, lng: lngori)
            locationOverlay.hidden = false
                
            cLocationIs = false
            
        }
        
    }
    
    //현재 위치(GPS기준)이동하는 것이 실패했을때 실행되는 함수
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 사용자가 장치에서 위치 서비스를 활성화하지 않았을때나,
        // 건물 내부에 있어 GPS 신호가 잡히지 않을 경우.
        // 예를 들자면 사용자에게 GPS 신호가 있는 장소로 걸어가라고 요청하는 경고를 표시하는 것이 좋습니다.
        
        print("GPS 신호가 불안정 합니다.")
    }
    
    
    //카메라 범위 가져오는 함수
    func cameraRange() -> (Double, Double, Double, Double) {
        
        //스크린원점(왼쪽상단)에서의 위경도
        let olat = mapView.projection.latlng(from: CGPoint(x: 0, y: 0)).lat
        let olng = mapView.projection.latlng(from: CGPoint(x: 0, y: 0)).lng
        
        //마커를 보여주기위한 위경도상 범위 설정 함수
        let cameraRlat = olat - mapView.cameraPosition.target.lat
        let cameraRlng = mapView.cameraPosition.target.lng - olng
        
        let cameraRtop = mapView.cameraPosition.target.lat + cameraRlat
        let cameraRbottom = mapView.cameraPosition.target.lat - cameraRlat
        let cameraRright = mapView.cameraPosition.target.lng + cameraRlng
        let cameraRleft = mapView.cameraPosition.target.lng - cameraRlng
        
        return (cameraRtop, cameraRbottom, cameraRright, cameraRleft)
        
    }
    
    //지도상 보여주는(=카메라) 위치 임의 변경해주는 함수
    func cameraUpdating(lat : Double, lng : Double) {
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
        //saveLocationRecent(lat: lat, lng: lng)

    }
    
    //지도상에 특정줌으로 변하면 법정동 구역의 위치로 임의 변경해주는 함수
    func cameraUpdatingwithzoom(lat : Double, lng : Double, zto : Double) {
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng), zoomTo: zto)
        mapView.moveCamera(cameraUpdate)
        //saveLocationRecent(lat: lat, lng: lng)

    }
    
    //AWS Lambda에 지도범위 위경도 파라미터를 요청하여 지도범위내 결과값(JSON Array)을 받아와 Local DB에 저장함
    func getMarkersInfo(t : Double, b : Double, r : Double, l : Double) {
        
        let rawEndPoint = EndPoint.getMarksInfo.rawValue
        let parameterString = "?t_lat=\(t)&b_lat=\(b)&r_lng=\(r)&l_lng=\(l)"
        
        let endPoint = rawEndPoint + parameterString
        
        let url = NSURL(string: endPoint)
        let session = URLSession.shared
        
        let realm = try! Realm()
        
        let toDel = realm.objects(MarkersInfoLDB.self)
        
        try! realm.write {
             realm.delete(toDel)
        }
        
        group.enter()

        let task = session.dataTask(with: url! as URL, completionHandler:
        {
            (data, response, error) -> Void in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers])
                
                guard let newValue = jsonResult as? [Any] else {
                    print("data type error")
                    return
                    
                }
                
                var mArray: [MarkersInfoLDB] = []
                
                for item in newValue{
                
                    if let stdata = item as? [Any]{
                        
                        let markersInfoDB = MarkersInfoLDB()
                        
                        markersInfoDB.stid = stdata[0] as! String
                        markersInfoDB.busiid = stdata[1] as! String
                        markersInfoDB.lat = stdata[2] as! Double
                        markersInfoDB.lng = stdata[3] as! Double
                        markersInfoDB.stat = stdata[4] as! Int8
                        markersInfoDB.type = stdata[5] as! Int8
                        
                        mArray.append(markersInfoDB)

                    }
                    
                }
                
                //아래 위치에 realm add가 들어가야 함(중요!)
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(mArray)
                }
                
            } catch {
                print("data receive error")
                
            }
            self.group.leave() //데이터 수집 종료시점
            
        })
        task.resume()

    }
    
    func getAreaInfo(t : Double, b : Double, r : Double, l : Double, level : Int8) {
        
        let rawEndPoint = EndPoint.getAreaInfo.rawValue
        let parameterString = "?t_lat=\(t)&b_lat=\(b)&r_lng=\(r)&l_lng=\(l)&level=\(level)"
        
        let endPoint = rawEndPoint + parameterString
        
        let url = NSURL(string: endPoint)
        let session = URLSession.shared
        
        let realm = try! Realm()
        
        let toDel = realm.objects(AreaInfoLDB.self)
        
        try! realm.write {
             realm.delete(toDel)
        }
        
        group.enter()

        let task = session.dataTask(with: url! as URL, completionHandler:
        {
            (data, response, error) -> Void in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers])
                
                guard let newValue = jsonResult as? [Any] else {
                    print("data type error")
                    return
                    
                }
                
                let mArray = List<AreaInfoLDB>()
                
                for item in newValue{
                    
                    if let stdata = item as? [Any]{
                        
                        let areaInfoDB = AreaInfoLDB()
                        
                       // areaInfoDB.level = stdata[0] as! Int8
                        areaInfoDB.name = stdata[0] as! String
                        areaInfoDB.lat = stdata[1] as! Double
                        areaInfoDB.lng = stdata[2] as! Double
                        
                        mArray.append(areaInfoDB)

                    }
                    
                }
                
                //아래 위치에 realm add가 들어가야 함(중요!)
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(mArray)
                }
                
            } catch {
                print("data receive error")
                
            }
            self.group.leave() //데이터 수집 종료시점
            
        })
        task.resume()

    }
    
    func markersShowing(item : MarkersInfoLDB, numtotal: String, numable : String, check: String) {
        
        let marker = NMFMarker()
        
        marker.userInfo = ["tag": item.stid]
        marker.position = NMGLatLng(lat: item.lat, lng: item.lng)

        marker.width = 38
        marker.height = 55
        
        switch check {
        
        case "allcharging":
            marker.iconImage = markerDisable
            marker.captionText = numable
            marker.captionColor = .marker_red
            marker.subCaptionColor = .marker_red_sub
            
        case "disable":
            marker.iconImage = markerNo
            marker.captionText = "-"
            marker.captionColor = .marker_gray
            marker.subCaptionColor = .marker_gray_sub
            
        default:
            marker.iconImage = markerAble
            marker.captionText = numable
            marker.captionColor = .marker_green
            marker.subCaptionColor = .marker_green_sub
        }
        
        marker.captionAligns = [NMFAlignType.top]
        marker.captionOffset = -45
        marker.captionTextSize = 20
        marker.captionHaloColor = UIColor.clear
        marker.subCaptionText = numtotal
        marker.subCaptionTextSize = 11
        //marker.subCaptionColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        marker.subCaptionHaloColor = UIColor.clear
        
        marker.mapView = mapView
        marker.touchHandler = { (overlay) -> Bool in
            
            //print("터치되었음")
            self.detailAction(sender : item.stid)
                
            return false
        }
        
        markers.append(marker)

    }
    
    func areaShowing(item : AreaInfoLDB, level : Int8) {
        
        let marker = NMFMarker()

        marker.position = NMGLatLng(lat: item.lat, lng: item.lng)
        
        switch item.name.count {
            
        case 4:
            marker.width = 65
        case 5:
            marker.width = 75
        case 6:
            marker.width = 85
        case 7:
            marker.width = 95
        default:
            marker.width = 55
            
        }
        
        marker.height = 40
        marker.iconImage = markerSquare
        marker.captionText = item.name
        marker.captionAligns = [NMFAlignType.top]
        marker.captionOffset = -27
        marker.captionTextSize = 12
        marker.captionColor = .white
        marker.captionHaloColor = UIColor.clear
        marker.mapView = mapView

        DispatchQueue.main.async{
            
            marker.touchHandler = { (overlay) -> Bool in
                
                var zto = 0.0
                
                if level == 3 {
                    
                    zto = 14.0
                    
                } else if level == 2 {
                    
                    zto = 12.5
                    
                } else if level == 1 {
                    
                    zto = 11.0
                }
                    
                self.cameraUpdatingwithzoom(lat: marker.position.lat, lng: marker.position.lng, zto: zto)
                
                
                return false
            }
        }
        
        markers.append(marker)

    }
    
    func getMarkersfromLocalDB() {
        
        let realm = try! Realm()
        
        group.wait()
        
        realm.refresh()
        
        //아래 마커들 추가 삭제하는 이유는 필터on->off시 중복으로 생성되는것을 방지
        for marker in markers{
            marker.mapView = nil
        }

        markers.removeAll()
        
        let filteron = realm.objects(FilterLDB.self).first?.filteron
        let onlycgrable = realm.objects(FilterLDB.self).first?.cgrable

        var cMulti : String = ""

        switch filteron {
        
        case true :
            
            let fbusiidstr = realm.objects(FilterLDB.self).first!.companyfstr as String
            let ftypestr = realm.objects(FilterLDB.self).first!.typefstr as String
            // .filter("(busiid = 'CV' OR busiid = 'ST') AND (type = 6)")
            for item in realm.objects(MarkersInfoLDB.self).filter("(\(fbusiidstr)) AND (\(ftypestr))"){
                
                if !(cMulti == item.stid) {
                    
                    let numtotal = realm.objects(MarkersInfoLDB.self).filter("stid = '\(item.stid)' AND (\(ftypestr))") //총 충전기 수(필터됨)
                    let numable = realm.objects(MarkersInfoLDB.self).filter("stid = '\(item.stid)' AND (\(ftypestr)) AND stat = 2") //충전가능 수(필터됨)
                    let numcharging = realm.objects(MarkersInfoLDB.self).filter("stid = '\(item.stid)' AND (\(ftypestr)) AND stat = 3") //충전중 수(필터됨)
                    
                    var check = ""
                    
                    if numable.count > 0 {
                        
                        check = "able"
                        markersShowing(item : item, numtotal: String(numtotal.count), numable: String(numable.count), check: check)
                        
                    } else if numable.count == 0 && numcharging.count > 0 && onlycgrable == false {
                         
                        check = "allcharging"
                        markersShowing(item : item, numtotal: String(numtotal.count), numable: String(numable.count), check: check)
                            
                    } else if numable.count == 0 && numcharging.count == 0 && onlycgrable == false {
                            
                        check = "disable"
                        markersShowing(item : item, numtotal: String(numtotal.count), numable: String(numable.count), check: check)
                            
                    }
                    
                }
                
                cMulti = item.stid
                
            }
            
        default:
            
            for item in realm.objects(MarkersInfoLDB.self){
                
                if !(cMulti == item.stid) {
                    
                    let numtotal = realm.objects(MarkersInfoLDB.self).filter("stid = '\(item.stid)'")//충전소의 총 충전기 수
                    let numable = realm.objects(MarkersInfoLDB.self).filter("stid = '\(item.stid)' AND stat = 2") //충전가능 충전기 수
                    let numcharging = realm.objects(MarkersInfoLDB.self).filter("stid = '\(item.stid)' AND stat = 3") //충전충 충전기 수
                    
                    var check = ""
                    
                    if numable.count > 0 {
                        
                        check = "able"
                        
                    } else if numable.count == 0 && numcharging.count > 0 {
                         
                        check = "allcharging"
                            
                    } else if numable.count == 0 && numcharging.count == 0 {
                            
                        check = "disable"
                            
                    }
                    
                    markersShowing(item : item, numtotal: String(numtotal.count), numable: String(numable.count), check: check)
            
                }
                
                cMulti = item.stid
                
            }
        }
        
    }
    
    func getAreafromLocalDB(level : Int8) {
        
        let realm = try! Realm()
        
        group.wait()
        
        realm.refresh()
        
        for item in realm.objects(AreaInfoLDB.self){
            
            areaShowing(item : item, level: level)
     
        }

    }
    
}

