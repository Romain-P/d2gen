package com.ankamagames.dofus.logic.game.fight.miscs
{
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.atouin.managers.InteractiveCellManager;
   import com.ankamagames.atouin.types.GraphicCell;
   import com.ankamagames.atouin.utils.DataMapProvider;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
   import com.ankamagames.dofus.logic.game.fight.managers.FightersStateManager;
   import com.ankamagames.dofus.logic.game.fight.types.BasicBuff;
   import com.ankamagames.dofus.logic.game.fight.types.FighterStatus;
   import com.ankamagames.dofus.logic.game.fight.types.PushedEntity;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.enums.DirectionsEnum;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class PushUtil
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(PushUtil));
      
      public static const PUSH_EFFECTS_IDS:Vector.<uint> = new <uint>[ActionIdEnum.ACTION_CHARACTER_PUSH,ActionIdEnum.ACTION_CHARACTER_GET_PUSHED];
      
      private static var _updatedEntitiesPositions:Dictionary = new Dictionary();
      
      private static var _pushSpells:Vector.<int> = new Vector.<int>(0);
       
      
      public function PushUtil()
      {
         super();
      }
      
      public static function reset() : void
      {
         var entityId:* = undefined;
         for(entityId in _updatedEntitiesPositions)
         {
            delete _updatedEntitiesPositions[entityId];
         }
         _pushSpells.length = 0;
      }
      
      public static function getPushSpells() : Vector.<int>
      {
         return _pushSpells;
      }
      
      public static function getPushedEntities(pSpell:*, pCasterId:Number, pSpellImpactCell:int, targets:Vector.<Number>) : Vector.<PushedEntity>
      {
         var pushedEntities:* = null;
         var zoneShape:int = 0;
         var pushEffect:* = null;
         var targetId:Number = NaN;
         var spellZoneCells:* = null;
         var origin:* = 0;
         var cellId:int = 0;
         var entity:* = null;
         var hasMinSize:Boolean = false;
         var originPoint:* = null;
         var direction:int = 0;
         var directions:* = null;
         var entitiesInDirection:* = null;
         var newSpell:Boolean = false;
         var force:int = 0;
         var pushed:Boolean = false;
         var i:int = 0;
         var fightEntitiesFrame:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         for each(targetId in targets)
         {
            pushEffect = getPushEffect(pSpell,pCasterId,targetId,pSpellImpactCell);
            if(!(!pushEffect || pushEffect.effect.diceNum == 0 || pushEffect.triggeringSpellCasterId == pushEffect.casterId))
            {
               zoneShape = pushEffect.effect.zoneShape;
               spellZoneCells = pushEffect.spellZoneCells;
               if(pushEffect.effect.effectId == ActionIdEnum.ACTION_CHARACTER_GET_PUSHED && spellZoneCells.indexOf(pushEffect.casterCell) == -1)
               {
                  spellZoneCells.push(pushEffect.casterCell);
               }
               hasMinSize = DamageUtil.hasMinSize(zoneShape);
               if(hasMinSize && (zoneShape != SpellShapeEnum.Q && zoneShape != SpellShapeEnum.sharp && (!pushEffect.effect.zoneMinSize || pushEffect.effect.zoneMinSize == 0)))
               {
                  hasMinSize = false;
               }
               if(zoneShape == SpellShapeEnum.T)
               {
                  origin = uint(pSpellImpactCell == fightEntitiesFrame.getEntityInfos(targetId).disposition.cellId?uint(pushEffect.casterCell):uint(pSpellImpactCell));
               }
               else
               {
                  origin = uint(!hasMinSize && pushEffect.effect.effectId != ActionIdEnum.ACTION_CHARACTER_GET_PUSHED?uint(pushEffect.casterCell):uint(pSpellImpactCell));
               }
               originPoint = MapPoint.fromCellId(origin);
               directions = new Dictionary();
               if(_pushSpells.indexOf(pSpell.id) == -1)
               {
                  _pushSpells.push(pSpell.id);
                  newSpell = true;
               }
               for each(cellId in spellZoneCells)
               {
                  if(!(pushEffect.effect.effectId == ActionIdEnum.ACTION_CHARACTER_GET_PUSHED && cellId != pushEffect.casterCell))
                  {
                     entity = EntitiesManager.getInstance().getEntityOnCell(cellId,AnimatedCharacter);
                     if(entity && originPoint.cellId != entity.position.cellId)
                     {
                        pushed = false;
                        if(pushedEntities)
                        {
                           for(i = 0; i < pushedEntities.length; )
                           {
                              if(pushedEntities[i].id == entity.id)
                              {
                                 pushed = true;
                                 break;
                              }
                              i++;
                           }
                        }
                        if(!pushed)
                        {
                           direction = originPoint.advancedOrientationTo(entity.position,false);
                           if(!directions[direction])
                           {
                              entitiesInDirection = getEntitiesInDirection(originPoint.cellId,pushEffect.spellZone.radius,direction);
                              entity = !!entitiesInDirection?entitiesInDirection[0]:entity;
                              directions[direction] = true;
                              if(!pushedEntities)
                              {
                                 pushedEntities = new Vector.<PushedEntity>(0);
                              }
                              force = getPushForce(origin,fightEntitiesFrame.getEntityInfos(entity.id) as GameFightFighterInformations,pushEffect.spell.effects,pushEffect.effect);
                              pushedEntities = pushedEntities.concat(getPushedEntitiesInLine(pushEffect.spell,newSpell,pushEffect,pSpellImpactCell,entity.position.cellId,force,direction,pSpell.id));
                           }
                        }
                     }
                  }
               }
            }
         }
         return pushedEntities;
      }
      
      private static function getPushEffect(pSpell:*, pCasterId:Number, pTargetId:Number, pSpellImpactCell:int, pTriggeringSpellCasterId:Number = 0, pCheckTargetBuffs:Boolean = true) : PushEffect
      {
         var effi:* = null;
         var buff:* = null;
         var pushEffect:* = null;
         for each(effi in pSpell.effects)
         {
            if(PUSH_EFFECTS_IDS.indexOf(effi.effectId) != -1)
            {
               return new PushEffect(effi as EffectInstanceDice,pSpell,pCasterId,pTargetId,(Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame).getEntityInfos(pCasterId).disposition.cellId,pSpellImpactCell,pTriggeringSpellCasterId);
            }
         }
         if(pCheckTargetBuffs)
         {
            for each(buff in BuffManager.getInstance().getAllBuff(pTargetId))
            {
               if(buff.effect.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL || buff.effect.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM)
               {
                  if(DamageUtil.verifyBuffTriggers(buff,pSpell.effects,pCasterId,pTargetId,false,pSpellImpactCell,null))
                  {
                     pushEffect = getPushEffect(SpellWrapper.create(int(buff.effect.parameter0),int(buff.effect.parameter1),true,pTargetId,true),pTargetId,pTargetId,pSpellImpactCell,pCasterId,false);
                     if(pushEffect)
                     {
                        return pushEffect;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      private static function getPushedEntitiesInLine(pSpell:SpellWrapper, pNewSpell:Boolean, pPushEffect:PushEffect, pSpellImpactCell:int, pStartCell:int, pPushForce:int, pDirection:int, pSourceSpellId:int) : Vector.<PushedEntity>
      {
         var pushedEntities:Vector.<PushedEntity> = null;
         var entity:IEntity = null;
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         var previousCell:MapPoint = null;
         var entities:Vector.<IEntity> = null;
         var entityInfo:GameFightFighterInformations = null;
         var entityPushable:Boolean = false;
         var nextCellEntity:IEntity = null;
         var nextCellEntityInfo:GameFightFighterInformations = null;
         var nextEntityPushable:Boolean = false;
         var pushedIndex:int = 0;
         var pushingEntity:PushedEntity = null;
         var firstPushingEntity:PushedEntity = null;
         var pushedEntity:PushedEntity = null;
         var emptyCells:Vector.<int> = null;
         var entityInSpellZone:Boolean = false;
         var cell:MapPoint = null;
         var entityCell:uint = 0;
         var forceReduction:int = 0;
         pushedEntities = new Vector.<PushedEntity>(0);
         var cellMp:MapPoint = MapPoint.fromCellId(pStartCell);
         var nextCell:MapPoint = cellMp.getNearestCellInDirection(pDirection);
         var force:int = pPushForce;
         for(i = 0; i < pPushForce; )
         {
            if(nextCell)
            {
               if(isBlockingCell(nextCell.cellId,!previousCell?int(cellMp.cellId):int(previousCell.cellId)))
               {
                  break;
               }
               force--;
               previousCell = nextCell;
               nextCell = nextCell.getNearestCellInDirection(pDirection);
            }
            i++;
         }
         previousCell = null;
         if(force <= 0)
         {
            return pushedEntities;
         }
         entities = new Vector.<IEntity>(0);
         entities.push(EntitiesManager.getInstance().getEntityOnCell(pStartCell,AnimatedCharacter));
         if(force == pPushForce)
         {
            while(cellMp)
            {
               cellMp = cellMp.getNearestCellInDirection(pDirection);
               if(cellMp)
               {
                  entity = EntitiesManager.getInstance().getEntityOnCell(cellMp.cellId,AnimatedCharacter);
                  if(entity && pPushEffect.spellZoneCells.indexOf(cellMp.cellId) != -1)
                  {
                     entities.push(entity);
                     continue;
                  }
                  break;
               }
            }
         }
         var getPushedEntity:Function = function(pEntityId:Number):PushedEntity
         {
            var pe:* = null;
            for each(pe in pushedEntities)
            {
               if(pe.id == pEntityId)
               {
                  return pe;
               }
            }
            return null;
         };
         var isEntityInSpellZone:Function = function(pEntity:Number):Boolean
         {
            var e:* = null;
            for each(e in entities)
            {
               if(e.id == pEntity)
               {
                  return true;
               }
            }
            return false;
         };
         var fightEntitiesFrame:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         var nbEntities:int = entities.length;
         var casterInfos:GameFightFighterInformations = fightEntitiesFrame.getEntityInfos(pSpell.playerId) as GameFightFighterInformations;
         for(i = 0; i < nbEntities; )
         {
            entityCell = pNewSpell && _updatedEntitiesPositions[entities[i].id]?uint(_updatedEntitiesPositions[entities[i].id]):uint(entities[i].position.cellId);
            cellMp = MapPoint.fromCellId(entityCell);
            entityInfo = fightEntitiesFrame.getEntityInfos(entities[i].id) as GameFightFighterInformations;
            entityPushable = isPushableEntity(entityInfo);
            pushedIndex = 0;
            if(entityPushable && (pPushEffect.effect.effectId == ActionIdEnum.ACTION_CHARACTER_GET_PUSHED || DamageUtil.verifySpellEffectZone(entities[i].id,pPushEffect.effect,pSpellImpactCell,casterInfos.disposition.cellId)) && (pPushEffect.effect.effectId != ActionIdEnum.ACTION_CHARACTER_GET_PUSHED?Boolean(DamageUtil.verifySpellEffectMask(pSpell.playerId,entities[i].id,pPushEffect.effect,pSpellImpactCell,pPushEffect.triggeringSpellCasterId)):Boolean(DamageUtil.verifySpellEffectMask(pSpell.playerId,pPushEffect.targetId,pPushEffect.effect,pSpellImpactCell,pPushEffect.triggeringSpellCasterId))))
            {
               pushingEntity = getPushedEntity(entities[i].id);
               if(!pushingEntity)
               {
                  pushingEntity = new PushedEntity(entities[i].id,pSourceSpellId,pushedIndex,pPushForce,pPushEffect.effect);
                  pushedEntities.push(pushingEntity);
                  if(!firstPushingEntity)
                  {
                     firstPushingEntity = pushingEntity;
                  }
               }
               else
               {
                  pushingEntity.pushedIndexes.push(pushedIndex);
               }
               for(pushedIndex++,j = 0; j < pPushForce; )
               {
                  if(j == 0)
                  {
                     previousCell = cellMp;
                     nextCell = cellMp.getNearestCellInDirection(pDirection);
                  }
                  else if(nextCell)
                  {
                     previousCell = nextCell;
                     nextCell = nextCell.getNearestCellInDirection(pDirection);
                     if(nextCell && !DataMapProvider.getInstance().pointMov(nextCell.x,nextCell.y))
                     {
                        break;
                     }
                  }
                  if(nextCell)
                  {
                     if(isBlockingCell(nextCell.cellId,previousCell.cellId))
                     {
                        nextCellEntity = EntitiesManager.getInstance().getEntityOnCell(nextCell.cellId,AnimatedCharacter);
                        if(nextCellEntity)
                        {
                           entityInSpellZone = isEntityInSpellZone(nextCellEntity.id);
                           nextCellEntityInfo = fightEntitiesFrame.getEntityInfos(nextCellEntity.id) as GameFightFighterInformations;
                           nextEntityPushable = isPushableEntity(nextCellEntityInfo);
                           if(nextEntityPushable)
                           {
                              if(entityInSpellZone && !isPathBlocked(nextCell.cellId,getCellIdInDirection(nextCell.cellId,pPushForce,pDirection),pDirection))
                              {
                                 pushingEntity.force = 0;
                                 break;
                              }
                           }
                           pushedEntity = getPushedEntity(nextCellEntity.id);
                           if(!pushedEntity)
                           {
                              pushedEntity = new PushedEntity(nextCellEntity.id,pSourceSpellId,pushedIndex,pPushForce,pPushEffect.effect);
                              pushedEntity.pushingEntity = firstPushingEntity;
                              pushedEntities.push(pushedEntity);
                           }
                           else
                           {
                              pushedEntity.pushedIndexes.push(pushedIndex);
                           }
                           pushedIndex++;
                        }
                        else if(j == 0)
                        {
                           break;
                        }
                        cell = nextCell.getNearestCellInDirection(pDirection);
                        if(cell && !isBlockingCell(cell.cellId,nextCell.cellId))
                        {
                           break;
                        }
                     }
                     else if(j != pPushForce - 1 && (!nextCellEntity || entities.indexOf(nextCellEntity) != -1) && isPathBlocked(nextCell.cellId,getCellIdInDirection(cellMp.cellId,pPushForce,pDirection),pDirection))
                     {
                        if(!emptyCells)
                        {
                           emptyCells = new Vector.<int>(0);
                        }
                        if(emptyCells.indexOf(nextCell.cellId) == -1)
                        {
                           emptyCells.push(nextCell.cellId);
                        }
                     }
                     else if(!isPathBlocked(cellMp.cellId,getCellIdInDirection(cellMp.cellId,pPushForce,pDirection),pDirection))
                     {
                        pushingEntity.force = 0;
                     }
                     if(pushingEntity.force == 0)
                     {
                        break;
                     }
                  }
                  j++;
               }
               if(!nextCellEntity || nextCellEntity.position.cellId != previousCell.cellId)
               {
                  _updatedEntitiesPositions[entities[i].id] = previousCell.cellId;
               }
            }
            i++;
         }
         if(emptyCells)
         {
            forceReduction = emptyCells.length;
            if(forceReduction > 0)
            {
               for each(pushedEntity in pushedEntities)
               {
                  pushedEntity.force = pushedEntity.force - forceReduction;
               }
            }
         }
         if(pushingEntity)
         {
            pushingEntity.pushedDistance = (!!emptyCells?emptyCells.length + 1:1) * ((pDirection & 1) == 0?2:1);
         }
         return pushedEntities;
      }
      
      private static function getPushForce(pPushOriginCell:int, pTargetInfos:GameFightFighterInformations, pSpellEffects:Vector.<EffectInstance>, pPushEffect:EffectInstance) : int
      {
         var pushForce:int = 0;
         var pullEffect:* = null;
         var effect:* = null;
         var pushEffectForce:int = 0;
         var targetCell:* = null;
         var originCell:* = null;
         var pullEffectForce:int = 0;
         var cell:* = null;
         var nextCell:* = null;
         var orientation:* = 0;
         var i:int = 0;
         var pullDistance:int = 0;
         var pushEffectIndex:int = pSpellEffects.indexOf(pPushEffect);
         var pullEffectIndex:int = -1;
         for each(effect in pSpellEffects)
         {
            if(effect.effectId == ActionIdEnum.ACTION_CHARACTER_PULL)
            {
               pullEffectIndex = pSpellEffects.indexOf(effect);
               pullEffect = effect as EffectInstanceDice;
               break;
            }
         }
         pushEffectForce = (pPushEffect as EffectInstanceDice).diceNum;
         targetCell = MapPoint.fromCellId(pTargetInfos.disposition.cellId);
         originCell = MapPoint.fromCellId(pPushOriginCell);
         pushEffectForce = (targetCell.advancedOrientationTo(originCell,false) & 1) == 0?int(Math.ceil(pushEffectForce / 2)):int(pushEffectForce);
         if(pullEffectIndex != -1 && pullEffectIndex < pushEffectIndex && isPushableEntity(pTargetInfos))
         {
            pullEffectForce = pullEffect.diceNum;
            cell = targetCell;
            orientation = uint(targetCell.advancedOrientationTo(originCell));
            pullDistance = 0;
            for(i = 0; i < pullEffectForce; )
            {
               nextCell = cell.getNearestCellInDirection(orientation);
               if(nextCell && !isBlockingCell(nextCell.cellId,cell.cellId))
               {
                  pullDistance++;
                  cell = nextCell;
                  i++;
                  continue;
               }
               break;
            }
            pushForce = pushEffectForce - pullDistance;
         }
         else
         {
            pushForce = pushEffectForce;
         }
         return pushForce;
      }
      
      public static function hasPushDamages(pCasterId:Number, pTargetId:Number, pSpellEffects:Vector.<EffectInstance>, pEffect:EffectInstance, pSpellImpactCell:int) : Boolean
      {
         var casterInfos:* = null;
         var origin:* = 0;
         var originPoint:* = null;
         var direction:int = 0;
         var pushForce:int = 0;
         var cellMp:* = null;
         var previousCell:* = null;
         var nextCell:* = null;
         var force:int = 0;
         var i:int = 0;
         var fightEntitiesFrame:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(PUSH_EFFECTS_IDS.indexOf(pEffect.effectId) == -1 || !fightEntitiesFrame)
         {
            return false;
         }
         var targetInfos:GameFightFighterInformations = fightEntitiesFrame.getEntityInfos(pTargetId) as GameFightFighterInformations;
         if(targetInfos && isPushableEntity(targetInfos))
         {
            casterInfos = fightEntitiesFrame.getEntityInfos(pCasterId) as GameFightFighterInformations;
            origin = uint(!DamageUtil.hasMinSize(pEffect.zoneShape) && pEffect.effectId != ActionIdEnum.ACTION_CHARACTER_GET_PUSHED?uint(casterInfos.disposition.cellId):uint(pSpellImpactCell));
            originPoint = MapPoint.fromCellId(origin);
            direction = originPoint.advancedOrientationTo(MapPoint.fromCellId(targetInfos.disposition.cellId),false);
            pushForce = getPushForce(origin,targetInfos,pSpellEffects,pEffect);
            cellMp = MapPoint.fromCellId(targetInfos.disposition.cellId);
            nextCell = cellMp.getNearestCellInDirection(direction);
            force = pushForce;
            for(i = 0; i < pushForce; )
            {
               if(nextCell)
               {
                  if(isBlockingCell(nextCell.cellId,!previousCell?int(cellMp.cellId):int(previousCell.cellId)))
                  {
                     break;
                  }
                  force--;
                  previousCell = nextCell;
                  nextCell = nextCell.getNearestCellInDirection(direction);
               }
               i++;
            }
            return force > 0;
         }
         return false;
      }
      
      public static function isBlockingCell(pCell:int, pFromCell:int, pCheckDiag:Boolean = true) : Boolean
      {
         var cellEntity:* = null;
         var startCell:* = null;
         var destCell:* = null;
         var direction:* = 0;
         var c1:* = null;
         var c2:* = null;
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         var gc:GraphicCell = InteractiveCellManager.getInstance().getCell(pCell);
         var blocking:Boolean = gc && !gc.visible;
         if(!blocking)
         {
            cellEntity = EntitiesManager.getInstance().getEntityOnCell(pCell,IEntity);
            blocking = cellEntity && (!fef || fef.getEntityInfos(cellEntity.id));
         }
         if(!blocking && pCheckDiag)
         {
            startCell = MapPoint.fromCellId(pFromCell);
            destCell = MapPoint.fromCellId(pCell);
            direction = uint(startCell.orientationTo(destCell));
            if(direction % 2 == 0)
            {
               switch(direction)
               {
                  case DirectionsEnum.RIGHT:
                     c1 = destCell.getNearestCellInDirection(DirectionsEnum.UP_LEFT);
                     c2 = destCell.getNearestCellInDirection(DirectionsEnum.DOWN_LEFT);
                     break;
                  case DirectionsEnum.DOWN:
                     c1 = destCell.getNearestCellInDirection(DirectionsEnum.UP_LEFT);
                     c2 = destCell.getNearestCellInDirection(DirectionsEnum.UP_RIGHT);
                     break;
                  case DirectionsEnum.LEFT:
                     c1 = destCell.getNearestCellInDirection(DirectionsEnum.UP_RIGHT);
                     c2 = destCell.getNearestCellInDirection(DirectionsEnum.DOWN_RIGHT);
                     break;
                  case DirectionsEnum.UP:
                     c1 = destCell.getNearestCellInDirection(DirectionsEnum.DOWN_LEFT);
                     c2 = destCell.getNearestCellInDirection(DirectionsEnum.DOWN_RIGHT);
               }
               blocking = c1 && isBlockingCell(c1.cellId,-1,false) || c2 && isBlockingCell(c2.cellId,-1,false);
            }
         }
         return blocking;
      }
      
      public static function isPathBlocked(pStartCell:int, pEndCell:int, pDirection:int) : Boolean
      {
         var pathBlocked:Boolean = false;
         var previousCell:* = null;
         var cellMp:MapPoint = MapPoint.fromCellId(pStartCell);
         while(true)
         {
            if(cellMp && !pathBlocked)
            {
               previousCell = cellMp;
               cellMp = cellMp.getNearestCellInDirection(pDirection);
               if(cellMp)
               {
                  pathBlocked = isBlockingCell(cellMp.cellId,previousCell.cellId);
                  if(cellMp.cellId != pEndCell)
                  {
                     continue;
                  }
               }
               else
               {
                  break;
               }
            }
            return pathBlocked;
         }
         return true;
      }
      
      public static function getCellIdInDirection(pStartCell:int, pLength:int, pDirection:int) : int
      {
         var i:int = 0;
         var cellMp:MapPoint = MapPoint.fromCellId(pStartCell);
         for(i = 0; i < pLength; )
         {
            cellMp = cellMp.getNearestCellInDirection(pDirection);
            if(!cellMp)
            {
               return -1;
            }
            i++;
         }
         return cellMp.cellId;
      }
      
      public static function getEntitiesInDirection(pStartCell:int, pLength:int, pDirection:int) : Vector.<IEntity>
      {
         var entities:* = null;
         var entity:* = null;
         var cellMp:MapPoint = MapPoint.fromCellId(pStartCell);
         var nextCell:MapPoint = cellMp.getNearestCellInDirection(pDirection);
         var i:int = 0;
         while(nextCell && i < pLength)
         {
            entity = EntitiesManager.getInstance().getEntityOnCell(nextCell.cellId,AnimatedCharacter);
            if(entity)
            {
               if(!entities)
               {
                  entities = new Vector.<IEntity>(0);
               }
               entities.push(entity);
            }
            nextCell = nextCell.getNearestCellInDirection(pDirection);
            i++;
         }
         return entities;
      }
      
      public static function isPushableEntity(pEntityInfo:GameFightFighterInformations) : Boolean
      {
         var monster:* = null;
         var entityStatus:FighterStatus = FightersStateManager.getInstance().getStatus(pEntityInfo.contextualId);
         var canBePushed:Boolean = true;
         if(pEntityInfo is GameFightMonsterInformations)
         {
            monster = Monster.getMonsterById((pEntityInfo as GameFightMonsterInformations).creatureGenericId);
            canBePushed = monster.canBePushed;
         }
         return !entityStatus.cantBePushed && canBePushed;
      }
      
      public static function isPushed(pTargetInfos:GameFightFighterInformations, pSpellImpactCell:int, pEffect:EffectInstance) : Boolean
      {
         var impactPos:* = null;
         var targetPos:* = null;
         var direction:int = 0;
         var nextCell:* = null;
         var force:int = pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_PUSH || pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_PULL?int((pEffect as EffectInstanceDice).diceNum):0;
         if(force > 0 && isPushableEntity(pTargetInfos))
         {
            impactPos = MapPoint.fromCellId(pSpellImpactCell);
            targetPos = MapPoint.fromCellId(pTargetInfos.disposition.cellId);
            direction = pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_PUSH?int(impactPos.orientationTo(targetPos)):int(targetPos.orientationTo(impactPos));
            if(force - (impactPos.distanceTo(targetPos) - 1) > 0)
            {
               nextCell = targetPos.getNearestCellInDirection(direction);
               return nextCell && !isBlockingCell(nextCell.cellId,targetPos.cellId);
            }
         }
         return false;
      }
   }
}

import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
import com.ankamagames.jerakine.types.zones.IZone;

class PushEffect
{
    
   
   public var effect:EffectInstanceDice;
   
   public var spell:SpellWrapper;
   
   public var spellZone:IZone;
   
   public var spellZoneCells:Vector.<uint>;
   
   public var casterId:Number;
   
   public var targetId:Number;
   
   public var triggeringSpellCasterId:Number;
   
   public var casterCell:int;
   
   function PushEffect(effect:EffectInstanceDice, spell:SpellWrapper, casterId:Number, targetId:Number, casterCell:int, spellImpactCell:int, triggeringSpellCasterId:Number)
   {
      super();
      this.effect = effect;
      this.spell = spell;
      this.casterId = casterId;
      this.targetId = targetId;
      this.triggeringSpellCasterId = triggeringSpellCasterId;
      this.casterCell = casterCell;
      this.spellZone = SpellZoneManager.getInstance().getSpellZone(spell,false,true,spellImpactCell,casterCell);
      this.spellZoneCells = this.spellZone.getCells(spellImpactCell);
   }
}
