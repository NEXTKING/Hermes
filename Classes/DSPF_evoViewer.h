//
//  DSPF_evoViewer.h
//  Hermes
//
//  Created by Lutz  Thalmann on 16.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Warning.h"

@interface DSPF_evoViewer : UIViewController <UIWebViewDelegate,
                                              DSPF_WarningDelegate,
                                              UIAlertViewDelegate,
                                              NSURLConnectionDelegate> {
	UIWebView       *webView;
    UIView          *waitView;
    NSURLRequest    *webRequest;
    NSMutableString *onscan;
    NSMutableString *onload;
    NSMutableArray  *toolBarScripts;
	NSString        *scannerDaten;
    NSURLConnection *serverConnection;
    NSURLResponse   *serverResponse;
    NSMutableData   *serverResponseData;
}

@property (nonatomic,retain) UIWebView       *webView;
@property (nonatomic,retain) UIView          *waitView;
@property (nonatomic,retain) NSURLRequest    *webRequest;
@property (nonatomic,retain) NSMutableString *onscan;
@property (nonatomic,retain) NSMutableString *onload;
@property (nonatomic,retain) NSMutableArray  *toolBarScripts;
@property (nonatomic,retain) NSString        *scannerDaten;

@end