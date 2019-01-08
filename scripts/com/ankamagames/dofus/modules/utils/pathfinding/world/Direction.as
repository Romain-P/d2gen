package com.ankamagames.dofus.modules.utils.pathfinding.world
{
   public final class Direction
   {
      
      public static var INVALID:int = -1;
      
      public static var EAST:int = 0;
      
      public static var SOUTH_EAST:int = 1;
      
      public static var SOUTH:int = 2;
      
      public static var SOUTH_WEST:int = 3;
      
      public static var WEST:int = 4;
      
      public static var NORTH_WEST:int = 5;
      
      public static var NORTH:int = 6;
      
      public static var NORTH_EAST:int = 7;
       
      
      public function Direction()
      {
         super();
      }
      
      public static function isValidDirection(dir:int) : Boolean
      {
         return dir >= EAST && dir <= NORTH_EAST;
      }
      
      public static function fromName(name:String) : int
      {
         switch(name)
         {
            case "EAST":
               return EAST;
            case "SOUTH_EAST":
               return SOUTH_EAST;
            case "SOUTH":
               return SOUTH;
            case "SOUTH_WEST":
               return SOUTH_WEST;
            case "WEST":
               return WEST;
            case "NORTH_WEST":
               return NORTH_WEST;
            case "NORTH":
               return NORTH;
            case "NORTH_EAST":
               return NORTH_EAST;
            default:
               return INVALID;
         }
      }
   }
}
