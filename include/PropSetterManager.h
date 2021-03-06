//
//  PropSetterManager.h
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

#import <Foundation/Foundation.h>
#import "PropSetterSelector.h"

@interface PropSetterManager : NSObject {
	NSMutableDictionary * selectors;
	NSMutableArray * observed;
	NSMutableArray * keypaths;
}

+(id) manager;


-(void) addSelectorFromString:(NSString *)str withTarget:(id)target andSelector:(SEL)selector;
-(void) addSelector:(PropSetterSelector *)sel withTarget:(id)target andSelector:(SEL)selector;

-(void) addSelectorFromString:(NSString *)str withValue:(id)val;
-(void) addSelector:(PropSetterSelector *)sel withValue:(id)val;

-(void) addSelectorsFromDictionary:(NSDictionary *)d;
-(void) addSelectorsFromPlist:(NSString *)filename;

-(void) addSelectorsFromDictionary:(NSDictionary *)d parsingStringsAsValues:(BOOL)b;
-(void) addSelectorsFromPlist:(NSString *)d  parsingStringsAsValues:(BOOL)b;

-(void) reset;

-(void) beginObservingObject:(id)o;
-(void) stopObservingObject:(id)o;

-(void) applyRulesToObject:(id)o;
-(void) applyRulesToAllObjects;

@end
