//
//  PropSetterExpression.h
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
#import "PropSetterObjectWithValue.h"
#import "PropSetterTypes.h"
#import "PropSetterOperator.h"

@interface PropSetterExpression : NSObject
{
	id<PropSetterObjectWithValue> lvalue;
	PropSetterOperator * op;
	id<PropSetterObjectWithValue>  rvalue;
	PropSetterBooleanOperator next;
	int level;
	BOOL empty;
}

@property(readwrite, retain) id<PropSetterObjectWithValue> lvalue;
@property(readwrite, retain) PropSetterOperator * op;
@property(readwrite, retain) id<PropSetterObjectWithValue> rvalue;
@property(readwrite, assign) PropSetterBooleanOperator next;
@property(readwrite, assign) int level;
@property(readonly, assign) BOOL empty;

-(BOOL) evaluateWithObject:(id)object andOperatorDelegate:(id<PropSetterOperatorCustomDelegate>)del;
-(NSArray *) affectedKeyPaths;

@end