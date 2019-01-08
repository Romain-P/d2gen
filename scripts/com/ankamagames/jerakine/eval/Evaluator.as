package com.ankamagames.jerakine.eval
{
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import flash.utils.getQualifiedClassName;
   
   public class Evaluator
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(Evaluator));
      
      private static const NUMBER:uint = 0;
      
      private static const STRING:uint = 1;
       
      
      public function Evaluator()
      {
         super();
      }
      
      public function eval(expr:String) : *
      {
         return this.complexEval(expr);
      }
      
      private function simpleEval(expr:String) : *
      {
         var currentChar:* = null;
         var partialOp:* = null;
         var lastOp:* = undefined;
         var k:* = 0;
         var currentOperator:String = "";
         var inQuote:* = false;
         var currentParam:String = "";
         var currentType:uint = STRING;
         var op:Array = new Array();
         for(var i:int = 0; i < expr.length; )
         {
            currentChar = expr.charAt(i);
            currentType = STRING;
            inQuote = !inQuote;
            i++;
         }
         if(currentParam.length)
         {
            if(currentType == STRING)
            {
               op.push(currentParam);
            }
            else
            {
               op.push(parseFloat(currentParam));
            }
         }
         var operatorPriority:Array = [this.divide,this.multiply,this.minus,this.plus,this.sup,this.inf,this.supOrEquals,this.infOrEquals,this.equals,this.diff,this.and,this.or,this.ternary];
         for(var j:int = 0; j < operatorPriority.length; j++)
         {
            partialOp = new Array();
            for(k = 0; k < op.length; k++)
            {
               if(op[k] is Function && op[k] == operatorPriority[j])
               {
                  lastOp = partialOp[partialOp.length - 1];
                  if(lastOp is Number || (op[k] == this.plus || op[k] == this.ternary || op[k] == this.equals || op[k] == this.diff) && lastOp is String)
                  {
                     if(op[k + 1] is Number || (op[k] == this.plus || op[k] == this.ternary || op[k] == this.equals || op[k] == this.diff) && op[k + 1] is String)
                     {
                        if(op[k] === this.ternary)
                        {
                           if(op[k + 2] == this.opElse)
                           {
                              partialOp[partialOp.length - 1] = this.ternary(lastOp,op[k + 1],op[k + 3]);
                              k = uint(k + 2);
                           }
                           else
                           {
                              _log.warn("operator \':\' not found");
                           }
                        }
                        else
                        {
                           partialOp[partialOp.length - 1] = op[k](lastOp,op[k + 1]);
                        }
                     }
                     else
                     {
                        _log.warn("Expect Number, but find [" + op[k + 1] + "]");
                     }
                     k++;
                  }
                  else
                  {
                     lastOp = op[k - 1];
                     if(lastOp is Number || (op[k] == this.plus || op[k] == this.ternary || op[k] == this.equals || op[k] == this.diff) && lastOp is String)
                     {
                        if(op[k + 1] is Number || (op[k] == this.plus || op[k] == this.ternary || op[k] == this.equals || op[k] == this.diff) && op[k + 1] is String)
                        {
                           if(op[k] === this.ternary)
                           {
                              if(op[k + 2] == this.opElse)
                              {
                                 partialOp[partialOp.length - 1] = this.ternary(lastOp,op[k + 1],op[k + 3]);
                              }
                              else
                              {
                                 _log.warn("operator \':\' not found");
                              }
                           }
                           else
                           {
                              partialOp.push(op[k](lastOp,op[k + 1]));
                           }
                        }
                        else
                        {
                           _log.warn("Expect Number,  but find [" + op[k + 1] + "]");
                        }
                        k++;
                     }
                  }
               }
               else
               {
                  partialOp.push(op[k]);
               }
            }
            op = partialOp;
         }
         return op[0];
      }
      
      private function complexEval(expr:String) : *
      {
         var start:int = 0;
         var res:* = undefined;
         var i:int = 0;
         expr = this.trim(expr);
         var modif:Boolean = true;
         var parenthCount:int = 0;
         loop0:
         while(modif)
         {
            modif = false;
            for(i = 0; i < expr.length; )
            {
               if(expr.charAt(i) == "(")
               {
                  if(!parenthCount)
                  {
                     start = i;
                  }
                  parenthCount++;
               }
               if(expr.charAt(i) == ")")
               {
                  parenthCount--;
                  if(!parenthCount)
                  {
                     res = this.complexEval(expr.substr(start + 1,i - start - 1));
                     expr = expr.substr(0,start) + (res is Number?res:"\'" + res + "\'") + expr.substr(i + 1);
                     modif = true;
                     continue loop0;
                  }
               }
               i++;
            }
         }
         if(parenthCount)
         {
            _log.warn("Missing right parenthesis in " + expr);
         }
         return this.simpleEval(expr);
      }
      
      private function plus(a:*, b:*) : *
      {
         return a + b;
      }
      
      private function minus(a:Number, b:Number) : Number
      {
         return a - b;
      }
      
      private function multiply(a:Number, b:Number) : Number
      {
         return a * b;
      }
      
      private function divide(a:Number, b:Number) : Number
      {
         return a / b;
      }
      
      private function sup(a:Number, b:Number) : Number
      {
         return a > b?1:Number(0);
      }
      
      private function supOrEquals(a:Number, b:Number) : Number
      {
         return a >= b?1:Number(0);
      }
      
      private function inf(a:Number, b:Number) : Number
      {
         return a < b?1:Number(0);
      }
      
      private function infOrEquals(a:Number, b:Number) : Number
      {
         return a <= b?1:Number(0);
      }
      
      private function and(a:Number, b:Number) : Number
      {
         return a && b?1:Number(0);
      }
      
      private function or(a:Number, b:Number) : Number
      {
         return a || b?1:Number(0);
      }
      
      private function equals(a:*, b:*) : Number
      {
         return a == b?1:Number(0);
      }
      
      private function diff(a:*, b:*) : Number
      {
         return a != b?1:Number(0);
      }
      
      private function ternary(cond:Number, a:*, b:*) : *
      {
         return !!cond?a:b;
      }
      
      private function opElse() : void
      {
      }
      
      private function showPosInExpr(pos:uint, expr:String) : String
      {
         var res:* = expr + "\n";
         for(var i:int = 0; i < pos; res = res + " ",i++)
         {
         }
         return res + "^";
      }
      
      private function trim(str:String) : String
      {
         var curChar:* = null;
         var res:String = "";
         var protect:Boolean = false;
         var inQuote:* = false;
         for(var i:int = 0; i < str.length; )
         {
            curChar = str.charAt(i);
            if(curChar == "\'" && !protect)
            {
               inQuote = !inQuote;
            }
            if(curChar == "\\")
            {
               protect = true;
            }
            else
            {
               protect = false;
            }
            if(curChar != " " || inQuote)
            {
               res = res + curChar;
            }
            i++;
         }
         return res;
      }
   }
}
