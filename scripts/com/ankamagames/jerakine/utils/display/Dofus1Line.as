package com.ankamagames.jerakine.utils.display
{
   import com.ankamagames.jerakine.types.Point3D;
   import flash.geom.Point;
   
   public class Dofus1Line
   {
      
      public static const useDofus2Line:Boolean = true;
       
      
      public function Dofus1Line()
      {
         super();
      }
      
      public static function getLine(x1:int, y1:int, z1:int, x2:int, y2:int, z2:int) : Array
      {
         var i:int = 0;
         var cell:* = null;
         var erreurSupArrondis:int = 0;
         var erreurInfArrondis:int = 0;
         var beforeY:Number = NaN;
         var afterY:Number = NaN;
         var diffBeforeCenterY:Number = NaN;
         var diffCenterAfterY:Number = NaN;
         var beforeX:Number = NaN;
         var afterX:Number = NaN;
         var diffBeforeCenterX:Number = NaN;
         var diffCenterAfterX:Number = NaN;
         var y:int = 0;
         var x:int = 0;
         var line:Array = new Array();
         var pFrom:Point3D = new Point3D(x1,y1,z1);
         var pTo:Point3D = new Point3D(x2,y2,z2);
         var pStart:Point3D = new Point3D(pFrom.x + 0.5,pFrom.y + 0.5,pFrom.z);
         var pEnd:Point3D = new Point3D(pTo.x + 0.5,pTo.y + 0.5,pTo.z);
         var padX:* = 0;
         var padY:* = 0;
         var padZ:* = 0;
         var steps:* = 0;
         var descending:* = pStart.z > pEnd.z;
         var xToTest:Array = new Array();
         var yToTest:Array = new Array();
         var cas:int = 0;
         if(Math.abs(pStart.x - pEnd.x) == Math.abs(pStart.y - pEnd.y))
         {
            steps = Number(Math.abs(pStart.x - pEnd.x));
            padX = Number(pEnd.x > pStart.x?1:Number(-1));
            padY = Number(pEnd.y > pStart.y?1:Number(-1));
            padZ = Number(steps == 0?0:!!descending?Number((pFrom.z - pTo.z) / steps):Number((pTo.z - pFrom.z) / steps));
            cas = 1;
         }
         else if(Math.abs(pStart.x - pEnd.x) > Math.abs(pStart.y - pEnd.y))
         {
            steps = Number(Math.abs(pStart.x - pEnd.x));
            padX = Number(pEnd.x > pStart.x?1:Number(-1));
            padY = Number(pEnd.y > pStart.y?Math.abs(pStart.y - pEnd.y) == 0?0:Number(Math.abs(pStart.y - pEnd.y) / steps):Number(-Math.abs(pStart.y - pEnd.y) / steps));
            padY = Number(padY * 100);
            padY = Number(Math.ceil(padY) / 100);
            padZ = Number(steps == 0?0:!!descending?Number((pFrom.z - pTo.z) / steps):Number((pTo.z - pFrom.z) / steps));
            cas = 2;
         }
         else
         {
            steps = Number(Math.abs(pStart.y - pEnd.y));
            padX = Number(pEnd.x > pStart.x?Math.abs(pStart.x - pEnd.x) == 0?0:Number(Math.abs(pStart.x - pEnd.x) / steps):Number(-Math.abs(pStart.x - pEnd.x) / steps));
            padX = Number(padX * 100);
            padX = Number(Math.ceil(padX) / 100);
            padY = Number(pEnd.y > pStart.y?1:Number(-1));
            padZ = Number(steps == 0?0:!!descending?Number((pFrom.z - pTo.z) / steps):Number((pTo.z - pFrom.z) / steps));
            cas = 3;
         }
         for(i = 0; i < steps; i++)
         {
            erreurSupArrondis = int(3 + steps / 2);
            erreurInfArrondis = int(97 - steps / 2);
            if(cas == 2)
            {
               beforeY = Math.ceil(pStart.y * 100 + padY * 50) / 100;
               afterY = Math.floor(pStart.y * 100 + padY * 150) / 100;
               diffBeforeCenterY = Math.floor(Math.abs(Math.floor(beforeY) * 100 - beforeY * 100)) / 100;
               diffCenterAfterY = Math.ceil(Math.abs(Math.ceil(afterY) * 100 - afterY * 100)) / 100;
               if(Math.floor(beforeY) == Math.floor(afterY))
               {
                  yToTest = [Math.floor(pStart.y + padY)];
                  if(beforeY == yToTest[0] && afterY < yToTest[0])
                  {
                     yToTest = [Math.ceil(pStart.y + padY)];
                  }
                  else if(beforeY == yToTest[0] && afterY > yToTest[0])
                  {
                     yToTest = [Math.floor(pStart.y + padY)];
                  }
                  else if(afterY == yToTest[0] && beforeY < yToTest[0])
                  {
                     yToTest = [Math.ceil(pStart.y + padY)];
                  }
                  else if(afterY == yToTest[0] && beforeY > yToTest[0])
                  {
                     yToTest = [Math.floor(pStart.y + padY)];
                  }
               }
               else if(Math.ceil(beforeY) == Math.ceil(afterY))
               {
                  yToTest = [Math.ceil(pStart.y + padY)];
                  if(beforeY == yToTest[0] && afterY < yToTest[0])
                  {
                     yToTest = [Math.floor(pStart.y + padY)];
                  }
                  else if(beforeY == yToTest[0] && afterY > yToTest[0])
                  {
                     yToTest = [Math.ceil(pStart.y + padY)];
                  }
                  else if(afterY == yToTest[0] && beforeY < yToTest[0])
                  {
                     yToTest = [Math.floor(pStart.y + padY)];
                  }
                  else if(afterY == yToTest[0] && beforeY > yToTest[0])
                  {
                     yToTest = [Math.ceil(pStart.y + padY)];
                  }
               }
               else if(int(diffBeforeCenterY * 100) <= erreurSupArrondis)
               {
                  yToTest = [Math.floor(afterY)];
               }
               else if(int(diffCenterAfterY * 100) >= erreurInfArrondis)
               {
                  yToTest = [Math.floor(beforeY)];
               }
               else
               {
                  yToTest = [Math.floor(beforeY),Math.floor(afterY)];
               }
            }
            else if(cas == 3)
            {
               beforeX = Math.ceil(pStart.x * 100 + padX * 50) / 100;
               afterX = Math.floor(pStart.x * 100 + padX * 150) / 100;
               diffBeforeCenterX = Math.floor(Math.abs(Math.floor(beforeX) * 100 - beforeX * 100)) / 100;
               diffCenterAfterX = Math.ceil(Math.abs(Math.ceil(afterX) * 100 - afterX * 100)) / 100;
               if(Math.floor(beforeX) == Math.floor(afterX))
               {
                  xToTest = [Math.floor(pStart.x + padX)];
                  if(beforeX == xToTest[0] && afterX < xToTest[0])
                  {
                     xToTest = [Math.ceil(pStart.x + padX)];
                  }
                  else if(beforeX == xToTest[0] && afterX > xToTest[0])
                  {
                     xToTest = [Math.floor(pStart.x + padX)];
                  }
                  else if(afterX == xToTest[0] && beforeX < xToTest[0])
                  {
                     xToTest = [Math.ceil(pStart.x + padX)];
                  }
                  else if(afterX == xToTest[0] && beforeX > xToTest[0])
                  {
                     xToTest = [Math.floor(pStart.x + padX)];
                  }
               }
               else if(Math.ceil(beforeX) == Math.ceil(afterX))
               {
                  xToTest = [Math.ceil(pStart.x + padX)];
                  if(beforeX == xToTest[0] && afterX < xToTest[0])
                  {
                     xToTest = [Math.floor(pStart.x + padX)];
                  }
                  else if(beforeX == xToTest[0] && afterX > xToTest[0])
                  {
                     xToTest = [Math.ceil(pStart.x + padX)];
                  }
                  else if(afterX == xToTest[0] && beforeX < xToTest[0])
                  {
                     xToTest = [Math.floor(pStart.x + padX)];
                  }
                  else if(afterX == xToTest[0] && beforeX > xToTest[0])
                  {
                     xToTest = [Math.ceil(pStart.x + padX)];
                  }
               }
               else if(int(diffBeforeCenterX * 100) <= erreurSupArrondis)
               {
                  xToTest = [Math.floor(afterX)];
               }
               else if(int(diffCenterAfterX * 100) >= erreurInfArrondis)
               {
                  xToTest = [Math.floor(beforeX)];
               }
               else
               {
                  xToTest = [Math.floor(beforeX),Math.floor(afterX)];
               }
            }
            if(yToTest.length > 0)
            {
               for(y = 0; y < yToTest.length; y++)
               {
                  cell = new Point(Math.floor(pStart.x + padX),yToTest[y]);
                  line.push(cell);
               }
            }
            else if(xToTest.length > 0)
            {
               for(x = 0; x < xToTest.length; x++)
               {
                  cell = new Point(xToTest[x],Math.floor(pStart.y + padY));
                  line.push(cell);
               }
            }
            else if(cas == 1)
            {
               cell = new Point(Math.floor(pStart.x + padX),Math.floor(pStart.y + padY));
               line.push(cell);
            }
            pStart.x = (pStart.x * 100 + padX * 100) / 100;
            pStart.y = (pStart.y * 100 + padY * 100) / 100;
         }
         return line;
      }
   }
}
