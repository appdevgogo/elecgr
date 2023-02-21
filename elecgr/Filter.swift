import UIKit
import RealmSwift

class Filter: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var filterOnOff: UISwitch!
    @IBOutlet weak var chargerAble: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let chargerType = ["DC콤보", "DC차데모", "AC단상", "AC3상"]
    //let company = ["대영체비", "에버온", "제주전기자동차서비스", "지엔텔", "차지비"]
    
    let filterOffScreen = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    let realm = try! Realm()
    let group = DispatchGroup()
    
    //var filtercompanyarray = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "지도 필터"
        
        addBackButton()
        addFilterOnOffButton()
        addFilterAbleButton()
        
    }
    
    @objc func backAction(_ sender: UIButton) {
        
        var typeset = Set<Int>()
        var companyarray: [String] = []
        var typefstr = ""
        var companyfstr = ""
        
        for item in realm.objects(FilterLDB.self).first!.cgrtype {
            
            var temp = Set<Int>()
            
            if item.value == true {
                
                //print(item.name)
                
                switch item.name {
            
                case "dccombo":
                    temp = [4,5,6]
                    
                case "dccha":
                    temp = [1,3,5,6]
                    
                case "acdan":
                    temp = [2]
                    
                case "ac3":
                    temp = [3,6,7]
                    
                default:
                    print("")
                }
                
                typeset = typeset.union(temp)
                
            }
            
        }
        
        for item in realm.objects(FilterLDB.self).first!.cgrcompany {
            
            if item.value == true {
                
                companyarray.append(item.id)
                
            }
            
        }
        
        if typeset.count == 0 {
            
            typefstr = "type = 0"
            
        } else {
            
            for (idx, item) in typeset.enumerated() {
                
                var tempstr = ""
                
                if idx == 0 {
                    
                    tempstr = "type = \(item)"
                    
                } else {
                    
                    tempstr = " OR type = \(item)"
                    
                }
                
                typefstr += tempstr
                
            }
            
            
        }
        
        if companyarray.count == 0 {
            
            companyfstr = "busiid = ''"
            
        } else {
            
            for (idx, item) in companyarray.enumerated() {
                
                var tempstr = ""
                
                if idx == 0 {
                    
                    tempstr = "busiid = '\(item)'"
                    
                } else {
                    
                    tempstr = " OR busiid = '\(item)'"
                    
                }
                
                companyfstr += tempstr
                
            }
            
        }


        let test = realm.objects(FilterLDB.self)
        
        try! realm.write {
            test.first?.companyfstr = companyfstr
            test.first?.typefstr = typefstr
        }
        
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "callMarkersFromLocalDB"), object: nil)
            
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func filterOnOffAction(filterSwitch: UISwitch) {
        
        let filterOn = filterSwitch.isOn
        let filterDB = realm.objects(FilterLDB.self).first
        
        
        if filterOn == true {
            
            filterOffScreen.isHidden = true
            
            try! realm.write {
                filterDB?.filteron = true
            }
            
        } else {
            
            filterOffScreen.isHidden = false
            
            try! realm.write {
                filterDB?.filteron = false
            }
        }
        
    }
    
    @objc func chargerAbleAction(_ sender: UIButton) {
        
        let filterDB = realm.objects(FilterLDB.self).first
        
        if filterDB?.cgrable == true {
            
            try! realm.write {
                filterDB?.cgrable = false
            }
            //print("fasle")
            //chargerAble.setTitleColor(.systemGray5, for: .normal)
            chargerAble.setImage(UIImage(systemName: "square"), for: .normal)
            chargerAble.tintColor = UIColor.systemGray5
            
            
        } else {
            
            try! realm.write {
                filterDB?.cgrable = true
            }
            
            //print("true")
            chargerAble.setTitleColor(.black, for: .normal)
            chargerAble.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            chargerAble.tintColor = UIColor.filter_green
        }
        /*
        try! realm.write {
            filterLDB!.cgrable = false
        }
        */
        
    }
    
    @objc func chargerTypeAction(sender : UIButton){
        
        let cgrtype = realm.objects(FilterLDB.self).first?.cgrtype[sender.tag]
        
        if cgrtype?.value == true {
            
            try! realm.write {
                cgrtype?.value = false
            }
            //print("fasle")
            sender.setImage(UIImage(systemName: "square"), for: .normal)
            sender.tintColor = UIColor.systemGray5
            
        } else if cgrtype?.value == false {
            
            try! realm.write {
                cgrtype?.value = true
            }
            //print("true")
            sender.setTitleColor(.black, for: .normal)
            sender.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            sender.tintColor = UIColor.filter_green

        }

    }
    
    @objc func chargerTypeSelectAll(sender : UIButton){
            
        try! realm.write {
            
            for item in realm.objects(FilterLDB.self).first!.cgrcompany.filter("value == false"){
                
                item.value = true
                
            }
            
        }
        tableView.reloadData()
        
    }
    
    @objc func chargerTypeDeselectAll(sender : UIButton){
        
        try! realm.write {
            
            for item in realm.objects(FilterLDB.self).first!.cgrcompany.filter("value == true"){
                
                item.value = false
                
            }
            
        }
        tableView.reloadData()
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
    
    func initLoading() {
        
        if realm.objects(FilterLDB.self).isEmpty {
            
            //print("FilterLDB에 저장된 값이 없습니다.")
            
            let realm = try! Realm()
            let initData = FilterLDB()
            initData.filteron = false
            initData.cgrable = false
            initData.typefstr = ""
            initData.companyfstr = ""
            
            let tempArray: [String] = ["dccombo", "dccha", "acdan", "ac3"]
            
            for item in tempArray {
                
                let temp = ChargerType()
                temp.name = item
                temp.value = true
                initData.cgrtype.append(temp)
                
            }
        
            let encodedQuery: String = EndPoint.getFilterCompany.rawValue
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
                        //print("init_getFilterCompany data type error")
                        self.group.leave()
                        return
                           
                    }
                    
                    for item in newValue{
                        
                        if let stdata = item as? [Any]{
                            
                            //print(stdata)
                            
                            let temp = ChargerCompany()
                            temp.id = stdata[0] as! String
                            temp.name = stdata[1] as! String
                            temp.value = true

                            DispatchQueue.main.async {
                                initData.cgrcompany.append(temp)
                            }
                            
                        }

                    }
                    
                } catch {
                    //print("init_getFilterCompany raw data error")
                    self.group.leave()
                    
                }
                
                DispatchQueue.main.async {
                    try! realm.write {
                        realm.add(initData)
                    }
                }
                
                self.group.leave()

            })
            task.resume()
            
        }
        
    }
    
    func addFilterOnOffButton() {
        
        let check = realm.objects(FilterLDB.self).first?.filteron

        
        if check == true {
            
            filterOnOff.setOn(true , animated: true)
            filterOffScreen.isHidden = true
            
        } else if check == false {
            
            filterOnOff.setOn(false , animated: true)
            filterOffScreen.isHidden = false
            
        }
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let topSafeArea: CGFloat = (windowScene?.windows.first?.safeAreaInsets.top)!
        
        filterOnOff.addTarget(self, action: #selector(filterOnOffAction), for: UIControl.Event.valueChanged)
        filterOffScreen.backgroundColor = UIColor(white: 1, alpha: 0.8)
        filterOffScreen.frame = filterOffScreen.frame.offsetBy(dx: 0, dy: topSafeArea + 80)
        
        self.view.addSubview(filterOffScreen)
        
    }
        
    func addFilterAbleButton(){
        
        chargerAble.setTitle("충전가능만 표시", for: .normal)
        chargerAble.setTitleColor(.black, for: .normal)
        chargerAble.titleLabel?.font = .systemFont(ofSize: 18)
        
        let check = realm.objects(FilterLDB.self).first?.cgrable
        
        if check == true {
            
            chargerAble.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            chargerAble.tintColor = UIColor.filter_green
            
            
        } else if check == false {
            
            chargerAble.setImage(UIImage(systemName: "square"), for: .normal)
            chargerAble.tintColor = UIColor.systemGray5
            
        }

        chargerAble.addTarget(self, action: #selector(self.chargerAbleAction(_:)), for: .touchUpInside)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterChargerTypeHeader", for: indexPath) as? FilterChargerTypeHeader{
            sectionHeader.label.text = "충전기타입"
            sectionHeader.label.textColor = UIColor.lightGray
            
            return sectionHeader
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return chargerType.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterChargerTypeCell", for: indexPath) as? FilterChargerTypeCell else {
            return UICollectionViewCell()
        }

        cell.button.tag = indexPath.row
        cell.button.setTitle(chargerType[indexPath.row], for: .normal)
        cell.button.setTitleColor(.black, for: .normal)
        cell.button.titleLabel?.font = .systemFont(ofSize: 17)
        
        let check = realm.objects(FilterLDB.self).first?.cgrtype[indexPath.row].value
        
        if check == true {
            
            cell.button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            cell.button.tintColor = UIColor.filter_green
            
        } else if check == false {
            
            cell.button.setImage(UIImage(systemName: "square"), for: .normal)
            cell.button.tintColor = UIColor.systemGray5
            
        }
        
        cell.button.addTarget(self, action: #selector(chargerTypeAction), for: .touchUpInside)
        
        return cell

    }
    

    
    
    //Section 몇개 되는지 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let frame = tableView.frame
        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.backgroundColor = UIColor.white
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 28))
        title.backgroundColor = UIColor.white
        title.text = "운영기관"
        title.textColor = UIColor.lightGray
        
        let selectAllBtn = UIButton(frame: CGRect(x: frame.size.width - 120, y: 0, width: 60, height: 28))
        selectAllBtn.setTitle("모두선택", for: .normal)
        selectAllBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        selectAllBtn.setTitleColor(UIColor.systemGray3, for: .normal)
        selectAllBtn.addTarget(self, action: #selector(chargerTypeSelectAll), for: .touchUpInside)
        
        let deselectAllBtn = UIButton(frame: CGRect(x: frame.size.width - 60, y: 0, width: 60, height: 28))
        deselectAllBtn.setTitle("모두해제", for: .normal)
        deselectAllBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        deselectAllBtn.setTitleColor(UIColor.systemGray3, for: .normal)
        deselectAllBtn.addTarget(self, action: #selector(chargerTypeDeselectAll), for: .touchUpInside)
        
        headerView.addSubview(title)
        headerView.addSubview(selectAllBtn)
        headerView.addSubview(deselectAllBtn)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let company = realm.objects(FilterLDB.self).first?.cgrcompany
        
        return company?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FilterCompanyCell", for: indexPath)
        let company = realm.objects(FilterLDB.self).first?.cgrcompany
        
        //Table View Cell나열되는 곳 옆에 여백을 삭제해주는 문구
        tableView.layoutMargins = .zero
        cell.layoutMargins = .zero
        cell.contentView.directionalLayoutMargins = .zero
        
        let check = company?[indexPath.row].value
        
        if check == true {
            
            cell.imageView?.image = UIImage(systemName: "checkmark.square")
            cell.imageView?.tintColor = UIColor.filter_green
            
        } else if check == false {
            
            cell.imageView?.image = UIImage(systemName: "square")
            cell.imageView?.tintColor = UIColor.systemGray5
            
        }
        
        cell.textLabel?.text = company?[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cgrcompany = realm.objects(FilterLDB.self).first?.cgrcompany[indexPath.row]
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FilterCompanyCell", for: indexPath)
        
        if cgrcompany?.value == true {
            
            try! realm.write {
                cgrcompany?.value = false
            }
            cell.imageView?.image = UIImage(systemName: "square")
            cell.imageView?.tintColor = UIColor.systemGray5
            
        } else if cgrcompany?.value == false {
            
            try! realm.write {
                cgrcompany?.value = true
            }
            
            cell.imageView?.image = UIImage(systemName: "checkmark.square")
            cell.imageView?.tintColor = UIColor.filter_green
            
        }
        tableView.deselectRow(at: indexPath, animated: false)
        //cell.selectionStyle = .none
        tableView.reloadData()

    }
    

}


class FilterChargerTypeHeader: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
}


class FilterChargerTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
}


