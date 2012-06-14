//
//  PCPageElementProgressDownloadingViewController.m
//  Pad CMS
//
//  Created by admin on 08.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementProgressDownloadingViewController.h"
#import "PCElementDownloadOperation.h"

@interface PCPageElementProgressDownloadingViewController()
@property (nonatomic, retain) PCElementDownloadOperation* downloadOperation;

@end

@implementation PCPageElementProgressDownloadingViewController
@synthesize downloadOperation;


- (id)init
{
    self = [super init];
    if (self)
    {
        progressView = nil;
        progressLabel = nil;
        progress = 0.0f;
        loaded = NO;
    }
    return self;
}

- (id)initWithOperation:(PCElementDownloadOperation*)operation
{
    self = [self init];
    if (self)
    {
        self.downloadOperation = operation;
        [self showProgress:YES];
        
    }
    return self;
}

- (void)showProgress:(BOOL)isShow
{
    if (downloadOperation) {
        [downloadOperation setPogresShow:isShow toThread:[NSThread currentThread] andTarget:self];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.view.backgroundColor = [UIColor clearColor];
    CGRect correctFrame = CGRectMake(0, 0, 200.0f, 75.0f);
    CGRect superViewFrame = self.view.superview.frame;
    correctFrame.size.width = superViewFrame.size.width * 0.7f;
    correctFrame.origin.x = (superViewFrame.size.width - correctFrame.size.width)/2.0f;
    correctFrame.origin.y = (superViewFrame.size.height - correctFrame.size.height)/2.0f;
    [self.view setFrame:correctFrame];
}

-(void)progressOfDownloading:(CGFloat)_progress forHelpPageKey:(NSString*)key
{
    progress = _progress;
    if (progress>=100.0f) 
    {
        [self unloadView];
        //[self.view removeFromSuperview];
        self.downloadOperation = nil;
        return;
    }
    if (progressView) 
    {
        [progressView setProgress:_progress];
    }
    if (progressLabel) 
    {
        progressLabel.text = [NSString stringWithFormat:@"%3.1f %%", progress*100.0f];
    }
}

-(void)progressOfDownloading:(CGFloat)_progress forElement:(PCPageElement*)element
{
    if (element&&_progress) {
        progress = _progress;
        if (progress>=100.0f) {
            [self unloadView];
            //[self.view removeFromSuperview];
            self.downloadOperation = nil;
            return;
        }
        if (progressView) {
            [progressView setProgress:_progress];
        }
        if (progressLabel) {
            progressLabel.text = [NSString stringWithFormat:@"%3.1f %%", progress*100.0f];
        }
    }
}

- (void) loadFullViewInRect:(CGRect)rect
{
    if (loaded) {
        return;
    }
    if (downloadOperation) {
        [downloadOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        CGRect correctFrame = CGRectMake(0, 0, 200.0f, 75.0f);
        CGRect superViewFrame = rect;
        correctFrame.size.width = superViewFrame.size.width * 0.7f;
        correctFrame.origin.x = (superViewFrame.size.width - correctFrame.size.width)/2.0f;
        correctFrame.origin.y = (superViewFrame.size.height - correctFrame.size.height)/2.0f;
        [self.view setFrame:correctFrame];

        if(progressView == nil)
        {
            CGRect progressRect = CGRectMake(0, 0, self.view.frame.size.width, 9.0f);
            progressView = [[UIProgressView alloc] initWithFrame:progressRect];        
            [self.view addSubview:progressView];
        }   else {
            CGRect progressRect = CGRectMake(0, 0, self.view.frame.size.width, 9.0f);
            [progressView setFrame:progressRect];
        }
        
        
        if(progressLabel == nil)
        {
            CGRect labelRect = CGRectMake(0, 30, self.view.frame.size.width, 30.0f);
            progressLabel = [[UILabel alloc] initWithFrame:labelRect];
            progressLabel.backgroundColor = [UIColor clearColor];
            progressLabel.textAlignment = UITextAlignmentCenter;
            [self.view addSubview:progressLabel];
        } else {
            CGRect labelRect = CGRectMake(0, 30, self.view.frame.size.width, 30.0f);
            [progressLabel setFrame:labelRect];
        }
        
        if (progress) {
            [progressView setProgress:progress];
            progressLabel.text = [NSString stringWithFormat:@"%.0f \%", progress];
        }
        loaded = YES;
    }    
}

- (void) unloadView
{
    if (!loaded) {
        return;
    }
    if(progressView)
    {
        [progressView removeFromSuperview];
        [progressView release];
        progressView = nil;//, ;        
        //TODO mb remove all operations
    }
    if(progressLabel)
    {
        [progressLabel removeFromSuperview],  [progressLabel release], progressLabel = nil;//,;   ,     
        //TODO mb remove all operations
    }
    if (downloadOperation&&!downloadOperation.isFinished) {
        [downloadOperation setQueuePriority:NSOperationQueuePriorityVeryLow];
    }
    loaded = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    if (progressLabel) {
        [progressLabel release];
    }
    if (progressView) {
        [progressView release];
    }
    [downloadOperation release], downloadOperation = nil;
    [super dealloc];
}

@end
