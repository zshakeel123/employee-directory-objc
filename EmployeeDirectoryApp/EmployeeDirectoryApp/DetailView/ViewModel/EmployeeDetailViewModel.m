//
//  EmployeeDetailViewModel.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 24/05/2025.
//

#import "EmployeeDetailViewModel.h"

@interface EmployeeDetailViewModel ()

// Private readwrite properties to back the public readonly properties
// The compiler will auto-synthesize the backing ivars (_fullName, etc.)
@property (nonatomic, copy, readwrite) NSString *fullName;
@property (nonatomic, copy, readwrite, nullable) NSString *phoneNumber;
@property (nonatomic, copy, readwrite, nullable) NSString *emailAddress;
@property (nonatomic, copy, readwrite, nullable) NSString *biography;
@property (nonatomic, copy, readwrite) NSString *team;
@property (nonatomic, copy, readwrite) NSString *employeeType;

@property (nonatomic, strong, readwrite, nullable) NSURL *photoURLSmall;
@property (nonatomic, strong, readwrite, nullable) NSURL *photoURLLarge;

@end

@implementation EmployeeDetailViewModel

- (instancetype)initWithEmployee:(Employee *)employee {
    self = [super init];
    if (self) {
        // Basic properties directly from the Employee model
        _fullName = employee.fullName ?: @"N/A";
        _emailAddress = employee.emailAddress;
        _biography = employee.biography;
        _team = employee.team ?: @"N/A";

        _photoURLSmall = [[NSURL alloc] initWithString: employee.photoUrlSmall];
        _photoURLLarge = [[NSURL alloc] initWithString: employee.photoUrlLarge];

        // Format phone number if available
        if (employee.phoneNumber) {
            _phoneNumber = [self formattedPhoneNumber:employee.phoneNumber];
        } else {
            _phoneNumber = nil;
        }

        // Convert EmployeeType enum to a user-friendly string
        _employeeType = [self stringForEmployeeType:employee.employeeType];
    }
    return self;
}

- (instancetype)init {
    // Prevent direct calls to init, ensuring an Employee object is always provided
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not the designated initializer for EmployeeDetailViewModel. Use -initWithEmployee: instead."
                                 userInfo:nil];
}

#pragma mark - Helper Methods for Formatting

// Helper to format phone number (e.g., from 1234567890 to (123) 456-7890)
- (nullable NSString *)formattedPhoneNumber:(NSString *)rawPhoneNumber {
    if (rawPhoneNumber.length == 0) {
        return nil;
    }

    // Remove non-numeric characters
    NSString *numericString = [[rawPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];

    if (numericString.length == 10) { // Assuming US 10-digit format
        return [NSString stringWithFormat:@"(%@) %@-%@",
                [numericString substringWithRange:NSMakeRange(0, 3)],
                [numericString substringWithRange:NSMakeRange(3, 3)],
                [numericString substringWithRange:NSMakeRange(6, 4)]];
    } else {
        // Return original if not a standard format we can handle
        return rawPhoneNumber;
    }
}

// Helper to convert EmployeeType enum to string
- (NSString *)stringForEmployeeType:(EmployeeType)type {
    switch (type) {
        case EmployeeTypeFullTime:
            return @"Full Time";
        case EmployeeTypePartTime:
            return @"Part Time";
        case EmployeeTypeContractor:
            return @"Contractor";
        default:
            return @"Unknown";
    }
}

@end
