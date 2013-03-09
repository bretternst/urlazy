//
//  ViewController.h
//  URLazy
//
//  Created by Brett Ernst on 3/2/13.
//  Copyright (c) 2013 iconmobile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *table;
    IBOutlet UIActivityIndicatorView *activityView;
}

@end
