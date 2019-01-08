package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
   import com.ankamagames.dofus.logic.game.fight.miscs.DamageUtil;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMinimalStats;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.Callback;
   import com.ankamagames.jerakine.types.zones.IZone;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class TriggeredSpell
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(TriggeredSpell));
       
      
      private var _casterId:Number;
      
      private var _targetId:Number;
      
      private var _spell:SpellWrapper;
      
      private var _triggers:String;
      
      private var _targets:Vector.<Number>;
      
      private var _effectId:uint;
      
      private var _sourceSpellEffectOrder:int;
      
      private var _casterAffectedOutOfZone:Boolean;
      
      private var _targetCell:int;
      
      private var _entityCellCallback:Callback;
      
      public function TriggeredSpell(pCasterId:Number, pTargetId:Number, pSpell:SpellWrapper, pTriggers:String, pTargets:Vector.<Number>, pEffectId:uint, pSourceSpellEffectOrder:int, pCasterAffectedOutOfZone:Boolean, pTargetCell:int)
      {
         super();
         this._casterId = pCasterId;
         this._targetId = pTargetId;
         this._spell = pSpell;
         this._triggers = pTriggers;
         this._targets = pTargets;
         this._effectId = pEffectId;
         this._sourceSpellEffectOrder = pSourceSpellEffectOrder;
         this._casterAffectedOutOfZone = pCasterAffectedOutOfZone;
         this._targetCell = pTargetCell;
      }
      
      public static function create(pTriggers:String, pSpellId:uint, pSpellLevel:int, pCasterId:Number, pTargetId:Number, pEffect:EffectInstance, pCasterAffectedOutOfZone:Boolean, pSourceSpellEffects:Vector.<EffectInstance>, pSourceSpellCasterId:Number, pSourceSpellImpactCell:int) : TriggeredSpell
      {
         var cellId:int = 0;
         var effect:* = null;
         var cellEntities:* = null;
         var cellEntity:* = null;
         var entityId:Number = NaN;
         var entityInfos:* = null;
         var triggeredSpellEffect:* = null;
         var effectOrder:int = 0;
         var spellZone:* = null;
         var spellZoneCells:* = null;
         var minSize:* = 0;
         var minSizeCells:* = null;
         var minSizeZone:* = null;
         var fcf:* = null;
         var entitiesIds:* = null;
         var sw:SpellWrapper = SpellWrapper.create(pSpellId,pSpellLevel,false,pCasterId);
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         var entityCellCallback:Callback = new Callback(DamageUtil.getEntityCellBeforeIndex,pTargetId,pSourceSpellCasterId,pTargetId,pSourceSpellEffects,pSourceSpellEffects.indexOf(pEffect),pSourceSpellImpactCell);
         var spellImpactCell:int = entityCellCallback.exec();
         var targets:Vector.<Number> = new Vector.<Number>(0);
         var zoneShapes:Dictionary = new Dictionary();
         for each(triggeredSpellEffect in sw.effects)
         {
            if(!zoneShapes[triggeredSpellEffect.rawZone])
            {
               zoneShapes[triggeredSpellEffect.rawZone] = true;
               spellZone = SpellZoneManager.getInstance().getZone(triggeredSpellEffect.zoneShape,triggeredSpellEffect.zoneSize as uint,triggeredSpellEffect.zoneMinSize as uint,false,0,false);
               if(spellZone.radius != 63)
               {
                  spellZoneCells = spellZone.getCells(spellImpactCell);
                  for each(cellId in spellZoneCells)
                  {
                     cellEntities = EntitiesManager.getInstance().getEntitiesOnCell(cellId,AnimatedCharacter);
                     for each(cellEntity in cellEntities)
                     {
                        if(fef.getEntityInfos(cellEntity.id))
                        {
                           for each(effect in sw.effects)
                           {
                              if((!effect.targetMask || effect.targetMask.indexOf("C") != -1 && DamageUtil.verifySpellEffectMask(pCasterId,pCasterId,effect,spellImpactCell) || DamageUtil.verifySpellEffectMask(pCasterId,cellEntity.id,effect,spellImpactCell)) && DamageUtil.verifyEffectTrigger(pCasterId,cellEntity.id,sw.effects,effect,false,effect.triggers,spellImpactCell) && targets.indexOf(cellEntity.id) == -1)
                              {
                                 targets.push(cellEntity.id);
                                 break;
                              }
                           }
                        }
                     }
                  }
               }
               else
               {
                  minSize = uint(triggeredSpellEffect.zoneShape == SpellShapeEnum.I?uint(triggeredSpellEffect.zoneSize as uint):uint(triggeredSpellEffect.zoneMinSize as uint));
                  if(minSize)
                  {
                     minSizeZone = SpellZoneManager.getInstance().getZone(SpellShapeEnum.C,minSize,0);
                     minSizeCells = minSizeZone.getCells(spellImpactCell);
                  }
                  for each(entityId in fef.getEntitiesIdsList())
                  {
                     entityInfos = fef.getEntityInfos(entityId) as GameFightFighterInformations;
                     if(entityInfos && (!minSizeCells || minSizeCells.indexOf(entityInfos.disposition.cellId) == -1))
                     {
                        for each(effect in sw.effects)
                        {
                           if((!effect.targetMask || effect.targetMask.indexOf("C") != -1 && DamageUtil.verifySpellEffectMask(pCasterId,pCasterId,effect,spellImpactCell) || DamageUtil.verifySpellEffectMask(pCasterId,entityId,effect,spellImpactCell)) && DamageUtil.verifyEffectTrigger(pCasterId,entityId,sw.effects,effect,false,effect.triggers,spellImpactCell) && targets.indexOf(entityId) == -1)
                           {
                              targets.push(entityId);
                              break;
                           }
                        }
                     }
                  }
               }
               if(spellZone.radius == 63)
               {
                  fcf = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
                  entitiesIds = fcf.entitiesFrame.getEntitiesIdsList();
                  for each(effect in sw.effects)
                  {
                     if(effect.targetMask.indexOf("E263") != -1)
                     {
                        for each(entityId in entitiesIds)
                        {
                           entityInfos = fcf.entitiesFrame.getEntityInfos(entityId) as GameFightFighterInformations;
                           if(entityInfos.disposition.cellId == -1 && DamageUtil.verifySpellEffectMask(pCasterId,entityId,effect,spellImpactCell) && DamageUtil.verifyEffectTrigger(pCasterId,entityId,sw.effects,effect,false,effect.triggers,spellImpactCell) && targets.indexOf(entityId) == -1)
                           {
                              targets.push(entityId);
                           }
                        }
                        break;
                     }
                  }
               }
            }
         }
         effectOrder = pSourceSpellEffects.indexOf(pEffect);
         effectOrder = effectOrder != -1?int(effectOrder):0;
         var ts:TriggeredSpell = new TriggeredSpell(pCasterId,pTargetId,sw,pTriggers,targets,pEffect.effectId,effectOrder,pCasterAffectedOutOfZone,spellImpactCell);
         ts._entityCellCallback = entityCellCallback;
         return ts;
      }
      
      public function get casterId() : Number
      {
         return this._casterId;
      }
      
      public function get casterStats() : GameFightMinimalStats
      {
         return ((Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame).entitiesFrame.getEntityInfos(this._casterId) as GameFightFighterInformations).stats;
      }
      
      public function get casterPosition() : int
      {
         return ((Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame).entitiesFrame.getEntityInfos(this._casterId) as GameFightFighterInformations).disposition.cellId;
      }
      
      public function get targetId() : Number
      {
         return this._targetId;
      }
      
      public function get spell() : SpellWrapper
      {
         return this._spell;
      }
      
      public function get triggers() : String
      {
         return this._triggers;
      }
      
      public function get targets() : Vector.<Number>
      {
         return this._targets;
      }
      
      public function get targetCell() : int
      {
         return this._targetCell;
      }
      
      public function get effectId() : uint
      {
         return this._effectId;
      }
      
      public function get sourceSpellEffectOrder() : int
      {
         return this._sourceSpellEffectOrder;
      }
      
      public function get casterAffectedOutOfZone() : Boolean
      {
         return this._casterAffectedOutOfZone;
      }
      
      public function get entityCellCallback() : Callback
      {
         return this._entityCellCallback;
      }
   }
}
