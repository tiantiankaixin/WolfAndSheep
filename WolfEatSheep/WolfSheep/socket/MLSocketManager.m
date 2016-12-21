//
//  MLSocketManager.m
//  WolfEatSheep
//
//  Created by mal on 16/12/21.
//  Copyright © 2016年 mal. All rights reserved.
//

#import "MLSocketManager.h"

static MLSocketManager *manager = nil;
static NSString *kWiTapBonjourType = @"_witap2._tcp.";

@interface MLSocketManager()<NSNetServiceDelegate,NSNetServiceBrowserDelegate,NSStreamDelegate>

@property (nonatomic, strong) NSNetService *server;
@property (nonatomic, assign) BOOL isServerStarted;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) NSUInteger streamOpenCount;

@property (nonatomic, strong, readwrite) NSNetServiceBrowser *browser;

@end

@implementation MLSocketManager

+ (MLSocketManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MLSocketManager alloc] init];
    });
    return manager;
}

//MARK: get
- (NSNetService *)server
{
    if (_server == nil)
    {
        _server = [[NSNetService alloc] initWithDomain:@"local." type:kWiTapBonjourType name:[UIDevice currentDevice].name port:0];
        _server.includesPeerToPeer = YES;
        [_server setDelegate:self];
    }
    return _server;
}

- (NSNetServiceBrowser *)browser
{
    if (_browser == nil)
    {
        _browser = [[NSNetServiceBrowser alloc] init];
        _browser.includesPeerToPeer = YES;
        [_browser setDelegate:self];

    }
    return _browser;
}

//MARK: 开启服务
- (void)startServer
{
    if (!self.isServerStarted)
    {
        [self.server publishWithOptions:NSNetServiceListenForConnections];
    }
}

//MARK: 搜索服务
- (void)beginSearchServer
{
    [self.browser searchForServicesOfType:kWiTapBonjourType inDomain:@"local"];
}

//MARK: NSNetServiceDelegate
- (void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"服务开启成功！");
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    // Due to a bug <rdar://problem/15626440>, this method is called on some unspecified
    // queue rather than the queue associated with the net service (which in this case
    // is the main queue).  Work around this by bouncing to the main queue.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        assert(sender == self.server);
#pragma unused(sender)
        assert(inputStream != nil);
        assert(outputStream != nil);
        
        assert( (self.inputStream != nil) == (self.outputStream != nil) );      // should either have both or neither
        
        if (self.inputStream != nil) {
            // We already have a game in place; reject this new one.
            [inputStream open];
            [inputStream close];
            [outputStream open];
            [outputStream close];
        } else {
            // Start up the new game.  Start by deregistering the server, to discourage
            // other folks from connecting to us (and being disappointed when we reject
            // the connection).
            
            [self.server stop];
            self.isServerStarted = NO;
            //self.registeredName = nil;
            
            // Latch the input and output sterams and kick off an open.
            
            self.inputStream  = inputStream;
            self.outputStream = outputStream;
            
            [self openStreams];
        }
    }];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
// This is called when the server stops of its own accord.  The only reason
// that might happen is if the Bonjour registration fails when we reregister
// the server, and that's hard to trigger because we use auto-rename.  I've
// left an assert here so that, if this does happen, we can figure out why it
// happens and then decide how best to handle it.
{
    assert(sender == self.server);
#pragma unused(sender)
#pragma unused(errorDict)
    assert(NO);
}

//MARK: NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
   
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
   
}

//MARK: stream
- (void)openStreams
{
    assert(self.inputStream != nil);            // streams must exist but aren't open
    assert(self.outputStream != nil);
    assert(self.streamOpenCount == 0);
    
    [self.inputStream  setDelegate:self];
    [self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream  open];
    
    [self.outputStream setDelegate:self];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}

- (void)closeStreams
{
    assert( (self.inputStream != nil) == (self.outputStream != nil) );      // should either have both or neither
    if (self.inputStream != nil) {
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream close];
        self.inputStream = nil;
        
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream close];
        self.outputStream = nil;
    }
    self.streamOpenCount = 0;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
#pragma unused(stream)
    
    switch(eventCode) {
            
        case NSStreamEventOpenCompleted: {
            self.streamOpenCount += 1;
            assert(self.streamOpenCount <= 2);
            
            // Once both streams are open we hide the picker and the game is on.
            
            if (self.streamOpenCount == 2) {
                //[self dismissPicker];
                [self.server stop];
                self.isServerStarted = NO;
                //self.registeredName = nil;
            }
        } break;
            
        case NSStreamEventHasSpaceAvailable: {
            assert(stream == self.outputStream);
            // do nothing
        } break;
            
        case NSStreamEventHasBytesAvailable: {
            uint8_t     b;
            NSInteger   bytesRead;
            
            assert(stream == self.inputStream);
            
            bytesRead = [self.inputStream read:&b maxLength:sizeof(uint8_t)];
            if (bytesRead <= 0) {
                // Do nothing; we'll handle EOF and error in the
                // NSStreamEventEndEncountered and NSStreamEventErrorOccurred case,
                // respectively.
            } else {
                // We received a remote tap update, forward it to the appropriate view
                /*
                if ( (b >= 'A') && (b < ('A' + kTapViewControllerTapItemCount))) {
                    [self.tapViewController remoteTouchDownOnItem:b - 'A'];
                } else if ( (b >= 'a') && (b < ('a' + kTapViewControllerTapItemCount))) {
                    [self.tapViewController remoteTouchUpOnItem:b - 'a'];
                } else {
                    // Ignore the bogus input.  This is important because it allows us
                    // to telnet in to the app in order to test its behaviour.  telnet
                    // sends all sorts of odd characters, so ignoring them is a good thing.
                }
                 */
            }
        } break;
            
        default:
            assert(NO);
            // fall through
        case NSStreamEventErrorOccurred:
            // fall through
        case NSStreamEventEndEncountered: {
            //[self setupForNewGame];
        } break;
    }
}


@end
