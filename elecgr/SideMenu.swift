import UIKit

class SideMenu: UIViewController {
    
    @objc func sideMenuBtnClick(sender: UIButton!) {
             
        print(sender.tag)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        setSideMenuBtns()
        
    }
    
    
    func setSideMenuBtns() {
        
        let frameWidth = Int(self.view.frame.width)
       // let frameHeight = Int(self.view.frame.height)
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let topSafeArea = Int((windowScene?.windows.first?.safeAreaInsets.top)!)
        //let bottomSafeArea = window.safeAreaInsets.bottom
        
        let topMargin = 50 + topSafeArea
        let leftMargin = 0
        let btnsHeight = 70 //사이드 메뉴의 개수가 늘어나면 임의로 늘리는것 권장
        
        let sideMenuTitle = ["북마크", "닉네임수정"]
        
        let sideMenuStack = UIStackView(frame: CGRect(x: leftMargin, y: topMargin, width: frameWidth, height: btnsHeight))
        sideMenuStack.backgroundColor = .white
        sideMenuStack.axis = .vertical
        sideMenuStack.distribution = .equalSpacing
        sideMenuStack.alignment = .fill
        sideMenuStack.spacing = 0.0
        
        for (idx, title) in sideMenuTitle.enumerated() {
            
            print("\(title)")
        
            let sideMenuBtn = UIButton()
            sideMenuBtn.backgroundColor = .white
            sideMenuBtn.setTitle("\(title)", for: .normal)
            sideMenuBtn.contentHorizontalAlignment = .left
           // sideMenuBtn.titleEdgeInsets.left = 20       //버튼의 타이틀에 대한 왼쪽 padding 설정,
            sideMenuBtn.titleLabel?.font = .systemFont(ofSize: 16)
            sideMenuBtn.setTitleColor(.systemGray, for: .normal)
            sideMenuBtn.tag = idx + 1
            sideMenuBtn.addTarget(self, action: #selector(sideMenuBtnClick), for: .touchUpInside)
            
            sideMenuStack.addArrangedSubview(sideMenuBtn)
            
        }
        
        self.view.addSubview(sideMenuStack)
        
        
    }
    

}


