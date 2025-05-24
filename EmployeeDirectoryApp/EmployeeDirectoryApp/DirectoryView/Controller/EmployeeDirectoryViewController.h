//
//  EmployeeDirectoryViewController.h
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import <UIKit/UIKit.h>
#import "EmployeeDirectoryViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmployeeDirectoryViewController : UIViewController <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    EmployeeDirectoryViewModelDelegate
>

@end

NS_ASSUME_NONNULL_END
