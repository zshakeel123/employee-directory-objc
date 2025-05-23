//
//  MockURLSession.m
//  EmployeeNetworkingTests
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import "MockURLSession.h"

NS_ASSUME_NONNULL_BEGIN

@implementation MockURLSession

// Override dataTaskWithURL to return our mock task
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(MockSessionCompletionHandler)completionHandler {
    // Return our custom mock data task that immediately calls its handler
    return (NSURLSessionDataTask *)[[MockURLSessionDataTask alloc] initWithData:self.mockData
                                                 response:self.mockResponse
                                                    error:self.mockError
                                          completionHandler:completionHandler];
}

@end

@implementation MockURLSessionDataTask

- (instancetype)initWithData:(nullable NSData *)data response:(nullable NSURLResponse *)response error:(nullable NSError *)error completionHandler:(nullable MockSessionCompletionHandler)completionHandler {
    self = [super init];
    if (self) {
        _storedData = data;
        _storedResponse = response;
        _storedError = error;
        _completionHandler = completionHandler;
    }
    return self;
}

// Override resume to immediately call the completion handler
- (void)resume {
    if (self.completionHandler) {
        // Dispatch to a background queue to simulate real async behavior
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(backgroundQueue, ^{
            self.completionHandler(self.storedData, self.storedResponse, self.storedError);
        });
    }
}

@end

NS_ASSUME_NONNULL_END
