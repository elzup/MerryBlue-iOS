import UIKit
import TwitterKit
import FontAwesomeKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    var listId: String!
    var users = [TwitterUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.setNavigationBar()
        self.title = "HomeBoard"
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: "pullToRefresh", forControlEvents:.ValueChanged)
        
        self.tableView.addSubview(refreshControl)
    }
    
    // 何を更新するのかを定義
    func pullToRefresh(){
        TwitterManager.getListUsers(self, listId: listId)
        
        refreshControl.endRefreshing() // データが取れたら更新を終える（くるくる回るViewを消去）
    }
    
    override func viewDidAppear(animated: Bool) {
        guard let listId: String = ConfigManager.getListId() else {
            self.openListsChooser()
            return
        }
        self.listId = listId
        self.activityIndicator.startAnimating()
        TwitterManager.getListUsers(self, listId: listId)
    }
    
    internal func setupListUsers(users: [TwitterUser]) {
        self.users = users
        self.tableView.reloadData()
        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UserStatusCell = tableView.dequeueReusableCellWithIdentifier("userStatusCell", forIndexPath: indexPath) as! UserStatusCell
        cell.setCell(users[indexPath.row])
        return cell
    }
    
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        self.openUserTimeline(user)
    }
    
    private func setNavigationBar() {
        let iconImage = FAKIonIcons.iosListIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        let switchListButton = UIBarButtonItem(image: iconImage, style: .Plain, target: self, action: "onClickSwitchList")
        
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        // self.navigationController?.navigationBar.alpha = 0.1
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem
        self.navigationItem.title = "HomeBoard"
        self.navigationItem.setRightBarButtonItem(switchListButton, animated: true)
    }
    
    func onClickSwitchList() {
        self.openListsChooser()
    }
    
    func openListsChooser() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("lists")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func openUserTimeline(user: TwitterUser) {
        self.delegate.userViewUser = user
        let vc = UINavigationController(rootViewController: UserTimelineViewController())
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let listId: String = ConfigManager.getListId() else {
            self.openListsChooser()
            return
        }
        if (self.listId == listId) {
            return
        }
        self.activityIndicator.startAnimating()
        TwitterManager.getListUsers(self, listId: listId)
        self.listId = listId
    }
}