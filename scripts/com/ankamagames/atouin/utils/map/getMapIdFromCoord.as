package com.ankamagames.atouin.utils.map
{
   public function getMapIdFromCoord(worldId:int, x:int, y:int) : Number
   {
      var worldIdMax:int = 8192;
      var mapCoordMax:int = 512;
      if(x > mapCoordMax || y > mapCoordMax || worldId > worldIdMax)
      {
         return -1;
      }
      var newWorldId:* = worldId & 4095;
      var newX:* = Math.abs(x) & 255;
      if(x < 0)
      {
         newX = newX | 256;
      }
      var newY:* = Math.abs(y) & 255;
      if(y < 0)
      {
         newY = newY | 256;
      }
      return newWorldId << 18 | (newX << 9 | newY);
   }
}
