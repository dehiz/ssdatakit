//
//  SSManagedUITableViewController.h
//  ios-agendary
//
//  Created by Ange Abou on 14/07/2013.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class SSManagedObject;

@interface SSManagedUITableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) SSManagedObject *managedObject;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BOOL ignoreChange;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) UIView *noContentView;
@property (nonatomic, strong) UIView *loadingView;

+ (Class)fetchedResultsControllerClass;
- (NSFetchRequest *)fetchRequest;
- (Class)entityClass;
- (NSArray *)sortDescriptors;
- (NSPredicate *)predicate;
- (NSManagedObjectContext *)managedObjectContext;
- (NSString *)sectionNameKeyPath;
- (NSString *)cacheName;

- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath;
- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath;
- (id)objectForViewIndexPath:(NSIndexPath *)indexPath;

- (void)setLoading:(BOOL)loading animated:(BOOL)animated;
- (BOOL)hasContent;
- (void)updatePlaceholderViews:(BOOL)animated;
- (void)showLoadingView:(BOOL)animated;
- (void)hideLoadingView:(BOOL)animated;
- (void)showNoContentView:(BOOL)animated;
- (void)hideNoContentView:(BOOL)animated;
- (BOOL)useChangeAnimations;

@end
