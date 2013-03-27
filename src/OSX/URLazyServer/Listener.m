#import "Listener.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation EntryModel
- (id)init {
    self = [super init];
    if (self) {
        _name = [[NSString alloc] init];
        _url = [[NSString alloc] init];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)coder {
    if((self = [super init])) {
        _name = [coder decodeObjectForKey:@"name"];
        _url = [coder decodeObjectForKey:@"url"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_url forKey:@"url"];
}
@end

@implementation Listener
- (id) init {
    if ((self = [super self])) {
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _myIP = [self getMyIP];
        [_socket bindToPort:SERVER_PORT error:nil];
        [_socket joinMulticastGroup:MULTICAST_ADDR error:nil];
        [_socket beginReceiving:nil];
    }
    return self;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if(_entries == nil)
        return;
    
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    for(EntryModel *e in _entries) {
        if(e.name.length > 0 && e.url.length > 0)
            [content setValue:[self processUrl:e.url] forKey:e.name];
    }
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    [payload setValue:[[NSHost currentHost] name] forKey:@"host"];
    [payload setValue:content forKey:@"content"];
    NSData *payloadBytes = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    uint16_t port;
    [GCDAsyncUdpSocket getHost:nil port:&port fromAddress:address];
    [_socket sendData:payloadBytes toHost:MULTICAST_ADDR port:port withTimeout:-1 tag:0];
}

- (NSString*) processUrl:(NSString*) url {
    if([url hasPrefix:@"http://localhost"]) {
        NSMutableString *newUrl = [[NSMutableString alloc] initWithString:@"http://"];
        [newUrl appendString:_myIP];
        [newUrl appendString:[url substringFromIndex:16]];
        return [[NSString alloc] initWithString:newUrl];
    }
    else if ([url hasPrefix:@"https://localhost"]) {
        NSMutableString *newUrl = [[NSMutableString alloc] initWithString:@"https://"];
        [newUrl appendString:_myIP];
        [newUrl appendString:[url substringFromIndex:17]];
        return [[NSString alloc] initWithString:newUrl];
    }
    else
        return url;
}

- (void) dealloc {
    [_socket close];
}

- (NSString *)getMyIP {
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if(success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if ([name hasPrefix:@"en"] || [name hasPrefix:@"fw"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}
@end
