//
//  MockURLSession.h
//  EmployeeNetworkingTests
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Forward declaration of MockURLSessionDataTask
@class MockURLSessionDataTask;

// Type definition for the completion handler that MockURLSession will use
typedef void (^MockSessionCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface MockURLSession : NSObject

// Properties to configure the mock's behavior
@property (nonatomic, strong, nullable) NSData *mockData;
@property (nonatomic, strong, nullable) NSURLResponse *mockResponse;
@property (nonatomic, strong, nullable) NSError *mockError;

@end

// This task will immediately call its completion handler upon resume
@interface MockURLSessionDataTask : NSObject

@property (nonatomic, copy, nullable) MockSessionCompletionHandler completionHandler;
@property (nonatomic, strong, nullable) NSData *storedData;
@property (nonatomic, strong, nullable) NSURLResponse *storedResponse;
@property (nonatomic, strong, nullable) NSError *storedError;

- (instancetype)initWithData:(nullable NSData *)data response:(nullable NSURLResponse *)response error:(nullable NSError *)error completionHandler:(nullable MockSessionCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
