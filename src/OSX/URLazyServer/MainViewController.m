//
//  MainViewController.m
//  URLazyServer
//
//  Created by Brett Ernst on 3/10/13.
//  Copyright (c) 2013 Brett Ernst. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _entries = [[NSMutableArray alloc] init];
        EntryModel *entry;
        entry = [[EntryModel alloc] init];
        entry.name = @"Google";
        entry.url = @"http://www.google.com";
        [_entries addObject:entry];
        _listener = [[Listener alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib {
    [NSApp setDelegate:self];
    [self loadData];
    _listener.entries = _entries;
    [_table reloadData];
}

- (void)applicationWillTerminate:(NSNotification*)note {
    [self saveData];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) sender{
    return YES;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView {
    return [_entries count];
}

- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[_entries objectAtIndex:row] valueForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    [[_entries objectAtIndex:row] setValue:object forKey:[tableColumn identifier]];
}

- (IBAction)addClick:(id)sender {
    [_entries addObject:[[EntryModel alloc] init]];
    [_table reloadData];
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:_entries.count-1];
    [_table selectRowIndexes:indexes byExtendingSelection:NO];
    [_table editColumn:0 row:_entries.count - 1 withEvent:nil select:YES];
}

- (IBAction)delClick:(id)sender {
    NSInteger idx = [_table selectedRow];
    if(idx >= 0) {
        [_table abortEditing];
        [_entries removeObjectAtIndex:idx];
        [_table reloadData];
    }
}

- (NSString *) pathForDataFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/URLazy/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = @"content.dat";
    return [folder stringByAppendingPathComponent: fileName];
}

- (void) saveData {
    NSString *path = [self pathForDataFile];
    [NSKeyedArchiver archiveRootObject:_entries toFile:path];
}

- (void) loadData {
    NSString *path = [self pathForDataFile];
    NSMutableArray *entries = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if(entries != nil)
        _entries = entries;
}

@end
