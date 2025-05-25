//
//  MockEmployeeService.m
//  EmployeeDirectoryAppTests
//
//  Created by Zeeshan Shakeel on 25/05/2025.
//

#import "MockEmployeeService.h"

@implementation MockEmployeeService

// Override the designated initializer to allow setting up the mock
- (instancetype)initWithBaseURLString:(NSString *)baseURLString session:(NSURLSession *)session {
    self = [super initWithBaseURLString:baseURLString andSession:session];
    
    if (self) {
        
    }
    return self;
}

// Override the fetch method to provide mock data/error
- (void)fetchEmployeesWithCompletion:(EmployeeFetchCompletionBlock)completion {
    // Call the completion handler so as to notify the caller for the response.
    if (completion) {
        completion(self.mockEmployeeListResponse, self.mockError);
    }
}

@end
