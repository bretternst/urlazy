#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "Foundation/NSJSONSerialization.h"

#define MULTICAST_ADDR @"239.255.41.1"
#define SERVER_PORT 4111
#define TIMEOUT_INTERVAL 3.0
#define TIMEOUT_RETRIES 3

@interface Pair : NSObject
{
    id key;
    id value;
}
@property (nonatomic, retain) id key;
@property (nonatomic, retain) id value;
@end

@implementation Pair
@synthesize key, value;
@end

@interface ViewController ()
{
    NSMutableArray *hosts;
    NSMutableArray *pairs;
    GCDAsyncUdpSocket *socket;
    NSTimer *timer;
    int timeouts;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if (![self isWiFiConnected]) {
        [self showAlert:@"This app requires a local Wi-Fi connection" title:@"Error"];
    }
    else {
        [self start];
    }
}

- (void)start
{
    [self stop];
    [activityView startAnimating];
    hosts = [[NSMutableArray alloc] init];
    pairs = [[NSMutableArray alloc] init];
    [table reloadData];
    
    NSError *error;
    if(!socket) {
        socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [socket bindToPort:0 error:&error];
        if(error != nil) {
            NSLog(@"error binding");
        }
        [socket beginReceiving:&error];
        if(error != nil) {
            NSLog(@"error receiving");
        }
        [socket joinMulticastGroup:MULTICAST_ADDR error:&error];
        if(error != nil) {
            NSLog(@"error joining multicast group");
        }
        [socket enableBroadcast:YES error:&error];
        if(error != nil) {
            NSLog(@"error enabling broadcast");
        }
    }
    
    [self send];
    timeouts = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
}

- (void)stop {
    if(socket != nil) {
        [socket close];
        socket = nil;
    }
    if(timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [activityView stopAnimating];
}

- (void)send {
    NSData *data = [@"query" dataUsingEncoding:NSUTF8StringEncoding];
    [socket sendData:data toHost:MULTICAST_ADDR port:SERVER_PORT withTimeout:-1 tag:0];
}

-(void)timeout:o {
    if(++timeouts == TIMEOUT_RETRIES) {
        if([hosts count] == 0)
            [self showAlert:@"No collections were found on your network. Please make sure a URLazy server is running." title:@"No Results"];
        [activityView stopAnimating];
        [self stop];
    }
    else
        [self send];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSError *err;
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    if(err) {
        NSLog(@"error parsing json payload");
        return;
    }
    NSString *host = payload[@"host"];
    NSDictionary *content = payload[@"content"];
    
    if([hosts containsObject:host])
        return;
    
    NSArray *orderedKeys = [[content allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *orderedPairs = [[NSMutableArray alloc] initWithCapacity:orderedKeys.count];
    for(int i = 0; i < orderedKeys.count; i++) {
        Pair *pair = [[Pair alloc] init];
        pair.key = orderedKeys[i];
        pair.value = [content objectForKey:pair.key];
        [orderedPairs addObject:pair];
    }
    [hosts addObject:host];
    [pairs addObject:orderedPairs];
    [table reloadData];
}

- (BOOL)isWiFiConnected {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
        (const struct sockaddr *)&localWifiAddress);
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(target, &flags);
    return (flags & kSCNetworkFlagsReachable);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self stop];
}

- (void)doForeground
{
    [self start];
}

- (IBAction)refresh
{
    [self start];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return hosts.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [hosts objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = [pairs objectAtIndex:section];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tabCellId = @"tabCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tabCellId];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tabCellId];
    }
    NSArray *list = [pairs objectAtIndex:indexPath.section];
    Pair *pair = [list objectAtIndex:indexPath.row];
    cell.textLabel.text = pair.key;
    cell.detailTextLabel.text = pair.value;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [pairs objectAtIndex:indexPath.section];
    Pair *pair = [list objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pair.value]];
    return nil;
}

-(void)showAlert:(NSString*)message title:(NSString*)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
