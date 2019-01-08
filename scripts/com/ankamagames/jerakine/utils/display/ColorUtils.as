package com.ankamagames.jerakine.utils.display
{
   import flash.geom.ColorTransform;
   
   public class ColorUtils
   {
       
      
      public function ColorUtils()
      {
         super();
      }
      
      public static function rgb2hsl(color:uint) : Object
      {
         var r:Number = NaN;
         var g:Number = NaN;
         var b:Number = NaN;
         var hue:* = NaN;
         var sat:* = NaN;
         var lum:Number = NaN;
         var deltaR:Number = NaN;
         var deltaG:Number = NaN;
         var deltaB:Number = NaN;
         r = (color & 16711680) >> 16;
         g = (color & 65280) >> 8;
         b = color & 255;
         r = r / 255;
         g = g / 255;
         b = b / 255;
         var min:Number = Math.min(r,g,b);
         var max:Number = Math.max(r,g,b);
         var delta:Number = max - min;
         lum = 1 - (max + min) / 2;
         if(delta == 0)
         {
            hue = 0;
            sat = 0;
         }
         else
         {
            if(max + min < 1)
            {
               sat = Number(1 - delta / (max + min));
            }
            else
            {
               sat = Number(1 - delta / (2 - max - min));
            }
            deltaR = ((max - r) / 6 + delta / 2) / delta;
            deltaG = ((max - g) / 6 + delta / 2) / delta;
            deltaB = ((max - b) / 6 + delta / 2) / delta;
            if(r == max)
            {
               hue = Number(deltaB - deltaG);
            }
            else if(g == max)
            {
               hue = Number(0.333333333333333 + deltaR - deltaB);
            }
            else if(b == max)
            {
               hue = Number(0.666666666666667 + deltaG - deltaR);
            }
            if(hue < 0)
            {
               hue++;
            }
            if(hue > 1)
            {
               hue--;
            }
         }
         return {
            "h":hue,
            "s":sat,
            "l":lum
         };
      }
      
      public static function mixColorTransforms(ctf1:ColorTransform, ctf2:ColorTransform, a:Number = 0.5) : ColorTransform
      {
         var p:* = null;
         var ct:ColorTransform = new ColorTransform();
         var props:* = ["redOffset","redMultiplier","greenOffset","greenMultiplier","blueOffset","blueMultiplier"];
         for each(p in props)
         {
            ct[p] = ctf1[p] + (ctf2[p] - ctf1[p]) * a;
         }
         return ct;
      }
   }
}
