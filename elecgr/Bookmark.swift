import UIKit
import RealmSwift

class Bookmark: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var bookmarkArray: [BookmarkLDB] = []
    var needToRefresh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "즐겨찾기"
        addBackButton()
        loadBookmark()
        settingTableView()
        
        //print("------------> viewDidLoad() 실행됨")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("------------> viewWillAppear() 시작됨")
        
        switch needToRefresh {
        
        case true:
            loadBookmark()
            tableView.reloadData()
            //print("neeToRefresh 실행됨")
            needToRefresh = false
            
        default:
            print("neeToRefresh 미실행됨")
        }
        

    }
    
    @objc func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        reSettingLocalDB()
        
    }
    
    @objc func delBookMark(sender: UIButton!) {
        
        let idxpath = IndexPath(row: sender.tag, section: 0)
        
        let realm = try! Realm()
        
        //print(sender.accessibilityLabel!)
        let checkstid = sender.accessibilityLabel!
        
        let toDel = realm.objects(BookmarkLDB.self).filter("stid == '\(checkstid)'")
            
        try! realm.write {
            realm.delete(toDel)
        }

        bookmarkArray.remove(at: sender.tag)
        tableView.deleteRows(at: [idxpath], with: .none)
        
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
        
    func loadBookmark(){
               
        bookmarkArray = []
        
        let realm = try! Realm()
        
        for item in realm.objects(BookmarkLDB.self){
            
            bookmarkArray.append(item)
            
        }
        
        //print("loadBookMark() 실행됨 ------------->")
        
    }
    
    func reSettingLocalDB(){
        
        var bArray: [BookmarkLDB] = []
        
        for item in self.bookmarkArray {
            
            let bookMarkDB = BookmarkLDB()
            
            bookMarkDB.stid = item.stid
            bookMarkDB.name = item.name
            bookMarkDB.addr = item.addr
            bookMarkDB.lat = item.lat
            bookMarkDB.lng = item.lng
            
            bArray.append(bookMarkDB)
            
        }
        let realm = try! Realm() //Realm Delete 코드가 아래에 위치해야함
        
        let toDel = realm.objects(BookmarkLDB.self)
        
        try! realm.write {
            realm.delete(toDel)
        }
        
        try! realm.write {
            realm.add(bArray)
        }
            
    }
    
    func settingTableView(){
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 25
    }
    
    /*
    //Section Footer(아래공간) 높이 설정
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return .leastNormalMagnitude
    }
    */
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "(길게누르면 순서변경이 가능합니다.)"
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        header.textLabel?.textColor = .systemGray3
        header.textLabel?.textAlignment = NSTextAlignment.center

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("----------------->> numberOfRowsInSection 실행")
        
        return bookmarkArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "BookMarkCell", for: indexPath)
        
        cell.textLabel?.text = bookmarkArray[indexPath.row].name
        cell.imageView?.image = UIImage(systemName: "bolt.car")
        //cell.backgroundColor = .green
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "multiply"), for: .normal)
        button.tintColor = UIColor.systemGray4
        button.tag = indexPath.row //delete 할때 중요한 요소임(sender에 해당정보를 받아옴 tag는 int만 가능)
        button.accessibilityLabel = bookmarkArray[indexPath.row].stid
        button.addTarget(self, action: #selector(delBookMark), for: .touchUpInside)
        button.sizeToFit()
        
        cell.accessoryView = button

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as? Detail{
            
            controller.statId = bookmarkArray[indexPath.row].stid
            
            self.navigationController?.pushViewController(controller, animated: true)
            needToRefresh = true
        }
                

    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //print("\(sourceIndexPath.row) -> \(destinationIndexPath.row)")
        let mover = bookmarkArray.remove(at: sourceIndexPath.row)
        bookmarkArray.insert(mover, at: destinationIndexPath.row)
        
        self.tableView.reloadData()
        
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = bookmarkArray[indexPath.row]
        return [ dragItem ]
    }

}
