package com.ankamagames.jerakine.utils.display
{
   public class AngleToOrientation
   {
       
      
      public function AngleToOrientation()
      {
         super();
      }
      
      public static function angleToOrientation(radianAngle:Number) : uint
      {
         var orientation:int = 0;
         switch(true)
         {
            case radianAngle > -(Math.PI / 8) && radianAngle <= Math.PI / 8:
               orientation = 0;
               break;
            case radianAngle > -(Math.PI * 0.375) && radianAngle <= -(Math.PI / 8):
               orientation = 7;
               break;
            case radianAngle > -(Math.PI * 0.625) && radianAngle <= -(Math.PI * 0.375):
               orientation = 6;
               break;
            case radianAngle > -(Math.PI * 0.875) && radianAngle <= -(Math.PI * 0.625):
               orientation = 5;
               break;
            case radianAngle > Math.PI * 0.875 || radianAngle <= -(Math.PI * 0.875):
               orientation = 4;
               break;
            case radianAngle > Math.PI * 0.625 && radianAngle <= Math.PI * 0.875:
               orientation = 3;
               break;
            case radianAngle > Math.PI * 0.375 && radianAngle <= Math.PI * 0.625:
               orientation = 2;
               break;
            case radianAngle > Math.PI / 8 && radianAngle <= Math.PI * 0.375:
               orientation = 1;
         }
         return orientation;
      }
   }
}
