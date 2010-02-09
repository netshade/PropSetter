//
//  GrammarTest.m
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
#import "PropSetter.h"

@interface GrammarTest : GTMTestCase {
	id mock; // Mock object used in tests	
	UILabel * l;
	NSArray * a;
	NSString * s;
	NSNumber * n;
}
@end

@implementation GrammarTest

#if TARGET_IPHONE_SIMULATOR     // Only run when the target is simulator

- (void) setUp {
	mock = [OCMockObject mockForClass:[NSString class]];  // create your mock objects here
	l = [[UILabel alloc] initWithFrame:CGRectZero];
	[l setText:@"Foo"];
	a = [[NSArray alloc] initWithObjects:@"Foo", @"Bar", nil];
	s = [[NSString alloc] initWithString:@"Foo"];
	n = [[NSNumber alloc] initWithInt:100];
}


-(void) testSuperclassComparisonWithoutClause {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UIView" matchObject:l], @"should be true when using superclass");
	STAssertFalse([[PropSetter sharedInstance] doesString:@"NSString" matchObject:l], @"should be true when using superclass");
}

-(void) testSuperclassComparison {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UIView[]" matchObject:l], @"should be true when using superclass");
}


-(void) testClassComparison {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[]" matchObject:l], @"should be true when using class");
}

-(void) testClassComparisonWithoutClause {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel" matchObject:l], @"should be true when using class");
	STAssertFalse([[PropSetter sharedInstance] doesString:@"NSString" matchObject:l], @"should be true when using class");
}

-(void) testTextComparisonEquality {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[.text = 'Foo']" matchObject:l], @"should be true when correct text");

}

-(void) testTextComparisonInequality {
	STAssertFalse([[PropSetter sharedInstance] doesString:@"UILabel[.text = 'Bar']" matchObject:l], @"should be false when not correct text");
}

-(void) testEqualityComparisonEmptyStringsSymbol {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel['' = '']" matchObject:l], @"should be true with a trivial selector");
}

-(void) testEqualityComparisonEmptyStrings {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel['' eq '']" matchObject:l], @"should be true with a trivial selector");
}





-(void) testInEqualityComparisonStringsSymbol {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel['' != 'Foo']" matchObject:l], @"should be true with a trivial selector");
}

-(void) testInEqualityComparisonStrings {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel['' ne 'Foobar']" matchObject:l], @"should be true with a trivial selector");
}


-(void) testNilComparisonSymbol {
	[l setText:nil];
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[.text = nil]" matchObject:l], @"should be true comparing to nil");
}

-(void) testNilComparison {
	[l setText:nil];
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[.text eq nil]" matchObject:l], @"should be true comparing to nil");
}

-(void) testNumericComparisonLessThanSymbol {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[1 < 3]" matchObject:l], @"should be true with a trivial numeric comparison");
}

-(void) testNumericComparisonLessThan {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[1 lt 3]" matchObject:l], @"should be true with a trivial numeric comparison");
}

-(void) testNumericComparisonLessThanEqualToSymbol {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[3 <= 3]" matchObject:l], @"should be true with a trivial numeric comparison");
}

-(void) testNumericComparisonLessThanEqualTo {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[3 lte 3]" matchObject:l], @"should be true with a trivial numeric comparison");
}

-(void) testNumericComparisonGreaterThanEqualTo {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[500 gte 3]" matchObject:l], @"should be true with a trivial numeric comparison");
}

-(void) testNumericComparisonGreaterThanEqualToSymbol {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[500 >= 3]" matchObject:l], @"should be true with a trivial numeric comparison");
}

-(void) testSelfKeyword {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSString[self = 'Foo']" matchObject:s], @"should be true with a self comparison");
}

-(void) testSelfKeywordNumericEquality {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSNumber[self = 100]" matchObject:n], @"should be true with a self comparison");
}

-(void) testSelfKeywordInequality {
	STAssertFalse([[PropSetter sharedInstance] doesString:@"NSString[self = 'Bar']" matchObject:s], @"should be false with a self comparison");
}

-(void) testSelfKeywordNumericInequality {
	STAssertFalse([[PropSetter sharedInstance] doesString:@"NSNumber[self = 101]" matchObject:n], @"should be false with a self comparison"); 
}

-(void) testContainsOperator {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[self contains 'Foo']" matchObject:a], @"should be true with an array check");	
}

-(void) testContainsOperatorSymbol { 
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[self => 'Foo']" matchObject:a], @"should be true with an array check");	
}

-(void) testBooleanOperatorsAnd {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[1=1 and 2=2]" matchObject:s], @"should be true");	
}

-(void) testBooleanOperatorsOr {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[1=2 or 2=2]" matchObject:s], @"should be true");	
}

-(void) testBooleanOperatorsAndSymbol {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[2=2 && 1=1]" matchObject:s], @"should be true");	
}

-(void) testBooleanOperatorsOrSymbol {
	STAssertTrue([[PropSetter sharedInstance] doesString:@"NSObject[1=2 || 2=2]" matchObject:s], @"should be true");	
}

-(void) testNoClassNameError {
	STAssertThrows([[PropSetter sharedInstance] doesString:@"!" matchObject:l], @"should throw an error");
}

-(void) testChainedProperty {
	// Create shared data structures here
	[l setText:@"Foo"];
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[.text = 'Foo']" matchObject:l], @"should be true");
	
}

-(void) testPropertyComparison {
	[l setText:@"Foo"];
	STAssertTrue([[PropSetter sharedInstance] doesString:@"UILabel[.text.length = .text.length]" matchObject:l], @"should be true");	
}

-(void) testPropertyExtraction {
	[l setText:@"Foo"];
	STAssertTrue([[[PropSetter sharedInstance] valueOfString:@"UILabel[.text = 'Foo'].text.length" forObject:l] intValue] == 3, @"property extraction is correct");
}

-(void) testPropertyExtractionWithoutClause {
	[l setText:@"Foo"];
	STAssertTrue([[[PropSetter sharedInstance] valueOfString:@"UILabel.text.length" forObject:l] intValue] == 3, @"property extraction is correct");
}

-(BOOL) customYesProperty:(NSString *)name lvalue:(id)l rvalue:(id)r {
	return YES;
}

-(BOOL) customNoProperty:(NSString *)name lvalue:(id)l rvalue:(id)r {
	return NO;
}

-(id) customColorFunction:(NSString *)name arguments:(NSArray *)args {
	NSAssert1([args count] == 1, @"Args for color must be 1, is %@", args);
	NSNumber * sat = [args objectAtIndex:0];
	UIColor * c = [UIColor colorWithWhite:[sat floatValue] alpha:1.0];
	return c;
}

-(void) testCustomYesProperty {
	PropSetter * ps = [[PropSetter alloc] init];
	[ps addTarget:self andSelector:@selector(customYesProperty:lvalue:rvalue:) forCustomOperator:@"yes"];
	STAssertTrue([ps doesString:@"NSObject[1 @yes 1]" matchObject:@"should evaluate yes"], @"should be true");
	[ps release];
}

-(void) testCustomNoProperty {
	PropSetter * ps = [[PropSetter alloc] init];
	[ps addTarget:self andSelector:@selector(customNoProperty:lvalue:rvalue:) forCustomOperator:@"no"];
	STAssertFalse([ps doesString:@"NSObject[1 @no 1]" matchObject:@"should evaluate yes"], @"should be true");
	[ps release];
}

-(void) testCustomFunctionParse {
	PropSetter * ps = [[PropSetter alloc] init];
	[ps addTarget:self andSelector:@selector(customColorFunction:arguments:) forCustomFunction:@"color"];
	STAssertTrue([[ps valueOfExpression:@"@color(1)"] isEqual:[UIColor colorWithWhite:1.0 alpha:1.0]], @"Must be equal colors");
}

-(void) testValueExpressionReturnsNilIfNotValidValueExpression {
	PropSetter * ps = [[PropSetter alloc] init];
	STAssertTrue([ps valueOfExpression:@"ThisShouldJustBeAString"] == nil, @"Must return nil if not a literal value");
}



- (void) tearDown {

	[s release];
	[n release];
	[l release];
	[a release];
    // Release data structures here.
}

#endif

@end
