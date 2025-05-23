//
//  EmployeeService.m
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 21/05/2025.
//

#import "EmployeeService.h"
#import "ModuleConstants.h"

NS_ASSUME_NONNULL_BEGIN

// Define an error domain for EmployeeService specific errors
NSString *const EmployeeServiceErrorDomain = @"com.zeeshan.EmployeeNetworking.ErrorDomain";

// Private Class Extension to store the base URL
@interface EmployeeService ()
@property (nonatomic, strong, readonly) NSString *baseURLString;
@property (nonatomic, strong, readonly) NSURLSession *session;
@end

@implementation EmployeeService

- (instancetype)initWithBaseURLString:(NSString *)baseURLString andSession:(NSURLSession *)session {
    self = [super init];
    if (self) {
        if (!baseURLString || baseURLString.length == 0) {
            NSLog(@"Error: EmployeeService initialized with an empty or nil base URL string.");
            return nil;
        }
        
        if (!session) {
            NSLog(@"Error: EmployeeService initialized with a nil NSURLSession.");
            return nil;
        }
        
        _baseURLString = [baseURLString copy];
        _session = session;
    }
    return self;
}

// Make init unavailable as per NS_DESIGNATED_INITIALIZER in .h
- (instancetype)init {
    // Optionally call the designated initializer with a default or throw an exception
    // This method should ideally not be called
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not the designated initializer for EmployeeService. Use -initWithBaseURLString: instead."
                                 userInfo:nil];
}

- (void)fetchEmployeesWithCompletion:(EmployeeFetchCompletionBlock)completion {
    // 1. Validate the stored URL
    if (!self.baseURLString) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                                 code:EmployeeServiceErrorCodeInitializationFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"EmployeeService was not initialized with a valid base URL."}];
            // Only call completion on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:self.baseURLString];
    if (!url) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                                 code:EmployeeServiceErrorCodeInvalidURL
                                             userInfo:@{NSLocalizedDescriptionKey: @"Constructed API URL is invalid."}];
            // Only call completion on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }
        return;
    }

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 4. Check for Network Errors
        if (error) {
            if (completion) {
                NSError *networkError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                                             code:EmployeeServiceErrorCodeNetworkError
                                                         userInfo:@{NSLocalizedDescriptionKey: @"Network request failed.",
                                                                    NSUnderlyingErrorKey: error}];
                // Only call completion on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, networkError);
                });
            }
            return;
        }

        // 5. Check for HTTP Response Status Code
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            if (completion) {
                NSString *errorMessage = [NSString stringWithFormat:@"Server returned non-200 status code: %ld", (long)httpResponse.statusCode];
                NSError *httpError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                                          code:httpResponse.statusCode
                                                      userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                                 @"HTTPStatusCode": @(httpResponse.statusCode)}];
                // Only call completion on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, httpError);
                });
            }
            return;
        }

        // 6. Check for Data
        if (!data) {
            if (completion) {
                NSError *noDataError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                                            code:EmployeeServiceErrorCodeNoData
                                                        userInfo:@{NSLocalizedDescriptionKey: @"No data received from API."}];
                // Only call completion on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, noDataError);
                });
            }
            return;
        }

        // 7. Parse JSON Data (ON BACKGROUND THREAD)
        NSError *jsonError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (jsonError) {
            if (completion) {
                NSError *parsingError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                                             code:EmployeeServiceErrorCodeJSONParsingFailed
                                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse JSON response.",
                                                                    NSUnderlyingErrorKey: jsonError}];
                // Only call completion on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, parsingError);
                });
            }
            return;
        }

        // 8. Validate and Map to Model
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            if (completion) {
                NSError *invalidFormatError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                                                   code:EmployeeServiceErrorCodeInvalidResponseFormat
                                                               userInfo:@{NSLocalizedDescriptionKey: @"Invalid top-level JSON format: expected a dictionary."}];
                // Only call completion on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, invalidFormatError);
                });
            }
            return;
        }

        // 9. Create the emplyee list
        EmployeeListResponse *employeeList = [[EmployeeListResponse alloc] initWithDictionary:jsonObject];

        // 10. Call the completion block on the main thread
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(employeeList, nil);
            });
        }
    }];

    // 11. Start the data task
    [dataTask resume];
}

@end

NS_ASSUME_NONNULL_END
