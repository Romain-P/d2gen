package com.ankamagames.dofus.modules.utils.pathfinding.world
{
   public class Vertex
   {
       
      
      private var _mapId:Number;
      
      private var _zoneId:int;
      
      public function Vertex(mapId:Number, zoneId:int)
      {
         super();
         this._mapId = mapId;
         this._zoneId = zoneId;
      }
      
      public static function getVertexUID(mapId:Number, zoneId:int) : String
      {
         return mapId + "|" + zoneId;
      }
      
      public static function mapId(vertexUid:String) : Number
      {
         return Number(vertexUid.split("|")[0]);
      }
      
      public static function zoneId(vertexUid:String) : int
      {
         return int(vertexUid.split("|")[1]);
      }
      
      public function get mapId() : Number
      {
         return this._mapId;
      }
      
      public function get zoneId() : int
      {
         return this._zoneId;
      }
      
      public function get UID() : String
      {
         return getVertexUID(this._mapId,this._zoneId);
      }
      
      public function toString() : String
      {
         return "Vertex{_mapId=" + String(this._mapId) + ",_zoneId=" + String(this._zoneId) + "}";
      }
   }
}
