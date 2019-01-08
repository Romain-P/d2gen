package com.ankamagames.jerakine.utils.misc
{
   public class Levenshtein
   {
       
      
      public function Levenshtein()
      {
         super();
      }
      
      public static function distance(a:String, b:String) : Number
      {
         var i:int = 0;
         var j:int = 0;
         var cost:* = NaN;
         var d:Array = new Array();
         if(a.length == 0)
         {
            return b.length;
         }
         if(b.length == 0)
         {
            return a.length;
         }
         for(i = 0; i <= a.length; )
         {
            d[i] = new Array();
            d[i][0] = i;
            i++;
         }
         for(j = 0; j <= b.length; j++)
         {
            d[0][j] = j;
         }
         for(i = 1; i <= a.length; i++)
         {
            for(j = 1; j <= b.length; j++)
            {
               if(a.charAt(i - 1) == b.charAt(j - 1))
               {
                  cost = 0;
               }
               else
               {
                  cost = 1;
               }
               d[i][j] = Math.min(d[i - 1][j] + 1,d[i][j - 1] + 1,d[i - 1][j - 1] + cost);
            }
         }
         return d[a.length][b.length];
      }
      
      public static function suggest(word:String, aPossibility:Array, max:uint = 5) : String
      {
         var res:* = null;
         var value:* = 0;
         var min:* = 100000;
         for(var i:int = 0; i < aPossibility.length; )
         {
            value = uint(distance(word,aPossibility[i]));
            if(min > value && value <= max)
            {
               min = uint(value);
               res = aPossibility[i];
            }
            i++;
         }
         return res;
      }
   }
}
