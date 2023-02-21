import UIKit
import SideMenu

class SideMenuNavigation: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .menuSlideIn
        self.leftSide = true
        self.statusBarEndAlpha = 0.0
        self.menuWidth = self.view.frame.width * 0.6

    }
    
}
