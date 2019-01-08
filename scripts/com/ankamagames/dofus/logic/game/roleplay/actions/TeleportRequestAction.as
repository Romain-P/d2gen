package com.ankamagames.dofus.logic.game.roleplay.actions
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class TeleportRequestAction implements Action
   {
       
      
      public var mapId:Number;
      
      public var teleportType:uint;
      
      public var cost:uint;
      
      public function TeleportRequestAction()
      {
         super();
      }
      
      public static function create(teleportType:uint, mapId:Number, cost:uint) : TeleportRequestAction
      {
         var action:TeleportRequestAction = new TeleportRequestAction();
         action.teleportType = teleportType;
         action.mapId = mapId;
         action.cost = cost;
         return action;
      }
   }
}
