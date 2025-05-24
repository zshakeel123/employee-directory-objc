//
//  EmployeeDetailViewModel.h
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 24/05/2025.
//

#import <Foundation/Foundation.h>
#import <EmployeeNetworking/Employee.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmployeeDetailViewModel : NSObject

// Public properties for displaying employee details
@property (nonatomic, copy, readonly) NSString *fullName;
@property (nonatomic, copy, readonly, nullable) NSString *phoneNumber; // Formatted
@property (nonatomic, copy, readonly, nullable) NSString *emailAddress;
@property (nonatomic, copy, readonly, nullable) NSString *biography;
@property (nonatomic, copy, readonly) NSString *team;
@property (nonatomic, copy, readonly) NSString *employeeType; // User-friendly string

// Photo URLs for potential image loading in the view
@property (nonatomic, strong, readonly, nullable) NSURL *photoURLSmall;
@property (nonatomic, strong, readonly, nullable) NSURL *photoURLLarge;

/**
 * @brief Initializes the view model with a specific Employee object.
 * @param employee The Employee object for which details are to be displayed.
 * @return An initialized EmployeeDetailViewModel instance.
 */
- (instancetype)initWithEmployee:(Employee *)employee NS_DESIGNATED_INITIALIZER;

// Prevent direct calls to init to enforce designated initializer
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
