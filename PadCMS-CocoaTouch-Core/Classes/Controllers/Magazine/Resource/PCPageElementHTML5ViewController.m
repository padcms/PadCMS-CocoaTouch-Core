//
//  PCPageElementHTML5ViewController.m
//  Pad CMS
//
//  Created by admin on 14.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementHTML5ViewController.h"
#import "PCPageElementHtml5.h"
#import "RssParser.h"
#import "RssChannel.h"
#import "RssDate.h"
#import "RssItem.h"
#import "JSON.h"
#import "PCTwitterImageDownloadOperation.h"


#define FACEBOOK_PAGE @"<html><head><title>Facebook Like</title></head><body><iframe src=\"//www.facebook.com/plugins/likebox.php?href=%@&amp;width=638&amp;height=916&amp;colorscheme=light&amp;show_faces=true&amp;border_color&amp;stream=true&amp;header=true\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; width:638px; height:916px;\" allowTransparency=\"true\"></iframe></body></html>"

@implementation PCPageElementHTML5ViewController

@synthesize html5Element, homeDirectory;

#pragma mark - View lifecycle

- (id)initWithElement:(PCPageElementHtml5*)element withHomeDirectory:(NSString*)directory
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.html5Element = element;
        self.homeDirectory = directory;
        _webView = nil;
        self.resource = @"";
    }
    return self;
}

- (UIImage*)twitterUserProgileImage:(NSDictionary*)userDict
{
    NSString* userId = [userDict objectForKey:@"id_str"];
    NSString* fileName =[homeDirectory stringByAppendingPathComponent:[[[html5Element twitterJSONFilePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[userId stringByAppendingString:@".png"]]];
    NSLog(@"fileName = %@", fileName);
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        return [UIImage imageWithContentsOfFile:fileName];
    } else {
  /*      PCTwitterImageDownloadOperation* operation = [self.managzineQuery operationForTwitterDict:userDict andKey:@"profile_image_url"];
        if (!operation) {
            operation = [[PCTwitterImageDownloadOperation alloc] initWithTwitterUserDict:userDict forKey:@"profile_image_url"];
            operation.operationTarget = self;
            operation.imageFilePath = fileName;
            [operation setQueuePriority:NSOperationQueuePriorityVeryLow];
            [self.managzineQuery addOperation:operation finishedAction:@selector(endDownloadingPCTwitterImageDownloadOperation:)];
        }*/
    }
    return nil;
}

- (UIView*)headerForTwitterTimeLine:(NSDictionary*)user
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 638.0, 150)];
	UIImageView* imView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
    imView.image = [self twitterUserProgileImage:user];
    [headerView addSubview:imView]; 
    [imView release];
    
    UILabel* screenName = [[UILabel alloc] initWithFrame:CGRectMake(125, 10, 638.0-125.0, 27)];
    screenName.tag = 11;
    screenName.text = [user objectForKey:@"screen_name"];
    screenName.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    [headerView addSubview:screenName];
    [screenName release];
    
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(125, 40, 638.0-125.0, 20)];
    name.tag = 12;
    name.text = [NSString stringWithFormat:@"@%@", [user objectForKey:@"screen_name"]];
    [headerView addSubview:name];
    [name release];
    
    UILabel* location = [[UILabel alloc] initWithFrame:CGRectMake(125, 60, 638.0-125.0, 15)];
    location.tag = 13;
    location.font = [UIFont systemFontOfSize:14];
    location.text = [user objectForKey:@"location"];
    [headerView addSubview:location];
    [location release];
    
    UILabel* desc = [[UILabel alloc] initWithFrame:CGRectMake(125, 75, 638.0-125.0, 20)];
    desc.tag = 14;
    desc.textAlignment = UITextAlignmentLeft;
    desc.font = [UIFont fontWithName:@"Helvetica-Oblique" size:16];
    desc.textColor = [UIColor grayColor];
    desc.backgroundColor = [UIColor clearColor];
    desc.text = [user objectForKey:@"description"];
    desc.lineBreakMode = UILineBreakModeWordWrap;
    CGSize s = [desc.text sizeWithFont:desc.font constrainedToSize:CGSizeMake(638.0-125.0, CGFLOAT_MAX)];
    CGRect r;
    r.size = s;
    r.origin = desc.frame.origin;
    [desc setFrame:r];
    [headerView addSubview:desc];
    [desc release];
    
    UILabel* url = [[UILabel alloc] initWithFrame:CGRectMake(125, r.origin.y+r.size.height+3, 638.0-125.0, 15)];
    url.tag = 14;
    url.font = [UIFont systemFontOfSize:14];
    url.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.7 alpha:1.0];
    url.text = [user objectForKey:@"url"];
    [headerView addSubview:url];
    [url release];
	
    return headerView;
}

- (void)setBackgroundImage:(NSString*)imagePath
{
    if (!_backgroundImageView) {        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_backgroundImageView];
        [self.view sendSubviewToBack:_backgroundImageView];
    }
    _backgroundImageView.image = [UIImage imageWithContentsOfFile:imagePath];
}

- (void)loadFullViewForTwitterLine {
    
    if (!_tableView) {
        CGRect tableFrame = self.view.frame;
        tableFrame.origin.x = 53.0;
        tableFrame.origin.y = 72.0;
        tableFrame.size.width = 638.0;
        tableFrame.size.height = 916.0;
        _tableView = [[UITableView alloc] initWithFrame:tableFrame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];   
        [self.view bringSubviewToFront:_tableView];
        
    }
    
    NSString*twitterJSONFilePath =  [homeDirectory stringByAppendingPathComponent:[html5Element twitterJSONFilePath]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:twitterJSONFilePath]) {
        NSString* stringFromFile = [NSString stringWithContentsOfFile:twitterJSONFilePath 
                                                             encoding:NSUTF8StringEncoding 
                                                                error:nil];
        _twitterJsonArray = [[NSMutableArray alloc] initWithArray:[stringFromFile JSONValue]];
        if ([_twitterJsonArray count]) {
            NSDictionary* firstElement = [_twitterJsonArray objectAtIndex:0];
            NSDictionary* user = [firstElement objectForKey:@"user"];
            NSString* backgroundUrl = [user objectForKey:@"profile_background_image_url"];
            NSString* backGroundFile = [[twitterJSONFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[@"backgound" stringByAppendingPathExtension:[backgroundUrl pathExtension]]];      
            if (![[NSFileManager defaultManager] fileExistsAtPath:backGroundFile]) {
                
          /*      PCTwitterImageDownloadOperation* operation  = [self.managzineQuery 
                                                               operationForTwitterDict:user                                                                                                    
                                                               andKey:@"profile_background_image_url"];
                if (!operation) {
                    operation = [[PCTwitterImageDownloadOperation alloc] initWithTwitterUserDict:user forKey:@"profile_background_image_url"];
                    operation.operationTarget = self;
                    operation.imageFilePath = backGroundFile;                    
                    [self.managzineQuery addOperation:operation finishedAction:@selector(endDownloadingPCTwitterImageDownloadOperation:)];
                }*/
                
            } else {
                [self setBackgroundImage:backGroundFile];
            }
            _tableView.tableHeaderView = [self headerForTwitterTimeLine:user];
        }        
    }    
}

- (UIView*)headerForRssChannel
{
    return nil;
}

- (void)loadFullViewForRssNewsline {

    if (!_tableView) {
        CGRect tableFrame = self.view.frame;
        tableFrame.origin.x = 53.0;
        tableFrame.origin.y = 72.0;
        tableFrame.size.width = 638.0;
        tableFrame.size.height = 916.0;
        _tableView = [[UITableView alloc] initWithFrame:tableFrame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];  
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
    }
    NSString* rssXmlFile = [homeDirectory stringByAppendingPathComponent:[html5Element rssNewsXmlFilePath]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:rssXmlFile]) {
        RssParser* parser = [RssParser parseRssData:[NSData dataWithContentsOfFile:rssXmlFile] 
                                           toTarget:self];
        [parser parse];
    }
    if (!_rssChannel) {
        ;
    } else {
        _tableView.tableHeaderView = [self headerForRssChannel];
    }
}

- (void)parser:(RssParser*)parser endParseRssChanel:(RssChannel*)channel
{
    _rssChannel = channel;
    _tableView.tableHeaderView = [self headerForRssChannel];
    [_tableView reloadData];
}
- (void)parser:(RssParser *)parser endParseWithError:(NSError*)error
{
    _rssChannel = nil;
}

- (void)loadFullViewForFaceBookLike {
    if (!_webView) {
        CGRect webFrame = self.view.frame;
        webFrame.origin.x = 53.0;//0.07*tableFrame.size.width;
		webFrame.origin.y = 72.0;//0.1*tableFrame.size.height;
		webFrame.size.width = 638.0;//0.7;
		webFrame.size.height = 916.0;//0.7;
        _webView = [[UIWebView alloc] initWithFrame:webFrame];
        [self.view addSubview:_webView];        
        NSString* urlStr = [NSString stringWithFormat:FACEBOOK_PAGE, html5Element.facebookNamePage];        
        [_webView loadHTMLString:urlStr baseURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
    }
}

- (void)loadFullViewForGoogleMaps {
    if (!_webView) {
        CGRect webFrame = self.view.frame;
        webFrame.origin.x = 53.0;//0.07*tableFrame.size.width;
		webFrame.origin.y = 72.0;//0.1*tableFrame.size.height;
		webFrame.size.width = 638.0;//0.7;
		webFrame.size.height = 916.0;//0.7;
        _webView = [[UIWebView alloc] initWithFrame:webFrame];
        [self.view addSubview:_webView];        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:html5Element.googleLinkToMap]]];
    }
}

- (NSString*)getHtml5IndexFile:(NSString*)rootCatalog
{
     NSArray* contentOFUnpackedZip = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootCatalog error:nil];
    BOOL isDir = NO;
    if (contentOFUnpackedZip&&[contentOFUnpackedZip count]) {
        NSMutableArray* contentOfUnpackedZip2 = [NSMutableArray arrayWithArray:contentOFUnpackedZip];
        for (NSString* path in contentOFUnpackedZip) {
            if ([[path lastPathComponent] isEqualToString:@".DS_Store"]||[[path lastPathComponent] isEqualToString:@"__MACOSX"]) {
                [contentOfUnpackedZip2 removeObject:path];
            }
            
        }
        if ([contentOfUnpackedZip2 count]==1) {            
            [[NSFileManager defaultManager] fileExistsAtPath:[rootCatalog stringByAppendingPathComponent:[contentOfUnpackedZip2 objectAtIndex:0]] isDirectory:&isDir];
            NSLog(@"[contentOfUnpackedZip2 objectAtIndex:0] = %@", [contentOfUnpackedZip2 objectAtIndex:0]);
            if (isDir) {
                rootCatalog = [rootCatalog stringByAppendingPathComponent:[contentOfUnpackedZip2 objectAtIndex:0]];
                contentOFUnpackedZip = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootCatalog error:nil]; 
                NSLog(@"%@::%@", rootCatalog, contentOFUnpackedZip);
            }            
        }
        for(int i = 0; i < [contentOFUnpackedZip count]; i++)
        {
            NSString* file = [contentOFUnpackedZip objectAtIndex:i];
            NSString* fileExt = [[file lastPathComponent] pathExtension];
            NSLog(@"fileExt = %@", fileExt);
            if ([fileExt isEqualToString:@"html"]||[fileExt isEqualToString:@"htm"]) {
                return [rootCatalog stringByAppendingPathComponent:file];
            }            
        }        
    }
    return nil;
}

- (void)loadFullViewForHtml5Code {
    NSLog(@"html5Element = %@", [html5Element description]);
    if (!_webView) {
        NSString* html5Index = [self getHtml5IndexFile:
                                [[self.homeDirectory stringByAppendingPathComponent:html5Element.resource] stringByDeletingPathExtension]];
        if (html5Index) {
            CGRect webFrame = self.view.frame;
            webFrame.origin.x = 53.0;//0.07*tableFrame.size.width;
            webFrame.origin.y = 72.0;//0.1*tableFrame.size.height;
            webFrame.size.width = 638.0;//0.7;
            webFrame.size.height = 916.0;//0.7;
            _webView = [[UIWebView alloc] initWithFrame:webFrame];
            [self.view addSubview:_webView];        
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:html5Index]]];
            if ([_webView respondsToSelector:@selector(getScrollView)]) {
                _webView.scrollView.scrollEnabled = NO;
            }            
            [_webView setScalesPageToFit:YES];
        }
        
    }
}

- (void) loadFullView
{
    NSLog(@"html5Element = %@", [html5Element description]);
    if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyCodeType]) {
        [self loadFullViewForHtml5Code];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyFacebookLikeType]) {
        [self loadFullViewForFaceBookLike];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyGoogleMapsType]) {
        [self loadFullViewForGoogleMaps];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]) {
        [self loadFullViewForRssNewsline];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyTwitterType]) {
        [self loadFullViewForTwitterLine];
    }
    [super loadFullView];
}

- (void) loadFullViewImmediate
{
    if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyCodeType]) {
        [self loadFullViewForHtml5Code];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyFacebookLikeType]) {
        [self loadFullViewForFaceBookLike];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyGoogleMapsType]) {
        [self loadFullViewForGoogleMaps];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]) {
        [self loadFullViewForRssNewsline];
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyTwitterType]) {
        [self loadFullViewForTwitterLine];
    }
    [super loadFullViewImmediate];
}

- (void) unloadView
{
    if (_webView) {
        [_webView removeFromSuperview],[_webView release], _webView = nil;
    }
    if (_tableView) {
        [_tableView removeFromSuperview],[_tableView release], _tableView = nil;
    }
    //[super unloadView];

}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadFullView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  
    // Return the number of rows in the section.
    if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyTwitterType]) {
        if (_twitterJsonArray) {
            return [_twitterJsonArray count];
        }           
    } else if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]) {
        if (_rssChannel&&_rssChannel.items&&[_rssChannel.items count]) {
            return [_rssChannel.items count]*2;
        }  
    }	    
    return 0;
}



- (void)configureCell:(UITableViewCell*)cell forTwitterLineAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *aTweet = [_twitterJsonArray objectAtIndex:[indexPath row]];  
    cell.textLabel.text = [aTweet objectForKey:@"text"];  
    cell.textLabel.adjustsFontSizeToFitWidth = YES;  
    cell.textLabel.font = [UIFont systemFontOfSize:12];  
    cell.textLabel.numberOfLines = 4;  
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap; 
	
	NSDictionary* user = [aTweet objectForKey:@"user"];
	NSDictionary* retweet = [aTweet objectForKey:@"retweeted_status"];
	if (retweet) {
		user = [retweet objectForKey:@"user"];
		cell.textLabel.text = [retweet objectForKey:@"text"];
	}  	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", [user objectForKey:@"screen_name"]];

	cell.imageView.image = [self twitterUserProgileImage:user]; 
    if (cell.imageView.image&&(cell.imageView.image.size.width>48.0||cell.imageView.image.size.height>48.0)) {
        UIGraphicsBeginImageContext(CGSizeMake(48.0, 48.0));
        [cell.imageView.image drawInRect:CGRectMake(0, 0, 48.0, 48.0)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.imageView.image = scaledImage;
    }
    CGRect r = cell.imageView.frame;
    r.size = CGSizeMake(48, 48);
    [cell.imageView setFrame:r];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureCell:(UITableViewCell*)cell forRssItemHeaderAtIndexPath:(NSIndexPath*)indexPath
{
    RssItem* item = [_rssChannel.items objectAtIndex:floor(indexPath.row/2)];
    if (item.title) {
        NSLog(@"item.title = %@", item.title);
        NSLog(@"item.title = %@", item.title.text);
        cell.textLabel.text = item.title.text;
    }
    
    if (item.author) {
        cell.detailTextLabel.text = [@"@" stringByAppendingString:item.author.text];
    }    
}

- (void)configureCell:(UITableViewCell*)cell forRssItemDescriptionrAtIndexPath:(NSIndexPath*)indexPath
{
    RssItem* item = [_rssChannel.items objectAtIndex:floor(indexPath.row/2)];
    if (item.elementDescription) {
        cell.textLabel.text = item.elementDescription.text;
    }    
    if (item.pubDate) {
        cell.detailTextLabel.text = item.pubDate.text;
    }    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyTwitterType]) {
        static NSString* twitterCellIdetifier = @"TwitterCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:twitterCellIdetifier];  
        if (cell == nil) {  
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:twitterCellIdetifier] autorelease]; 
        }        
        [self configureCell:cell forTwitterLineAtIndexPath:indexPath];        
        return cell;        
    }
    
    if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]) {
        if (indexPath.row % 2 == 0) {
            static NSString *CellIdentifier = @"RssTitleCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
            if (cell == nil) {  
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

            } 	
            // Configure the cell... 
            [self configureCell:cell forRssItemHeaderAtIndexPath:indexPath];
            return cell;
        } else {
            static NSString *CellIdentifier = @"RssDescriptionCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
            if (cell == nil) {  
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            } 	
            // Configure the cell...  
            [self configureCell:cell forRssItemDescriptionrAtIndexPath:indexPath];
            return cell;
        }
    }

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    if (cell == nil) {  
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease]; 
    } 	
    // Configure the cell...  
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
    if ([html5Element.html5Body isEqualToString:PCPageElementHtml5BodyRSSFeedType]&&_rssChannel) {
        RssItem* item  = [_rssChannel.items objectAtIndex:floor(indexPath.row/2)]; 
        if (item.link) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.link.text]];
        }        
    }
    
}

- (void)endDownloadingPCTwitterImageDownloadOperation:(PCTwitterImageDownloadOperation*)operation
{
    
}

@end
