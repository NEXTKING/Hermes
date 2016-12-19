//
//  DSPF_evoViewer.m
//  Hermes
//
//  Created by Lutz  Thalmann on 16.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVR_NetworkMonitor.h"
#import "DSPF_evoViewer.h"

// auslagern

@implementation DSPF_evoViewer

@synthesize webView;
@synthesize waitView;
@synthesize webRequest;
@synthesize onscan;
@synthesize onload;
@synthesize toolBarScripts;
@synthesize scannerDaten;

- (UIWebView *)webView {
	if (!webView) {
		webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	}
	return webView;
}

- (UIView *)waitView {
	if (!waitView) {
		waitView = [[UIView alloc] initWithFrame:self.webView.frame];
        waitView.backgroundColor = [UIColor clearColor];
        UIActivityIndicatorView *activityIndicator	= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = CGPointMake(waitView.center.x , waitView.center.y);
        activityIndicator.color  = [UIColor blackColor];
        [activityIndicator startAnimating];
        [waitView addSubview:[activityIndicator autorelease]];
	}
	return waitView;
}

- (NSString *)scannerDaten {
	if (!scannerDaten) {
		scannerDaten = [[NSString alloc] initWithString:@""];
	}
	return scannerDaten;
}

- (NSMutableArray *)toolBarScripts {
    if (!toolBarScripts) {
        toolBarScripts = [[NSMutableArray alloc] init];
    }
    return toolBarScripts;
}

#pragma mark *** evoViewer ***

- (void)scanDown {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
}

- (void)scanUp {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}

-(void)sndmsg:(NSString *)msg title:(NSString *)title type:(NSString *)type {
	if([type isEqualToString:@"*INFO"]) {
		[[[[UIAlertView alloc]initWithTitle:title message:msg delegate:self 
                          cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease] show];
	} else if([type isEqualToString:@"*INQ"]) {
		[[[[UIAlertView alloc]initWithTitle:title message:msg delegate:self 
                          cancelButtonTitle:NSLocalizedString(@"TITLE_002", @"NEIN") otherButtonTitles:NSLocalizedString(@"TITLE_037", @"JA"), nil] autorelease] show];
	}
}

- (void)loadView {
    serverResponse     = [[NSURLResponse alloc] init];
    serverResponseData = [[NSMutableData alloc] init];
    self.view             = self.webView;
    self.webView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Register for notification when the app shuts down
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFunc) name:UIApplicationWillTerminateNotification object:nil];    
    // On iOS 4.0+ only, listen for background notification
    // if(&UIApplicationDidEnterBackgroundNotification != nil) {
    //     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFunc) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // }
    // On iOS 4.0+ only, listen for foreground notification
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBarcode:) name:@"barcodeData" object:nil]; 
	if([self.webView request] == nil){ 
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage  sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage  sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        //  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
        
        NSString *savedPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"LogisOnline_SYSVAL_PORT"];
        NSString *portToUse = @"";
        if (savedPort && ![savedPort isEqualToString:@""] && ![savedPort isEqualToString:@"80"]) {
            portToUse = [NSString stringWithFormat:@":%@", savedPort];
        }
        NSString *serverURL = [NSString stringWithFormat:@"%@://%@%@/%@",
                     [[NSUserDefaults standardUserDefaults] stringForKey:@"LogisOnline_SYSVAL_SCHEME"],
                     [[NSUserDefaults standardUserDefaults] stringForKey:@"LogisOnline_SYSVAL_HOST"],
                     portToUse,
                     [[NSUserDefaults standardUserDefaults] stringForKey:@"LogisOnline_SYSVAL_PATH"]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?sn=%@", serverURL, PFDeviceId()]];
        self.webRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
		[self.webView loadRequest:self.webRequest];
	}
    self.navigationController.toolbarHidden = NO;
//  self.navigationController.toolbar.barStyle  = UIBarStyleDefault;
//  self.navigationController.toolbar.tintColor = [[[UIColor alloc] initWithRed:153.0 / 255 green:153.0 / 255 blue:153.0 / 255 alpha: 1.0] autorelease];
}

- (void)checkConnectionResponse:(NSTimer *)aTimer {
    if (self.waitView.window && [aTimer.userInfo valueForKey:@"webRequest_PND"] &&
        [(NSURLRequest *)[aTimer.userInfo valueForKey:@"webRequest_PND"] isEqual:self.webRequest]) {
        [serverConnection cancel];
        [serverConnection release];   serverConnection   = nil;
        [serverResponseData release]; serverResponseData = [[NSMutableData alloc] init];
        [self.waitView removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE__099", @"Verbindungsproblem")
                       messageText:@"Zeitüberschreitung\nKeine Antwort vom Server\nnach 67 Sekunden."
                              item:@"confirmToReload"
                          delegate:self];
    }
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //	UIWebViewNavigationType = enum {
	//	UIWebViewNavigationTypeLinkClicked,
	//	UIWebViewNavigationTypeFormSubmitted,
	//	UIWebViewNavigationTypeBackForward,
	//	UIWebViewNavigationTypeReload,
	//	UIWebViewNavigationTypeFormResubmitted,
	//	UIWebViewNavigationTypeOther};
	//  NSLog(@"%@, %i", [request.URL absoluteString], navigationType);
	if ([[request.URL scheme] isEqualToString:@"call"]) {
		NSArray  *parameter = [[request.URL path] componentsSeparatedByString:@"/"];
		NSString *call      = [parameter objectAtIndex:1];		
		if([call isEqualToString:@"scanDown"]) {
			[self scanDown];
		} else if ([call isEqualToString: @"scanUp"]) {
			[self scanUp];
		} else if ([call isEqualToString: @"alert_info"]) {
			[self sndmsg:[[parameter objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                   title:[parameter objectAtIndex:2] 
                    type:@"*INFO"];
		} else if ([call isEqualToString: @"alert_inq"]) {
			[self sndmsg:[[parameter objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                   title:[parameter objectAtIndex:2] 
                    type:@"*INQ"];
		}
		return NO;
	}
    NSMutableURLRequest *tmpRequest = [request mutableCopy];
    tmpRequest.cachePolicy     = NSURLRequestReloadRevalidatingCacheData;
    tmpRequest.timeoutInterval = 60;
    self.webRequest =  [tmpRequest autorelease];
    if (![SVR_NetworkMonitor reachabilityForLocalWiFi]) {
        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE__099", @"Verbindungsproblem")
                       messageText:@"Kein WLAN-Netz!"
                              item:@"confirmToReload"
                          delegate:self];
        return NO;
    }
    self.toolbarItems = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (!self.waitView.window) [self.view addSubview:self.waitView];
    if(navigationType != UIWebViewNavigationTypeOther) {
        [NSTimer scheduledTimerWithTimeInterval:67
                                         target:self
                                       selector:@selector(checkConnectionResponse:)
                                       userInfo:[NSDictionary dictionaryWithObjects:
                                                 [NSArray arrayWithObjects:self.webRequest,
                                                  nil]
                                                                            forKeys:
                                                 [NSArray arrayWithObjects:@"webRequest_PND",
                                                  nil]]
                                        repeats:NO];
        serverConnection = [[NSURLConnection alloc] initWithRequest:self.webRequest delegate:self startImmediately:NO];
        [serverConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [serverConnection start];
        return NO;
    }
	return YES;
}

- (void)buttonJavaScript:(id )sender {
    if (![SVR_NetworkMonitor reachabilityForLocalWiFi]) {
        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE__099", @"Verbindungsproblem")
                       messageText:@"Kein WLAN-Netz!"
                              item:(UIBarButtonItem *)sender
                          delegate:self];
    } else {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"function f(){%@}; f();",
                                                              [self.toolBarScripts objectAtIndex:((UIBarButtonItem *)sender).tag]]];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [self.waitView removeFromSuperview];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSMutableString *errorText = [NSMutableString stringWithString:error.localizedDescription];
    if (error.localizedFailureReason) {
        [errorText appendString:@"\n"];
        [errorText appendString:error.localizedFailureReason];
    }
    if (error.localizedRecoverySuggestion) {
        [errorText appendString:@"\n"];
        [errorText appendString:error.localizedRecoverySuggestion];
    }
    [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE__099", @"Verbindungsproblem")
                   messageText:errorText
                          item:@"confirmToReload"
                      delegate:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitUserSelect='none';"];
    //  [aWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"BODY\")[0].style.webkitTextSizeAdjust= '128%'"];
    self.onscan = nil;
    self.onload = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil]; 
    if ([[aWebView stringByEvaluatingJavaScriptFromString:@"document.title.toLowerCase();"] 
         rangeOfString:@"splash"].location != NSNotFound) { 
        self.navigationItem.hidesBackButton = NO;
    } else { 
        self.navigationItem.hidesBackButton = YES;
    }
    for (id tmpSubview in aWebView.subviews) {
        if ([[tmpSubview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)tmpSubview).bounces = NO;
        }
    }
    NSMutableArray *tmpTCbar = [NSMutableArray arrayWithArray:self.toolbarItems];
    [tmpTCbar            removeAllObjects];
    [self.toolBarScripts removeAllObjects];
    NSString *navbarString = [aWebView stringByEvaluatingJavaScriptFromString:
                              @" function f(){ var allTables = document.getElementsByTagName(\"TABLE\"); "
                              "               var lastTable = new Array(); "
                              "               var lastRow   = new Array(); "
                              "               var buttons   = new Array(); "
                              "               var navBar    = new Boolean(false); "
                              "               var navBottom = new Boolean(true);  "
                              "           if (allTables.length > 0) { "
                              "                   lastTable = allTables[(allTables.length -1)]; "
                              "               var allRows   = lastTable.getElementsByTagName(\"TR\"); "
                              "               if (allRows.length > 0) { "
                              "                   if (allRows.length > 1) { "
                              "                        navBottom    = false; "
                              "                        var navRows  = allRows; "
                              "                        if (navRows[0].getAttribute(\"width\")                   == \"40\" &   " 
                              "                            navRows[(navRows.length -1)].getAttribute(\"width\") == \"40\" ) { " 
                              "                            navBar   = true; "
                              "                            for (var i = 0; i < navRows.length; i++) { "
                              "                                if (navRows[i].getElementsByTagName(\"TD\")[0].getElementsByTagName(\"A\").length > 0) { "
                              "                                    if (navRows[i].getElementsByTagName(\"TD\")[0].getElementsByTagName(\"A\")[0].getAttribute(\"onclick\") != \"\" &   " 
                              "                                        navRows[i].getElementsByTagName(\"TD\")[0].getElementsByTagName(\"A\")[0].getAttribute(\"onclick\") != null ) { " 
                              "                                        buttons.push(navRows[i].getElementsByTagName(\"TD\")[0].getElementsByTagName(\"A\")[0].getAttribute(\"onclick\")); "
                              "                                    } "
                              "                                } "
                              "                            } "
                              "                        } "
                              "                   } else { " 
                              "                        lastRow    = allRows[(allRows.length -1)]; "
                              "                    var rowData    = lastRow.getElementsByTagName(\"TD\"); "
                              "                        if (lastRow.getAttribute(\"height\") == \"40\" ) { " 
                              "                            navBar   = true; "
                              "                            for (var i = 0; i < rowData.length; i++) { " 
                              "                                if (rowData[i].getElementsByTagName(\"A\").length > 0) { " 
                              "                                    if (rowData[i].getElementsByTagName(\"A\")[0].getAttribute(\"onclick\") != \"\" &   " 
                              "                                        rowData[i].getElementsByTagName(\"A\")[0].getAttribute(\"onclick\") != null ) { " 
                              "                                        buttons.push(rowData[i].getElementsByTagName(\"A\")[0].getAttribute(\"onclick\")); "
                              "                                    } "
                              "                                } "
                              "                            } "
                              "                        } "
                              "                   } "
                              "               } "
                              "            } " 
                              "            if (navBar) { "
                              "                if (navBottom) { "
                              "                    lastRow.innerHTML              = \"\"; "
                              "                } else { "
                              "                    lastTable.parentNode.outerHTML = \"\"; "
                              "                } "
                              "            } "
                              "            return buttons.join(\"~;~\"); "
                              "           }; "
                              " f();"];
    if (navbarString && navbarString.length > 0 && ![navbarString isEqualToString:@"~;~"]) {
        NSArray *navbar = [navbarString componentsSeparatedByString:@"~;~"]; 
        NSUInteger buttonIndex = 0; 
        UIBarButtonItem *tmpButton;
        UIImage *tmpButtonIcon;
        for (NSString *buttonScript in navbar) { 
            if ([buttonScript rangeOfString:@"ESC"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"arrowleft"   ofType:@"png"]];
            }  else if ([buttonScript rangeOfString:@"ENTER"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"next-item"   ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"EXIT"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"terminate"   ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"ABBRECHEN"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"terminate"   ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"NEIN"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"delete-item" ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"DELETE"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"delete-item" ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"JA"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"next-item"   ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"DRUCK"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"printer"     ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"LIST"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notepad"     ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"NEXT"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"next-page"   ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"CALC"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"calculator"  ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"MAIL"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mail"        ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"NEW"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"add-item"    ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"BOX"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"collection"  ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"PACKAGE"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"collection"  ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"PALOK"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"collection"  ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"MERGE"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inbox"       ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"DEFECT"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"warning"     ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"MESSEN"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ruler"       ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"BALANCE"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"scales"      ofType:@"png"]];
            } else if ([buttonScript rangeOfString:@"INFO"].location != NSNotFound) { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info"        ofType:@"png"]];
            }   else { 
                tmpButtonIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"processing"  ofType:@"png"]];
            }
            tmpButton = [[UIBarButtonItem alloc] initWithImage:tmpButtonIcon
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(buttonJavaScript:)];
            tmpButton.tag = buttonIndex;
            if (buttonIndex > 0) {
                [tmpTCbar addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]]; 
            }
            [tmpTCbar            addObject:[tmpButton autorelease]];
            [self.toolBarScripts addObject:buttonScript];
            buttonIndex ++;
        } 
    }
    NSString *metaString = [aWebView stringByEvaluatingJavaScriptFromString:
                            @" function f(){ var v     = new Array(); "
                            "               var k     = new Array(); "
                            "               var d     = new Array(); "
                            "               var j     = 0 ; "
                            "               var metas = document.getElementsByTagName(\"META\"); "
                            "               for (var i = 0; i < metas.length; i++) { " 
                            "                    if (metas[i].parentNode.nodeType          != 8    &   " 
                            "                        metas[i].getAttribute(\"HTTP-Equiv\") != \"\" &   " 
                            "                        metas[i].getAttribute(\"HTTP-Equiv\") != null &   " 
                            "                        metas[i].getAttribute(\"content\")    != \"\" &   " 
                            "                        metas[i].getAttribute(\"content\")    != null ) { " 
                            "                            k[j] = metas[i].getAttribute(\"HTTP-Equiv\").toLowerCase(); "
                            "                            v[j] = metas[i].getAttribute(\"content\"); " 
                            "                              j++  ; " 
                            "                    } "
                            "               } "
                            "               d[0] =  v.join(\"~;~\"); "
                            "               d[1] =  k.join(\"~;~\"); "
                            "               return  d.join(\"~~;~~\"); "
                            "             }; "
                            " f();"];
    if (metaString && metaString.length > 0 && ![metaString isEqualToString:@"~~;~~"]) { 
        NSArray *metaKeys   = [NSArray arrayWithArray:[[[metaString componentsSeparatedByString:@"~~;~~"] objectAtIndex:1] componentsSeparatedByString:@"~;~"]];
        NSArray *metaValues = [NSArray arrayWithArray:[[[metaString componentsSeparatedByString:@"~~;~~"] objectAtIndex:0] componentsSeparatedByString:@"~;~"]];
        NSSet   *keySet     = [NSSet setWithArray:metaKeys];
        if (keySet.count   != 0) { 
            NSMutableDictionary *metas = [[NSMutableDictionary alloc] initWithCapacity:keySet.count];
            for (NSString *tmpKey in keySet) { 
                [metas setValue:[[NSArray arrayWithArray:[metaValues objectsAtIndexes:
                                                          [metaKeys indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                    return ([obj isEqualToString:tmpKey]);}]]] 
                                 componentsJoinedByString:@";"] 
                         forKey:tmpKey];
            } 
            if (  [metas valueForKey:@"scanner"] &&
                [[[metas valueForKey:@"scanner"] componentsSeparatedByString:@";"] indexOfObject:@"on"] != NSNotFound) { 
                [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
                if ([metas valueForKey:@"onscan"]) { 
                    self.onscan = [[[metas valueForKey:@"onscan"] mutableCopy]  autorelease];
                } else {
                    self.onscan = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
                }
            }
            if ([metas valueForKey:@"onload"]) {
                self.onload = [[[metas valueForKey:@"onload"] mutableCopy]  autorelease];
            } else {
                self.onload = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
            }
            [metas release];
        }
    }
    self.toolbarItems = tmpTCbar;
    [self.waitView removeFromSuperview];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.onload) {
        [aWebView setKeyboardDisplayRequiresUserAction:NO];
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"{%@}", self.onload]];
        [aWebView setKeyboardDisplayRequiresUserAction:YES];
    }
}

/*
 - (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation { 
 return YES;
 }
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 
 CGFloat toolbarHeight  = [self.navigationController.toolbar frame].size.height; 
 CGRect  rootViewBounds = self.parentViewController.view.bounds;    
 CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);    
 CGFloat rootViewWidth  = CGRectGetWidth(rootViewBounds);    
 CGRect  rectArea       = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);    
 [self.toolBar setFrame:rectArea];
 }
 */

- (void)viewWillDisappear: (BOOL)animated{ 
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
        self.navigationController.toolbarHidden = YES;
	}
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;    
    [super viewDidUnload];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This can be called multiple times, for example in the case of a redirect,
    // so each time we reset the data.
    [serverResponseData setLength:0];
	[serverResponse release]; serverResponse = [response copy];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [serverResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.waitView removeFromSuperview];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [connection release];
    [serverResponseData release]; serverResponseData = [[NSMutableData alloc] init];
    NSMutableString *errorText = [NSMutableString stringWithString:error.localizedDescription];
    if (error.localizedFailureReason) {
        [errorText appendString:@"\n"];
        [errorText appendString:error.localizedFailureReason];
    }
    if (error.localizedRecoverySuggestion) {
        [errorText appendString:@"\n"];
        [errorText appendString:error.localizedRecoverySuggestion];
    }
    [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE__099", @"Verbindungsproblem")
                   messageText:errorText
                          item:@"confirmToReload"
                      delegate:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // "loadData:" will call "webViewDidFinishLoad:" so this will then perform the following actions
    //  -  [self.waitView removeFromSuperview];
    //  -  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [connection release];
    [self.webView loadData:serverResponseData MIMEType:[serverResponse MIMEType] textEncodingName:[serverResponse textEncodingName] baseURL:[serverResponse URL]];
    [serverResponseData release]; serverResponseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // At the moment this info will be ignored
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse {
    // Return the request unmodified to allow the redirect.
    return request;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    [serverResponseData release];
    [serverResponse     release];
	[scannerDaten       release];
    [toolBarScripts     release];
    [onload             release];
    [onscan             release];
    [webRequest         release];
    [waitView           release];
    [webView            release];
    [super dealloc];
}

- (void)didReturnBarcode:(NSNotification *)aNotification {
    if (![SVR_NetworkMonitor reachabilityForLocalWiFi]) {
        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE__099", @"Verbindungsproblem")
                       messageText:@"Kein WLAN-Netz!"
                              item:(NSNotification *)aNotification
                          delegate:self];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    [[NSUserDefaults standardUserDefaults] setValue:[[aNotification userInfo] valueForKey:@"barcodeData"] forKey:@"current_evoViewerBC"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.scannerDaten = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_evoViewerBC"]; 
    //  OPTION = meta.onscan() 
    if (self.onscan && self.onscan.length > 0) { 
        [self.onscan replaceOccurrencesOfString:@"%s" withString:self.scannerDaten options:0 range:NSMakeRange(0, self.onscan.length)];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"{%@}", self.onscan]];
        //  OPTION = form.submit()
    } else if ([[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"form\")[0].getElementsByTagName(\"input\")[0].value;"] isEqualToString:@"ENTER"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"{document.getElementsByTagName(\"form\")[0].getElementsByTagName(\"input\")[0].value = \"%@\";}", @"SCAN"]];
        [self.webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"{document.getElementsByTagName(\"form\")[0].getElementsByTagName(\"input\")[1].value = \"%@\";}", scannerDaten]];
        [self.webView stringByEvaluatingJavaScriptFromString:@"{document.getElementsByTagName(\"form\")[0].submit();}"];
        //  OPTION = POST new page
    } else {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.webView.request.URL.absoluteURL];
        [request setTimeoutInterval:60];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
        [request setValue:@"60"        forHTTPHeaderField:@"Keep-Alive"];
        [request setHTTPBody: [[NSString stringWithFormat: @"event=%@&INPUT=%@", @"SCAN", scannerDaten] dataUsingEncoding: NSUTF8StringEncoding]];
        request.cachePolicy     = NSURLRequestReloadRevalidatingCacheData;
        self.webRequest  = [request autorelease];
        [self.view addSubview:self.waitView];
        serverConnection = [[NSURLConnection alloc] initWithRequest:self.webRequest delegate:self startImmediately:NO];
        [serverConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [serverConnection start];
    }
}

// Returns the saved value from the delegate methode above
-(NSString *)getBarcodeData{
	return scannerDaten;
}

-(void)alertView:(UIAlertView *)sender clickedButtonAtIndex:(NSInteger)button {
	if(button == 0) {
		[self.webView stringByEvaluatingJavaScriptFromString:@"send_alert_no();"];
	}else{
		[self.webView stringByEvaluatingJavaScriptFromString:@"send_alert_yes();"];
	}
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger)buttonIndex
{
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
        if ([item isKindOfClass:[UIBarButtonItem class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self buttonJavaScript:item];
            });
        } else if ([item isKindOfClass:[NSNotification class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didReturnBarcode:item];
            });
        } else if (self.webRequest) {
            NSMutableURLRequest *tmpRequest = [self.webRequest mutableCopy];
            [tmpRequest setTimeoutInterval:60];
            [tmpRequest setHTTPMethod: @"POST"];
            [tmpRequest setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
            [tmpRequest setValue:@"60"        forHTTPHeaderField:@"Keep-Alive"];
            [tmpRequest setHTTPBody:[[NSString stringWithFormat: @"event=REFRESH"] dataUsingEncoding: NSUTF8StringEncoding]];
            tmpRequest.cachePolicy     = NSURLRequestReloadRevalidatingCacheData;
            self.webRequest  = [tmpRequest autorelease];
            [self.view addSubview:self.waitView];
            serverConnection = [[NSURLConnection alloc] initWithRequest:self.webRequest delegate:self startImmediately:NO];
            [serverConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [serverConnection start];
        }
    } else {
        if (self.waitView.window) [self.waitView removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.navigationItem.hidesBackButton = NO;
    }
}

@end