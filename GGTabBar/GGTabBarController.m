//
//  VITabBarController.m
//  Vinoli
//
//  Created by Nicolas Goles on 5/16/14.
//  Copyright (c) 2014 Goles. All rights reserved.
//

#import "GGTabBarController.h"
#import "GGTabBar.h"

@interface GGTabBarController () <GGTabBarDelegate>
@property (nonatomic, strong) UIView *presentationView;
@property (nonatomic, strong) GGTabBar *tabBarView;
@property (nonatomic, assign) BOOL isFirstAppear;
@end

@implementation GGTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];

    _tabBarView = [[GGTabBar alloc] initWithFrame:CGRectZero viewControllers:_viewControllers appearance:_tabBarAppearanceSettings];
    _tabBarView.delegate = self;

    _presentationView = [[UIView alloc] init];
    _presentationView.translatesAutoresizingMaskIntoConstraints = NO;
    _tabBarView.selectedButtonIndex = self.selectedIndex;
    
    [self.view addSubview:_tabBarView];
    [self.view addSubview:_presentationView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutTabBarView];
    [_tabBarView needsUpdateConstraints];

    if (_debug) {
        [self startDebugMode];
        [_tabBarView startDebugMode];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSParameterAssert(_viewControllers.count > 0);

    // Select first view controller on first Launch.
    if (!_isFirstAppear) {
        _isFirstAppear = YES;
        UIViewController *firstViewController = [_viewControllers objectAtIndex:self.selectedIndex];
        [self selectViewController:firstViewController];
    }
}

- (void)selectViewAtIndex:(int)select{
    if (select < self.viewControllers.count || select >= 0){
        [self selectViewController:[_viewControllers objectAtIndex:select]];
        [self.tabBarView selectButtonAtIndex:select];
        self.selectedViewController = [_viewControllers objectAtIndex:select];
        self.selectedIndex = select;
    }
}

- (void)setHidden:(BOOL) hidden{
    if(hidden)self.tabBarView.removeHeightConstraints;
    else self.tabBarView.addHeightConstraints;
    [self.view layoutIfNeeded];
}

#pragma mark - Delegation

- (void)tabBar:(GGTabBar *)tabBar didPressButton:(UIButton *)button atIndex:(NSUInteger)tabIndex
{
    UIViewController *selectedViewController = _viewControllers[tabIndex];
    
    if ([_delegate respondsToSelector:@selector(ggTabBarController:shouldSelectViewController:)]) {
        if ([_delegate ggTabBarController:self shouldSelectViewController:selectedViewController]) {
            [self selectViewController:selectedViewController withButton:button];
        }
    }
    
    self.selectedIndex = tabIndex;
    
    [self selectViewController:selectedViewController withButton:button];
}

# pragma mark - View Controller Selection

- (void)selectViewController:(UIViewController *)viewController withButton:(UIButton *)button
{
    [_tabBarView setSelectedButton:button];
    [self selectViewController:viewController];

}

- (void)selectViewController:(UIViewController *)viewController
{
    UIView *presentedView = [_presentationView.subviews firstObject];
    if (presentedView) {
        [presentedView removeFromSuperview];
    }
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [_presentationView addSubview:viewController.view];
    [self fitView:viewController.view intoView:_presentationView];
}


#pragma mark - Layout

- (void)layoutViewWithoutTabBar
{
    NSDictionary *viewsDictionary = @{@"tabbar_view" : _tabBarView,
                                      @"presentation_view" : _presentationView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabbar_view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[presentation_view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[presentation_view][tabbar_view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
}

- (void)layoutTabBarView
{
    NSDictionary *viewsDictionary = @{@"tabbar_view" : _tabBarView,
                                      @"presentation_view" : _presentationView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabbar_view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[presentation_view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[presentation_view][tabbar_view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
}

- (void)fitView:(UIView *)toPresentView intoView:(UIView *)containerView
{
    NSDictionary *viewsDictioanry = @{@"presented_view" : toPresentView};

    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[presented_view]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictioanry]];

    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[presented_view]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictioanry]];
}

#pragma mark - Debug

- (void)startDebugMode
{
    _presentationView.backgroundColor = [UIColor yellowColor];
}

@end

