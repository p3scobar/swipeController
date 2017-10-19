
import UIKit

protocol ViewControllerDelegate {
    func innerScrollViewShouldScroll() -> Bool
}

class SwipeController: UIViewController {
    
    var dataSource: DataSource!
    var controllers: [UIViewController] = []
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    var scrollView: UIScrollView!
    var delegate: ViewControllerDelegate?
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHorizontalScrollView()
    }
    
    func setupHorizontalScrollView() {

        let width = self.view.bounds.width
        let height = self.view.bounds.height
        let count = CGFloat(controllers.count)
        
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        
        //Set the size of the frame
        self.scrollView!.frame = UIScreen.main.bounds
        self.view.addSubview(scrollView)
        
        let scrollWidth: CGFloat  = count * width
        let scrollHeight: CGFloat  = height
        self.scrollView!.contentSize = CGSize(width: width*2.0, height: height)
        
        let chatVC = MessagesController()
        let chatNav = UINavigationController(rootViewController: chatVC)
        chatVC.dataSource = self.dataSource
        self.addChildViewController(chatNav)
        chatNav.view.frame = UIScreen.main.bounds
        
        let contactsVC = ContactsController()
        let contactsNav = UINavigationController(rootViewController: contactsVC)
        self.addChildViewController(contactsNav)
        contactsNav.view.frame = UIScreen.main.bounds
        
        controllers = [contactsNav, chatNav]
        
        var idx:Int = 0
        for controller in controllers {
            addChildViewController(controller)
            let originX:CGFloat = CGFloat(idx) * width
            controller.view.frame = CGRect(x: originX, y: 0, width: width, height: height);
            scrollView!.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
            idx += 1
        }
        
        self.scrollView!.delegate = self
        scrollView.scrollRectToVisible(chatNav.view.frame, animated: false)
    }
    
    
}

// MARK: UIScrollView Delegate
extension SwipeController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if delegate != nil && !delegate!.innerScrollViewShouldScroll() {
            // This is probably crazy movement: diagonal scrolling
            var newOffset = CGPoint()
            
            if (abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y)) {
                newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
            } else {
                newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
            }
            
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            self.scrollView!.setContentOffset(newOffset,animated:  false)
        }
    }
}
