package com.ankamagames.dofus.logic.game.fight.miscs
{
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.fight.managers.FightersStateManager;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
   import com.ankamagames.dofus.logic.game.fight.types.FightTeleportation;
   import com.ankamagames.dofus.logic.game.fight.types.FighterStatus;
   import com.ankamagames.dofus.network.enums.SubEntityBindingPointCategoryEnum;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.types.zones.IZone;
   import flash.utils.getQualifiedClassName;
   
   public class TeleportationUtil
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(TeleportationUtil));
      
      public static const TELEPORTATION_EFFECTS:Array = [ActionIdEnum.ACTION_TELEPORT_TO_PREVIOUS_POSITION,ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_TARGET,ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_CASTER,ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_AREA_CENTER,ActionIdEnum.ACTION_CHARACTER_EXCHANGE_PLACES,ActionIdEnum.ACTION_TELEPORT_TO_TURN_START_POSITION];
       
      
      public function TeleportationUtil()
      {
         super();
      }
      
      public static function getFightTeleportation(pEntities:Vector.<Number>, pEffects:Vector.<EffectInstance>, pCasterId:Number, pCasterCell:int, pImpactCell:uint, pTriggeringSpellCasterId:Number = 0) : FightTeleportation
      {
         var fightTeleportation:* = null;
         var effect:* = null;
         var entityId:Number = NaN;
         var entityInfos:* = null;
         var entity:* = null;
         var targetIsCaster:Boolean = false;
         var i:int = 0;
         var j:int = 0;
         var updatePosition:Boolean = false;
         var spellZone:* = null;
         var cellId:int = 0;
         var targetEntity:* = null;
         var currentCell:* = null;
         var orientation:* = 0;
         var fcf:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         var numEffects:uint = pEffects.length;
         var casterCell:int = pCasterCell;
         for(i = 0; i < numEffects; )
         {
            effect = pEffects[i];
            updatePosition = false;
            if(effect.effectId == ActionIdEnum.ACTION_CHARACTER_GET_PULLED)
            {
               spellZone = SpellZoneManager.getInstance().getZone(effect.rawZone.charCodeAt(0),effect.zoneSize as uint,effect.zoneMinSize as uint,false,effect.zoneStopAtTarget as uint);
               for each(cellId in spellZone.getCells(pImpactCell))
               {
                  for each(targetEntity in EntitiesManager.getInstance().getEntitiesOnCell(cellId,AnimatedCharacter))
                  {
                     if(fcf.entitiesFrame.getEntityInfos(targetEntity.id) && DamageUtil.verifySpellEffectMask(pCasterId,targetEntity.id,effect,pImpactCell,pTriggeringSpellCasterId))
                     {
                        updatePosition = true;
                     }
                     if(updatePosition)
                     {
                        break;
                     }
                  }
                  if(updatePosition)
                  {
                     break;
                  }
               }
               if(updatePosition)
               {
                  currentCell = MapPoint.fromCellId(casterCell);
                  orientation = uint(currentCell.advancedOrientationTo(MapPoint.fromCellId(pImpactCell)));
                  for(j = 0; j < effect.parameter0; )
                  {
                     currentCell = currentCell.getNearestCellInDirection(orientation);
                     if(currentCell && !PushUtil.isBlockingCell(currentCell.cellId,-1,false))
                     {
                        casterCell = currentCell.cellId;
                        j++;
                        continue;
                     }
                     break;
                  }
               }
            }
            if(TELEPORTATION_EFFECTS.indexOf(effect.effectId) != -1)
            {
               if(!fightTeleportation)
               {
                  fightTeleportation = new FightTeleportation(effect.effectId,pCasterId,casterCell,pImpactCell);
               }
               else
               {
                  fightTeleportation.multipleEffects = true;
               }
               for each(entityId in pEntities)
               {
                  entityInfos = fcf.entitiesFrame.getEntityInfos(entityId) as GameFightFighterInformations;
                  entity = DofusEntities.getEntity(entityId) as AnimatedCharacter;
                  targetIsCaster = entityId == pCasterId || entityId == pTriggeringSpellCasterId;
                  if(entityInfos && entityInfos.alive && entity && entity.displayed && (effect.targetMask.indexOf("C") != -1 && targetIsCaster || effect.targetMask.indexOf("O") != -1 && entityId == pTriggeringSpellCasterId || DamageUtil.verifySpellEffectZone(entityId,effect,pImpactCell,casterCell)) && DofusEntities.getEntity(entityId) && canTeleport(entityInfos.contextualId) && (effect.effectId != ActionIdEnum.ACTION_CHARACTER_EXCHANGE_PLACES || !entity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_LIFTED_ENTITY,0)) && fightTeleportation.targets.indexOf(entityId) == -1 && DamageUtil.verifySpellEffectMask(pCasterId,entityId,effect,pImpactCell,pTriggeringSpellCasterId) && DamageUtil.verifyEffectTrigger(pCasterId,entityId,pEffects,effect,false,effect.triggers,pImpactCell) && !(pImpactCell == entityInfos.disposition.cellId && (effect.effectId == ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_TARGET || effect.effectId == ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_AREA_CENTER)))
                  {
                     fightTeleportation.targets.push(entityId);
                  }
               }
            }
            i++;
         }
         if(fightTeleportation)
         {
            if(fightTeleportation.targets.length == 0 && fightTeleportation.effectId == ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_TARGET && canTeleport(pCasterId))
            {
               fightTeleportation.targets.push(pCasterId);
            }
            fightTeleportation.allTargets = fightTeleportation.targets.length == pEntities.length;
         }
         return fightTeleportation;
      }
      
      public static function canTeleport(pEntityId:Number) : Boolean
      {
         var monster:* = null;
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         var entityInfos:GameFightFighterInformations = fef.getEntityInfos(pEntityId) as GameFightFighterInformations;
         if(entityInfos is GameFightMonsterInformations)
         {
            monster = Monster.getMonsterById((entityInfos as GameFightMonsterInformations).creatureGenericId);
            if(!monster.canSwitchPos)
            {
               return false;
            }
         }
         var entityStatus:FighterStatus = FightersStateManager.getInstance().getStatus(pEntityId);
         return !entityStatus.cantBeMoved;
      }
      
      public static function hasTeleportation(pSpellW:SpellWrapper) : Boolean
      {
         var effect:* = null;
         for each(effect in pSpellW.effects)
         {
            if(TELEPORTATION_EFFECTS.indexOf(effect.effectId) != -1)
            {
               return true;
            }
         }
         return false;
      }
   }
}
