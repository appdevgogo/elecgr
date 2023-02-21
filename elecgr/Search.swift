import UIKit
import RealmSwift
import NMapsMap

class Search: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let group = DispatchGroup()
    
    var isSearching: Bool = false
    let cellIdentifier: String = "cell"
    
    var rSearchArray: [RecentSearchLDB] = []
    var aSearchArray: [ASearchInfo] = []
    var bSearchArray: [BSearchInfo] = []
    var cSearchArray: [CSearchInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
        addBackButton()
        addSearchBar()
        loadRecentSearch()
        
        //키보드 사이즈에 맞게 스크롤 범위 재설정
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        //스크롤시 스마폰 키보드 사라지게 하는 기능
        //tableView.keyboardDismissMode = .onDrag

    }
    
    @objc func backAction(_ sender: UIButton) {
        
       self.navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteRSearch(sender: UIButton!) {
        
        let idxpath = IndexPath(row: sender.tag, section: 0)
        
        let realm = try! Realm()
        
        //print(sender.accessibilityLabel!)
        let checkid = sender.accessibilityLabel!
        
        let toDel = realm.objects(RecentSearchLDB.self).filter("id == '\(checkid)'")
            
        try! realm.write {
            realm.delete(toDel)
        }

        rSearchArray.remove(at: sender.tag)
        tableView.deleteRows(at: [idxpath], with: .none)
        
        tableView.reloadData()
        
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }

    
    func addSearchBar(){
        
        //네비게이션 title위치에 searchbar를 삽입
        let searchBar = UISearchBar()
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
        
        //searchbar 기본설정
        searchBar.placeholder = "충전소명, 장소, 행정구역 검색"
        searchBar.searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: searchBar.searchTextField.frame.size.height))
        searchBar.searchTextField.backgroundColor = .searchbar_gray
        
    }
    
    //searchbar에서 검색버튼 눌렀을때 키보드 사라지게 하는 함수
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
    }
    
    func addBackButton() {
            
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .large)
        let imgObj = UIImage(systemName: "arrow.backward", withConfiguration: imgConfig)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        let btnBack = UIButton(frame: CGRect(x: -15, y: 0, width: 60, height: 45))
        btnBack.setImage(imgObj, for: .normal)
        btnBack.tintColor = .black
        btnBack.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        containerView.addSubview(btnBack)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
    
    func loadRecentSearch(){
               
        rSearchArray = []
        
        let realm = try! Realm()
        
        for item in realm.objects(RecentSearchLDB.self){
            
            rSearchArray.append(item)
            
        }
        
        rSearchArray.reverse()
        
    }
    
    //Section 몇개 되는지 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //print("numberOfSection 실행")
        
        if isSearching {
            
            return 3
            
        } else {
            
            return 1
            
        }
        
    }
    
    //Section Header 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
       // print("titleForHeaderInSection 실행")

        if isSearching {
            
            switch section {
            
            case 0:
                return "충전소 바로가기"
                
            case 1:
                return "장소주변 지도로 보기"
                
            case 2:
                return "행정구역 지도로 보기"
                
            default:
                return ""
            }

        } else {
        
            return "최근검색"
        
        }
        
    }
    
    //Section Header Title 텍스트 크기 등 변경 가능
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        //print("willDisplayHeaderView 실행")
    
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        header.textLabel?.textColor = UIColor.lightGray
       // header.contentView.backgroundColor = .blue
        

    }
    
    //storyboard에서 설정 가능(아래 코딩을 사용하면 함수안에 코드가 셀 변경될때마다 계속 실행됨)
    //Section Hearder(위공간) 높이 설정
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
            
        case 0:
            
            return 25
            
        default:
            
            return 40
            
        }
        
        

    }
    
    //Section Footer(아래공간) 높이 설정
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return .leastNormalMagnitude
    }
    
    
    //Row 숫자 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       // print("---------------------numberOfRowsInSection 실행")
        
        if isSearching {
            
            switch section {
            
            case 0:
                return self.aSearchArray.count
                            
            case 1:
                return self.bSearchArray.count
                
            case 2:
                return self.cSearchArray.count
                
            default:
                return 0
            }
            
        } else {
        
            return self.rSearchArray.count
            
        }
        
    }
    
    //+++++++++++++++ 각각 Row에 들어가는 View 설정(Row 숫자만큼 실행됨)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print("-------- cellForRowAt 실행")
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        var img = UIImage(systemName: "bolt.car")
        var qtxt : String = ""
        var text : String = ""
        
        if isSearching {
            
            switch indexPath.section {
            
            case 0:
                qtxt = self.aSearchArray[indexPath.row].qtxt
                text = self.aSearchArray[indexPath.row].text
                img = UIImage(systemName: "bolt.car")
                
            case 1:
                qtxt = self.bSearchArray[indexPath.row].qtxt
                text = self.bSearchArray[indexPath.row].text
                img = UIImage(systemName: "location")
                
            case 2:
                qtxt = self.cSearchArray[indexPath.row].qtxt
                text = self.cSearchArray[indexPath.row].text
                img = UIImage(systemName: "aspectratio")
            
            default:
                print("")
                
            }
            
            let attrString : NSMutableAttributedString = NSMutableAttributedString(string: text)
            let range = (text as NSString).range(of: qtxt, options: .caseInsensitive)
            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.marker_green , range: range)
            cell.textLabel?.attributedText = attrString
            cell.accessoryView = nil
            
        } else {
            
            switch self.rSearchArray[indexPath.row].dist {
            
            case 0:
                img = UIImage(systemName: "bolt.car")
                
            case 1:
                img = UIImage(systemName: "location")
                
            case 2:
                img = UIImage(systemName: "aspectratio")
            
            default:
                print("")
            }
            
            text = self.rSearchArray[indexPath.row].text
            
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "multiply"), for: .normal)
            button.tintColor = UIColor.systemGray4
            button.tag = indexPath.row //delete 할때 중요한 요소임(sender에 해당정보를 받아옴 tag는 int만 가능)
            button.accessibilityLabel = rSearchArray[indexPath.row].id
            button.addTarget(self, action: #selector(deleteRSearch), for: .touchUpInside)
            button.sizeToFit()
            
            cell.accessoryView = button
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = text

        }
        
        //cell.textLabel?.font = UIFont.systemFont(ofSize: 30.0)
        cell.imageView?.image = img

        return cell
    }
    
    //Row를 클릭했을때 실행되는 것
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       // print(indexPath)
        
        if isSearching {
            
            let rsearch = RecentSearchLDB()
            rsearch.dist = indexPath.section
            rsearch.id = UUID().uuidString
            
            let realm = try! Realm()
            
            switch indexPath.section {

            case 0:
              //  print("Section 0 클릭")
             //   print(self.aSearchArray[indexPath.row].text)
                rsearch.text = self.aSearchArray[indexPath.row].text
                rsearch.stid = self.aSearchArray[indexPath.row].stid
                
                let toDel = realm.objects(RecentSearchLDB.self).filter("stid == '\(self.aSearchArray[indexPath.row].stid)'")
                
                try! realm.write {
                    realm.delete(toDel)
                    
                }
                
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as? Detail{
                    controller.statId = aSearchArray[indexPath.row].stid
                    
                    self.navigationController?.pushViewController(controller, animated: true)

                }
                
            case 1:
               // print("Section 1 클릭")
               // print(self.bSearchArray[indexPath.row].text)
                
                let tm128 = NMGTm128(x: self.bSearchArray[indexPath.row].lng, y: self.bSearchArray[indexPath.row].lat)
                let latlng = tm128.toLatLng()
                
                rsearch.text = self.bSearchArray[indexPath.row].text
                rsearch.lat = latlng.lat
                rsearch.lng = latlng.lng
                
                let toDel = realm.objects(RecentSearchLDB.self).filter("text == '\(self.bSearchArray[indexPath.row].text)' AND lat == \(latlng.lat) AND lng == \(latlng.lng)")  //reaml에서 중요한것은 변수를 넣을때 String 은 ''가들어가야하고 그외 숫자들은 ''불필요
                    
                try! realm.write {
                    realm.delete(toDel)
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "callCameraUpdate"), object: nil, userInfo: ["lat" : latlng.lat, "lng" : latlng.lng])

                self.navigationController?.popViewController(animated: true)

            case 2:
              //  print("Section 2 클릭")
              //  print(self.cSearchArray[indexPath.row].text)
                rsearch.text = self.cSearchArray[indexPath.row].text
                rsearch.lat = self.cSearchArray[indexPath.row].lat
                rsearch.lng = self.cSearchArray[indexPath.row].lng
                
                let toDel = realm.objects(RecentSearchLDB.self).filter("text == '\(self.cSearchArray[indexPath.row].text)' AND lat == \(self.cSearchArray[indexPath.row].lat) AND lng == \(self.cSearchArray[indexPath.row].lng)")
                    
                try! realm.write {
                    realm.delete(toDel)
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "callCameraUpdate"), object: nil, userInfo: ["lat" : cSearchArray[indexPath.row].lat, "lng" : cSearchArray[indexPath.row].lng])

                self.navigationController?.popViewController(animated: true)
                

            default:
                print("")

            }
            
            try! realm.write {
                realm.add(rsearch)
            }
            
        } else {
            
            switch rSearchArray[indexPath.row].dist {

            case 0:
                
               // print(rSearchArray[indexPath.row].dist)
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as? Detail{
                    controller.statId = rSearchArray[indexPath.row].stid
                    
                    self.navigationController?.pushViewController(controller, animated: true)

                }
                
            default :
                
             //   print(rSearchArray[indexPath.row].dist)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "callCameraUpdate"), object: nil, userInfo: ["lat" : rSearchArray[indexPath.row].lat, "lng" : rSearchArray[indexPath.row].lng])

                self.navigationController?.popViewController(animated: true)

            }
                 
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //검색바 설정
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let qsearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //searchBar
        if (qsearch == ""){

            isSearching = false
            
            DispatchQueue.main.async {
                self.aSearchArray = []
                self.bSearchArray = []
                self.cSearchArray = []
            }
            
            DispatchQueue.main.async {
               // print("검색창 닫았을때 실행되는지 확인")
              //  searchBar.resignFirstResponder()
                self.loadRecentSearch()
                self.tableView.reloadData()
            }
            
        } else {
            
            isSearching = true
            
            getASearchInfo(qtxt: qsearch)
            getBSearchInfo(qtxt: qsearch)
            getCSearchInfo(qtxt: qsearch)
            
            group.notify(queue: .main) {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    //충전소 바로가기 검색
    func getASearchInfo(qtxt: String){
        
        //print("============================> getASearchInfo()")
        
        //let qqtxt = qtxt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (qtxt.count >= 1) {
            
           // let realm = try! Realm()
            
           // let crtlocation = realm.objects(LocationCurrentLDB.self).first
            
            //let latc = String(crtlocation!.latcrt)
            //let lngc = String(crtlocation!.lngcrt)
            
            let latc = 37.5466102 //나중에 수정해줘야함
            let lngc = 126.9683881 //나중에 수정해줘야함
            
            let rawEndPoint = EndPoint.getASearchInfo.rawValue
            let parameterString = "?txt=\(qtxt)&latc=\(latc)&lngc=\(lngc)"
            
            let endPoint = rawEndPoint + parameterString
            
            let encodedQuery: String = endPoint.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            let queryURL: URL = URL(string: encodedQuery)!
           
            let requestURL = URLRequest(url: queryURL)
            let session = URLSession.shared
            
            group.enter()
                
            let task = session.dataTask(with: requestURL, completionHandler:
            {
                (data, response, error) -> Void in
                
                do {
                    
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers])
                    
                    guard let newValue = jsonResult as? [Any] else {
                     //   print("getASearch() data type error")
                        self.group.leave()
                        return
                           
                    }
                    
                    self.aSearchArray = []
                    
                    //print("getASearch() 결과 출력 ---------------->")
                   // print(newValue)
                    
                    for item in newValue{
                        
                        if let stdata = item as? [Any]{
                            
                            var temp = ASearchInfo()
                                
                            temp.qtxt = qtxt
                            temp.stid = stdata[0] as! String
                            temp.text = stdata[1] as! String
                            
                            DispatchQueue.main.async {
                                self.aSearchArray.append(temp)
                            }
                            
                        }

                    }
                    
                } catch {
                //    print("getASearch() raw data error")
                    self.group.leave()
                    
                }
               // print("<---------------------- getASearch() 데이터 수집 끝")
                self.group.leave()

            })
            task.resume()
            
        }
        
    }
    
    //네이버 검색 API 실행
    func getBSearchInfo(qtxt : String) {
            
     //   print("============================> getBSearchInfo()")
        
        let clientID: String = Keys.naversearchid.rawValue
        let clientKEY: String = Keys.naversearchkey.rawValue
       // let qqtxt = qtxt.trimmingCharacters(in: .whitespacesAndNewlines)
        let rnum = 3 //몇개 정보를 되돌려 받을 것인지
            
            if (qtxt.count >= 1) {
                
                let query: String  = "https://openapi.naver.com/v1/search/local.json?query=\(qtxt)&display=\(rnum)"
                let encodedQuery: String = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                let queryURL: URL = URL(string: encodedQuery)!
               
                var requestURL = URLRequest(url: queryURL)
                requestURL.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
                requestURL.addValue(clientKEY, forHTTPHeaderField: "X-Naver-Client-Secret")
                
                let session = URLSession.shared
                
                group.enter()

                let task = session.dataTask(with: requestURL, completionHandler:
                {
                    (data, response, error) -> Void in

                    do {
                        
                        let ojson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                        
                        guard let jarray = ojson["items"] as? Array<Any> else {
                            //print("getBSearch() data type error")
                            self.group.leave()
                            return
                        }
                        
                        self.bSearchArray = []
                        
                        //print("getBSearch() 결과 출력 ---------------->")
                        //print(jarray)

                        for item in jarray{
                            
                            guard let addrdic = item as? Dictionary<AnyHashable, Any> else {
                                //print("getBSearch() data type error")
                                return
                                
                            }

                            var temp = BSearchInfo()
                            
                            temp.qtxt = qtxt
                            temp.text = (addrdic["title"] as! String).withoutHtmlTags
                           // temp.addr = addrdic["address"] as! String
                            temp.lat = (addrdic["mapy"] as! NSString).doubleValue
                            temp.lng = (addrdic["mapx"] as! NSString).doubleValue
                            
                            //print("###################################")
                            print(temp.lat, temp.lng)
                            
                           DispatchQueue.main.async {
                                self.bSearchArray.append(temp)
                           }

                        }
                   
                    } catch {
                        //print("getBSearch() raw data error")
                        self.group.leave()
                        
                    }
                    //print("<---------------------- getBSearch() 데이터 수집 끝")
                    self.group.leave()
                    
                })
                task.resume()
                
            }
         
        }

    //행정구역 검색
    func getCSearchInfo(qtxt : String) {
            
        //print("============================> getCSearch()")
        
        /*
        if qtxt.contains("도") || qtxt.contains("시") || qtxt.contains("군") || qtxt.contains("구") || qtxt.contains("동") || qtxt.contains("읍") || qtxt.contains("면") || qtxt.contains("리")  {
        */
        //let qqtxt = qtxt.trimmingCharacters(in: .whitespacesAndNewlines)
        let qarray = qtxt.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        
        if (qarray.count >= 1) {
            
            var t_first = ""
            var t_second = ""
            var t_third = ""
            var t_fourth = ""
            var t_fifth = ""
            
            switch qarray.count {
            
            case 1:
                t_first = qarray[0]

            case 2:
                t_first = qarray[0]
                t_second = qarray[1]
                
            case 3:
                t_first = qarray[0]
                t_second = qarray[1]
                t_third = qarray[2]
                
            case 4:
                t_first = qarray[0]
                t_second = qarray[1]
                t_third = qarray[2]
                t_fourth = qarray[3]
                
            case 5:
                t_first = qarray[0]
                t_second = qarray[1]
                t_third = qarray[2]
                t_fourth = qarray[3]
                t_fifth = qarray[4]
                
            default:
                print("")
            }
            
            let rawEndPoint = EndPoint.getCSearchInfo.rawValue
            let parameterString = "?t_first=\(t_first)&t_second=\(t_second)&t_third=\(t_third)&t_fourth=\(t_fourth)&t_fifth=\(t_fifth)"
            
            let endPoint = rawEndPoint + parameterString
            
            let encodedQuery: String = endPoint.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            let queryURL: URL = URL(string: encodedQuery)!
           
            let requestURL = URLRequest(url: queryURL)
            let session = URLSession.shared
            
            group.enter()
            
            let task = session.dataTask(with: requestURL, completionHandler:
                                            
            {
                (data, response, error) -> Void in
                
                do {
                    
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers])
                    
                    guard let newValue = jsonResult as? [Any] else {
                        //print("getCSearch() data type error")
                        self.group.leave()
                        return
                           
                    }
                    
                    self.cSearchArray = []
                    
                    //print("getCSearch() 결과 출력 ---------------->")
                    //print(newValue)
                    
                    for item in newValue{
                        
                        if let stdata = item as? [Any]{
                            
                            var temp = CSearchInfo()

                            temp.qtxt = qtxt
                            temp.text = stdata[0] as! String
                            temp.lat = stdata[1] as! Double
                            temp.lng = stdata[2] as! Double
                            
                            DispatchQueue.main.async {
                                self.cSearchArray.append(temp)
                            }
                            
                            
                        }

                    }
                    
                } catch {
                    //print("getCSearch()raw data error")
                    self.group.leave()
                    
                }
                //print("<---------------------- getCSearch() 데이터 수집 끝")
                self.group.leave()

            })
            task.resume()
        }
        
            
   }

}
