#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *table;
    IBOutlet UIActivityIndicatorView *activityView;
}

@end
