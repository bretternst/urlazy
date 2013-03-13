#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

#define MULTICAST_ADDR @"239.255.41.1"
#define SERVER_PORT 4111


@interface EntryModel : NSObject <NSCoding> {
    NSString *_name;
    NSString *_url;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;

@end

@interface Listener : NSObject {
    NSMutableArray *_entries;
    GCDAsyncUdpSocket *_socket;
    NSString *_myIP;
}

@property (nonatomic, strong) NSMutableArray *entries;

@end
