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
#define EndStr @"E"

@interface MLSocketManager()<NSNetServiceDelegate,NSNetServiceBrowserDelegate,NSStreamDelegate>

@property (nonatomic, strong) NSNetService *server;
@property (nonatomic, assign) BOOL isServerStarted;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) NSUInteger streamOpenCount;
@property (nonatomic, assign) NodeType type;
//服务搜寻
@property (nonatomic, strong) NSNetServiceBrowser *browser;
@property (nonatomic, strong) NSMutableArray<NSNetService*> *services;
@property (nonatomic, strong) NSMutableString *receiveStr;

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

- (NSMutableArray<NSNetService *> *)services
{
    if (_services == nil)
    {
        _services = [NSMutableArray array];
    }
    return _services;
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
            self.type = sheep;
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
    NSLog(@"服务已关闭");
}

//MARK: NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if([browser isEqual:self.browser])
    {
        if (![service isEqual:self.server] && [self.services indexOfObject:service] != NSNotFound)
        {
            [self.services removeObject:service];
        }
    }
    if (!moreComing)//移除完毕
    {
        if([self.m_delegate respondsToSelector:@selector(updatePlayerList:)])
        {
            [self.m_delegate updatePlayerList:[NSMutableArray arrayWithArray:self.services]];
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if([browser isEqual:self.browser])
    {
        if (![service isEqual:self.server] && [self.services indexOfObject:service] == NSNotFound)
        {
            [self.services addObject:service];
        }
    }
    if (!moreComing && self.services.count > 0)//加入完毕
    {
        if([self.m_delegate respondsToSelector:@selector(updatePlayerList:)])
        {
            [self.m_delegate updatePlayerList:[NSMutableArray arrayWithArray:self.services]];
        }
    }
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
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.inputStream  setDelegate:self];
        [self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream  open];
        
        [self.outputStream setDelegate:self];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream open];
    });
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
    
    switch(eventCode)
    {
        case NSStreamEventOpenCompleted:
        {
            self.streamOpenCount += 1;
            assert(self.streamOpenCount <= 2);
            // Once both streams are open we hide the picker and the game is on.
            if (self.streamOpenCount == 2)
            {
                //[self dismissPicker];
                [self.server stop];
                self.isServerStarted = NO;
                //self.registeredName = nil;
                //FIXME: 连接成功
                if ([self.m_delegate respondsToSelector:@selector(connectSuccess)])
                {
                    [self.m_delegate connectSuccess];
                }
            }
        } break;
            
        case NSStreamEventHasSpaceAvailable: {
            assert(stream == self.outputStream);
            // do nothing
        } break;
            
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t b;
            NSInteger bytesRead;
            assert(stream == self.inputStream);
            bytesRead = [self.inputStream read:&b maxLength:sizeof(uint8_t)];
            if (bytesRead <= 0)
            {
                // Do nothing; we'll handle EOF and error in the
                // NSStreamEventEndEncountered and NSStreamEventErrorOccurred case,
                // respectively.
            }
            else
            {
                NSString *message = [[NSString alloc] initWithCString:(char *)&b encoding:NSUTF8StringEncoding];
                if ([message isEqualToString:EndStr])
                {
                    NSLog(@"=====%@",self.receiveStr);
                    self.receiveStr = nil;
                }
                else
                {
                    if (!self.receiveStr)
                    {
                        self.receiveStr = [[NSMutableString alloc] init];
                    }
                    [self.receiveStr appendString:message];
                }
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

- (void)sendMessage:(NSString *)message
{
    assert(self.streamOpenCount == 2);
    message = [NSString stringWithFormat:@"%@%@",message,EndStr];
    if ([self.outputStream hasSpaceAvailable] )
    {
        NSInteger bytesWritten;
        bytesWritten = [self.outputStream write:(const uint8_t *)[message cStringUsingEncoding:NSUTF8StringEncoding] maxLength:sizeof(message)];
        if (bytesWritten != sizeof(message))
        {
        }
    }
}

#pragma mark - 连接service
- (void)connectService:(NSNetService *)service
{
    BOOL                success;
    NSInputStream *     inStream;
    NSOutputStream *    outStream;
    assert(self.inputStream == nil);
    assert(self.outputStream == nil);
    success = [service getInputStream:&inStream outputStream:&outStream];
    if ( ! success )
    {
        
    }
    else
    {
        self.type = wolf;
        self.inputStream  = inStream;
        self.outputStream = outStream;
        [self openStreams];
    }
}

+ (NodeType)roleType
{
    return [MLSocketManager shareManager].type;
}

@end
