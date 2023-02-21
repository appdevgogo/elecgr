import UIKit
import RealmSwift

class Detail: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var contentView: UIView!
    
    let lMargin: CGFloat = 20
    let rMargin: CGFloat = 20
    //var pGuideTable: CGFloat = 0.0
    //var hTopLayout: CGFloat = 0.0
    var topBaseInfo: CGFloat = 0.0
    var topChargerTable: CGFloat = 0.0
    var detailArray = [DetailInfoLDB]()
    
    var statId: String = ""

    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton()
        addRightButtons()
        
        getDetialInfo(statid: statId)
    
        group.notify(queue: .main) {
            self.loadDetailInfo()
            self.addTopLayout()
            self.addChargerTable()
        }


        self.navigationItem.title = ""
        
    }
    
    @objc func backAction(_ sender: UIButton) {
        
       self.navigationController?.popViewController(animated: true)
    }
    
    @objc func callCameraUpdate(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "callCameraUpdate"), object: nil, userInfo: ["lat" : detailArray[0].lat, "lng" : detailArray[0].lng])
        
       self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func bookMarkAction(_ sender: UIButton) {
        
        let realm = try! Realm()
        
        if let toDel = realm.objects(BookmarkLDB.self).filter("stid == '\(detailArray[0].statid)'").first {
            
            try! realm.write {
                   realm.delete(toDel)
             }
            //print("북마크 삭제")
            
        } else {
            
            let toAdd = BookmarkLDB()
            
            toAdd.stid = detailArray[0].statid
            toAdd.name = detailArray[0].statnm
            toAdd.addr = detailArray[0].addr
            toAdd.lat = detailArray[0].lat
            toAdd.lng = detailArray[0].lng
            
            try! realm.write {
                   realm.add(toAdd)
             }
            //print("북마크 추가")
        }

        addRightButtons()
        
        
    }
    
    @objc func refreshAction() {
        
        //print("refreshaction")
        
        getDetialInfo(statid: statId)
        
        group.notify(queue: .main) {
            self.loadDetailInfo()
            self.addTopLayout()
            self.addChargerTable()
        }
        
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
    
    func addRightButtons() {

        var rBtnsConfig = UIButton.Configuration.plain()
        rBtnsConfig.baseForegroundColor = .systemGray
        rBtnsConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .default)
        
        //===== 1번째 버튼
        let btnRefresh = UIButton(configuration: rBtnsConfig, primaryAction: nil)
        btnRefresh.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: imgConfig), for: .normal)
        btnRefresh.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
        let addButton1 = UIBarButtonItem(customView: btnRefresh)
        
        //===== 2번째 버튼
        let btnBookMark = UIButton(configuration: rBtnsConfig, primaryAction: nil)

        let realm = try! Realm()
        
        if let check = realm.objects(BookmarkLDB.self).filter("stid == '\(statId)'").first {
            
            print(check)
            btnBookMark.setImage(UIImage(systemName: "star.fill", withConfiguration: imgConfig), for: .normal)
            btnBookMark.configuration?.baseForegroundColor = .bookmark_yellow
            
        } else {
            
            btnBookMark.setImage(UIImage(systemName: "star", withConfiguration: imgConfig), for: .normal)
        }
        
        btnBookMark.addTarget(self, action: #selector(bookMarkAction), for: .touchUpInside)
        let addButton2 = UIBarButtonItem(customView: btnBookMark)

        //===== 3번째 버튼
        let btnMapView : UIButton = UIButton(configuration: rBtnsConfig, primaryAction: nil)
        btnMapView.setImage(UIImage(systemName: "map", withConfiguration: imgConfig), for: .normal)
        btnMapView.addTarget(self, action: #selector(callCameraUpdate), for: .touchUpInside)
        let addButton3 = UIBarButtonItem(customView: btnMapView)
        
        //------ 네비게이션 바오른쪽 버튼추가
        self.navigationItem.rightBarButtonItems = [addButton1, addButton2, addButton3]
        
    }
    
    func getDetialInfo(statid: String) {
               
        let rawEndPoint = EndPoint.getDetailInfo.rawValue
        let parameterString = "?statid=\(statid)"
        
        let endPoint = rawEndPoint + parameterString
        
        let encodedQuery: String = endPoint.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: encodedQuery)!
       
        let requestURL = URLRequest(url: queryURL)
        let session = URLSession.shared
        
        let realm = try! Realm()
        
        let toDel = realm.objects(DetailInfoLDB.self)
        
        try! realm.write {
             realm.delete(toDel)
        }
        
        group.enter()
        
        let task = session.dataTask(with: requestURL, completionHandler:
                                        
        {
            (data, response, error) -> Void in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers])
                
                guard let newValue = jsonResult as? [Any] else {
                    //print("getDetailInfo() data type error")
                    self.group.leave()
                    return
                       
                }
                
                //print(newValue)
                
                var dArray = [DetailInfoLDB]()
                
                for item in newValue{
                    
                    if let stdata = item as? [Any]{
                        
                        let temp = DetailInfoLDB()
                        
                        temp.statnm = stdata[0] as! String
                        temp.statid = stdata[1] as! String
                        temp.chgerid = stdata[2] as! Int8
                        temp.chgertype = stdata[3] as! Int8
                        temp.addr = stdata[4] as! String
                        temp.location = stdata[5] as! String
                        temp.lat = stdata[6] as! Double
                        temp.lng = stdata[7] as! Double
                        temp.addcd = stdata[8] as! String
                        temp.usetime = stdata[9] as! String
                        temp.busiid = stdata[10] as! String
                        temp.bnm = stdata[11] as! String
                        temp.businm = stdata[12] as! String
                        temp.busicall = stdata[13] as! String
                        temp.stat = stdata[14] as! Int8
                        temp.statupddt = stdata[15] as! String
                        temp.lasttsdt = stdata[16] as! String
                        temp.lasttedt = stdata[17] as! String
                        temp.nowtsdt = stdata[18] as! String
                        temp.output = stdata[19] as! Int
                        temp.method = stdata[20] as! String
                        temp.zcode = stdata[21] as! Int8
                        temp.parkingfree = stdata[22] as! String
                        temp.note = stdata[23] as! String
                        temp.limityn = stdata[24] as! String
                        temp.limitdetail = stdata[25] as! String
                        temp.delyn = stdata[26] as! String
                        temp.deldetail = stdata[27] as! String
                            
                        dArray.append(temp)
                            
                    }

                }
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(dArray)
                }
                
            } catch {
                //print("getDetailInfo() raw data error")
                self.group.leave()
                
            }

            self.group.leave()
            
        })
        task.resume()
        
    }
    
    func loadDetailInfo() {
        
        detailArray = []
        
        let realm = try! Realm()
        
        for item in realm.objects(DetailInfoLDB.self){
            
            detailArray.append(item)
            
        }

    }
        
    func addTopLayout() {
        
        let realm = try! Realm()
        
        let item = realm.objects(DetailInfoLDB.self).first
        let numable = realm.objects(DetailInfoLDB.self).filter("stat = 2")
        let numcharging = realm.objects(DetailInfoLDB.self).filter("stat = 3")
        
        let tNameLabel: CGFloat = 12
        let tAbleLabel: CGFloat = 10
        let wAbleLabel: CGFloat = 120
        let hAbleLabel: CGFloat = 70
        //let spacing: CGFloat = 10
        
        let nameLabel = UILabel(frame: CGRect(x: lMargin, y: tNameLabel, width: UIScreen.main.bounds.width - (lMargin + 10 + wAbleLabel + rMargin), height: 0))
        nameLabel.text = item?.statnm
       // nameLabel.backgroundColor = UIColor.yellow
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont.systemFont(ofSize: 20.0)
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        nameLabel.sizeToFit()
        
        let addressLabel = UILabel(frame: CGRect(x: lMargin, y: 0, width: UIScreen.main.bounds.width - (lMargin + 10 + wAbleLabel + rMargin), height: 0))
        
        switch item?.location {
        
        case "null" :
            addressLabel.text = item!.addr
        
        default:
            addressLabel.text = item!.addr + " (" + item!.location + ")"
            
        }
        
        addressLabel.textColor = UIColor.systemGray
        addressLabel.font = UIFont.systemFont(ofSize: 15.0)
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        addressLabel.sizeToFit()
        
        let ableLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - (wAbleLabel + rMargin), y: tAbleLabel, width: wAbleLabel, height: hAbleLabel))
                
        if numable.count > 0 {
            
            ableLabel.text = "\(numable.count)대 가능"
            ableLabel.textColor = UIColor.marker_green
            ableLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
            ableLabel.layer.borderColor = UIColor.marker_green.cgColor
            
        } else if numable.count == 0 && numcharging.count > 0 {
             
            ableLabel.text = "모두충전중"
            ableLabel.textColor = UIColor.marker_red
            ableLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            ableLabel.layer.borderColor = UIColor.marker_red.cgColor
      
        } else if numable.count == 0 && numcharging.count == 0 {
                
            ableLabel.text = "모두점검중"
            ableLabel.textColor = UIColor.marker_gray
            ableLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            ableLabel.layer.borderColor = UIColor.marker_gray.cgColor
                
        }
        
        ableLabel.textAlignment = .center
        ableLabel.layer.masksToBounds = true
        ableLabel.layer.cornerRadius = 30.0
        ableLabel.layer.borderWidth = 5
        
        let hNameLable = nameLabel.frame.height //높이 재산정 why 1줄 또는 2줄일 경우가 있음
        let hAddressLable = addressLabel.frame.height //

        //글자 길이에 따라 위치 및 높이 재조정
        nameLabel.frame.size.height = hNameLable
        addressLabel.frame.size.height = hAddressLable
        addressLabel.frame.origin.y = tNameLabel + hNameLable + 5
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(ableLabel)
        
        let guideBaseInfo = tNameLabel + hNameLable + 5 + hAddressLable
        
        switch true {
            
        case guideBaseInfo > (tAbleLabel + hAbleLabel):
            topBaseInfo = guideBaseInfo + 7
            
        default:
            topBaseInfo = tAbleLabel + hAbleLabel + 7
        }
        
        var stringBaseInfo1: String = ""
        var stringBaseInfo2: String = ""
        
        switch item?.busicall {
            
        case "null":
            stringBaseInfo1 = "운영기관 : " + item!.businm
            
        default:
            stringBaseInfo1 = "운영기관 : " + item!.businm + "(" + item!.busicall + ")"
            
        }
        
        switch (item?.usetime, item?.parkingfree) {
        
        case ("",""):
            stringBaseInfo2 = "이용정보 : 현장확인"
            
        case ("","Y"):
            stringBaseInfo2 = "이용정보 : 무료주차"
            
        case ("","N"):
            stringBaseInfo2 = "이용정보 : 유로주차"
            
        case (_,""):
            stringBaseInfo2 = "이용정보 : " + item!.usetime
            
        case (_,"Y"):
            stringBaseInfo2 = "이용정보 : " + item!.usetime + "(무료주차)"
        
        case (_,"N"):
            stringBaseInfo2 = "이용정보 : " + item!.usetime + "(유로주차)"
            
        default:
            print("")
            
        }
        
        
        
        let baseInfo = UILabel(frame: CGRect(x: lMargin, y: topBaseInfo, width: UIScreen.main.bounds.width - (lMargin + rMargin), height: 0))
        
        baseInfo.numberOfLines = 0
        baseInfo.attributedText = bulletPointList(strings: [stringBaseInfo1, stringBaseInfo2])
        baseInfo.lineBreakMode = NSLineBreakMode.byCharWrapping
        baseInfo.sizeToFit()
        
        topChargerTable = topBaseInfo + baseInfo.frame.height + 5
        //print(baseInfo.frame.height)

        contentView.addSubview(baseInfo)
            
    }
    
    func bulletPointList(strings: [String]) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 0
        paragraphStyle.minimumLineHeight = 17
        paragraphStyle.maximumLineHeight = 17
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 10)]

        let stringAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.5),
            NSAttributedString.Key.foregroundColor: UIColor.systemGray,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        let string = strings.map({ "•\t\($0)" }).joined(separator: "\n")

        return NSAttributedString(string: string, attributes: stringAttributes)
    }

    
    func addChargerTable() {
        
        let chargerTable: UITableView = UITableView(frame: CGRect(x: lMargin, y: topChargerTable, width: UIScreen.main.bounds.width - (lMargin + rMargin), height: 50000))

        chargerTable.dataSource = self
        chargerTable.delegate = self
        chargerTable.isScrollEnabled = false
        chargerTable.allowsSelection = false
        chargerTable.layer.borderWidth = 1 //테이블 외곽선
        chargerTable.layer.borderColor = UIColor.systemGray5.cgColor
        //chargerTable.separatorColor = .white

        chargerTable.register(UITableViewCell.self, forCellReuseIdentifier: "DetailChargerCell")
        
        contentView.addSubview(chargerTable)
        
        DispatchQueue.main.async {
            
           // print("테이블 높이 재계산 : \(chargerTable.contentSize.height)" )
            
            chargerTable.frame.size.height = chargerTable.contentSize.height
            
           // chargerTable.frame = CGRect(x: 20, y: self.topBaseInfo + 45, width: UIScreen.main.bounds.width - 40, height: chargerTable.contentSize.height)
            
            self.contentView.heightAnchor.constraint(equalToConstant: chargerTable.contentSize.height + 170).isActive = true
            
        }
        
    }
    
    func leftViewOfCell(item: DetailInfoLDB) -> UIView {
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 80))
        let leftLabel1 = UILabel(frame: CGRect(x: 0, y: 15, width: 60, height: 30))
        
        
        switch item.output {
            
        case 0:
            leftLabel1.text = "no.\(item.chgerid)"
            leftLabel1.font = .systemFont(ofSize: 17.0)
            
        default:
            leftLabel1.text = "\(item.output)kw"
            leftLabel1.font = .systemFont(ofSize: 15.0)
            
        }

        leftLabel1.textAlignment = .center
        
        let leftLabel2 = UILabel(frame: CGRect(x: 0, y: 40, width: 60, height: 20))
        
        switch item.stat {

        case 2:
            leftLabel2.text = "충전가능"
            leftLabel2.textColor = UIColor.marker_green
            
        case 3:
            leftLabel2.text = "충전중"
            leftLabel2.textColor = UIColor.marker_red
            
        default:
            leftLabel2.text = "점검중"
            leftLabel2.textColor = UIColor.marker_gray
        }
        
        leftLabel2.font = .systemFont(ofSize: 13.5, weight: .medium)
        leftLabel2.textAlignment = .center
    
        let frame = leftView.frame
        
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: frame.width - 1, y: 0, width: 1, height: frame.height)
        rightBorder.backgroundColor = UIColor.systemGray5.cgColor
        leftView.layer.addSublayer(rightBorder)

        leftView.addSubview(leftLabel1)
        leftView.addSubview(leftLabel2)
        
        return leftView
        
    }
    
    func rightViewOfCell(item: DetailInfoLDB) -> UIView {
                
        let rightView = UIView(frame: CGRect(x: UIScreen.main.bounds.width - 100, y: 0, width: 60, height: 80))
        
        let rightLabel1 = UILabel(frame: CGRect(x: 0, y: 15, width: 60, height: 30))

        rightLabel1.textColor = UIColor.systemGray
        rightLabel1.font = UIFont.systemFont(ofSize: 13)
        rightLabel1.textAlignment = .center
        
        let rightLabel2 = UILabel(frame: CGRect(x: 0, y: 40, width: 60, height: 20))
        rightLabel2.textColor = UIColor.systemGray
        rightLabel2.font = UIFont.systemFont(ofSize: 13)
        rightLabel2.textAlignment = .center
        
        
        switch (item.stat, item.lasttedt, item.nowtsdt) {
        
        case (3,_,"0000-00-00 00:00:00") :
            rightLabel1.text = "-"
            rightLabel2.text = "정보없음"
            
        case (3,_,"") :
            rightLabel1.text = "-"
            rightLabel2.text = "정보없음"
            
        case (3,_,_) :
            rightLabel1.text = timeDiffer(time: item.nowtsdt)
            rightLabel2.text = "충전시작"
            //print(item.nowtsdt)
            
        case (_,"0000-00-00 00:00:00",_) :
            rightLabel1.text = "-"
            rightLabel2.text = "정보없음"
            
        case (_,"",_) :
            rightLabel1.text = "-"
            rightLabel2.text = "정보없음"
            
        default:
            rightLabel1.text = timeDiffer(time: item.lasttedt)
            rightLabel2.text = "충전종료"
            //print(item.lasttedt)
            
        }
    
        let frame = rightView.frame
        
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: -1, y: 0, width: 1, height: frame.height)
        leftBorder.backgroundColor = UIColor.systemGray5.cgColor
        rightView.layer.addSublayer(leftBorder)

        rightView.addSubview(rightLabel1)
        rightView.addSubview(rightLabel2)
        
        return rightView
        
    }
    
    func centerViewOfCell(item: DetailInfoLDB) -> UIView {
        
        var listOfImgs: [String] = []
        
        switch item.chgertype {
        
        case 1:
            listOfImgs = ["dccha"]
        
        case 2:
            listOfImgs = ["acdan"]
            
        case 3:
            listOfImgs = ["dccha", "ac3"]
            
        case 4:
            listOfImgs = ["dccombo"]
        
        case 5:
            listOfImgs = ["dccha", "dccombo"]
            
        case 6:
            listOfImgs = ["dccha", "ac3", "dccombo"]
            
        case 7:
            listOfImgs = ["ac3"]
            
        default:
            print("")
        
        }
        
        let sizeOfImg: CGFloat = 35
        let widthOfCenterView = sizeOfImg * 3
        let centerView = UIView(frame: CGRect(x: (UIScreen.main.bounds.width - widthOfCenterView)/2 - 20, y: 0, width: widthOfCenterView, height: 80))
        //centerView.backgroundColor = .brown
        
        var listOfViews: [UIView] = []
        
        for nameOfImg in listOfImgs {
            
            let view = UIView()
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: nameOfImg)
            
            let label = UILabel()
            
            switch nameOfImg {
            
            case "acdan":
                label.text = "AC단상"
                
            case "ac3":
                label.text = "AC3상"
            
            case "dccha":
                label.text = "DC차데모"
                
            case "dccombo":
                label.text = "DC콤보"
                
            default:
                label.text = ""
                
            }
            
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .systemGray2

            let vStackView = UIStackView(arrangedSubviews: [imageView, label])
            vStackView.axis = .vertical
            vStackView.distribution = .fill
            vStackView.spacing = 5.0
            vStackView.alignment = .center
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: sizeOfImg).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: sizeOfImg).isActive = true
            
            
            view.addSubview(vStackView)
            
            vStackView.translatesAutoresizingMaskIntoConstraints = false
            vStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
            vStackView.centerXAnchor.constraint(lessThanOrEqualTo: view.centerXAnchor).isActive = true
            vStackView.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor).isActive = true
            
            listOfViews.append(view)
            
        }
        
        let hStackView = UIStackView(arrangedSubviews: listOfViews)
        
        hStackView.axis = .horizontal
        hStackView.distribution = .fillEqually
        hStackView.spacing = 50
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        hStackView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        hStackView.widthAnchor.constraint(equalToConstant: widthOfCenterView).isActive = true
        
        centerView.addSubview(hStackView)
        
        return centerView
    }
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //let frame = tableView.frame
        let headerView: UIView = UIView()
        let borderBottom = UIView(frame: CGRect(x: 0, y: 25, width: tableView.bounds.size.width, height: 1.0))
        borderBottom.backgroundColor = .systemGray5
        
        
        let label1 = UILabel(frame: CGRect(x: 10, y: -18, width: tableView.bounds.size.width, height: 20))
        //label1.backgroundColor = .blue
       // title.backgroundColor = UIColor.white
        label1.text = "운영기관 : " + detailArray[0].businm + "(24시간운영)"
        label1.font = .systemFont(ofSize: 13, weight: .medium)
        label1.textColor = UIColor.lightGray
        
        
        let label2 = UILabel(frame: CGRect(x: 10, y: 2, width: tableView.bounds.size.width, height: 20))
        //label2.backgroundColor = .blue
       // title.backgroundColor = UIColor.white
        label2.text = detailArray[0].usetime
        label2.font = .systemFont(ofSize: 13, weight: .medium)
        label2.textColor = UIColor.lightGray
        
        

        headerView.addSubview(label1)
        headerView.addSubview(label2)
       // headerView.addSubview(selectAllBtn)
      //  headerView.addSubview(deselectAllBtn)
        headerView.addSubview(borderBottom)
        

        return headerView
    }
    */
    /*
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        header.textLabel?.textColor = .systemGray3
        header.textLabel?.textAlignment = NSTextAlignment.center

    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return detailArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailChargerCell", for: indexPath)
        
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.addSubview(leftViewOfCell(item: detailArray[indexPath.row]))
        cell.addSubview(rightViewOfCell(item: detailArray[indexPath.row]))
        cell.addSubview(centerViewOfCell(item: detailArray[indexPath.row]))

        return cell
    }
    
}
