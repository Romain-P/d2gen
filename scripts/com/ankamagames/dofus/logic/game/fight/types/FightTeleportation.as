package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.jerakine.types.positions.MapPoint;
   
   public class FightTeleportation
   {
       
      
      private var _effectId:uint;
      
      public var targets:Vector.<Number>;
      
      public var casterId:Number;
      
      public var casterPos:MapPoint;
      
      public var impactPos:MapPoint;
      
      public var multipleEffects:Boolean;
      
      public var allTargets:Boolean;
      
      public function FightTeleportation(pEffectId:uint, pCasterId:Number, pCasterCell:uint, pImpactCell:uint)
      {
         super();
         this._effectId = pEffectId;
         this.targets = new Vector.<Number>(0);
         this.casterId = pCasterId;
         this.casterPos = MapPoint.fromCellId(pCasterCell);
         this.impactPos = MapPoint.fromCellId(pImpactCell);
      }
      
      public function get effectId() : uint
      {
         return this._effectId;
      }
   }
}
