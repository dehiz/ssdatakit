//
//  SSManagedUITableViewController.m
//  ios-agendary
//
//  Created by Ange Abou on 14/07/2013.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import "SSManagedUITableViewController.h"
#import "SSManagedObject.h"

@implementation SSManagedUITableViewController

@synthesize managedObject = _managedObject;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize ignoreChange = _ignoreChange;
@synthesize loading = _loading;
@synthesize noContentView = _noContentView;
@synthesize loadingView = _loadingView;

#pragma mark - Accessors

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [[[[self class] fetchedResultsControllerClass] alloc] initWithFetchRequest:self.fetchRequest
                                                                                          managedObjectContext:self.managedObjectContext
                                                                                            sectionNameKeyPath:self.sectionNameKeyPath
                                                                                                     cacheName:self.cacheName];
		_fetchedResultsController.delegate = self;
		[_fetchedResultsController performFetch:nil];
	}
	return _fetchedResultsController;
}


- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	_fetchedResultsController.delegate = nil;
	_fetchedResultsController = fetchedResultsController;
}


- (void)setLoading:(BOOL)loading {
	[self setLoading:loading animated:YES];
}


#pragma mark - NSObject

- (id)init {
    return (self = [self initWithStyle:UITableViewStylePlain]);
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
	self.fetchedResultsController = nil;
}


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updatePlaceholderViews:NO];
}


#pragma mark - Configuration

+ (Class)fetchedResultsControllerClass {
	return [NSFetchedResultsController class];
}


- (NSFetchRequest *)fetchRequest {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self.entityClass entityWithContext:self.managedObjectContext];
	fetchRequest.sortDescriptors = self.sortDescriptors;
	fetchRequest.predicate = self.predicate;
	return fetchRequest;
}


- (Class)entityClass {
	return [SSManagedObject class];
}


- (NSArray *)sortDescriptors {
	return [self.entityClass defaultSortDescriptors];
}


- (NSPredicate *)predicate {
	return nil;
}


- (NSManagedObjectContext *)managedObjectContext {
    return [[self entityClass] mainQueueContext];
}


- (NSString *)sectionNameKeyPath {
	return nil;
}


- (NSString *)cacheName {
	return nil;
}


#pragma mark - Accessing Objects

- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath {
	return fetchedIndexPath;
}


- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath {
	return viewIndexPath;
}


- (id)objectForViewIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:[self fetchedIndexPathForViewIndexPath:indexPath]];
}


#pragma mark - Placeholders

- (void)setLoading:(BOOL)loading animated:(BOOL)animated {
	_loading = loading;
	[self updatePlaceholderViews:animated];
}


- (BOOL)hasContent {
	return self.fetchedResultsController.fetchedObjects.count > 0;
}


- (void)updatePlaceholderViews:(BOOL)animated {
	// Disable animated changes for now since they are buggy
	animated = NO;
    
	// There is content to be displayed
	if ([self hasContent]) {
		// Hide the loading and content view
		[self hideLoadingView:animated];
		[self hideNoContentView:animated];
		return;
	}
    
	// There is no content to be displayed.
	if ([self isLoading]) {
		// Show the loading view and hide the no content view
		[self hideNoContentView:animated];
		[self showLoadingView:animated];
	} else {
		// Show the no content view and hide the loading view
		[self hideLoadingView:animated];
		[self showNoContentView:animated];
	}
}


- (void)showLoadingView:(BOOL)animated {
	if (!self.loadingView || self.loadingView.superview) {
		return;
	}
    
	self.loadingView.alpha = 0.0f;
	self.loadingView.frame = self.view.bounds;
	[self.view addSubview:self.loadingView];
    
	void (^change)(void) = ^{
		self.loadingView.alpha = 1.0f;
	};
    
    
	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:nil];
	} else {
		change();
	}
}


- (void)hideLoadingView:(BOOL)animated {
	if (!self.loadingView || !self.loadingView.superview) {
		return;
	}
    
	void (^change)(void) = ^{
		self.loadingView.alpha = 0.0f;
	};
    
	void (^completion)(BOOL finished) = ^(BOOL finished) {
		[self.loadingView removeFromSuperview];
	};
    
	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:completion];
	} else {
		change();
		completion(YES);
	}
}


- (void)showNoContentView:(BOOL)animated {
	if (!self.noContentView || self.noContentView.superview) {
		return;
	}
    
	self.noContentView.alpha = 0.0f;
	self.noContentView.frame = self.view.bounds;
	[self.view addSubview:self.noContentView];
    
	void (^change)(void) = ^{
		self.noContentView.alpha = 1.0f;
	};
    
    
	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:nil];
	} else {
		change();
	}
}


- (void)hideNoContentView:(BOOL)animated {
	if (!self.noContentView || !self.noContentView.superview) {
		return;
	}
    
	void (^change)(void) = ^{
		self.noContentView.alpha = 0.0f;
	};
    
	void (^completion)(BOOL finished) = ^(BOOL finished) {
		[self.noContentView removeFromSuperview];
	};
    
	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:completion];
	} else {
		change();
		completion(YES);
	}
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}
    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
            
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}
    
    UITableView *tableView = self.tableView;
	indexPath = [self viewIndexPathForFetchedIndexPath:indexPath];
	newIndexPath = [self viewIndexPathForFetchedIndexPath:newIndexPath];
    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
            
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
            
        case NSFetchedResultsChangeUpdate: {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
		}
            
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self updatePlaceholderViews:YES];
	if (self.ignoreChange) {
		return;
	}
    
	if ([self useChangeAnimations]) {
		[self.tableView endUpdates];
	} else {
		[self.tableView reloadData];
	}
}

#pragma mark - UITableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Subclasses should override this method
}

- (BOOL)useChangeAnimations {
	return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses should override this method
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

@end
