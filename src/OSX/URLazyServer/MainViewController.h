//
//  MainViewController.h
//  URLazyServer
//
//  Created by Brett Ernst on 3/10/13.
//  Copyright (c) 2013 Brett Ernst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Listener.h"

@interface MainViewController : NSViewController <NSTableViewDataSource> {
    IBOutlet NSMutableArray *_entries;
    IBOutlet NSTableView *_table;
    Listener *_listener;
}

@end
