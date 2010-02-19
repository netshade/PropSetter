//
//  PropSetterManagerTest.m
//  PropSetter
//
// Copyright (c) 2010 StarMedia
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

//
//  Link to Google Toolbox For Mac (IPhone Unit Test): 
//					http://code.google.com/p/google-toolbox-for-mac/wiki/iPhoneUnitTesting
//  Link to OCUnit:	http://www.sente.ch/s/?p=276&lang=en
//  Link to OCMock:	http://www.mulle-kybernetik.com/software/OCMock/



#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMConstraint.h>
#import "GTMSenTestCase.h"
#import "PropSetterManager.h"
#import "PropSetter.h"

@interface PropSetterManagerTest : GTMTestCase {
	UILabel * label;
}
@end

@implementation PropSetterManagerTest

#if TARGET_IPHONE_SIMULATOR     // Only run when the target is simulator

- (void) setUp {
	label = [[UILabel alloc] initWithFrame:CGRectZero];
	PropSetterManager * mgr = [PropSetterManager manager];
	[mgr reset];
}

- (void) testBasicKVOChange {
	PropSetterManager * mgr = [PropSetterManager manager];
	UIColor * black = [UIColor blackColor];
	UIColor * red = [UIColor redColor];
	[mgr addSelectorFromString:@"NSObject[.text = 'Foo'].backgroundColor" withValue:black];
	[mgr addSelectorFromString:@"NSObject[.text = 'Bar'].backgroundColor" withValue:red];
	[mgr beginObservingObject:label];
	[label setText:@"Foo"];
	STAssertTrue([[label backgroundColor] isEqual:black], @"should be black");
	[label setText:@"Bar"];
	STAssertTrue([[label backgroundColor]isEqual:red], @"should be red");
	[mgr stopObservingObject:label];
}

-(id) changeColorOfObject:(id)o {
	NSString * msg = [NSString stringWithFormat:@"%@Color", [o text]];
	SEL sel = NSSelectorFromString(msg);
	UIColor * c = [[UIColor class] performSelector:sel];
	return c;
}

-(void) testCallbackKVOChange {
	PropSetterManager * mgr = [PropSetterManager manager];
	[mgr addSelectorFromString:@"NSObject[.text.length].backgroundColor" withTarget:self andSelector:@selector(changeColorOfObject:)];
	[mgr beginObservingObject:label];
	[label setText:@"purple"];
	STAssertTrue([[label backgroundColor] isEqual:[UIColor purpleColor]], @"should be purple");
	[label setText:@"red"];
	STAssertTrue([[label backgroundColor]isEqual:[UIColor redColor]], @"should be red");
	[mgr stopObservingObject:label];
}

-(void) testLoadingRulesViaDictionary {
	NSDictionary * example = [[NSDictionary alloc] initWithObjectsAndKeys:@"Foo", @"NSObject[.text = 'GoFoo'].text",
							  @"Bar", @"NSObject[.text = 'GoBar'].text",
							  nil];
	PropSetterManager * mgr = [PropSetterManager manager];
	[mgr addSelectorsFromDictionary:example];
	[mgr beginObservingObject:label];
	[label setText:@"GoBar"];
	STAssertTrue([[label text] isEqualToString:@"Bar"], @"should be bar");
	[label setText:@"GoFoo"];
	STAssertTrue([[label text] isEqualToString:@"Foo"], @"should be foo");
	[mgr stopObservingObject:label];
}

-(id) customSelfPassedFunction:(NSString *)name arguments:(NSArray *)args {
	NSAssert([[args objectAtIndex:0] isKindOfClass:[UILabel class]] && [args count] == 1,@"Object must be a UILabel");
	UILabel * l = [args objectAtIndex:0];
	NSString * s = [NSString stringWithFormat:@"%@Bar", [l text]];
	return s;
}


-(void) testCustomFunctionsHavingValueOfPropertyPassedAsArgument {
	[label setText:@"Foo"];
	PropSetterManager * mgr = [PropSetterManager manager];
	NSDictionary * rule = [[NSDictionary alloc] initWithObjectsAndKeys:@"@alterself(self)", @"NSObject[.text = 'Foo'].text",
						   @"@alterself(self)", @"NSObject[.text = 'Bar'].text",
						   nil];
	[mgr addSelectorsFromDictionary:rule parsingStringsAsValues:YES];
	[[PropSetter sharedInstance] addTarget:self andSelector:@selector(customSelfPassedFunction:arguments:) forCustomFunction:@"alterself"];
	[mgr beginObservingObject:label];

	STAssertTrue([[label text] isEqualToString:@"FooBar"], @"Must create value based on existing value");
	[label setText:@"Bar"];
	STAssertTrue([[label text] isEqualToString:@"BarBar"], @"Must create value based on existing value");
}



- (void) tearDown {
	[label release];
}

#endif

@end
