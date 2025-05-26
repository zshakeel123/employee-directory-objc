//
//  EmployeeDirectoryViewController.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import "EmployeeDirectoryViewController.h"
#import "EmployeeCollectionViewCell.h"
#import <EmployeeNetworking/EmployeeService.h>
#import "AppConstants.h"
#import "EmployeeDetailViewController.h"

@interface EmployeeDirectoryViewController ()

// UI Elements
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *statusLabel; // To display error or empty state messages
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIButton *retryButton;

// ViewModel
@property (nonatomic, strong) EmployeeDirectoryViewModel *viewModel;

@end

@implementation EmployeeDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Employee Directory";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 1. Initialize ViewModel
    EmployeeService *employeeService = [[EmployeeService alloc] initWithBaseURLString:kEmployeeAPIBaseURL andSession:[NSURLSession sharedSession]];
    
    self.viewModel = [[EmployeeDirectoryViewModel alloc] initWithEmployeeService: employeeService];
    
    // Set ViewModel's delegate to recieve updates
    self.viewModel.delegate = self;

    // 2. Setup UI Components
    [self setupCollectionView];
    [self setupActivityIndicator];
    [self setupStatusLabel];
    [self setupRefreshControl];
    [self setupRetryButton];

    // Initial UI state update based on ViewModel (before first fetch)
    [self updateUIForViewModelState];

    // 3. Initiate data fetch
    [self.viewModel fetchEmployees];
}

#pragma mark - UI Setup

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor systemGrayColor];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    [self.viewModel fetchEmployees];
}

- (void)setupCollectionView {
    // Configure Collection View Flow Layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 16.0;      // Vertical spacing between cells
    layout.minimumInteritemSpacing = 8.0;  // Horizontal spacing between cells in the same row
    layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16); // Padding around the section

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    // Register your custom cell
    [self.collectionView registerClass:[EmployeeCollectionViewCell class] forCellWithReuseIdentifier:EmployeeCollectionViewCellReuseIdentifier];

    [self.view addSubview:self.collectionView];

    // Constraints for collection view to fill the safe area
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES; // Automatically hide when not animating
    [self.view addSubview:self.activityIndicator];

    // Center the activity indicator
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)setupStatusLabel {
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0; // Allow text to wrap
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.hidden = YES;

    [self.view addSubview:self.statusLabel];

    // Center the status label with some horizontal padding
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.statusLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20]
    ]];
}

- (void)setupRetryButton {
    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.retryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.retryButton setTitle:@"Try Again" forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.retryButton addTarget:self action:@selector(handleRetryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.hidden = YES; // Initially hidden

    [self.view addSubview:self.retryButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.retryButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.retryButton.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:20] // Below status label
    ]];
}

// Retry button handler
- (void)handleRetryButtonTapped:(UIButton *)sender {
    [self.viewModel fetchEmployees];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.employees.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue a reusable cell
    EmployeeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EmployeeCollectionViewCellReuseIdentifier forIndexPath:indexPath];

    // Get the corresponding employee from the ViewModel
    Employee *employee = self.viewModel.employees[indexPath.item];

    // Configure the cell with employee data
    [cell configureWithEmployee:employee];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout (for cell sizing)

// This method tells the flow layout the size for each cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Assuming a two-column layout.
    // Calculate available width after subtracting section insets and inter-item spacing.
    UIEdgeInsets sectionInsets = ((UICollectionViewFlowLayout *)collectionViewLayout).sectionInset;
    CGFloat minimumInteritemSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;

    CGFloat totalHorizontalPadding = sectionInsets.left + sectionInsets.right;
    CGFloat spacingBetweenColumns = minimumInteritemSpacing;
    CGFloat availableWidth = collectionView.bounds.size.width - totalHorizontalPadding - spacingBetweenColumns;

    CGFloat itemWidth = availableWidth / 2.0; // Two items per row

    // A fixed height for each item,
    CGFloat itemHeight = 180.0;

    return CGSizeMake(itemWidth, itemHeight);
}


#pragma mark - EmployeeDirectoryViewModelDelegate

// Delegate method called when the ViewModel's data changes (success or error/empty causing data to clear)
- (void)employeeDirectoryViewModelDidUpdateData:(EmployeeDirectoryViewModel *)sender {
    // All UI updates must be on the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self updateUIForViewModelState];
        
        // End the refresh control's animation when data has been updated
        if(self.refreshControl.isRefreshing){
            [self.refreshControl endRefreshing];
        }
    });
}

// Delegate method called when the ViewModel's loading state changes
- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didUpdateLoadingState:(BOOL)isLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIForViewModelState]; // This will show/hide activity indicator
    });
}

// Delegate method called when the ViewModel encounters an error
- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didEncounterError:(nullable NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIForViewModelState];
        
        // Also end the refresh control's animation if an error occurs
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    });
}

#pragma mark - UI State Management

- (void)updateUIForViewModelState {
    if (self.viewModel.isLoading) {
        // If the refresh control is active, its loader is sufficient.
        // Otherwise, show the central activity indicator for initial load
        if (self.refreshControl.isRefreshing) {
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.retryButton.hidden = YES;
            self.statusLabel.hidden = YES;
            self.collectionView.hidden = NO;
        } else {
            // This is for initial load
            // Show central activity indicator, hide everything else including retry button.
            [self.activityIndicator startAnimating];
            self.activityIndicator.hidden = NO;
            self.statusLabel.hidden = YES;
            self.collectionView.hidden = YES;
            self.retryButton.hidden = YES;
        }
    } else {
        // Not loading (fetch completed, either success or error)
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;

        if (self.viewModel.errorMessage) {
            // Show error message and retry button
            self.statusLabel.text = self.viewModel.errorMessage;
            self.statusLabel.hidden = NO;
            self.collectionView.hidden = YES;
            self.retryButton.hidden = NO;
        } else if (self.viewModel.employees.count == 0) {
            // Show empty state message and retry button
            self.statusLabel.text = @"No employees found.";
            self.statusLabel.hidden = NO;
            self.collectionView.hidden = YES;
            self.retryButton.hidden = NO;
        } else {
            // Data loaded successfully, show collection view, hide status/retry.
            self.statusLabel.hidden = YES;
            self.collectionView.hidden = NO;
            self.retryButton.hidden = YES;
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the item to prevent it from staying highlighted
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    // Get the selected employee
        Employee *selectedEmployee = self.viewModel.employees[indexPath.item];

        // Create the EmployeeDetailViewModel
        EmployeeDetailViewModel *detailViewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:selectedEmployee];

        // instantiate EmployeeDetailViewController from Storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

        // Instantiate the view controller using its Storyboard ID
        EmployeeDetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"EmployeeDetailViewControllerID"];

        // Pass the ViewModel to the detail view controller
        detailVC.viewModel = detailViewModel;
        
        [self.navigationController pushViewController:detailVC animated:YES];
}

@end
