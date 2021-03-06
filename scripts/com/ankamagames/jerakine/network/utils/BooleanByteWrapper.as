package com.ankamagames.jerakine.network.utils
{
   public class BooleanByteWrapper
   {
       
      
      public function BooleanByteWrapper()
      {
         super();
      }
      
      public static function setFlag(a:uint, pos:uint, b:Boolean) : uint
      {
         switch(pos)
         {
            case 0:
               if(b)
               {
                  a = a | 1;
                  break;
               }
               a = a & 254;
               break;
            case 1:
               if(b)
               {
                  a = a | 2;
                  break;
               }
               a = a & 253;
               break;
            case 2:
               if(b)
               {
                  a = a | 4;
                  break;
               }
               a = a & 251;
               break;
            case 3:
               if(b)
               {
                  a = a | 8;
                  break;
               }
               a = a & 247;
               break;
            case 4:
               if(b)
               {
                  a = a | 16;
                  break;
               }
               a = a & 239;
               break;
            case 5:
               if(b)
               {
                  a = a | 32;
                  break;
               }
               a = a & 223;
               break;
            case 6:
               if(b)
               {
                  a = a | 64;
                  break;
               }
               a = a & 191;
               break;
            case 7:
               if(b)
               {
                  a = a | 128;
                  break;
               }
               a = a & 127;
               break;
            default:
               throw new Error("Bytebox overflow.");
         }
         return a;
      }
      
      public static function getFlag(a:uint, pos:uint) : Boolean
      {
         switch(pos)
         {
            case 0:
               return (a & 1) != 0;
            case 1:
               return (a & 2) != 0;
            case 2:
               return (a & 4) != 0;
            case 3:
               return (a & 8) != 0;
            case 4:
               return (a & 16) != 0;
            case 5:
               return (a & 32) != 0;
            case 6:
               return (a & 64) != 0;
            case 7:
               return (a & 128) != 0;
            default:
               throw new Error("Bytebox overflow.");
         }
      }
   }
}
