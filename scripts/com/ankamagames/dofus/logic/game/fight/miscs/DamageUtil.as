package com.ankamagames.dofus.logic.game.fight.miscs
{
   import com.ankamagames.atouin.data.map.CellData;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.atouin.managers.MapDisplayManager;
   import com.ankamagames.dofus.datacenter.effects.Effect;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceInteger;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceMinMax;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.datacenter.monsters.MonsterGrade;
   import com.ankamagames.dofus.datacenter.spells.SpellBomb;
   import com.ankamagames.dofus.datacenter.spells.SpellLevel;
   import com.ankamagames.dofus.internalDatacenter.DataEnum;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
   import com.ankamagames.dofus.logic.game.fight.managers.CurrentPlayedFighterManager;
   import com.ankamagames.dofus.logic.game.fight.managers.FightersStateManager;
   import com.ankamagames.dofus.logic.game.fight.managers.LinkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.managers.MarkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellDamagesManager;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
   import com.ankamagames.dofus.logic.game.fight.types.BasicBuff;
   import com.ankamagames.dofus.logic.game.fight.types.EffectDamage;
   import com.ankamagames.dofus.logic.game.fight.types.EffectModification;
   import com.ankamagames.dofus.logic.game.fight.types.FighterStates;
   import com.ankamagames.dofus.logic.game.fight.types.InterceptedDamage;
   import com.ankamagames.dofus.logic.game.fight.types.MarkInstance;
   import com.ankamagames.dofus.logic.game.fight.types.PushedEntity;
   import com.ankamagames.dofus.logic.game.fight.types.ReflectDamage;
   import com.ankamagames.dofus.logic.game.fight.types.ReflectValues;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamage;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageInfo;
   import com.ankamagames.dofus.logic.game.fight.types.SplashDamage;
   import com.ankamagames.dofus.logic.game.fight.types.StatBuff;
   import com.ankamagames.dofus.logic.game.fight.types.TriggeredSpell;
   import com.ankamagames.dofus.network.enums.CharacterSpellModificationTypeEnum;
   import com.ankamagames.dofus.network.enums.GameActionMarkTypeEnum;
   import com.ankamagames.dofus.network.types.game.character.characteristic.CharacterSpellModification;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCharacterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightEntityInformation;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.types.zones.IZone;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class DamageUtil
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(DamageUtil));
      
      private static const exclusiveTargetMasks:RegExp = /\*?[bBeEfFzZKoOPpTWUvVrR][0-9]*/g;
      
      public static const UNKNOWN_ELEMENT:int = -1;
      
      public static const NEUTRAL_ELEMENT:int = 0;
      
      public static const EARTH_ELEMENT:int = 1;
      
      public static const FIRE_ELEMENT:int = 2;
      
      public static const WATER_ELEMENT:int = 3;
      
      public static const AIR_ELEMENT:int = 4;
      
      public static const BUMP_DAMAGE:int = 5;
      
      public static const EFFECTSHAPE_DEFAULT_AREA_SIZE:int = 1;
      
      public static const EFFECTSHAPE_DEFAULT_MIN_AREA_SIZE:int = 0;
      
      public static const EFFECTSHAPE_DEFAULT_EFFICIENCY:int = 10;
      
      public static const EFFECTSHAPE_DEFAULT_MAX_EFFICIENCY_APPLY:int = 4;
      
      private static const DAMAGE_NOT_BOOSTED:int = 1;
      
      private static const UNLIMITED_ZONE_SIZE:int = 50;
      
      private static const AT_LEAST_MASK_TYPES:Array = ["B","F","Z"];
      
      private static const ZONE_MAX_SIZE:int = 63;
      
      public static const EROSION_DAMAGE_EFFECTS_IDS:Array = [1092,1093,1094,1095,1096];
      
      public static const HEALING_EFFECTS_IDS:Array = [81,108,1109,90];
      
      public static const IMMEDIATE_BOOST_EFFECTS_IDS:Array = [266,268,269,271,414];
      
      public static const BOMB_SPELLS_IDS:Array = [2796,2797,2808,10041];
      
      public static const SPLASH_EFFECTS_IDS:Array = [1123,1124,1125,1126,1127,1128,2020];
      
      public static const SPLASH_HEAL_EFFECT_ID:uint = 2020;
      
      public static const MP_BASED_DAMAGE_EFFECTS_IDS:Array = [1012,1013,1014,1015,1016];
      
      public static const HP_BASED_DAMAGE_EFFECTS_IDS:Array = [672,85,86,87,88,89,90];
      
      public static const ERODED_HP_BASED_DAMAGE_EFFETS_IDS:Array = [1118,1119,1120,1121,1122];
      
      public static const TARGET_HP_BASED_DAMAGE_EFFECTS_IDS:Array = [1067,1068,1069,1070,1071,1048];
      
      public static const TRIGGERED_EFFECTS_IDS:Array = [138,1040];
      
      public static const NO_BOOST_EFFECTS_IDS:Array = [144,82];
      
      public static const LIFE_STEAL_EFFECTS_IDS:Array = [91,92,93,94,95,82];
      
      public static const SHIELD_GAIN_EFFECTS_IDS:Array = [1039,1040];
      
      public static const REFLECT_EFFECTS_IDS:Array = [107,220];
      
      public static const CAST_SPELL_EFFECTS_IDS:Array = [792,793,1160,1017];
      
      public static var fightersStates:Dictionary = new Dictionary();
       
      
      public function DamageUtil()
      {
         super();
      }
      
      public static function isDamagedOrHealedBySpell(pCasterId:Number, pTargetId:Number, pSpell:Object, pSpellImpactCell:int, pCheckTriggeredSpells:Boolean = true, pTriggeringEffects:Vector.<uint> = null) : Boolean
      {
         var effi:* = null;
         var targetBuffs:* = null;
         var spellZone:* = null;
         var spellZoneCells:* = null;
         var cellId:int = 0;
         var targetEntities:* = null;
         var targetEntity:* = null;
         var buff:* = null;
         var triggeredSpellCasterId:Number = NaN;
         var triggeringEffects:* = null;
         var ts:* = null;
         var tsTargetId:Number = NaN;
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!pSpell || !fef)
         {
            return false;
         }
         var targetInfos:GameFightFighterInformations = fef.getEntityInfos(pTargetId) as GameFightFighterInformations;
         if(!targetInfos)
         {
            return false;
         }
         var target:TiphonSprite = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var targetIsCaster:* = pTargetId == pCasterId;
         var targetIsCarried:Boolean = target && target.parentSprite && target.parentSprite.carriedEntity == target;
         var casterInfos:GameFightFighterInformations = fef.getEntityInfos(pCasterId) as GameFightFighterInformations;
         if(!(pSpell is SpellWrapper) || pSpell.id == 0)
         {
            if(!targetIsCaster && !targetIsCarried)
            {
               return true;
            }
            if(!targetIsCarried)
            {
               spellZone = SpellZoneManager.getInstance().getSpellZone(pSpell,false,false,pSpellImpactCell,casterInfos.disposition.cellId);
               spellZone.direction = MapPoint.fromCellId(casterInfos.disposition.cellId).advancedOrientationTo(MapPoint.fromCellId(pSpellImpactCell),false);
               spellZoneCells = spellZone.getCells(pSpellImpactCell);
               for each(cellId in spellZoneCells)
               {
                  if(cellId != casterInfos.disposition.cellId)
                  {
                     targetEntities = EntitiesManager.getInstance().getEntitiesOnCell(cellId,AnimatedCharacter);
                     for each(targetEntity in targetEntities)
                     {
                        if(targetEntity.id != pCasterId && fef.getEntityInfos(targetEntity.id) && isDamagedOrHealedBySpell(pCasterId,targetEntity.id,pSpell,pSpellImpactCell) && getReflectDamageValues(targetEntity.id))
                        {
                           return true;
                        }
                     }
                  }
               }
               return false;
            }
            return false;
         }
         var targetCanBePushed:Boolean = PushUtil.isPushableEntity(targetInfos);
         if(BOMB_SPELLS_IDS.indexOf(pSpell.id) != -1)
         {
            pSpell = getBombDirectDamageSpellWrapper(pSpell as SpellWrapper);
         }
         for each(effi in pSpell.effects)
         {
            if(effi.triggers == "I" && (effi.category == DataEnum.ACTION_TYPE_DAMAGES || HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1 || SHIELD_GAIN_EFFECTS_IDS.indexOf(effi.effectId) != -1 || effi.effectId == 5 && targetCanBePushed) && verifySpellEffectMask(pCasterId,pTargetId,effi,pSpellImpactCell) && (effi.targetMask.indexOf("C") != -1 && targetIsCaster || verifySpellEffectZone(pTargetId,effi,pSpellImpactCell,casterInfos.disposition.cellId)))
            {
               return true;
            }
         }
         for each(effi in pSpell.criticalEffect)
         {
            if(effi.triggers == "I" && (effi.category == DataEnum.ACTION_TYPE_DAMAGES || HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1 || SHIELD_GAIN_EFFECTS_IDS.indexOf(effi.effectId) != -1 || effi.effectId == 5 && targetCanBePushed) && verifySpellEffectMask(pCasterId,pTargetId,effi,pSpellImpactCell) && verifySpellEffectZone(pTargetId,effi,pSpellImpactCell,casterInfos.disposition.cellId))
            {
               return true;
            }
         }
         targetBuffs = BuffManager.getInstance().getAllBuff(pTargetId);
         if(targetBuffs)
         {
            for each(buff in targetBuffs)
            {
               if(buff.effect.category == DataEnum.ACTION_TYPE_DAMAGES)
               {
                  for each(effi in pSpell.effects)
                  {
                     if(verifyEffectTrigger(pCasterId,pTargetId,pSpell.effects,effi,pSpell is SpellWrapper,buff.effect.triggers,pSpellImpactCell))
                     {
                        return true;
                     }
                  }
                  for each(effi in pSpell.criticalEffect)
                  {
                     if(verifyEffectTrigger(pCasterId,pTargetId,pSpell.criticalEffect,effi,pSpell is SpellWrapper,buff.effect.triggers,pSpellImpactCell))
                     {
                        return true;
                     }
                  }
               }
            }
         }
         if(pCheckTriggeredSpells)
         {
            for each(effi in pSpell.effects)
            {
               if(effi.triggers == "I" && (!pTriggeringEffects || pTriggeringEffects.indexOf(effi.effectUid) == -1))
               {
                  triggeredSpellCasterId = NaN;
                  if(effi.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL || effi.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM)
                  {
                     triggeredSpellCasterId = pTargetId;
                  }
                  else if(effi.effectId == ActionIdEnum.ACTION_CASTER_EXECUTE_SPELL)
                  {
                     triggeredSpellCasterId = pCasterId;
                  }
                  if(!isNaN(triggeredSpellCasterId) && verifySpellEffectMask(pCasterId,pTargetId,effi,pSpellImpactCell) && verifySpellEffectZone(pTargetId,effi,pSpellImpactCell,casterInfos.disposition.cellId))
                  {
                     triggeringEffects = !pTriggeringEffects?new Vector.<uint>(0):pTriggeringEffects;
                     triggeringEffects.push(effi.effectUid);
                     ts = TriggeredSpell.create(effi.triggers,int(effi.parameter0),int(effi.parameter1),triggeredSpellCasterId,pTargetId,effi,effi.targetMask.indexOf("C") != -1,pSpell.effects,pCasterId,pSpellImpactCell);
                     for each(tsTargetId in ts.targets)
                     {
                        if(isDamagedOrHealedBySpell(ts.casterId,tsTargetId,ts.spell,ts.targetCell,true,triggeringEffects))
                        {
                           return true;
                        }
                     }
                     if(ts.targets.indexOf(pCasterId) == -1 && ts.spell.canTargetCasterOutOfZone)
                     {
                        return isDamagedOrHealedBySpell(ts.casterId,ts.casterId,ts.spell,fef.getEntityInfos(ts.casterId).disposition.cellId,true,triggeringEffects);
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public static function getBombDirectDamageSpellWrapper(pBombSummoningSpell:SpellWrapper) : SpellWrapper
      {
         return SpellWrapper.create(SpellBomb.getSpellBombById((pBombSummoningSpell.effects[0] as EffectInstanceDice).diceNum).instantSpellId,pBombSummoningSpell.spellLevel,true,pBombSummoningSpell.playerId);
      }
      
      public static function getBuffEffectElements(pBuff:BasicBuff) : Vector.<int>
      {
         var elements:* = null;
         var effi:* = null;
         var spellLevel:* = null;
         var effect:Effect = Effect.getEffectById(pBuff.effect.effectId);
         if(effect.elementId == -1)
         {
            spellLevel = pBuff.castingSpell.spellRank;
            if(!spellLevel)
            {
               spellLevel = SpellLevel.getLevelById(pBuff.castingSpell.spell.spellLevels[0]);
            }
            for each(effi in spellLevel.effects)
            {
               if(effi.effectId == pBuff.effect.effectId)
               {
                  if(!elements)
                  {
                     elements = new Vector.<int>(0);
                  }
                  if(effi.triggers.indexOf("DA") != -1 && elements.indexOf(AIR_ELEMENT) == -1)
                  {
                     elements.push(AIR_ELEMENT);
                  }
                  if(effi.triggers.indexOf("DE") != -1 && elements.indexOf(EARTH_ELEMENT) == -1)
                  {
                     elements.push(EARTH_ELEMENT);
                  }
                  if(effi.triggers.indexOf("DF") != -1 && elements.indexOf(FIRE_ELEMENT) == -1)
                  {
                     elements.push(FIRE_ELEMENT);
                  }
                  if(effi.triggers.indexOf("DN") != -1 && elements.indexOf(NEUTRAL_ELEMENT) == -1)
                  {
                     elements.push(NEUTRAL_ELEMENT);
                  }
                  if(effi.triggers.indexOf("DW") != -1 && elements.indexOf(WATER_ELEMENT) == -1)
                  {
                     elements.push(WATER_ELEMENT);
                     break;
                  }
                  break;
               }
            }
         }
         return elements;
      }
      
      public static function verifyBuffTriggers(pBuff:BasicBuff, pEffects:Vector.<EffectInstance>, pCasterId:Number, pTargetId:Number, pIsWeapon:Boolean, pSpellCenterCell:int, pSplashes:Vector.<SplashDamage>) : uint
      {
         var numTriggeredBuffs:int = 0;
         var triggersList:* = null;
         var trigger:* = null;
         var eff:* = null;
         var splashDmg:* = null;
         var triggers:String = pBuff.effect.triggers;
         if(triggers)
         {
            triggersList = triggers.split("|");
            for each(trigger in triggersList)
            {
               for each(eff in pEffects)
               {
                  if(verifyEffectTrigger(pCasterId,pTargetId,pEffects,eff,pIsWeapon,trigger,pSpellCenterCell))
                  {
                     numTriggeredBuffs++;
                  }
               }
               for each(splashDmg in pSplashes)
               {
                  if(splashDmg.targets.indexOf(pTargetId) != -1 && verifyEffectTrigger(splashDmg.casterId,pTargetId,null,splashDmg.effect,false,trigger,splashDmg.casterCell,pCasterId))
                  {
                     numTriggeredBuffs++;
                  }
               }
            }
         }
         return numTriggeredBuffs;
      }
      
      public static function verifyEffectTrigger(pCasterId:Number, pTargetId:Number, pSpellEffects:Vector.<EffectInstance>, pEffect:EffectInstance, pWeaponEffect:Boolean, pTriggers:String, pSpellImpactCell:int, pTriggeringSpellCasterId:Number = 0) : Boolean
      {
         var trigger:* = null;
         var verify:* = false;
         var damageReceived:Boolean = false;
         var effectMaskVerified:Boolean = false;
         var fightEntitiesFrame:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!fightEntitiesFrame || !pTriggers)
         {
            return true;
         }
         var triggersList:Array = pTriggers.split("|");
         var casterInfos:GameFightFighterInformations = fightEntitiesFrame.getEntityInfos(pCasterId) as GameFightFighterInformations;
         var targetInfos:GameFightFighterInformations = fightEntitiesFrame.getEntityInfos(pTargetId) as GameFightFighterInformations;
         var isTargetAlly:* = targetInfos.teamId == (fightEntitiesFrame.getEntityInfos(pCasterId) as GameFightFighterInformations).teamId;
         var distance:int = targetInfos.disposition.cellId != -1?int(MapPoint.fromCellId(casterInfos.disposition.cellId).distanceTo(MapPoint.fromCellId(targetInfos.disposition.cellId))):-1;
         for each(trigger in triggersList)
         {
            effectMaskVerified = pWeaponEffect || pEffect.spellId == 0 || !pEffect.targetMask || verifySpellEffectMask(pCasterId,pTargetId,pEffect,pSpellImpactCell,pTriggeringSpellCasterId);
            damageReceived = pEffect.category == DataEnum.ACTION_TYPE_DAMAGES && pEffect.effectId != SPLASH_HEAL_EFFECT_ID && effectMaskVerified && (pEffect.targetMask && pEffect.targetMask.indexOf("O") != -1 && pTargetId == pTriggeringSpellCasterId || verifySpellEffectZone(pTargetId,pEffect,pSpellImpactCell,casterInfos.disposition.cellId));
            switch(trigger)
            {
               case "I":
                  verify = true;
                  break;
               case "D":
                  verify = Boolean(damageReceived);
                  break;
               case "DA":
                  verify = Boolean(damageReceived && Effect.getEffectById(pEffect.effectId).elementId == AIR_ELEMENT);
                  break;
               case "DBA":
                  verify = Boolean(damageReceived && isTargetAlly);
                  break;
               case "DBE":
                  verify = Boolean(damageReceived && !isTargetAlly);
                  break;
               case "DC":
                  verify = Boolean(pWeaponEffect);
                  break;
               case "DE":
                  verify = Boolean(damageReceived && Effect.getEffectById(pEffect.effectId).elementId == EARTH_ELEMENT);
                  break;
               case "DF":
                  verify = Boolean(damageReceived && Effect.getEffectById(pEffect.effectId).elementId == FIRE_ELEMENT);
                  break;
               case "DG":
                  break;
               case "DI":
                  break;
               case "DM":
                  verify = Boolean(distance == -1?false:damageReceived && distance <= 1);
                  break;
               case "DN":
                  verify = Boolean(damageReceived && Effect.getEffectById(pEffect.effectId).elementId == NEUTRAL_ELEMENT);
                  break;
               case "DP":
                  break;
               case "DR":
                  verify = Boolean(distance == -1?false:damageReceived && distance > 1);
                  break;
               case "Dr":
                  break;
               case "DS":
                  verify = !pWeaponEffect;
                  break;
               case "DTB":
                  break;
               case "DTE":
                  break;
               case "DW":
                  verify = Boolean(damageReceived && Effect.getEffectById(pEffect.effectId).elementId == WATER_ELEMENT);
                  break;
               case "M":
                  verify = Boolean((pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_PUSH || pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_PULL) && PushUtil.isPushed(targetInfos,pSpellImpactCell,pEffect) || pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_EXCHANGE_PLACES);
                  break;
               case "MD":
                  verify = Boolean(pSpellEffects && PushUtil.hasPushDamages(pCasterId,pTargetId,pSpellEffects,pEffect,pSpellImpactCell));
                  break;
               case "MDM":
                  break;
               case "MDP":
                  break;
               case "ML":
                  verify = Boolean(pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_PULL && PushUtil.isPushed(targetInfos,pSpellImpactCell,pEffect));
                  break;
               case "MP":
                  verify = Boolean(pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_PUSH && PushUtil.isPushed(targetInfos,pSpellImpactCell,pEffect));
                  break;
               case "MS":
                  verify = pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_EXCHANGE_PLACES;
                  break;
               case "A":
                  verify = pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_ACTION_POINTS_LOST;
                  break;
               case "m":
                  verify = pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_MOVEMENT_POINTS_LOST;
                  break;
               case "H":
                  verify = HEALING_EFFECTS_IDS.indexOf(pEffect.effectId) != -1;
            }
            if(verify)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function verifySpellEffectMask(pCasterId:Number, pTargetId:Number, pEffect:EffectInstance, pSpellImpactCell:int, pTriggeringSpellCasterId:Number = 0) : Boolean
      {
         var usingPortals:Boolean = false;
         var mp:* = null;
         var r:* = null;
         var targetMaskPattern:* = null;
         var exclusiveMasks:* = null;
         var exclusiveMask:* = null;
         var exclusiveMaskParam:* = null;
         var exclusiveMaskCasterOnly:Boolean = false;
         var verify:* = false;
         var states:* = null;
         var summonedTargetCanPlay:Boolean = false;
         var maskState:int = 0;
         var multipleMasks:* = null;
         var masksTypes:* = null;
         var maskType:* = null;
         var verifiedMasks:* = null;
         var isMultipleMask:Boolean = false;
         var lastMaskType:* = null;
         var multipleMaskCount:int = 0;
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!fef || !pEffect.targetMask)
         {
            return true;
         }
         if(!pEffect || pEffect.delay > 0)
         {
            return false;
         }
         var target:TiphonSprite = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var targetIsCaster:* = pTargetId == pCasterId;
         var targetIsCarried:Boolean = target && target.parentSprite && target.parentSprite.carriedEntity == target;
         var casterInfos:GameFightFighterInformations = fef.getEntityInfos(pCasterId) as GameFightFighterInformations;
         var targetInfos:GameFightFighterInformations = fef.getEntityInfos(pTargetId) as GameFightFighterInformations;
         var monsterInfo:GameFightMonsterInformations = targetInfos as GameFightMonsterInformations;
         var casterStates:Array = FightersStateManager.getInstance().getStates(pCasterId);
         var targetStates:Array = FightersStateManager.getInstance().getStates(pTargetId);
         var targetContextStates:FighterStates = DamageUtil.fightersStates[pTargetId];
         if(targetContextStates)
         {
            states = targetContextStates.getStates(pEffect.spellId);
            if(states)
            {
               targetStates = !!targetStates?targetStates.concat(states):states;
            }
         }
         var isTargetAlly:* = targetInfos.teamId == (fef.getEntityInfos(pCasterId) as GameFightFighterInformations).teamId;
         var mpWithPortals:Vector.<MapPoint> = MarkedCellsManager.getInstance().getMarksMapPoint(GameActionMarkTypeEnum.PORTAL);
         for each(mp in mpWithPortals)
         {
            if(mp.cellId == FightContextFrame.currentCell)
            {
               usingPortals = true;
               break;
            }
         }
         targetMaskPattern = "";
         if(targetIsCaster)
         {
            if(pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT)
            {
               return true;
            }
            if(pEffect.targetMask.indexOf("g") == -1)
            {
               if(pEffect.effectId == ActionIdEnum.ACTION_CHARACTER_GET_PUSHED || verifySpellEffectZone(pCasterId,pEffect,pSpellImpactCell,targetInfos.disposition.cellId))
               {
                  targetMaskPattern = "caC";
               }
               else
               {
                  targetMaskPattern = "C";
               }
            }
            else
            {
               return false;
            }
         }
         else
         {
            if(targetIsCarried && pEffect.zoneShape != SpellShapeEnum.A && pEffect.zoneShape != SpellShapeEnum.a)
            {
               return false;
            }
            if(targetInfos.stats.summoned && monsterInfo && !Monster.getMonsterById(monsterInfo.creatureGenericId).canPlay)
            {
               targetMaskPattern = !!isTargetAlly?"sj":"SJ";
            }
            else if(targetInfos.stats.summoned)
            {
               targetMaskPattern = !!isTargetAlly?"ij":"IJ";
               summonedTargetCanPlay = true;
            }
            else if(targetInfos is GameFightEntityInformation)
            {
               targetMaskPattern = !!isTargetAlly?"dl":"DL";
            }
            if(monsterInfo)
            {
               targetMaskPattern = targetMaskPattern + (!!isTargetAlly?"ag":"A");
               if(!summonedTargetCanPlay)
               {
                  targetMaskPattern = targetMaskPattern + (!!isTargetAlly?"m":"M");
               }
            }
            else
            {
               targetMaskPattern = targetMaskPattern + (!!isTargetAlly?"aghl":"AHL");
            }
         }
         r = new RegExp("[" + targetMaskPattern + "]","g");
         verify = pEffect.targetMask.match(r).length > 0;
         if(verify)
         {
            exclusiveMasks = pEffect.targetMask.match(exclusiveTargetMasks);
            if(exclusiveMasks.length > 0)
            {
               verify = false;
               multipleMasks = new Dictionary();
               masksTypes = new Vector.<String>(0);
               for each(exclusiveMask in exclusiveMasks)
               {
                  maskType = exclusiveMask.charAt(0);
                  if(maskType == "*")
                  {
                     maskType = exclusiveMask.substr(0,2);
                  }
                  if(AT_LEAST_MASK_TYPES.indexOf(maskType) != -1)
                  {
                     if(masksTypes.indexOf(maskType) != -1)
                     {
                        if(!multipleMasks[maskType])
                        {
                           multipleMasks[maskType] = 2;
                        }
                        else
                        {
                           multipleMasks[maskType]++;
                        }
                     }
                     else
                     {
                        masksTypes.push(maskType);
                     }
                  }
               }
               verifiedMasks = new Vector.<String>(0);
               for each(exclusiveMask in exclusiveMasks)
               {
                  exclusiveMaskCasterOnly = exclusiveMask.charAt(0) == "*" || pEffect.targetMask.charAt(0) == "C";
                  exclusiveMask = exclusiveMask.charAt(0) == "*"?exclusiveMask.substr(1,exclusiveMask.length - 1):exclusiveMask;
                  exclusiveMaskParam = exclusiveMask.length > 1?exclusiveMask.substr(1,exclusiveMask.length - 1):null;
                  exclusiveMask = exclusiveMask.charAt(0);
                  switch(exclusiveMask)
                  {
                     case "b":
                        break;
                     case "B":
                        break;
                     case "e":
                        maskState = parseInt(exclusiveMaskParam);
                        if(exclusiveMaskCasterOnly)
                        {
                           verify = Boolean(!casterStates || casterStates.indexOf(maskState) == -1);
                           break;
                        }
                        verify = Boolean(!targetStates || targetStates.indexOf(maskState) == -1);
                        break;
                     case "E":
                        maskState = parseInt(exclusiveMaskParam);
                        if(exclusiveMaskCasterOnly)
                        {
                           verify = Boolean(casterStates && casterStates.indexOf(maskState) != -1);
                           break;
                        }
                        verify = Boolean(targetStates && targetStates.indexOf(maskState) != -1);
                        break;
                     case "f":
                        verify = Boolean(!monsterInfo || monsterInfo.creatureGenericId != parseInt(exclusiveMaskParam));
                        break;
                     case "F":
                        verify = Boolean(monsterInfo && monsterInfo.creatureGenericId == parseInt(exclusiveMaskParam));
                        break;
                     case "z":
                        break;
                     case "Z":
                        break;
                     case "K":
                        break;
                     case "o":
                        verify = Boolean(pTriggeringSpellCasterId != 0 && pTargetId == pTriggeringSpellCasterId && verifySpellEffectZone(pTriggeringSpellCasterId,pEffect,pSpellImpactCell,casterInfos.disposition.cellId));
                        break;
                     case "O":
                        verify = Boolean(pTriggeringSpellCasterId != 0 && pTargetId == pTriggeringSpellCasterId);
                        break;
                     case "p":
                        break;
                     case "P":
                        verify = Boolean(targetInfos.stats.summoned && targetInfos.stats.summoner == pCasterId);
                        break;
                     case "T":
                        break;
                     case "W":
                        break;
                     case "U":
                        break;
                     case "v":
                        if(exclusiveMaskCasterOnly)
                        {
                           verify = casterInfos.stats.lifePoints / casterInfos.stats.maxLifePoints * 100 > parseInt(exclusiveMaskParam);
                           break;
                        }
                        verify = targetInfos.stats.lifePoints / targetInfos.stats.maxLifePoints * 100 > parseInt(exclusiveMaskParam);
                        break;
                     case "V":
                        if(exclusiveMaskCasterOnly)
                        {
                           verify = casterInfos.stats.lifePoints / casterInfos.stats.maxLifePoints * 100 <= parseInt(exclusiveMaskParam);
                           break;
                        }
                        verify = targetInfos.stats.lifePoints / targetInfos.stats.maxLifePoints * 100 <= parseInt(exclusiveMaskParam);
                        break;
                     case "r":
                        verify = !usingPortals;
                        break;
                     case "R":
                        verify = Boolean(usingPortals);
                  }
                  maskType = !!exclusiveMaskCasterOnly?"*" + exclusiveMask:exclusiveMask;
                  isMultipleMask = multipleMasks[maskType];
                  if(!lastMaskType || maskType == lastMaskType)
                  {
                     multipleMaskCount++;
                  }
                  else
                  {
                     multipleMaskCount = 0;
                  }
                  lastMaskType = maskType;
                  if(verify && isMultipleMask && verifiedMasks.indexOf(maskType) == -1)
                  {
                     verifiedMasks.push(maskType);
                  }
                  if(!verify)
                  {
                     if(!isMultipleMask)
                     {
                        return false;
                     }
                     if(verifiedMasks.indexOf(maskType) != -1)
                     {
                        verify = true;
                     }
                     else if(multipleMasks[maskType] == multipleMaskCount)
                     {
                        return false;
                     }
                  }
               }
            }
         }
         return verify;
      }
      
      public static function verifySpellEffectZone(pTargetId:Number, pEffect:EffectInstance, pSpellImpactCell:int, pCasterCell:int) : Boolean
      {
         var verify:Boolean = false;
         var effectZone:* = null;
         var minSize:* = 0;
         var minSizeCells:* = null;
         var minSizeZone:* = null;
         var effectZoneCells:* = null;
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!fef || pSpellImpactCell == -1)
         {
            return false;
         }
         var targetInfos:GameFightFighterInformations = fef.getEntityInfos(pTargetId) as GameFightFighterInformations;
         switch(pEffect.zoneShape)
         {
            case SpellShapeEnum.A:
               verify = true;
               break;
            case SpellShapeEnum.a:
               verify = targetInfos.alive;
               break;
            default:
               effectZone = SpellZoneManager.getInstance().getZone(pEffect.zoneShape,uint(pEffect.zoneSize),uint(pEffect.zoneMinSize),false,uint(pEffect.zoneStopAtTarget));
               if(effectZone.radius == 63)
               {
                  minSize = uint(pEffect.zoneShape == SpellShapeEnum.I?uint(pEffect.zoneSize as uint):uint(pEffect.zoneMinSize as uint));
                  if(minSize)
                  {
                     minSizeZone = SpellZoneManager.getInstance().getZone(SpellShapeEnum.C,minSize,0);
                     minSizeCells = minSizeZone.getCells(pSpellImpactCell);
                  }
                  return !minSizeCells || minSizeCells.indexOf(targetInfos.disposition.cellId) == -1?true:false;
               }
               if(pEffect.targetMask && pEffect.targetMask.indexOf("E263") != -1)
               {
                  verify = true;
                  break;
               }
               effectZone.direction = MapPoint(MapPoint.fromCellId(pCasterCell)).advancedOrientationTo(MapPoint.fromCellId(pSpellImpactCell),false);
               effectZoneCells = effectZone.getCells(pSpellImpactCell);
               if(targetInfos.disposition.cellId != -1)
               {
                  verify = !!effectZoneCells?effectZoneCells.indexOf(targetInfos.disposition.cellId) != -1:false;
                  break;
               }
               break;
         }
         return verify;
      }
      
      public static function getSpellElementDamage(pSpell:Object, pElementType:int, pCasterId:Number, pTargetId:Number, pSpellImpactCell:int, pCasterCell:int) : SpellDamage
      {
         var ed:* = null;
         var effi:* = null;
         var effid:* = null;
         var i:int = 0;
         var j:int = 0;
         var sd:SpellDamage = new SpellDamage();
         var numEffects:int = pSpell.effects.length;
         var isWeapon:Boolean = !(pSpell is SpellWrapper) || pSpell.id == 0;
         for(i = 0; i < numEffects; )
         {
            effi = pSpell.effects[i];
            if(effi.category == DataEnum.ACTION_TYPE_DAMAGES && (isWeapon || effi.triggers == "I") && HEALING_EFFECTS_IDS.indexOf(effi.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) == -1 && HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) == -1 && Effect.getEffectById(effi.effectId).elementId == pElementType && (!effi.targetMask || isWeapon || effi.targetMask && DamageUtil.verifySpellEffectMask(pCasterId,pTargetId,effi,pSpellImpactCell)) && DamageUtil.verifySpellEffectZone(pTargetId,effi,pSpellImpactCell,pCasterCell))
            {
               ed = EffectDamage.fromEffectInstance(effi);
               ed.spellEffectOrder = i;
               sd.addEffectDamage(ed);
               if(EROSION_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) != -1)
               {
                  effid = effi as EffectInstanceDice;
                  ed.minErosionPercent = ed.maxErosionPercent = effid.diceNum;
               }
               else if(!(effi is EffectInstanceDice))
               {
                  if(effi is EffectInstanceInteger)
                  {
                     ed.minDamage = ed.minDamage + (effi as EffectInstanceInteger).value;
                     ed.maxDamage = ed.maxDamage + (effi as EffectInstanceInteger).value;
                  }
                  else if(effi is EffectInstanceMinMax)
                  {
                     ed.minDamage = ed.minDamage + (effi as EffectInstanceMinMax).min;
                     ed.maxDamage = ed.maxDamage + (effi as EffectInstanceMinMax).max;
                  }
               }
               else
               {
                  effid = effi as EffectInstanceDice;
                  ed.minDamage = ed.minDamage + effid.diceNum;
                  ed.maxDamage = ed.maxDamage + (effid.diceSide == 0?effid.diceNum:effid.diceSide);
               }
            }
            i++;
         }
         var numEffectDamages:int = sd.effectDamages.length;
         var numCriticalEffects:int = !!pSpell.criticalEffect?int(pSpell.criticalEffect.length):0;
         if(numCriticalEffects == 0)
         {
            for each(ed in sd.effectDamages)
            {
               ed.minCriticalDamage = ed.minDamage;
               ed.maxCriticalDamage = ed.maxDamage;
               ed.minCriticalErosionPercent = ed.minErosionPercent;
               ed.maxCriticalErosionPercent = ed.maxErosionPercent;
            }
         }
         for(i = 0; i < numCriticalEffects; )
         {
            effi = pSpell.criticalEffect[i];
            if(effi.category == DataEnum.ACTION_TYPE_DAMAGES && (isWeapon || effi.triggers == "I") && HEALING_EFFECTS_IDS.indexOf(effi.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) == -1 && HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) == -1 && Effect.getEffectById(effi.effectId).elementId == pElementType && (!effi.targetMask || isWeapon || effi.targetMask && DamageUtil.verifySpellEffectMask(pCasterId,pTargetId,effi,pSpellImpactCell)) && DamageUtil.verifySpellEffectZone(pTargetId,effi,pSpellImpactCell,pCasterCell))
            {
               if(j < numEffectDamages)
               {
                  ed = sd.effectDamages[j];
               }
               else
               {
                  ed = EffectDamage.fromEffectInstance(effi);
                  ed.spellEffectOrder = i;
                  sd.addEffectDamage(ed);
               }
               if(EROSION_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) != -1)
               {
                  effid = effi as EffectInstanceDice;
                  ed.minCriticalErosionPercent = ed.maxCriticalErosionPercent = effid.diceNum;
               }
               else if(!(effi is EffectInstanceDice))
               {
                  if(effi is EffectInstanceInteger)
                  {
                     ed.minCriticalDamage = ed.minCriticalDamage + (effi as EffectInstanceInteger).value;
                     ed.maxCriticalDamage = ed.maxCriticalDamage + (effi as EffectInstanceInteger).value;
                  }
                  else if(effi is EffectInstanceMinMax)
                  {
                     ed.minCriticalDamage = ed.minCriticalDamage + (effi as EffectInstanceMinMax).min;
                     ed.maxCriticalDamage = ed.maxCriticalDamage + (effi as EffectInstanceMinMax).max;
                  }
               }
               else
               {
                  effid = effi as EffectInstanceDice;
                  ed.minCriticalDamage = ed.minCriticalDamage + effid.diceNum;
                  ed.maxCriticalDamage = ed.maxCriticalDamage + (effid.diceSide == 0?effid.diceNum:effid.diceSide);
               }
               sd.hasCriticalDamage = ed.hasCritical = true;
               j++;
            }
            i++;
         }
         return sd;
      }
      
      public static function getHealEffectDamage(pSpellDamageInfo:SpellDamageInfo) : EffectDamage
      {
         var computedHealEffect:* = null;
         var minCriticalLifePointsAdded:int = 0;
         var maxCriticalLifePointsAdded:int = 0;
         var ed:* = null;
         var casterIntelligence:int = pSpellDamageInfo.casterIntelligence <= 0?1:int(pSpellDamageInfo.casterIntelligence + (!!pSpellDamageInfo.isWeapon?pSpellDamageInfo.casterWeaponDamagesBonus:0));
         var healEffect:EffectDamage = new EffectDamage();
         for each(ed in pSpellDamageInfo.heal.effectDamages)
         {
            computedHealEffect = new EffectDamage(ed.effectId,-1,-1,ed.duration);
            computedHealEffect.spellEffectOrder = ed.spellEffectOrder;
            computedHealEffect.minLifePointsAdded = getHeal(ed.minLifePointsAdded,casterIntelligence,pSpellDamageInfo.casterHealBonus);
            computedHealEffect.maxLifePointsAdded = getHeal(ed.maxLifePointsAdded,casterIntelligence,pSpellDamageInfo.casterHealBonus);
            if(pSpellDamageInfo.isWeapon)
            {
               minCriticalLifePointsAdded = ed.minLifePointsAdded > 0?int(ed.minLifePointsAdded + pSpellDamageInfo.spellWeaponCriticalBonus):0;
               maxCriticalLifePointsAdded = ed.maxLifePointsAdded > 0?int(ed.maxLifePointsAdded + pSpellDamageInfo.spellWeaponCriticalBonus):0;
               if(minCriticalLifePointsAdded > 0 || maxCriticalLifePointsAdded > 0)
               {
                  pSpellDamageInfo.spellHasCriticalHeal = true;
               }
            }
            else
            {
               minCriticalLifePointsAdded = pSpellDamageInfo.heal.minCriticalLifePointsAdded;
               maxCriticalLifePointsAdded = pSpellDamageInfo.heal.maxCriticalLifePointsAdded;
            }
            computedHealEffect.minCriticalLifePointsAdded = getHeal(minCriticalLifePointsAdded,casterIntelligence,pSpellDamageInfo.casterHealBonus);
            computedHealEffect.maxCriticalLifePointsAdded = getHeal(maxCriticalLifePointsAdded,casterIntelligence,pSpellDamageInfo.casterHealBonus);
            healEffect.minLifePointsAdded = healEffect.minLifePointsAdded + computedHealEffect.minLifePointsAdded;
            healEffect.maxLifePointsAdded = healEffect.maxLifePointsAdded + computedHealEffect.maxLifePointsAdded;
            healEffect.minCriticalLifePointsAdded = healEffect.minCriticalLifePointsAdded + computedHealEffect.minCriticalLifePointsAdded;
            healEffect.maxCriticalLifePointsAdded = healEffect.maxCriticalLifePointsAdded + computedHealEffect.maxCriticalLifePointsAdded;
            computedHealEffect.lifePointsAddedBasedOnLifePercent = ed.lifePointsAddedBasedOnLifePercent;
            computedHealEffect.criticalLifePointsAddedBasedOnLifePercent = ed.criticalLifePointsAddedBasedOnLifePercent > 0?int(ed.criticalLifePointsAddedBasedOnLifePercent):int(ed.lifePointsAddedBasedOnLifePercent);
            healEffect.lifePointsAddedBasedOnLifePercent = healEffect.lifePointsAddedBasedOnLifePercent + computedHealEffect.lifePointsAddedBasedOnLifePercent;
            healEffect.criticalLifePointsAddedBasedOnLifePercent = healEffect.criticalLifePointsAddedBasedOnLifePercent + computedHealEffect.criticalLifePointsAddedBasedOnLifePercent;
            healEffect.computedEffects.push(computedHealEffect);
         }
         return healEffect;
      }
      
      public static function applySpellModificationsOnEffect(pEffectDamage:EffectDamage, pSpellW:SpellWrapper) : void
      {
         if(!pSpellW)
         {
            return;
         }
         var baseDamageModif:CharacterSpellModification = CurrentPlayedFighterManager.getInstance().getSpellModifications(pSpellW.id,CharacterSpellModificationTypeEnum.BASE_DAMAGE);
         if(baseDamageModif)
         {
            pEffectDamage.minDamage = pEffectDamage.minDamage + (pEffectDamage.minDamage > 0?baseDamageModif.value.contextModif:0);
            pEffectDamage.maxDamage = pEffectDamage.maxDamage + (pEffectDamage.maxDamage > 0?baseDamageModif.value.contextModif:0);
            if(pEffectDamage.hasCritical)
            {
               pEffectDamage.minCriticalDamage = pEffectDamage.minCriticalDamage + (pEffectDamage.minCriticalDamage > 0?baseDamageModif.value.contextModif:0);
               pEffectDamage.maxCriticalDamage = pEffectDamage.maxCriticalDamage + (pEffectDamage.maxCriticalDamage > 0?baseDamageModif.value.contextModif:0);
            }
         }
      }
      
      public static function getReflectDamageValues(pTargetId:Number) : ReflectValues
      {
         var reflectValues:* = null;
         var targetReflectValue:* = 0;
         var targetBoostedReflectValue:* = 0;
         var buff:* = null;
         var targetInfos:* = null;
         var monster:* = null;
         var monsterGrade:* = null;
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         if(!fightContextFrame)
         {
            return null;
         }
         var targetBuffs:Array = BuffManager.getInstance().getAllBuff(pTargetId);
         for each(buff in targetBuffs)
         {
            if(REFLECT_EFFECTS_IDS.indexOf(buff.actionId) != -1)
            {
               if(buff.actionId == ActionIdEnum.ACTION_CHARACTER_REFLECTOR_UNBOOSTED)
               {
                  targetReflectValue = uint(targetReflectValue + (buff.effect as EffectInstanceInteger).value);
               }
               else if(buff.actionId == ActionIdEnum.ACTION_CHARACTER_LIFE_LOST_REFLECTOR)
               {
                  targetBoostedReflectValue = uint(targetBoostedReflectValue + (buff.effect as EffectInstanceInteger).value);
               }
            }
         }
         targetInfos = fightContextFrame.entitiesFrame.getEntityInfos(pTargetId) as GameFightFighterInformations;
         if(targetInfos is GameFightMonsterInformations)
         {
            monster = Monster.getMonsterById((targetInfos as GameFightMonsterInformations).creatureGenericId);
            for each(monsterGrade in monster.grades)
            {
               if(monsterGrade.grade == (targetInfos as GameFightMonsterInformations).creatureGrade)
               {
                  targetReflectValue = uint(targetReflectValue + monsterGrade.damageReflect);
                  break;
               }
            }
         }
         else if(targetInfos is GameFightCharacterInformations)
         {
            targetReflectValue = uint(targetReflectValue + targetInfos.stats.fixedDamageReflection);
         }
         if(targetReflectValue > 0 || targetBoostedReflectValue > 0)
         {
            reflectValues = new ReflectValues(targetReflectValue,targetBoostedReflectValue);
         }
         return reflectValues;
      }
      
      public static function getSpellDamage(pSpellDamageInfo:SpellDamageInfo, pWithTargetBuffs:Boolean = true, pWithTargetResists:Boolean = true, pWithTargetPercentResists:Boolean = true) : SpellDamage
      {
         var ed:EffectDamage = null;
         var buff:BasicBuff = null;
         var buffDamageMultiplier:Number = NaN;
         var efficiencyMultiplier:Number = NaN;
         var splashEffectDamages:Vector.<EffectDamage> = null;
         var spellShape:uint = 0;
         var spellShapeSize:Object = null;
         var spellShapeMinSize:Object = null;
         var spellShapeEfficiencyPercent:Object = null;
         var spellShapeMaxEfficiency:Object = null;
         var shapeSize:int = 0;
         var emptyDamage:EffectDamage = null;
         var finalNeutralDmg:EffectDamage = null;
         var finalEarthDmg:EffectDamage = null;
         var finalWaterDmg:EffectDamage = null;
         var finalAirDmg:EffectDamage = null;
         var finalFireDmg:EffectDamage = null;
         var finalInterceptedDmg:EffectDamage = null;
         var erosion:EffectDamage = null;
         var targetHpBasedBuffDamages:Vector.<SpellDamage> = null;
         var hasInterceptedDamage:Boolean = false;
         var dmgMultiplier:Number = NaN;
         var finalTargetHpBasedDamages:Vector.<EffectDamage> = null;
         var splashHealDmg:EffectDamage = null;
         var forceIsHealingSpell:Boolean = false;
         var forceIsHealingSpellValue:Boolean = false;
         var meleeFinalMultiplier:Number = NaN;
         var rangeFinalMultiplier:Number = NaN;
         var weaponFinalMultiplier:Number = NaN;
         var spellFinalMultiplier:Number = NaN;
         var finalDamageMultiplier:Number = NaN;
         var permanentMinDamage:int = 0;
         var permanentMaxDamage:int = 0;
         var permanentMinCriticalDamage:int = 0;
         var permanentMaxCriticalDamage:int = 0;
         var computedEffect:EffectDamage = null;
         var sd:SpellDamage = null;
         var effi:EffectInstance = null;
         var pushDamage:EffectDamage = null;
         var pushedEntity:PushedEntity = null;
         var pushIndex:uint = 0;
         var pushDmg:int = 0;
         var criticalPushDmg:int = 0;
         var pushedEntityDamage:int = 0;
         var pushedEntityCriticalDamage:int = 0;
         var pushOriginCell:MapPoint = null;
         var targetCell:MapPoint = null;
         var direction:int = 0;
         var finalForce:int = 0;
         var buffDamage:EffectDamage = null;
         var buffEffectDamage:EffectDamage = null;
         var buffSpellDamage:SpellDamage = null;
         var effid:EffectInstanceDice = null;
         var buffEffectMinDamage:int = 0;
         var buffEffectMaxDamage:int = 0;
         var buffEffectDispelled:Boolean = false;
         var buffHealMultiplier:Number = NaN;
         var numTriggeredBuffs:uint = 0;
         var i:int = 0;
         var splashEffectDmg:EffectDamage = null;
         var interceptedDmg:InterceptedDamage = null;
         var isTargetHpBasedDamage:Boolean = false;
         var buffSpellEffectDmg:EffectDamage = null;
         var reflectDmg:ReflectDamage = null;
         var reflectDmgEffect:EffectDamage = null;
         var tmpEffect:EffectDamage = null;
         var sourceDmgWithoutPercentResists:SpellDamage = null;
         var finalElementDmgWithoutPercentResists:EffectDamage = null;
         var currentTargetId:Number = NaN;
         var minimizeEffects:Boolean = false;
         var maximizeEffects:Boolean = false;
         var reflectSpellDmg:SpellDamage = null;
         var reflectOrder:int = 0;
         var reflectValue:int = 0;
         var lifeStealHasRandom:Boolean = false;
         var targetId:Number = NaN;
         var spellDamages:Object = null;
         var spellDamage:Object = null;
         var lifeStealEffect:EffectDamage = null;
         var targetLifePoints:int = 0;
         var fightContextFrame:FightContextFrame = null;
         var hasDamageDistance:Boolean = false;
         var invulnerableToRange:Boolean = false;
         var invulnerableToMelee:Boolean = false;
         var minShieldDiff:int = 0;
         var maxShieldDiff:int = 0;
         var minCriticalShieldDiff:int = 0;
         var maxCriticalShieldDiff:int = 0;
         var intercepted:InterceptedDamage = null;
         var interceptedEffect:EffectDamage = null;
         if(pWithTargetBuffs && pSpellDamageInfo.sharedDamage && pSpellDamageInfo.damageSharingTargets.indexOf(pSpellDamageInfo.targetId) != -1)
         {
            sd = new SpellDamage();
            for each(ed in pSpellDamageInfo.sharedDamage.effectDamages)
            {
               sd.addEffectDamage(ed.clone());
            }
            sd.hasCriticalDamage = pSpellDamageInfo.spellHasCriticalDamage;
            sd.criticalHitRate = pSpellDamageInfo.criticalHitRate;
            sd.minimizedEffects = pSpellDamageInfo.minimizedEffects;
            sd.maximizedEffects = pSpellDamageInfo.maximizedEffects;
            buffDamageMultiplier = 1;
            for each(buff in pSpellDamageInfo.targetBuffs)
            {
               if(buff.actionId == ActionIdEnum.ACTION_CHARACTER_MULTIPLY_RECEIVED_DAMAGE)
               {
                  buffDamageMultiplier = buffDamageMultiplier * (buff.param1 / 100);
               }
            }
            for each(ed in sd.effectDamages)
            {
               ed.applyDamageMultiplier(buffDamageMultiplier);
            }
            sd.updateDamage();
            sd.invulnerableState = pSpellDamageInfo.targetIsInvulnerable;
            sd.hasCriticalDamage = pSpellDamageInfo.spellHasCriticalDamage;
            return sd;
         }
         var finalDamage:SpellDamage = new SpellDamage();
         splashEffectDamages = new Vector.<EffectDamage>();
         var splashHealEffectDamages:Vector.<EffectDamage> = new Vector.<EffectDamage>();
         pSpellDamageInfo.targetSpellMinErosionLifePoints = 0;
         pSpellDamageInfo.targetSpellMaxErosionLifePoints = 0;
         pSpellDamageInfo.targetSpellMinCriticalErosionLifePoints = 0;
         pSpellDamageInfo.targetSpellMaxCriticalErosionLifePoints = 0;
         addSplashDamages(finalDamage,pSpellDamageInfo.splashDamages,pSpellDamageInfo,pSpellDamageInfo.casterLifePoints,false,splashEffectDamages,splashHealEffectDamages);
         addSplashDamages(finalDamage,pSpellDamageInfo.criticalSplashDamages,pSpellDamageInfo,pSpellDamageInfo.casterLifePoints,true,splashEffectDamages,splashHealEffectDamages);
         if(pSpellDamageInfo.isWeapon)
         {
            spellShapeEfficiencyPercent = pSpellDamageInfo.weaponShapeEfficiencyPercent;
         }
         else
         {
            for each(effi in pSpellDamageInfo.spellEffects)
            {
               if((effi.category == DataEnum.ACTION_TYPE_DAMAGES || DamageUtil.HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1) && DamageUtil.verifySpellEffectMask(pSpellDamageInfo.casterId,pSpellDamageInfo.targetId,effi,pSpellDamageInfo.spellCenterCell) && DamageUtil.verifySpellEffectZone(pSpellDamageInfo.targetId,effi,pSpellDamageInfo.spellCenterCell,pSpellDamageInfo.casterPosition))
               {
                  if(effi.rawZone)
                  {
                     spellShape = effi.rawZone.charCodeAt(0);
                     spellShapeSize = effi.zoneSize;
                     spellShapeMinSize = effi.zoneMinSize;
                     spellShapeEfficiencyPercent = effi.zoneEfficiencyPercent;
                     spellShapeMaxEfficiency = effi.zoneMaxEfficiency;
                     break;
                  }
               }
            }
         }
         shapeSize = spellShapeSize != null?int(int(spellShapeSize)):int(EFFECTSHAPE_DEFAULT_AREA_SIZE);
         var shapeMinSize:int = spellShapeMinSize != null?int(int(spellShapeMinSize)):int(EFFECTSHAPE_DEFAULT_MIN_AREA_SIZE);
         var shapeEfficiencyPercent:int = spellShapeEfficiencyPercent != null?int(int(spellShapeEfficiencyPercent)):int(EFFECTSHAPE_DEFAULT_EFFICIENCY);
         var shapeMaxEfficiency:int = spellShapeMaxEfficiency != null?int(int(spellShapeMaxEfficiency)):int(EFFECTSHAPE_DEFAULT_MAX_EFFICIENCY_APPLY);
         if(shapeEfficiencyPercent == 0 || shapeMaxEfficiency == 0)
         {
            efficiencyMultiplier = DAMAGE_NOT_BOOSTED;
         }
         else
         {
            efficiencyMultiplier = getShapeEfficiency(spellShape,pSpellDamageInfo.spellCenterCell,pSpellDamageInfo.targetCell,shapeSize,shapeMinSize,shapeEfficiencyPercent,shapeMaxEfficiency);
         }
         if(!pSpellDamageInfo.triggeredSpell)
         {
            efficiencyMultiplier = efficiencyMultiplier * pSpellDamageInfo.portalsSpellEfficiencyBonus;
         }
         finalDamage.efficiencyMultiplier = efficiencyMultiplier;
         if(!pSpellDamageInfo.triggeredSpell && SpellDamagesManager.getInstance().getSpellDamageBySpellId(pSpellDamageInfo.targetId,pSpellDamageInfo.spell.id))
         {
            emptyDamage = new EffectDamage();
         }
         finalNeutralDmg = !!emptyDamage?emptyDamage:computeDamage(pSpellDamageInfo.neutralDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalEarthDmg = !!emptyDamage?emptyDamage:computeDamage(pSpellDamageInfo.earthDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalWaterDmg = !!emptyDamage?emptyDamage:computeDamage(pSpellDamageInfo.waterDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalAirDmg = !!emptyDamage?emptyDamage:computeDamage(pSpellDamageInfo.airDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalFireDmg = !!emptyDamage?emptyDamage:computeDamage(pSpellDamageInfo.fireDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         var finalHpBasedDmg:EffectDamage = !!emptyDamage?emptyDamage:computeDamage(pSpellDamageInfo.hpBasedDamage,pSpellDamageInfo,1,true,true,!pWithTargetPercentResists);
         if(pSpellDamageInfo.interceptedDamage && pSpellDamageInfo.interceptedDamage.targetId == pSpellDamageInfo.targetId)
         {
            finalInterceptedDmg = computeDamage(pSpellDamageInfo.interceptedDamage,pSpellDamageInfo,1,true,true,true,true,true,true);
         }
         pSpellDamageInfo.casterLifePointsAfterNormalMinDamage = 0;
         pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage = 0;
         pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage = 0;
         pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage = 0;
         var totalMinErosionDamage:int = finalNeutralDmg.minErosionDamage + finalEarthDmg.minErosionDamage + finalWaterDmg.minErosionDamage + finalAirDmg.minErosionDamage + finalFireDmg.minErosionDamage;
         var totalMaxErosionDamage:int = finalNeutralDmg.maxErosionDamage + finalEarthDmg.maxErosionDamage + finalWaterDmg.maxErosionDamage + finalAirDmg.maxErosionDamage + finalFireDmg.maxErosionDamage;
         var totalMinCriticaErosionDamage:int = finalNeutralDmg.minCriticalErosionDamage + finalEarthDmg.minCriticalErosionDamage + finalWaterDmg.minCriticalErosionDamage + finalAirDmg.minCriticalErosionDamage + finalFireDmg.minCriticalErosionDamage;
         var totalMaxCriticaErosionlDamage:int = finalNeutralDmg.maxCriticalErosionDamage + finalEarthDmg.maxCriticalErosionDamage + finalWaterDmg.maxCriticalErosionDamage + finalAirDmg.maxCriticalErosionDamage + finalFireDmg.maxCriticalErosionDamage;
         var finalHeal:EffectDamage = new EffectDamage();
         if(pSpellDamageInfo.originalTargetsIds.indexOf(pSpellDamageInfo.targetId) != -1 || pSpellDamageInfo.casterId == pSpellDamageInfo.targetId && pSpellDamageInfo.casterAffectedOutOfZone)
         {
            finalHeal = getHealEffectDamage(pSpellDamageInfo);
         }
         finalDamage.hasHeal = finalHeal.minLifePointsAdded > 0 || finalHeal.maxLifePointsAdded > 0 || finalHeal.minCriticalLifePointsAdded > 0 || finalHeal.maxCriticalLifePointsAdded > 0 || finalHeal.lifePointsAddedBasedOnLifePercent > 0 || finalHeal.criticalLifePointsAddedBasedOnLifePercent > 0 || splashHealEffectDamages.length > 0;
         erosion = new EffectDamage();
         erosion.minDamage = totalMinErosionDamage;
         erosion.maxDamage = totalMaxErosionDamage;
         erosion.minCriticalDamage = totalMinCriticaErosionDamage;
         erosion.maxCriticalDamage = totalMaxCriticaErosionlDamage;
         if(pSpellDamageInfo.pushedEntities && pSpellDamageInfo.pushedEntities.length > 0)
         {
            for each(pushedEntity in pSpellDamageInfo.pushedEntities)
            {
               if(pushedEntity.id == pSpellDamageInfo.targetId)
               {
                  pushDamage = new EffectDamage(BUMP_DAMAGE);
                  pushDamage.damageDistance = pushedEntity.pushedDistance;
                  pushedEntityDamage = pushedEntityCriticalDamage = 0;
                  for each(pushIndex in pushedEntity.pushedIndexes)
                  {
                     pushOriginCell = !hasMinSize(pushedEntity.pushEffect.zoneShape) && pushedEntity.pushEffect.effectId != ActionIdEnum.ACTION_CHARACTER_GET_PUSHED?EntitiesManager.getInstance().getEntity(pSpellDamageInfo.casterId).position:MapPoint.fromCellId(pSpellDamageInfo.spellCenterCell);
                     targetCell = EntitiesManager.getInstance().getEntity(pushedEntity.id).position;
                     direction = pushOriginCell.advancedOrientationTo(targetCell,false);
                     finalForce = (direction & 1) == 0?int(pushedEntity.force * 2):int(pushedEntity.force);
                     pushDmg = (pSpellDamageInfo.casterLevel / 2 + (pSpellDamageInfo.casterPushDamageBonus - pSpellDamageInfo.targetPushDamageFixedResist) + 32) * finalForce / (4 * Math.pow(2,pushIndex));
                     pushedEntityDamage = pushedEntityDamage + (pushDmg > 0?pushDmg:0);
                     criticalPushDmg = (pSpellDamageInfo.casterLevel / 2 + (pSpellDamageInfo.casterCriticalPushDamageBonus - pSpellDamageInfo.targetPushDamageFixedResist) + 32) * finalForce / (4 * Math.pow(2,pushIndex));
                     pushedEntityCriticalDamage = pushedEntityCriticalDamage + (criticalPushDmg > 0?criticalPushDmg:0);
                  }
                  pushDamage.minDamage = pushDamage.maxDamage = pushedEntityDamage;
                  pushDamage.minCriticalDamage = pushDamage.maxCriticalDamage = pushedEntityCriticalDamage;
                  if(pushedEntityCriticalDamage > 0)
                  {
                     pSpellDamageInfo.spellHasCriticalDamage = true;
                  }
                  finalDamage.addEffectDamage(pushDamage);
               }
            }
         }
         var applyDamageMultiplier:Function = function(pMultiplier:Number, pIgnoreSplash:Boolean = false):void
         {
            var ed:* = null;
            erosion.applyDamageMultiplier(pMultiplier);
            finalNeutralDmg.applyDamageMultiplier(pMultiplier);
            finalEarthDmg.applyDamageMultiplier(pMultiplier);
            finalWaterDmg.applyDamageMultiplier(pMultiplier);
            finalAirDmg.applyDamageMultiplier(pMultiplier);
            finalFireDmg.applyDamageMultiplier(pMultiplier);
            if(!pIgnoreSplash && splashEffectDamages)
            {
               for each(ed in splashEffectDamages)
               {
                  ed.applyDamageMultiplier(pMultiplier);
               }
            }
         };
         if(pWithTargetBuffs)
         {
            buffHealMultiplier = 1;
            buffDamageMultiplier = 1;
            pSpellDamageInfo.interceptedDamages.length = 0;
            for each(buff in pSpellDamageInfo.targetBuffs)
            {
               buffEffectDispelled = buff.canBeDispell() && buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationReduction <= 0;
               if((!buff.hasOwnProperty("delay") || buff["delay"] == 0) && (!(buff is StatBuff) || !(buff as StatBuff).statName) && !buffEffectDispelled)
               {
                  numTriggeredBuffs = verifyBuffTriggers(buff,pSpellDamageInfo.spellEffects,pSpellDamageInfo.casterId,pSpellDamageInfo.targetId,pSpellDamageInfo.isWeapon,pSpellDamageInfo.spellCenterCell,pSpellDamageInfo.splashDamages);
                  if(numTriggeredBuffs)
                  {
                     for(i = 0; i < numTriggeredBuffs; )
                     {
                        switch(buff.actionId)
                        {
                           case ActionIdEnum.ACTION_CHARACTER_MULTIPLY_RECEIVED_HEAL:
                              buffHealMultiplier = buffHealMultiplier * (buff.param1 / 100);
                              break;
                           case ActionIdEnum.ACTION_CHARACTER_MULTIPLY_RECEIVED_DAMAGE:
                              buffDamageMultiplier = buffDamageMultiplier * (buff.param1 / 100);
                              break;
                           case ActionIdEnum.ACTION_CHARACTER_GIVE_LIFE_WITH_RATIO:
                              erosion.convertDamageToHeal();
                              finalNeutralDmg.convertDamageToHeal();
                              finalEarthDmg.convertDamageToHeal();
                              finalWaterDmg.convertDamageToHeal();
                              finalAirDmg.convertDamageToHeal();
                              finalFireDmg.convertDamageToHeal();
                              if(splashEffectDamages)
                              {
                                 for each(splashEffectDmg in splashEffectDamages)
                                 {
                                    splashEffectDmg.convertDamageToHeal();
                                 }
                              }
                              pSpellDamageInfo.spellHasCriticalHeal = pSpellDamageInfo.spellHasCriticalDamage;
                              finalDamage.hasHeal = true;
                              break;
                           case ActionIdEnum.ACTION_CHARACTER_SACRIFY:
                              if(pSpellDamageInfo.targetId != buff.source)
                              {
                                 hasInterceptedDamage = false;
                                 for each(interceptedDmg in pSpellDamageInfo.interceptedDamages)
                                 {
                                    if(interceptedDmg.buffId == buff.id)
                                    {
                                       hasInterceptedDamage = true;
                                    }
                                 }
                                 if(!hasInterceptedDamage)
                                 {
                                    pSpellDamageInfo.interceptedDamages.push(new InterceptedDamage(buff.id,buff.source,pSpellDamageInfo.targetId));
                                    break;
                                 }
                                 break;
                              }
                        }
                        if(buff.effect.category == DataEnum.ACTION_TYPE_DAMAGES && HEALING_EFFECTS_IDS.indexOf(buff.effect.effectId) == -1)
                        {
                           buffSpellDamage = new SpellDamage();
                           buffEffectDamage = EffectDamage.fromEffectInstance(buff.effect);
                           buffEffectDamage.random = -1;
                           if(buff.effect is EffectInstanceDice)
                           {
                              effid = buff.effect as EffectInstanceDice;
                              buffEffectMinDamage = effid.value + effid.diceNum;
                              buffEffectMaxDamage = effid.value + effid.diceSide;
                           }
                           else if(buff.effect is EffectInstanceMinMax)
                           {
                              buffEffectMinDamage = (buff.effect as EffectInstanceMinMax).min;
                              buffEffectMaxDamage = (buff.effect as EffectInstanceMinMax).max;
                           }
                           else if(buff.effect is EffectInstanceInteger)
                           {
                              buffEffectMinDamage = buffEffectMaxDamage = (buff.effect as EffectInstanceInteger).value;
                           }
                           buffEffectDamage.minDamage = buff.effect.duration == -1000 || buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationReduction > 0?int(buffEffectMinDamage):0;
                           buffEffectDamage.maxDamage = buff.effect.duration == -1000 || buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationReduction > 0?int(buffEffectMaxDamage):0;
                           buffEffectDamage.minCriticalDamage = buff.effect.duration == -1000 || buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationCriticalReduction > 0?int(buffEffectMinDamage):0;
                           buffEffectDamage.maxCriticalDamage = buff.effect.duration == -1000 || buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationCriticalReduction > 0?int(buffEffectMaxDamage):0;
                           buffSpellDamage.addEffectDamage(buffEffectDamage);
                           isTargetHpBasedDamage = TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(buff.actionId) != -1;
                           if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(buff.actionId) != -1)
                           {
                              for each(buffSpellEffectDmg in buffSpellDamage.effectDamages)
                              {
                                 switch(buffSpellEffectDmg.effectId)
                                 {
                                    case ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_CASTER_LIFE_FROM_WATER:
                                       buffSpellEffectDmg.effectId = ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_TARGET_LIFE_FROM_WATER;
                                       continue;
                                    case ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_CASTER_LIFE_FROM_EARTH:
                                       buffSpellEffectDmg.effectId = ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_TARGET_LIFE_FROM_EARTH;
                                       continue;
                                    case ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_CASTER_LIFE_FROM_AIR:
                                       buffSpellEffectDmg.effectId = ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_TARGET_LIFE_FROM_AIR;
                                       continue;
                                    case ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_CASTER_LIFE_FROM_FIRE:
                                       buffSpellEffectDmg.effectId = ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_TARGET_LIFE_FROM_FIRE;
                                       continue;
                                    case ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_CASTER_LIFE:
                                       buffSpellEffectDmg.effectId = ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_TARGET_LIFE;
                                       continue;
                                    default:
                                       continue;
                                 }
                              }
                              isTargetHpBasedDamage = true;
                           }
                           if(!isTargetHpBasedDamage)
                           {
                              buffDamage = computeDamage(buffSpellDamage,SpellDamageInfo.fromBuff(buff,pSpellDamageInfo.spellCenterCell,pSpellDamageInfo.casterAffectedOutOfZone),1);
                              finalDamage.addEffectDamage(buffDamage);
                           }
                           else
                           {
                              if(!targetHpBasedBuffDamages)
                              {
                                 targetHpBasedBuffDamages = new Vector.<SpellDamage>(0);
                              }
                              targetHpBasedBuffDamages.push(buffSpellDamage);
                           }
                        }
                        i++;
                     }
                  }
               }
            }
            if(buffDamageMultiplier != 1)
            {
               applyDamageMultiplier(int(buffDamageMultiplier * 100) / 100);
            }
            if(buffHealMultiplier != 1)
            {
               finalHeal.applyHealMultiplier(int(buffHealMultiplier * 100) / 100);
            }
         }
         var damageBoostPercentTotal:int = pSpellDamageInfo.casterDamageBoostPercent - pSpellDamageInfo.casterDamageDeboostPercent;
         if(damageBoostPercentTotal != 0)
         {
            dmgMultiplier = 100 + damageBoostPercentTotal;
            applyDamageMultiplier(dmgMultiplier < 0?0:dmgMultiplier / 100,true);
         }
         if(pSpellDamageInfo.isWeapon)
         {
            applyDamageMultiplier(pSpellDamageInfo.spellWeaponMultiplier);
         }
         var finalReflectDmg:Vector.<EffectDamage> = new Vector.<EffectDamage>(0);
         if(pSpellDamageInfo.reflectDamages && pSpellDamageInfo.reflectDamages.length > 0)
         {
            currentTargetId = pSpellDamageInfo.targetId;
            minimizeEffects = true;
            maximizeEffects = true;
            for each(reflectDmg in pSpellDamageInfo.reflectDamages)
            {
               sourceDmgWithoutPercentResists = DamageUtil.getSpellDamage(SpellDamageInfo.fromCurrentPlayer(pSpellDamageInfo.spell,CurrentPlayedFighterManager.getInstance().currentFighterId,reflectDmg.sourceId,pSpellDamageInfo.spellCenterCell),true,true,false);
               if(!sourceDmgWithoutPercentResists.minimizedEffects)
               {
                  minimizeEffects = false;
               }
               if(!sourceDmgWithoutPercentResists.maximizedEffects)
               {
                  maximizeEffects = false;
               }
               for each(reflectDmgEffect in reflectDmg.effects)
               {
                  finalElementDmgWithoutPercentResists = null;
                  for each(ed in sourceDmgWithoutPercentResists.effectDamages)
                  {
                     if(ed.element == reflectDmgEffect.element)
                     {
                        finalElementDmgWithoutPercentResists = ed;
                        break;
                     }
                  }
                  if(!(!finalElementDmgWithoutPercentResists || !finalElementDmgWithoutPercentResists.hasDamage))
                  {
                     reflectValue = !!reflectDmg.boosted?int(reflectDmg.reflectValue * (pSpellDamageInfo.casterLevel / 20 + 1)):int(reflectDmg.reflectValue);
                     tmpEffect = new EffectDamage(-1,finalElementDmgWithoutPercentResists.element,finalElementDmgWithoutPercentResists.random);
                     tmpEffect.minDamage = reflectDmgEffect.minDamage > 0?int(Math.min(finalElementDmgWithoutPercentResists.minDamage,reflectValue)):0;
                     tmpEffect.maxDamage = reflectDmgEffect.maxDamage > 0?int(Math.min(finalElementDmgWithoutPercentResists.maxDamage,reflectValue)):0;
                     tmpEffect.minCriticalDamage = reflectDmgEffect.minCriticalDamage > 0 || pSpellDamageInfo.isWeapon?int(Math.min(finalElementDmgWithoutPercentResists.minCriticalDamage,reflectValue)):0;
                     tmpEffect.maxCriticalDamage = reflectDmgEffect.maxCriticalDamage > 0 || pSpellDamageInfo.isWeapon?int(Math.min(finalElementDmgWithoutPercentResists.maxCriticalDamage,reflectValue)):0;
                     tmpEffect.hasCritical = tmpEffect.minCriticalDamage > 0 || tmpEffect.maxCriticalDamage > 0;
                     reflectDmgEffect = computeDamageWithoutResistsBoosts(reflectDmg.sourceId,tmpEffect,pSpellDamageInfo,1,true,true);
                     reflectDmgEffect.spellEffectOrder = --reflectOrder;
                     reflectSpellDmg = new SpellDamage();
                     reflectSpellDmg.addEffectDamage(reflectDmgEffect);
                     reflectSpellDmg.hasCriticalDamage = reflectDmgEffect.hasCritical;
                     pSpellDamageInfo.targetId = currentTargetId;
                     ed = computeDamage(reflectSpellDmg,pSpellDamageInfo,1,true);
                     finalReflectDmg.push(ed);
                  }
               }
            }
            pSpellDamageInfo.minimizedEffects = minimizeEffects;
            pSpellDamageInfo.maximizedEffects = maximizeEffects;
            pSpellDamageInfo.targetId = currentTargetId;
         }
         if(pSpellDamageInfo.originalTargetsIds.indexOf(pSpellDamageInfo.targetId) == -1)
         {
            if(finalInterceptedDmg)
            {
               if(finalInterceptedDmg.random > 0)
               {
                  for each(ed in finalInterceptedDmg.computedEffects)
                  {
                     finalDamage.addEffectDamage(ed);
                  }
               }
               else
               {
                  finalDamage.addEffectDamage(finalInterceptedDmg);
               }
            }
         }
         for each(splashHealDmg in splashHealEffectDamages)
         {
            finalHeal.minLifePointsAdded = finalHeal.minLifePointsAdded + splashHealDmg.minLifePointsAdded;
            finalHeal.maxLifePointsAdded = finalHeal.maxLifePointsAdded + splashHealDmg.maxLifePointsAdded;
            finalHeal.minCriticalLifePointsAdded = finalHeal.minCriticalLifePointsAdded + splashHealDmg.minCriticalLifePointsAdded;
            finalHeal.maxCriticalLifePointsAdded = finalHeal.maxCriticalLifePointsAdded + splashHealDmg.maxCriticalLifePointsAdded;
            finalHeal.computedEffects.push(splashHealDmg);
            finalDamage.hasHeal = true;
         }
         if(pSpellDamageInfo.targetId == pSpellDamageInfo.casterId)
         {
            for each(ed in finalReflectDmg)
            {
               finalDamage.addEffectDamage(ed);
               if(ed.hasCritical)
               {
                  pSpellDamageInfo.spellHasCriticalDamage = true;
               }
            }
            if(pSpellDamageInfo.spellHasLifeSteal && !pSpellDamageInfo.interceptedDamage)
            {
               fightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               for each(targetId in pSpellDamageInfo.originalTargetsIds)
               {
                  if(targetId != pSpellDamageInfo.casterId)
                  {
                     spellDamages = SpellDamagesManager.getInstance().getSpellDamages(targetId);
                     if(fightContextFrame)
                     {
                        targetLifePoints = (fightContextFrame.entitiesFrame.getEntityInfos(targetId) as GameFightFighterInformations).stats.lifePoints;
                     }
                     for each(spellDamage in spellDamages)
                     {
                        for each(ed in spellDamage.spellDamage.effectDamages)
                        {
                           for each(ed in ed.computedEffects)
                           {
                              if(LIFE_STEAL_EFFECTS_IDS.indexOf(ed.effectId) != -1)
                              {
                                 lifeStealEffect = new EffectDamage(ed.effectId,ed.element,ed.random,ed.duration);
                                 lifeStealEffect.minLifePointsAdded = targetLifePoints > 0?int(Math.min(targetLifePoints,ed.minDamage) / 2):int(ed.minDamage / 2);
                                 lifeStealEffect.maxLifePointsAdded = targetLifePoints > 0?int(Math.min(targetLifePoints,ed.maxDamage) / 2):int(ed.maxDamage / 2);
                                 lifeStealEffect.minCriticalLifePointsAdded = targetLifePoints > 0?int(Math.min(targetLifePoints,ed.minCriticalDamage) / 2):int(ed.minCriticalDamage / 2);
                                 lifeStealEffect.maxCriticalLifePointsAdded = targetLifePoints > 0?int(Math.min(targetLifePoints,ed.maxCriticalDamage) / 2):int(ed.maxCriticalDamage / 2);
                                 lifeStealEffect.spellEffectOrder = ed.spellEffectOrder;
                                 lifeStealEffect.lifeSteal = true;
                                 finalHeal.computedEffects.push(lifeStealEffect);
                                 finalDamage.hasHeal = true;
                                 if(lifeStealEffect.minCriticalLifePointsAdded > 0 || lifeStealEffect.maxCriticalLifePointsAdded > 0)
                                 {
                                    lifeStealEffect.hasCritical = true;
                                    pSpellDamageInfo.spellHasCriticalHeal = true;
                                 }
                                 if(lifeStealEffect.random > 0)
                                 {
                                    lifeStealHasRandom = true;
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
            if(pSpellDamageInfo.originalTargetsIds.indexOf(pSpellDamageInfo.targetId) == -1 || pSpellDamageInfo.isWeapon)
            {
               if(targetHpBasedBuffDamages)
               {
                  finalTargetHpBasedDamages = computeTargetHpBasedBuffDamage(pSpellDamageInfo,getAllEffectDamages(finalDamage),targetHpBasedBuffDamages,pWithTargetResists,pWithTargetPercentResists);
                  for each(ed in finalTargetHpBasedDamages)
                  {
                     finalDamage.addEffectDamage(ed);
                  }
               }
               computeHeal(finalHeal,getAllEffectDamages(finalDamage),pSpellDamageInfo,1);
               if(lifeStealHasRandom)
               {
                  for each(ed in finalHeal.computedEffects)
                  {
                     finalDamage.addEffectDamage(ed);
                  }
               }
               else
               {
                  finalDamage.addEffectDamage(finalHeal);
               }
               forceIsHealingSpell = true;
            }
         }
         else if(splashHealEffectDamages && splashHealEffectDamages.length > 0 && pSpellDamageInfo.originalTargetsIds.indexOf(pSpellDamageInfo.targetId) == -1)
         {
            computeHeal(finalHeal,getAllEffectDamages(finalDamage),pSpellDamageInfo,1);
            finalDamage.addEffectDamage(finalHeal);
            forceIsHealingSpell = true;
         }
         if(pSpellDamageInfo.originalTargetsIds.indexOf(pSpellDamageInfo.targetId) != -1 && (!pSpellDamageInfo.isWeapon || pSpellDamageInfo.casterId != pSpellDamageInfo.targetId))
         {
            finalDamage.addEffectDamage(erosion);
            finalDamage.addEffectDamage(finalNeutralDmg,0);
            finalDamage.addEffectDamage(finalEarthDmg,0);
            finalDamage.addEffectDamage(finalWaterDmg,0);
            finalDamage.addEffectDamage(finalAirDmg,0);
            finalDamage.addEffectDamage(finalFireDmg,0);
            finalDamage.addEffectDamage(finalHpBasedDmg,0);
            if(finalInterceptedDmg)
            {
               if(finalInterceptedDmg.random > 0)
               {
                  for each(ed in finalInterceptedDmg.computedEffects)
                  {
                     finalDamage.addEffectDamage(ed);
                  }
               }
               else
               {
                  finalDamage.addEffectDamage(finalInterceptedDmg);
               }
            }
            if(targetHpBasedBuffDamages)
            {
               finalTargetHpBasedDamages = computeTargetHpBasedBuffDamage(pSpellDamageInfo,getAllEffectDamages(finalDamage),targetHpBasedBuffDamages,pWithTargetResists,pWithTargetPercentResists);
               for each(ed in finalTargetHpBasedDamages)
               {
                  finalDamage.addEffectDamage(ed);
               }
            }
            computeHeal(finalHeal,getAllEffectDamages(finalDamage),pSpellDamageInfo,efficiencyMultiplier);
            finalDamage.addEffectDamage(finalHeal);
         }
         finalDamage.hasCriticalDamage = pSpellDamageInfo.spellHasCriticalDamage;
         finalDamage.criticalHitRate = pSpellDamageInfo.criticalHitRate;
         finalDamage.minimizedEffects = pSpellDamageInfo.minimizedEffects;
         finalDamage.maximizedEffects = pSpellDamageInfo.maximizedEffects;
         var invulnerable:Boolean = pSpellDamageInfo.targetIsInvulnerable;
         if(!invulnerable)
         {
            invulnerableToRange = pSpellDamageInfo.targetIsInvulnerableToRange;
            if(invulnerableToRange)
            {
               for each(ed in finalDamage.effectDamages)
               {
                  if(ed.damageDistance != -1 && ed.hasDamage)
                  {
                     hasDamageDistance = true;
                     if(ed.damageDistance < 2)
                     {
                        invulnerableToRange = false;
                     }
                     else
                     {
                        ed.minDamage = ed.maxDamage = ed.minCriticalDamage = ed.maxCriticalDamage = 0;
                     }
                  }
               }
               if(!hasDamageDistance)
               {
                  invulnerableToRange = false;
               }
            }
            invulnerableToMelee = pSpellDamageInfo.targetIsInvulnerableToMelee;
            if(invulnerableToMelee)
            {
               hasDamageDistance = false;
               for each(ed in finalDamage.effectDamages)
               {
                  if(ed.damageDistance != -1 && ed.hasDamage)
                  {
                     hasDamageDistance = true;
                     if(ed.damageDistance > 1)
                     {
                        invulnerableToMelee = false;
                     }
                     else
                     {
                        ed.minDamage = ed.maxDamage = ed.minCriticalDamage = ed.maxCriticalDamage = 0;
                     }
                  }
               }
               if(!hasDamageDistance)
               {
                  invulnerableToMelee = false;
               }
            }
            invulnerable = invulnerableToRange || invulnerableToMelee;
         }
         var meleeCasterDone:Number = 1;
         var meleeTargetReceived:Number = 1;
         var rangeCasterDone:Number = 1;
         var rangeTargetReceived:Number = 1;
         var weaponCasterDone:Number = 1;
         var weaponTargetReceived:Number = 1;
         var spellCasterDone:Number = 1;
         var spellTargetReceived:Number = 1;
         if(pSpellDamageInfo.casterMeleeDamageDonePercent != 0)
         {
            meleeCasterDone = 1 + pSpellDamageInfo.casterMeleeDamageDonePercent / 100;
         }
         meleeTargetReceived = pSpellDamageInfo.targetMeleeDamageReceivedPercent / 100;
         if(pSpellDamageInfo.casterRangedDamageDonePercent != 0)
         {
            rangeCasterDone = 1 + pSpellDamageInfo.casterRangedDamageDonePercent / 100;
         }
         rangeTargetReceived = pSpellDamageInfo.targetRangedDamageReceivedPercent / 100;
         if(pSpellDamageInfo.casterWeaponDamageDonePercent != 0)
         {
            weaponCasterDone = 1 + pSpellDamageInfo.casterWeaponDamageDonePercent / 100;
         }
         weaponTargetReceived = pSpellDamageInfo.targetWeaponDamageReceivedPercent / 100;
         if(pSpellDamageInfo.casterSpellDamageDonePercent != 0)
         {
            spellCasterDone = 1 + pSpellDamageInfo.casterSpellDamageDonePercent / 100;
         }
         spellTargetReceived = pSpellDamageInfo.targetSpellDamageReceivedPercent / 100;
         for each(ed in finalDamage.effectDamages)
         {
            if(ed.hasDamage)
            {
               if(ed.effectId != BUMP_DAMAGE)
               {
                  if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(ed.effectId) != -1 || TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(ed.effectId) != -1 || ERODED_HP_BASED_DAMAGE_EFFETS_IDS.indexOf(ed.effectId) != -1)
                  {
                     meleeFinalMultiplier = meleeTargetReceived;
                     rangeFinalMultiplier = rangeTargetReceived;
                     weaponFinalMultiplier = weaponTargetReceived;
                     spellFinalMultiplier = spellTargetReceived;
                  }
                  else
                  {
                     meleeFinalMultiplier = meleeCasterDone * meleeTargetReceived;
                     rangeFinalMultiplier = rangeCasterDone * rangeTargetReceived;
                     weaponFinalMultiplier = weaponCasterDone * weaponTargetReceived;
                     spellFinalMultiplier = spellCasterDone * spellTargetReceived;
                  }
                  finalDamageMultiplier = 1;
                  if(ed.damageDistance != -1)
                  {
                     if(ed.damageDistance < 2)
                     {
                        finalDamageMultiplier = finalDamageMultiplier * meleeFinalMultiplier;
                     }
                     else if(ed.damageDistance >= 2)
                     {
                        finalDamageMultiplier = finalDamageMultiplier * rangeFinalMultiplier;
                     }
                  }
                  if(pSpellDamageInfo.isWeapon)
                  {
                     finalDamageMultiplier = finalDamageMultiplier * weaponFinalMultiplier;
                  }
                  else
                  {
                     finalDamageMultiplier = finalDamageMultiplier * spellFinalMultiplier;
                  }
                  ed.applyDamageMultiplier(finalDamageMultiplier);
               }
            }
         }
         finalDamage.updateDamage();
         if(forceIsHealingSpell)
         {
            forceIsHealingSpellValue = finalDamage.hasHeal && finalDamage.minDamage == 0 && finalDamage.maxDamage == 0 && finalDamage.minCriticalDamage == 0 && finalDamage.maxCriticalDamage == 0;
         }
         var finalShield:EffectDamage = computeShield(pSpellDamageInfo.shield);
         finalDamage.addEffectDamage(finalShield);
         finalDamage.updateShield();
         finalDamage.hasCriticalShieldPointsAdded = finalShield.minCriticalShieldPointsAdded > 0 && finalShield.maxCriticalShieldPointsAdded > 0;
         for each(ed in finalDamage.effectDamages)
         {
            for each(computedEffect in ed.computedEffects)
            {
               if(computedEffect.duration <= 0)
               {
                  permanentMinDamage = permanentMinDamage + computedEffect.minDamage;
                  permanentMaxDamage = permanentMaxDamage + computedEffect.maxDamage;
                  permanentMinCriticalDamage = permanentMinCriticalDamage + computedEffect.minCriticalDamage;
                  permanentMaxCriticalDamage = permanentMaxCriticalDamage + computedEffect.maxCriticalDamage;
               }
            }
         }
         pSpellDamageInfo.targetShieldPoints = pSpellDamageInfo.targetShieldPoints + pSpellDamageInfo.targetTriggeredShieldPoints;
         if(pSpellDamageInfo.targetShieldPoints > 0)
         {
            minShieldDiff = permanentMinDamage - pSpellDamageInfo.targetShieldPoints;
            if(minShieldDiff < 0)
            {
               finalDamage.minShieldPointsRemoved = permanentMinDamage;
               if(permanentMinDamage > 0)
               {
                  finalDamage.minDamage = 0;
               }
            }
            else
            {
               finalDamage.minDamage = finalDamage.minDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.minShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            maxShieldDiff = permanentMaxDamage - pSpellDamageInfo.targetShieldPoints;
            if(maxShieldDiff < 0)
            {
               finalDamage.maxShieldPointsRemoved = permanentMaxDamage;
               if(permanentMaxDamage > 0)
               {
                  finalDamage.maxDamage = 0;
               }
            }
            else
            {
               finalDamage.maxDamage = finalDamage.maxDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.maxShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            minCriticalShieldDiff = permanentMinCriticalDamage - pSpellDamageInfo.targetShieldPoints;
            if(minCriticalShieldDiff < 0)
            {
               finalDamage.minCriticalShieldPointsRemoved = permanentMinCriticalDamage;
               if(permanentMinCriticalDamage > 0)
               {
                  finalDamage.minCriticalDamage = 0;
               }
            }
            else
            {
               finalDamage.minCriticalDamage = finalDamage.minCriticalDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.minCriticalShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            maxCriticalShieldDiff = permanentMaxCriticalDamage - pSpellDamageInfo.targetShieldPoints;
            if(maxCriticalShieldDiff < 0)
            {
               finalDamage.maxCriticalShieldPointsRemoved = permanentMaxCriticalDamage;
               if(permanentMaxCriticalDamage > 0)
               {
                  finalDamage.maxCriticalDamage = 0;
               }
            }
            else
            {
               finalDamage.maxCriticalDamage = finalDamage.maxCriticalDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.maxCriticalShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            if(pSpellDamageInfo.spellHasCriticalDamage)
            {
               finalDamage.hasCriticalShieldPointsRemoved = true;
            }
         }
         if(pSpellDamageInfo.casterStatus.cantDealDamage)
         {
            finalDamage.minDamage = finalDamage.maxDamage = finalDamage.minCriticalDamage = finalDamage.maxCriticalDamage = 0;
            finalDamage.minShieldPointsRemoved = finalDamage.maxShieldPointsRemoved = finalDamage.minCriticalShieldPointsRemoved = finalDamage.maxCriticalShieldPointsRemoved = 0;
         }
         finalDamage.hasCriticalLifePointsAdded = pSpellDamageInfo.spellHasCriticalHeal;
         finalDamage.invulnerableState = invulnerable;
         finalDamage.unhealableState = pSpellDamageInfo.targetIsUnhealable;
         finalDamage.isHealingSpell = !forceIsHealingSpell?Boolean(pSpellDamageInfo.isHealingSpell):Boolean(forceIsHealingSpellValue);
         hasInterceptedDamage = false;
         if(!pSpellDamageInfo.damageSharingTargets || pSpellDamageInfo.damageSharingTargets.length)
         {
            for each(intercepted in pSpellDamageInfo.interceptedDamages)
            {
               if(intercepted.interceptedEntityId == pSpellDamageInfo.targetId)
               {
                  hasInterceptedDamage = true;
                  break;
               }
            }
         }
         if(hasInterceptedDamage)
         {
            for each(intercepted in pSpellDamageInfo.interceptedDamages)
            {
               intercepted.damage.invulnerableState = finalDamage.invulnerableState;
               intercepted.damage.unhealableState = finalDamage.unhealableState;
               intercepted.damage.hasCriticalDamage = finalDamage.hasCriticalDamage;
               intercepted.damage.hasCriticalShieldPointsRemoved = finalDamage.hasCriticalShieldPointsRemoved;
               intercepted.damage.hasCriticalShieldPointsAdded = finalDamage.hasCriticalShieldPointsAdded;
               intercepted.damage.hasCriticalLifePointsAdded = finalDamage.hasCriticalLifePointsAdded;
               intercepted.damage.isHealingSpell = finalDamage.isHealingSpell;
               intercepted.damage.hasHeal = finalDamage.hasHeal;
               intercepted.damage.criticalHitRate = finalDamage.criticalHitRate;
               intercepted.damage.minimizedEffects = finalDamage.minimizedEffects;
               intercepted.damage.maximizedEffects = finalDamage.maximizedEffects;
               intercepted.damage.efficiencyMultiplier = finalDamage.efficiencyMultiplier;
            }
            for each(ed in finalDamage.effectDamages)
            {
               if(ed != finalInterceptedDmg && (!splashEffectDamages || splashEffectDamages.indexOf(ed) == -1))
               {
                  for each(intercepted in pSpellDamageInfo.interceptedDamages)
                  {
                     interceptedEffect = ed.clone();
                     interceptedEffect.effectId = ActionIdEnum.ACTION_CHARACTER_SACRIFY;
                     intercepted.damage.addEffectDamage(interceptedEffect);
                  }
                  ed.minDamage = ed.maxDamage = ed.minCriticalDamage = ed.maxCriticalDamage = 0;
                  ed.computedEffects.length = 0;
               }
            }
            finalDamage.updateDamage();
         }
         return finalDamage;
      }
      
      private static function addSplashDamages(pTargetDamage:SpellDamage, pSlashDamages:Vector.<SplashDamage>, pSpellDamageInfo:SpellDamageInfo, pCurrentCasterLifePoints:int, pCritical:Boolean, pSplashEffectDamages:Vector.<EffectDamage>, pSplashHealEffectDamages:Vector.<EffectDamage>) : void
      {
         var splashEffectDmg:* = null;
         var hasHealingSplash:Boolean = false;
         var ed:* = null;
         var splashDmg:* = null;
         var splashCasterCell:* = 0;
         var efficiencyMultiplier:Number = NaN;
         var splashRandomEffect:* = null;
         if(pSlashDamages)
         {
            for each(splashDmg in pSlashDamages)
            {
               if(splashDmg.targets.indexOf(pSpellDamageInfo.targetId) != -1)
               {
                  splashCasterCell = uint(EntitiesManager.getInstance().getEntity(splashDmg.casterId).position.cellId);
                  efficiencyMultiplier = getShapeEfficiency(splashDmg.spellShape,splashCasterCell,pSpellDamageInfo.targetCell,splashDmg.spellShapeSize != null?int(int(splashDmg.spellShapeSize)):int(EFFECTSHAPE_DEFAULT_AREA_SIZE),splashDmg.spellShapeMinSize != null?int(int(splashDmg.spellShapeMinSize)):int(EFFECTSHAPE_DEFAULT_MIN_AREA_SIZE),splashDmg.spellShapeEfficiencyPercent != null?int(int(splashDmg.spellShapeEfficiencyPercent)):int(EFFECTSHAPE_DEFAULT_EFFICIENCY),splashDmg.spellShapeMaxEfficiency != null?int(int(splashDmg.spellShapeMaxEfficiency)):int(EFFECTSHAPE_DEFAULT_MAX_EFFICIENCY_APPLY));
                  hasHealingSplash = false;
                  for each(ed in splashDmg.damage.effectDamages)
                  {
                     if(ed.effectId == SPLASH_HEAL_EFFECT_ID)
                     {
                        hasHealingSplash = true;
                        break;
                     }
                  }
                  splashEffectDmg = computeDamage(splashDmg.damage,pSpellDamageInfo,efficiencyMultiplier,true,!pCritical || hasHealingSplash,hasHealingSplash);
                  splashEffectDmg.damageDistance = pSpellDamageInfo.targetCell != -1?int(MapPoint.fromCellId(splashDmg.casterCell).distanceToCell(MapPoint.fromCellId(pSpellDamageInfo.targetCell))):-1;
                  if(splashEffectDmg.effectId == SPLASH_HEAL_EFFECT_ID)
                  {
                     splashEffectDmg.convertDamageToHeal();
                     if(splashEffectDmg.hasCritical)
                     {
                        pSpellDamageInfo.spellHasCriticalHeal = true;
                     }
                     pSplashHealEffectDamages.push(splashEffectDmg);
                  }
                  else if(splashEffectDmg.random > 0)
                  {
                     if(splashDmg.random > 0)
                     {
                        splashRandomEffect = new EffectDamage(splashEffectDmg.effectId,splashEffectDmg.element,splashDmg.random);
                        splashRandomEffect.hasCritical = splashEffectDmg.hasCritical;
                        splashRandomEffect.damageDistance = splashEffectDmg.damageDistance;
                        pSplashEffectDamages.push(splashRandomEffect);
                        for each(ed in splashEffectDmg.computedEffects)
                        {
                           if(ed.random > 0)
                           {
                              ed.hasCritical = splashEffectDmg.hasCritical;
                              splashRandomEffect.minDamage = splashRandomEffect.minDamage > 0?int(Math.min(splashRandomEffect.minDamage,ed.minDamage)):int(ed.minDamage);
                              splashRandomEffect.maxDamage = Math.max(splashRandomEffect.maxDamage,ed.maxDamage);
                              splashRandomEffect.minCriticalDamage = splashRandomEffect.minCriticalDamage > 0?int(Math.min(splashRandomEffect.minCriticalDamage,ed.minCriticalDamage)):int(ed.minCriticalDamage);
                              splashRandomEffect.maxCriticalDamage = Math.max(splashRandomEffect.maxCriticalDamage,ed.maxCriticalDamage);
                           }
                        }
                        pTargetDamage.addEffectDamage(splashRandomEffect);
                     }
                     else
                     {
                        pSplashEffectDamages.push(splashEffectDmg);
                        for each(ed in splashEffectDmg.computedEffects)
                        {
                           ed.hasCritical = splashEffectDmg.hasCritical;
                           ed.damageDistance = splashEffectDmg.damageDistance;
                           pTargetDamage.addEffectDamage(ed);
                        }
                     }
                  }
                  else
                  {
                     pSplashEffectDamages.push(splashEffectDmg);
                     splashEffectDmg.random = splashDmg.random;
                     pTargetDamage.addEffectDamage(splashEffectDmg);
                  }
                  if(pSpellDamageInfo.targetId == pSpellDamageInfo.casterId)
                  {
                     if(pSpellDamageInfo.casterLifePointsAfterNormalMinDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMinDamage = pCurrentCasterLifePoints - splashEffectDmg.minDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMinDamage = pSpellDamageInfo.casterLifePointsAfterNormalMinDamage - splashEffectDmg.minDamage;
                     }
                     if(pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage = pCurrentCasterLifePoints - splashEffectDmg.maxDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage = pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage - splashEffectDmg.maxDamage;
                     }
                     if(pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage = pCurrentCasterLifePoints - splashEffectDmg.minCriticalDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage = pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage - splashEffectDmg.minCriticalDamage;
                     }
                     if(pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage = pCurrentCasterLifePoints - splashEffectDmg.maxCriticalDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage = pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage - splashEffectDmg.maxCriticalDamage;
                     }
                  }
               }
            }
         }
      }
      
      public static function getDamageBeforeIndex(pEffectsList:Vector.<EffectDamage>, pSpellEffectIndex:uint) : EffectDamage
      {
         var effect:* = null;
         var totalDamageEffect:EffectDamage = new EffectDamage();
         for each(effect in pEffectsList)
         {
            if(effect.spellEffectOrder < pSpellEffectIndex)
            {
               totalDamageEffect.minDamage = totalDamageEffect.minDamage + effect.minDamage;
               totalDamageEffect.minBaseDamage = totalDamageEffect.minBaseDamage + effect.minBaseDamage;
               totalDamageEffect.maxDamage = totalDamageEffect.maxDamage + effect.maxDamage;
               totalDamageEffect.maxBaseDamage = totalDamageEffect.maxBaseDamage + effect.maxBaseDamage;
               totalDamageEffect.minCriticalDamage = totalDamageEffect.minCriticalDamage + effect.minCriticalDamage;
               totalDamageEffect.minBaseCriticalDamage = totalDamageEffect.minBaseCriticalDamage + effect.minBaseCriticalDamage;
               totalDamageEffect.maxCriticalDamage = totalDamageEffect.maxCriticalDamage + effect.maxCriticalDamage;
               totalDamageEffect.maxBaseCriticalDamage = totalDamageEffect.maxBaseCriticalDamage + effect.maxBaseCriticalDamage;
            }
         }
         return totalDamageEffect;
      }
      
      public static function getAllEffectDamages(pSpellDamage:SpellDamage) : Vector.<EffectDamage>
      {
         var i:int = 0;
         var effects:Vector.<EffectDamage> = new Vector.<EffectDamage>(0);
         var numEffects:uint = pSpellDamage.effectDamages.length;
         for(i = 0; i < numEffects; i++)
         {
            effects = effects.concat(pSpellDamage.effectDamages[i].computedEffects);
         }
         return effects;
      }
      
      private static function computeTargetHpBasedBuffDamage(pSpellDamageInfo:SpellDamageInfo, pDamageEffects:Vector.<EffectDamage>, pTargetHpBasedBuffDamages:Vector.<SpellDamage>, pWithTargetResists:Boolean, pWithTargetPercentResists:Boolean) : Vector.<EffectDamage>
      {
         var dmgEffect:* = null;
         var targetHpBasedBuffDamage:* = null;
         var finalTargetHpBasedBuffDmg:* = null;
         var i:int = 0;
         var finalTargetHpBasedBuffDamages:Vector.<EffectDamage> = new Vector.<EffectDamage>();
         var currentTargetLifePoints:int = ((Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame).getEntityInfos(pSpellDamageInfo.targetId) as GameFightFighterInformations).stats.lifePoints;
         var numEffects:uint = pDamageEffects.length;
         for(i = 0; i < numEffects; i++)
         {
            dmgEffect = pDamageEffects[i];
            if(i == 0)
            {
               pSpellDamageInfo.targetLifePointsAfterNormalMinDamage = currentTargetLifePoints - dmgEffect.minDamage < 0?0:uint(currentTargetLifePoints - dmgEffect.minDamage);
               pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage = currentTargetLifePoints - dmgEffect.maxDamage < 0?0:uint(currentTargetLifePoints - dmgEffect.maxDamage);
               pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage = currentTargetLifePoints - dmgEffect.minCriticalDamage < 0?0:uint(currentTargetLifePoints - dmgEffect.minCriticalDamage);
               pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage = currentTargetLifePoints - dmgEffect.maxCriticalDamage < 0?0:uint(currentTargetLifePoints - dmgEffect.maxCriticalDamage);
            }
            else
            {
               pSpellDamageInfo.targetLifePointsAfterNormalMinDamage = pSpellDamageInfo.targetLifePointsAfterNormalMinDamage - dmgEffect.minDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterNormalMinDamage - dmgEffect.minDamage);
               pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage = pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage - dmgEffect.maxDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage - dmgEffect.maxDamage);
               pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage = pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage - dmgEffect.minCriticalDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage - dmgEffect.minCriticalDamage);
               pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage = pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage - dmgEffect.maxCriticalDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage - dmgEffect.maxCriticalDamage);
            }
            for each(targetHpBasedBuffDamage in pTargetHpBasedBuffDamages)
            {
               finalTargetHpBasedBuffDmg = computeDamage(targetHpBasedBuffDamage,pSpellDamageInfo,1,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
               finalTargetHpBasedBuffDamages.push(finalTargetHpBasedBuffDmg);
               pSpellDamageInfo.targetLifePointsAfterNormalMinDamage = pSpellDamageInfo.targetLifePointsAfterNormalMinDamage - finalTargetHpBasedBuffDmg.minDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterNormalMinDamage - finalTargetHpBasedBuffDmg.minDamage);
               pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage = pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage - finalTargetHpBasedBuffDmg.maxDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage - finalTargetHpBasedBuffDmg.maxDamage);
               pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage = pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage - finalTargetHpBasedBuffDmg.minCriticalDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage - finalTargetHpBasedBuffDmg.minCriticalDamage);
               pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage = pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage - finalTargetHpBasedBuffDmg.maxCriticalDamage < 0?0:uint(pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage - finalTargetHpBasedBuffDmg.maxCriticalDamage);
            }
         }
         return finalTargetHpBasedBuffDamages;
      }
      
      private static function computeHeal(pHealDamage:EffectDamage, pDamageEffects:Vector.<EffectDamage>, pSpellDamageInfo:SpellDamageInfo, pEfficiencyMultiplier:Number) : void
      {
         var damageBeforeIndex:* = null;
         var totalMinLifePointsAdded:* = 0;
         var totalMaxLifePointsAdded:* = 0;
         var totalMinCriticalLifePointsAdded:* = 0;
         var totalMaxCriticalLifePointsAdded:* = 0;
         var healingEffect:* = null;
         var targetLostLifePoints:uint = pSpellDamageInfo.targetInfos.stats.maxLifePoints - pSpellDamageInfo.targetInfos.stats.lifePoints;
         var totalErosionPercent:* = uint(10 + pSpellDamageInfo.targetErosionPercentBonus);
         if(totalErosionPercent > 50)
         {
            totalErosionPercent = 50;
         }
         for each(healingEffect in pHealDamage.computedEffects)
         {
            damageBeforeIndex = getDamageBeforeIndex(pDamageEffects,healingEffect.spellEffectOrder);
            damageBeforeIndex.minDamage = damageBeforeIndex.minDamage + (targetLostLifePoints - Math.floor(totalErosionPercent * damageBeforeIndex.minBaseDamage / 100));
            damageBeforeIndex.maxDamage = damageBeforeIndex.maxDamage + (targetLostLifePoints - Math.floor(totalErosionPercent * damageBeforeIndex.maxBaseDamage / 100));
            damageBeforeIndex.minCriticalDamage = damageBeforeIndex.minCriticalDamage + (targetLostLifePoints - Math.floor(totalErosionPercent * damageBeforeIndex.minBaseCriticalDamage / 100));
            damageBeforeIndex.maxCriticalDamage = damageBeforeIndex.maxCriticalDamage + (targetLostLifePoints - Math.floor(totalErosionPercent * damageBeforeIndex.maxBaseCriticalDamage / 100));
            if(!pSpellDamageInfo.isHealingSpell && damageBeforeIndex.minDamage > 0 && healingEffect.minLifePointsAdded > damageBeforeIndex.minDamage - totalMinLifePointsAdded)
            {
               totalMinLifePointsAdded = uint(totalMinLifePointsAdded + (damageBeforeIndex.minDamage - totalMinLifePointsAdded));
            }
            else
            {
               totalMinLifePointsAdded = uint(totalMinLifePointsAdded + healingEffect.minLifePointsAdded);
            }
            if(!pSpellDamageInfo.isHealingSpell && damageBeforeIndex.maxDamage > 0 && healingEffect.maxLifePointsAdded > damageBeforeIndex.maxDamage - totalMaxLifePointsAdded)
            {
               totalMaxLifePointsAdded = uint(totalMaxLifePointsAdded + (damageBeforeIndex.maxDamage - totalMaxLifePointsAdded));
            }
            else
            {
               totalMaxLifePointsAdded = uint(totalMaxLifePointsAdded + healingEffect.maxLifePointsAdded);
            }
            if(!pSpellDamageInfo.isHealingSpell && damageBeforeIndex.minCriticalDamage > 0 && healingEffect.minCriticalLifePointsAdded > damageBeforeIndex.minCriticalDamage - totalMinCriticalLifePointsAdded)
            {
               totalMinCriticalLifePointsAdded = uint(totalMinCriticalLifePointsAdded + (damageBeforeIndex.minCriticalDamage - totalMinCriticalLifePointsAdded));
            }
            else
            {
               totalMinCriticalLifePointsAdded = uint(totalMinCriticalLifePointsAdded + healingEffect.minCriticalLifePointsAdded);
            }
            if(!pSpellDamageInfo.isHealingSpell && damageBeforeIndex.maxCriticalDamage > 0 && healingEffect.maxCriticalLifePointsAdded > damageBeforeIndex.maxCriticalDamage - totalMaxCriticalLifePointsAdded)
            {
               totalMaxCriticalLifePointsAdded = uint(totalMaxCriticalLifePointsAdded + (damageBeforeIndex.maxCriticalDamage - totalMaxCriticalLifePointsAdded));
            }
            else
            {
               totalMaxCriticalLifePointsAdded = uint(totalMaxCriticalLifePointsAdded + healingEffect.maxCriticalLifePointsAdded);
            }
            if(!pSpellDamageInfo.isHealingSpell && damageBeforeIndex.minDamage > 0 && healingEffect.lifePointsAddedBasedOnLifePercent > damageBeforeIndex.minDamage - totalMinLifePointsAdded || !pSpellDamageInfo.isHealingSpell && healingEffect.lifePointsAddedBasedOnLifePercent > damageBeforeIndex.maxDamage - totalMaxLifePointsAdded)
            {
               totalMinLifePointsAdded = uint(totalMinLifePointsAdded + (damageBeforeIndex.minDamage - totalMinLifePointsAdded));
               totalMaxLifePointsAdded = uint(totalMaxLifePointsAdded + (damageBeforeIndex.maxDamage - totalMaxLifePointsAdded));
            }
            else
            {
               totalMinLifePointsAdded = uint(totalMinLifePointsAdded + healingEffect.lifePointsAddedBasedOnLifePercent);
               totalMaxLifePointsAdded = uint(totalMaxLifePointsAdded + healingEffect.lifePointsAddedBasedOnLifePercent);
            }
            if(!pSpellDamageInfo.isHealingSpell && damageBeforeIndex.minCriticalDamage > 0 && healingEffect.criticalLifePointsAddedBasedOnLifePercent > damageBeforeIndex.minCriticalDamage - totalMinCriticalLifePointsAdded || !pSpellDamageInfo.isHealingSpell && healingEffect.criticalLifePointsAddedBasedOnLifePercent > damageBeforeIndex.maxCriticalDamage - totalMaxCriticalLifePointsAdded)
            {
               totalMinCriticalLifePointsAdded = uint(totalMinCriticalLifePointsAdded + (damageBeforeIndex.minCriticalDamage - totalMinCriticalLifePointsAdded));
               totalMaxCriticalLifePointsAdded = uint(totalMaxCriticalLifePointsAdded + (damageBeforeIndex.maxCriticalDamage - totalMaxCriticalLifePointsAdded));
            }
            else
            {
               totalMinCriticalLifePointsAdded = uint(totalMinCriticalLifePointsAdded + healingEffect.criticalLifePointsAddedBasedOnLifePercent);
               totalMaxCriticalLifePointsAdded = uint(totalMaxCriticalLifePointsAdded + healingEffect.criticalLifePointsAddedBasedOnLifePercent);
            }
         }
         pHealDamage.minLifePointsAdded = totalMinLifePointsAdded * pEfficiencyMultiplier;
         pHealDamage.maxLifePointsAdded = totalMaxLifePointsAdded * pEfficiencyMultiplier;
         pHealDamage.minCriticalLifePointsAdded = totalMinCriticalLifePointsAdded * pEfficiencyMultiplier;
         pHealDamage.maxCriticalLifePointsAdded = totalMaxCriticalLifePointsAdded * pEfficiencyMultiplier;
         if(pSpellDamageInfo.isHealingSpell)
         {
            pHealDamage.minLifePointsAdded = pHealDamage.minLifePointsAdded > targetLostLifePoints?int(targetLostLifePoints):int(pHealDamage.minLifePointsAdded);
            pHealDamage.maxLifePointsAdded = pHealDamage.maxLifePointsAdded > targetLostLifePoints?int(targetLostLifePoints):int(pHealDamage.maxLifePointsAdded);
            pHealDamage.minCriticalLifePointsAdded = pHealDamage.minCriticalLifePointsAdded > targetLostLifePoints?int(targetLostLifePoints):int(pHealDamage.minCriticalLifePointsAdded);
            pHealDamage.maxCriticalLifePointsAdded = pHealDamage.maxCriticalLifePointsAdded > targetLostLifePoints?int(targetLostLifePoints):int(pHealDamage.maxCriticalLifePointsAdded);
         }
      }
      
      private static function computeShield(pShieldDamage:SpellDamage) : EffectDamage
      {
         var ed:* = null;
         var finalShield:EffectDamage = new EffectDamage();
         for each(ed in pShieldDamage.effectDamages)
         {
            finalShield.minShieldPointsAdded = finalShield.minShieldPointsAdded + ed.minShieldPointsAdded;
            finalShield.maxShieldPointsAdded = finalShield.maxShieldPointsAdded + ed.maxShieldPointsAdded;
            finalShield.minCriticalShieldPointsAdded = finalShield.minCriticalShieldPointsAdded + ed.minCriticalShieldPointsAdded;
            finalShield.maxCriticalShieldPointsAdded = finalShield.maxCriticalShieldPointsAdded + ed.maxCriticalShieldPointsAdded;
         }
         return finalShield;
      }
      
      private static function computeDamageWithoutResistsBoosts(pTargetId:Number, pEffect:EffectDamage, pSpellDamageInfo:SpellDamageInfo, pEfficiencyMultiplier:Number, pIgnoreCasterStats:Boolean = false, pIgnoreTargetFixedElementReduction:Boolean = false) : EffectDamage
      {
         var sd:* = null;
         sd = new SpellDamage();
         sd.addEffectDamage(pEffect);
         sd.hasCriticalDamage = pEffect.hasCritical;
         pSpellDamageInfo.targetId = pTargetId;
         return computeDamage(sd,pSpellDamageInfo,pEfficiencyMultiplier,pIgnoreCasterStats,false,false,false,true,pIgnoreTargetFixedElementReduction);
      }
      
      public static function computeDamage(pRawDamage:SpellDamage, pSpellDamageInfo:SpellDamageInfo, pEfficiencyMultiplier:Number, pIgnoreCasterStats:Boolean = false, pIgnoreCriticalResist:Boolean = false, pIgnoreTargetResists:Boolean = false, pIgnoreTargetPercentResists:Boolean = false, pIgnoreResistsBoosts:Boolean = false, pIgnoreTargetFixedElementReduction:Boolean = false) : EffectDamage
      {
         var stat:int = 0;
         var statBonus:int = 0;
         var criticalStatBonus:int = 0;
         var resistPercent:int = 0;
         var efficiencyPercent:int = 0;
         var elementReduction:int = 0;
         var elementBonus:int = 0;
         var boostable:Boolean = false;
         var efm:* = null;
         var triggeredDamagesBonus:int = 0;
         var ed:* = null;
         var totalMinBaseDmg:int = 0;
         var totalMinCriticalBaseDmg:int = 0;
         var totalMaxBaseDmg:int = 0;
         var totalMaxCriticalBaseDmg:int = 0;
         var minBaseDmg:int = 0;
         var minBaseDmgList:* = null;
         var minCriticalBaseDmg:int = 0;
         var minCriticalBaseDmgList:* = null;
         var maxBaseDmg:int = 0;
         var maxBaseDmgList:* = null;
         var maxCriticalBaseDmg:int = 0;
         var maxCriticalBaseDmgList:* = null;
         var i:int = 0;
         var j:int = 0;
         var elementStat:int = 0;
         var finalDamage:* = null;
         var damageDistance:int = 0;
         var ei:* = null;
         var maxDistance:int = 0;
         var computedEffect:* = null;
         var spellDamageModifBonus:int = 0;
         var spellBaseDamageModifBonus:int = 0;
         var spellModification:* = null;
         var targetIsDamaged:Boolean = false;
         var baseMaxLifePoints:* = 0;
         var maxLifePoints:* = 0;
         var lifePoints:* = 0;
         var lifeMin:* = 0;
         var lifeMax:* = 0;
         var criticalLifeMin:* = 0;
         var criticalLifeMax:* = 0;
         var erosionLife:int = 0;
         var dmgWithEfficiency:int = 0;
         var criticalDmgWithEfficiency:int = 0;
         var totalErosionPercent:* = 0;
         var allDamagesBonus:int = pSpellDamageInfo.casterAllDamagesBonus;
         var casterCriticalDamageBonus:int = !pSpellDamageInfo.triggeredSpell?int(pSpellDamageInfo.casterCriticalDamageBonus):0;
         var targetCriticalDamageFixedResist:int = pSpellDamageInfo.targetCriticalDamageFixedResist;
         var casterMovementPointsRatio:Number = Math.max(pSpellDamageInfo.casterMovementPoints,0) / pSpellDamageInfo.casterMaxMovementPoints;
         var lifePointsMin:uint = pSpellDamageInfo.casterLifePointsAfterNormalMinDamage > 0?uint(pSpellDamageInfo.casterLifePointsAfterNormalMinDamage):uint(pSpellDamageInfo.casterLifePoints);
         var lifePointsMax:uint = pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage > 0?uint(pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage):uint(pSpellDamageInfo.casterLifePoints);
         var criticalLifePointsMin:uint = pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage > 0?uint(pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage):uint(pSpellDamageInfo.casterLifePoints);
         var criticalLifePointsMax:uint = pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage > 0?uint(pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage):uint(pSpellDamageInfo.casterLifePoints);
         var targetLifePointsMin:uint = pSpellDamageInfo.targetLifePointsAfterNormalMinDamage > 0?uint(pSpellDamageInfo.targetLifePointsAfterNormalMinDamage):!!pSpellDamageInfo.targetInfos?uint(pSpellDamageInfo.targetInfos.stats.lifePoints):uint(0);
         var targetLifePointsMax:uint = pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage > 0?uint(pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage):!!pSpellDamageInfo.targetInfos?uint(pSpellDamageInfo.targetInfos.stats.lifePoints):uint(0);
         var targetCriticalLifePointsMin:uint = pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage > 0?uint(pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage):!!pSpellDamageInfo.targetInfos?uint(pSpellDamageInfo.targetInfos.stats.lifePoints):uint(0);
         var targetCriticalLifePointsMax:uint = pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage > 0?uint(pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage):!!pSpellDamageInfo.targetInfos?uint(pSpellDamageInfo.targetInfos.stats.lifePoints):uint(0);
         var numEffectsDamages:int = pRawDamage.effectDamages.length;
         for(i = 0; i < numEffectsDamages; )
         {
            ed = pRawDamage.effectDamages[i];
            if(!finalDamage)
            {
               finalDamage = new EffectDamage(ed.effectId,pRawDamage.element,pRawDamage.random);
            }
            resistPercent = 0;
            if(NO_BOOST_EFFECTS_IDS.indexOf(ed.effectId) != -1)
            {
               pIgnoreCasterStats = true;
            }
            efm = pSpellDamageInfo.getEffectModification(ed.effectId,i,ed.hasCritical);
            if(efm)
            {
               triggeredDamagesBonus = efm.damagesBonus;
               if(efm.shieldPoints > pSpellDamageInfo.targetTriggeredShieldPoints)
               {
                  pSpellDamageInfo.targetTriggeredShieldPoints = efm.shieldPoints;
               }
            }
            damageDistance = pSpellDamageInfo.distanceBetweenCasterAndTarget;
            for(j = 0; j < pSpellDamageInfo.spellEffects.length; )
            {
               ei = pSpellDamageInfo.spellEffects[j];
               if(ed.spellEffectOrder > j && !pSpellDamageInfo.casterStatus.cantBePushed)
               {
                  if(ei.effectId == ActionIdEnum.ACTION_CHARACTER_GET_PUSHED)
                  {
                     damageDistance = damageDistance + int(ei.parameter0);
                  }
                  else if(ei.effectId == ActionIdEnum.ACTION_CHARACTER_GET_PULLED)
                  {
                     damageDistance = damageDistance - int(ei.parameter0);
                  }
               }
               j++;
            }
            damageDistance = Math.max(damageDistance,1);
            switch(ed.element)
            {
               case NEUTRAL_ELEMENT:
                  if(!pIgnoreCasterStats)
                  {
                     elementStat = pSpellDamageInfo.casterStrength;
                     stat = elementStat + pSpellDamageInfo.casterDamagesBonus + triggeredDamagesBonus + (!!pSpellDamageInfo.isWeapon?pSpellDamageInfo.casterWeaponDamagesBonus:pSpellDamageInfo.casterSpellDamagesBonus);
                     statBonus = pSpellDamageInfo.casterStrengthBonus;
                     criticalStatBonus = pSpellDamageInfo.casterCriticalStrengthBonus;
                  }
                  if(!pIgnoreTargetResists)
                  {
                     resistPercent = pSpellDamageInfo.targetNeutralElementResistPercent;
                     elementReduction = pSpellDamageInfo.targetNeutralElementReduction;
                  }
                  elementBonus = pSpellDamageInfo.casterNeutralDamageBonus;
                  break;
               case EARTH_ELEMENT:
                  if(!pIgnoreCasterStats)
                  {
                     elementStat = pSpellDamageInfo.casterStrength;
                     stat = elementStat + pSpellDamageInfo.casterDamagesBonus + triggeredDamagesBonus + (!!pSpellDamageInfo.isWeapon?pSpellDamageInfo.casterWeaponDamagesBonus:pSpellDamageInfo.casterSpellDamagesBonus);
                     statBonus = pSpellDamageInfo.casterStrengthBonus;
                     criticalStatBonus = pSpellDamageInfo.casterCriticalStrengthBonus;
                  }
                  if(!pIgnoreTargetResists)
                  {
                     resistPercent = pSpellDamageInfo.targetEarthElementResistPercent;
                     elementReduction = pSpellDamageInfo.targetEarthElementReduction;
                  }
                  elementBonus = pSpellDamageInfo.casterEarthDamageBonus;
                  break;
               case FIRE_ELEMENT:
                  if(!pIgnoreCasterStats)
                  {
                     elementStat = pSpellDamageInfo.casterIntelligence;
                     stat = elementStat + pSpellDamageInfo.casterDamagesBonus + triggeredDamagesBonus + (!!pSpellDamageInfo.isWeapon?pSpellDamageInfo.casterWeaponDamagesBonus:pSpellDamageInfo.casterSpellDamagesBonus);
                     statBonus = pSpellDamageInfo.casterIntelligenceBonus;
                     criticalStatBonus = pSpellDamageInfo.casterCriticalIntelligenceBonus;
                  }
                  if(!pIgnoreTargetResists)
                  {
                     resistPercent = pSpellDamageInfo.targetFireElementResistPercent;
                     elementReduction = pSpellDamageInfo.targetFireElementReduction;
                  }
                  elementBonus = pSpellDamageInfo.casterFireDamageBonus;
                  break;
               case WATER_ELEMENT:
                  if(!pIgnoreCasterStats)
                  {
                     elementStat = pSpellDamageInfo.casterChance;
                     stat = elementStat + pSpellDamageInfo.casterDamagesBonus + triggeredDamagesBonus + (!!pSpellDamageInfo.isWeapon?pSpellDamageInfo.casterWeaponDamagesBonus:pSpellDamageInfo.casterSpellDamagesBonus);
                     statBonus = pSpellDamageInfo.casterChanceBonus;
                     criticalStatBonus = pSpellDamageInfo.casterCriticalChanceBonus;
                  }
                  if(!pIgnoreTargetResists)
                  {
                     resistPercent = pSpellDamageInfo.targetWaterElementResistPercent;
                     elementReduction = pSpellDamageInfo.targetWaterElementReduction;
                  }
                  elementBonus = pSpellDamageInfo.casterWaterDamageBonus;
                  break;
               case AIR_ELEMENT:
                  if(!pIgnoreCasterStats)
                  {
                     elementStat = pSpellDamageInfo.casterAgility;
                     stat = elementStat + pSpellDamageInfo.casterDamagesBonus + triggeredDamagesBonus + (!!pSpellDamageInfo.isWeapon?pSpellDamageInfo.casterWeaponDamagesBonus:pSpellDamageInfo.casterSpellDamagesBonus);
                     statBonus = pSpellDamageInfo.casterAgilityBonus;
                     criticalStatBonus = pSpellDamageInfo.casterCriticalAgilityBonus;
                  }
                  if(!pIgnoreTargetResists)
                  {
                     resistPercent = pSpellDamageInfo.targetAirElementResistPercent;
                     elementReduction = pSpellDamageInfo.targetAirElementReduction;
                  }
                  elementBonus = pSpellDamageInfo.casterAirDamageBonus;
            }
            stat = Math.max(0,stat);
            if(!pIgnoreTargetResists && ed.effect)
            {
               elementReduction = elementReduction + getBuffElementReduction(pSpellDamageInfo,ed.effect,pSpellDamageInfo.targetId);
            }
            if(pIgnoreTargetFixedElementReduction)
            {
               elementReduction = 0;
               targetCriticalDamageFixedResist = 0;
            }
            if(!pSpellDamageInfo.targetIsMonster)
            {
               resistPercent = Math.min(resistPercent,50);
            }
            if(pIgnoreTargetPercentResists)
            {
               resistPercent = 0;
            }
            resistPercent = 100 - resistPercent;
            efficiencyPercent = (!!isNaN(ed.efficiencyMultiplier)?pEfficiencyMultiplier:ed.efficiencyMultiplier) * 100;
            if(pIgnoreResistsBoosts)
            {
               resistPercent = Math.min(100,resistPercent);
            }
            boostable = true;
            if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(ed.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(ed.effectId) == -1 && ERODED_HP_BASED_DAMAGE_EFFETS_IDS.indexOf(ed.effectId) == -1)
            {
               if(pIgnoreCasterStats)
               {
                  elementBonus = allDamagesBonus = casterCriticalDamageBonus = 0;
               }
               if(pIgnoreCriticalResist)
               {
                  targetCriticalDamageFixedResist = 0;
               }
               spellDamageModifBonus = 0;
               spellBaseDamageModifBonus = 0;
               for each(spellModification in pSpellDamageInfo.spellDamageModifications)
               {
                  if(spellModification.modificationType == CharacterSpellModificationTypeEnum.DAMAGE)
                  {
                     spellDamageModifBonus = spellDamageModifBonus + (spellModification.value.base + spellModification.value.additionnal + spellModification.value.objectsAndMountBonus + spellModification.value.alignGiftBonus + spellModification.value.contextModif);
                  }
                  else if(spellModification.modificationType == CharacterSpellModificationTypeEnum.BASE_DAMAGE)
                  {
                     spellBaseDamageModifBonus = spellBaseDamageModifBonus + (spellModification.value.base + spellModification.value.additionnal + spellModification.value.objectsAndMountBonus + spellModification.value.alignGiftBonus + spellModification.value.contextModif);
                  }
               }
               minBaseDmg = getDamage(ed.minDamage,pIgnoreCasterStats,stat,statBonus,elementBonus,allDamagesBonus,spellDamageModifBonus,elementReduction,resistPercent,efficiencyPercent,spellBaseDamageModifBonus);
               minCriticalBaseDmg = getDamage(!pIgnoreCasterStats && pSpellDamageInfo.spellWeaponCriticalBonus != 0?ed.minDamage > 0?int(ed.minDamage + pSpellDamageInfo.spellWeaponCriticalBonus):0:pSpellDamageInfo.isWeapon && pSpellDamageInfo.spell.id != 0?int(ed.minDamage):int(ed.minCriticalDamage),pIgnoreCasterStats,stat,criticalStatBonus,elementBonus + casterCriticalDamageBonus,allDamagesBonus,spellDamageModifBonus,elementReduction + targetCriticalDamageFixedResist,resistPercent,efficiencyPercent,spellBaseDamageModifBonus);
               maxBaseDmg = getDamage(ed.maxDamage,pIgnoreCasterStats,stat,statBonus,elementBonus,allDamagesBonus,spellDamageModifBonus,elementReduction,resistPercent,efficiencyPercent,spellBaseDamageModifBonus);
               maxCriticalBaseDmg = getDamage(!pIgnoreCasterStats && pSpellDamageInfo.spellWeaponCriticalBonus != 0?ed.maxDamage > 0?int(ed.maxDamage + pSpellDamageInfo.spellWeaponCriticalBonus):0:pSpellDamageInfo.isWeapon && pSpellDamageInfo.spell.id != 0?int(ed.maxDamage):int(ed.maxCriticalDamage),pIgnoreCasterStats,stat,criticalStatBonus,elementBonus + casterCriticalDamageBonus,allDamagesBonus,spellDamageModifBonus,elementReduction + targetCriticalDamageFixedResist,resistPercent,efficiencyPercent,spellBaseDamageModifBonus);
               minBaseDmg = minBaseDmg < 0?0:int(minBaseDmg);
               maxBaseDmg = maxBaseDmg < 0?0:int(maxBaseDmg);
               minCriticalBaseDmg = minCriticalBaseDmg < 0?0:int(minCriticalBaseDmg);
               maxCriticalBaseDmg = maxCriticalBaseDmg < 0?0:int(maxCriticalBaseDmg);
               if(MP_BASED_DAMAGE_EFFECTS_IDS.indexOf(ed.effectId) != -1)
               {
                  minBaseDmg = minBaseDmg * casterMovementPointsRatio;
                  maxBaseDmg = maxBaseDmg * casterMovementPointsRatio;
                  minCriticalBaseDmg = minCriticalBaseDmg * casterMovementPointsRatio;
                  maxCriticalBaseDmg = maxCriticalBaseDmg * casterMovementPointsRatio;
               }
               if(DamageUtil.EROSION_DAMAGE_EFFECTS_IDS.indexOf(ed.effectId) != -1)
               {
                  ed.minErosionDamage = (pSpellDamageInfo.targetErosionLifePoints + pSpellDamageInfo.targetSpellMinErosionLifePoints) * ed.minErosionPercent / 100;
                  ed.maxErosionDamage = (pSpellDamageInfo.targetErosionLifePoints + pSpellDamageInfo.targetSpellMaxErosionLifePoints) * ed.maxErosionPercent / 100;
                  if(ed.hasCritical)
                  {
                     ed.minCriticalErosionDamage = (pSpellDamageInfo.targetErosionLifePoints + pSpellDamageInfo.targetSpellMinCriticalErosionLifePoints) * ed.minCriticalErosionPercent / 100;
                     ed.maxCriticalErosionDamage = (pSpellDamageInfo.targetErosionLifePoints + pSpellDamageInfo.targetSpellMaxCriticalErosionLifePoints) * ed.maxCriticalErosionPercent / 100;
                  }
               }
               else
               {
                  totalErosionPercent = uint(10 + pSpellDamageInfo.targetErosionPercentBonus);
                  if(totalErosionPercent > 50)
                  {
                     totalErosionPercent = 50;
                  }
                  pSpellDamageInfo.targetSpellMinErosionLifePoints = pSpellDamageInfo.targetSpellMinErosionLifePoints + minBaseDmg * totalErosionPercent / 100;
                  pSpellDamageInfo.targetSpellMaxErosionLifePoints = pSpellDamageInfo.targetSpellMaxErosionLifePoints + maxBaseDmg * totalErosionPercent / 100;
                  pSpellDamageInfo.targetSpellMinCriticalErosionLifePoints = pSpellDamageInfo.targetSpellMinCriticalErosionLifePoints + minCriticalBaseDmg * totalErosionPercent / 100;
                  pSpellDamageInfo.targetSpellMaxCriticalErosionLifePoints = pSpellDamageInfo.targetSpellMaxCriticalErosionLifePoints + maxCriticalBaseDmg * totalErosionPercent / 100;
               }
               if(!minBaseDmgList)
               {
                  minBaseDmgList = new Vector.<int>(0);
               }
               minBaseDmgList.push(minBaseDmg);
               if(!maxBaseDmgList)
               {
                  maxBaseDmgList = new Vector.<int>(0);
               }
               maxBaseDmgList.push(maxBaseDmg);
               if(!minCriticalBaseDmgList)
               {
                  minCriticalBaseDmgList = new Vector.<int>(0);
               }
               minCriticalBaseDmgList.push(minCriticalBaseDmg);
               if(!maxCriticalBaseDmgList)
               {
                  maxCriticalBaseDmgList = new Vector.<int>(0);
               }
               maxCriticalBaseDmgList.push(maxCriticalBaseDmg);
               totalMinBaseDmg = totalMinBaseDmg + minBaseDmg;
               totalMaxBaseDmg = totalMaxBaseDmg + maxBaseDmg;
               totalMinCriticalBaseDmg = totalMinCriticalBaseDmg + minCriticalBaseDmg;
               totalMaxCriticalBaseDmg = totalMaxCriticalBaseDmg + maxCriticalBaseDmg;
               computedEffect = new EffectDamage(ed.effectId,ed.element,ed.random,ed.duration,boostable);
               computedEffect.spellEffectOrder = ed.spellEffectOrder;
               computedEffect.minDamage = computedEffect.minBaseDamage = minBaseDmg;
               computedEffect.maxDamage = computedEffect.maxBaseDamage = maxBaseDmg;
               computedEffect.minCriticalDamage = computedEffect.minBaseCriticalDamage = minCriticalBaseDmg;
               computedEffect.maxCriticalDamage = computedEffect.maxBaseCriticalDamage = maxCriticalBaseDmg;
               computedEffect.minErosionDamage = ed.minErosionDamage;
               computedEffect.maxErosionDamage = ed.maxErosionDamage;
               computedEffect.minCriticalErosionDamage = ed.minCriticalErosionDamage;
               computedEffect.maxCriticalErosionDamage = ed.maxCriticalErosionDamage;
               computedEffect.hasCritical = ed.hasCritical;
               computedEffect.damageDistance = damageDistance;
               finalDamage.computedEffects.push(computedEffect);
            }
            else if(ed.computedEffects.length == 0)
            {
               if(TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(ed.effectId) != -1)
               {
                  baseMaxLifePoints = uint(pSpellDamageInfo.targetBaseMaxLifePoints);
                  maxLifePoints = uint(pSpellDamageInfo.targetMaxLifePoints);
                  lifePoints = uint(pSpellDamageInfo.targetLifePoints);
                  lifeMin = uint(targetLifePointsMin);
                  lifeMax = uint(targetLifePointsMax);
                  criticalLifeMin = uint(targetCriticalLifePointsMin);
                  criticalLifeMax = uint(targetCriticalLifePointsMax);
                  erosionLife = pSpellDamageInfo.targetErosionLifePoints;
                  targetIsDamaged = true;
               }
               else if(pSpellDamageInfo.triggeredSpell)
               {
                  baseMaxLifePoints = uint(pSpellDamageInfo.triggeredSpell.casterStats.baseMaxLifePoints);
                  maxLifePoints = uint(pSpellDamageInfo.triggeredSpell.casterStats.maxLifePoints);
                  lifePoints = uint(pSpellDamageInfo.triggeredSpell.casterStats.lifePoints);
                  lifeMin = uint(targetLifePointsMin);
                  lifeMax = uint(targetLifePointsMax);
                  criticalLifeMin = uint(targetCriticalLifePointsMin);
                  criticalLifeMax = uint(targetCriticalLifePointsMax);
                  erosionLife = pSpellDamageInfo.triggeredSpell.casterStats.baseMaxLifePoints - pSpellDamageInfo.triggeredSpell.casterStats.maxLifePoints;
                  targetIsDamaged = true;
               }
               else
               {
                  baseMaxLifePoints = uint(pSpellDamageInfo.casterBaseMaxLifePoints);
                  maxLifePoints = uint(pSpellDamageInfo.casterMaxLifePoints);
                  lifePoints = uint(pSpellDamageInfo.casterLifePoints);
                  lifeMin = uint(lifePointsMin);
                  lifeMax = uint(lifePointsMax);
                  criticalLifeMin = uint(criticalLifePointsMin);
                  criticalLifeMax = uint(criticalLifePointsMax);
                  erosionLife = pSpellDamageInfo.casterErosionLifePoints;
               }
               if(ed.effectId == ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_CASTER_LIFE_MIDLIFE)
               {
                  boostable = false;
                  dmgWithEfficiency = ed.maxDamage * baseMaxLifePoints * getMidLifeDamageMultiplier(Math.min(100,Math.max(0,100 * lifePoints / maxLifePoints))) / 100;
                  minBaseDmg = maxBaseDmg = (dmgWithEfficiency - elementReduction) * resistPercent / 100;
                  criticalDmgWithEfficiency = ed.maxCriticalDamage * baseMaxLifePoints * getMidLifeDamageMultiplier(Math.min(100,Math.max(0,100 * lifePoints / maxLifePoints))) / 100;
                  minCriticalBaseDmg = maxCriticalBaseDmg = (criticalDmgWithEfficiency - elementReduction) * resistPercent / 100;
               }
               else if(ed.effectId == ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT)
               {
                  minBaseDmg = ed.minDamage * lifeMin / 100;
                  maxBaseDmg = ed.maxDamage * lifeMax / 100;
                  if(ed.hasCritical)
                  {
                     minCriticalBaseDmg = ed.minCriticalDamage * criticalLifeMin / 100;
                     maxCriticalBaseDmg = ed.maxCriticalDamage * criticalLifeMax / 100;
                  }
                  else
                  {
                     minCriticalBaseDmg = minBaseDmg;
                     maxCriticalBaseDmg = maxBaseDmg;
                  }
               }
               else
               {
                  if(ERODED_HP_BASED_DAMAGE_EFFETS_IDS.indexOf(ed.effectId) != -1)
                  {
                     lifeMin = uint(lifeMax = uint(criticalLifeMin = uint(criticalLifeMax = uint(erosionLife))));
                  }
                  minBaseDmg = getHpBasedDamage(ed.minDamage,lifeMin,resistPercent,elementReduction,efficiencyPercent);
                  maxBaseDmg = getHpBasedDamage(ed.maxDamage,lifeMax,resistPercent,elementReduction,efficiencyPercent);
                  if(ed.hasCritical)
                  {
                     minCriticalBaseDmg = getHpBasedDamage(ed.minCriticalDamage,criticalLifeMin,resistPercent,elementReduction,efficiencyPercent);
                     maxCriticalBaseDmg = getHpBasedDamage(ed.maxCriticalDamage,criticalLifeMax,resistPercent,elementReduction,efficiencyPercent);
                  }
                  else
                  {
                     minCriticalBaseDmg = minBaseDmg;
                     maxCriticalBaseDmg = maxBaseDmg;
                  }
               }
               if(!targetIsDamaged)
               {
                  lifePointsMin = lifePointsMin - minBaseDmg;
                  lifePointsMax = lifePointsMax - maxBaseDmg;
                  criticalLifePointsMin = criticalLifePointsMin - minCriticalBaseDmg;
                  criticalLifePointsMax = criticalLifePointsMax - maxCriticalBaseDmg;
               }
               else
               {
                  targetLifePointsMin = targetLifePointsMin - minBaseDmg;
                  targetLifePointsMax = targetLifePointsMax - maxBaseDmg;
                  targetCriticalLifePointsMin = targetCriticalLifePointsMin - minCriticalBaseDmg;
                  targetCriticalLifePointsMax = targetCriticalLifePointsMax - maxCriticalBaseDmg;
               }
               §§goto(addr1681);
            }
            else
            {
               totalMinBaseDmg = totalMinBaseDmg + ed.minDamage;
               totalMaxBaseDmg = totalMaxBaseDmg + ed.maxDamage;
               totalMinCriticalBaseDmg = totalMinCriticalBaseDmg + ed.minCriticalDamage;
               totalMaxCriticalBaseDmg = totalMaxCriticalBaseDmg + ed.maxCriticalDamage;
            }
            i++;
         }
         if(!finalDamage)
         {
            finalDamage = new EffectDamage(-1,pRawDamage.element,pRawDamage.random);
         }
         finalDamage.minDamage = finalDamage.minBaseDamage = totalMinBaseDmg;
         finalDamage.minDamageList = minBaseDmgList;
         finalDamage.maxDamage = finalDamage.maxBaseDamage = totalMaxBaseDmg;
         finalDamage.maxDamageList = maxBaseDmgList;
         finalDamage.minCriticalDamage = finalDamage.minBaseCriticalDamage = totalMinCriticalBaseDmg;
         finalDamage.minCriticalDamageList = minCriticalBaseDmgList;
         finalDamage.maxCriticalDamage = finalDamage.maxBaseCriticalDamage = totalMaxCriticalBaseDmg;
         finalDamage.maxCriticalDamageList = maxCriticalBaseDmgList;
         finalDamage.minErosionDamage = pRawDamage.minErosionDamage * efficiencyPercent / 100;
         finalDamage.minErosionDamage = finalDamage.minErosionDamage * resistPercent / 100;
         finalDamage.maxErosionDamage = pRawDamage.maxErosionDamage * efficiencyPercent / 100;
         finalDamage.maxErosionDamage = finalDamage.maxErosionDamage * resistPercent / 100;
         finalDamage.minCriticalErosionDamage = pRawDamage.minCriticalErosionDamage * efficiencyPercent / 100;
         finalDamage.minCriticalErosionDamage = finalDamage.minCriticalErosionDamage * resistPercent / 100;
         finalDamage.maxCriticalErosionDamage = pRawDamage.maxCriticalErosionDamage * efficiencyPercent / 100;
         finalDamage.maxCriticalErosionDamage = finalDamage.maxCriticalErosionDamage * resistPercent / 100;
         finalDamage.hasCritical = pRawDamage.hasCriticalDamage;
         for each(ed in finalDamage.computedEffects)
         {
            maxDistance = Math.max(ed.damageDistance,maxDistance);
         }
         finalDamage.damageDistance = maxDistance;
         return finalDamage;
      }
      
      private static function getDamage(pBaseDmg:int, pIgnoreStats:Boolean, pStat:int, pStatBonus:int, pDamageBonus:int, pAllDamagesBonus:int, pSpellDamageModifBonus:int, pDamageReduction:int, pResistPercent:int, pEfficiencyPercent:int, pSpellBaseDamageModifBonus:int) : int
      {
         if(!pIgnoreStats && pStat + pStatBonus <= 0)
         {
            pStatBonus = 0;
            pStat = 0;
         }
         pBaseDmg = pBaseDmg + pSpellBaseDamageModifBonus;
         var dmg:int = pBaseDmg > 0?int(Math.floor(pBaseDmg * (100 + pStat + pStatBonus) / 100) + pDamageBonus + pAllDamagesBonus):0;
         var dmgWithEfficiency:int = dmg > 0?int((dmg + pSpellDamageModifBonus) * pEfficiencyPercent / 100):0;
         var dmgWithDamageReduction:int = dmgWithEfficiency > 0?int(dmgWithEfficiency - pDamageReduction):0;
         dmgWithDamageReduction = dmgWithDamageReduction < 0?0:int(dmgWithDamageReduction);
         return dmgWithDamageReduction * pResistPercent / 100;
      }
      
      private static function getHeal(pBaseHeal:int, pIntelligence:int, pHealBonus:int) : int
      {
         return Math.floor(pBaseHeal * (100 + pIntelligence) / 100) + (pBaseHeal > 0?pHealBonus:0);
      }
      
      private static function getMidLifeDamageMultiplier(pLifePercent:int) : Number
      {
         return Math.pow(Math.cos(2 * Math.PI * (pLifePercent * 0.01 - 0.5)) + 1,2) / 4;
      }
      
      private static function getHpBasedDamage(pBaseDmg:int, pCurrentLifePoints:uint, pResistPercent:int, pElementReduction:int, pEfficiencyPercent:int) : int
      {
         var dmgWithEfficiency:int = pBaseDmg * pCurrentLifePoints / 100 * pEfficiencyPercent / 100;
         return (dmgWithEfficiency - pElementReduction) * pResistPercent / 100;
      }
      
      private static function getDistance(pCellA:uint, pCellB:uint) : int
      {
         return MapPoint.fromCellId(pCellA).distanceToCell(MapPoint.fromCellId(pCellB));
      }
      
      private static function getSquareDistance(pCellA:uint, pCellB:uint) : int
      {
         var pt1:MapPoint = MapPoint.fromCellId(pCellA);
         var pt2:MapPoint = MapPoint.fromCellId(pCellB);
         return Math.max(Math.abs(pt1.x - pt2.x),Math.abs(pt1.y - pt2.y));
      }
      
      public static function getShapeEfficiency(pShape:uint, pSpellImpactCell:uint, pTargetCell:uint, pShapeSize:int, pShapeMinSize:int, pShapeEfficiencyPercent:int, pShapeMaxEfficiency:int) : Number
      {
         var distance:int = 0;
         switch(pShape)
         {
            case SpellShapeEnum.A:
            case SpellShapeEnum.a:
            case SpellShapeEnum.Z:
            case SpellShapeEnum.I:
            case SpellShapeEnum.O:
            case SpellShapeEnum.semicolon:
            case SpellShapeEnum.empty:
            case SpellShapeEnum.P:
               return DAMAGE_NOT_BOOSTED;
            case SpellShapeEnum.B:
            case SpellShapeEnum.V:
            case SpellShapeEnum.G:
            case SpellShapeEnum.W:
               distance = getSquareDistance(pSpellImpactCell,pTargetCell);
               break;
            case SpellShapeEnum.minus:
            case SpellShapeEnum.plus:
            case SpellShapeEnum.U:
               distance = getDistance(pSpellImpactCell,pTargetCell) / 2;
               break;
            default:
               distance = getDistance(pSpellImpactCell,pTargetCell);
         }
         return getSimpleEfficiency(distance,pShapeSize,pShapeMinSize,pShapeEfficiencyPercent,pShapeMaxEfficiency);
      }
      
      public static function getSimpleEfficiency(pDistance:int, pShapeSize:int, pShapeMinSize:int, pShapeEfficiencyPercent:int, pShapeMaxEfficiency:int) : Number
      {
         if(pShapeEfficiencyPercent == 0)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(pShapeSize <= 0 || pShapeSize >= UNLIMITED_ZONE_SIZE)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(pDistance > pShapeSize)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(pShapeEfficiencyPercent <= 0)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(pShapeMinSize != 0)
         {
            if(pDistance <= pShapeMinSize)
            {
               return DAMAGE_NOT_BOOSTED;
            }
            return Math.max(0,DAMAGE_NOT_BOOSTED - 0.01 * Math.min(pDistance - pShapeMinSize,pShapeMaxEfficiency) * pShapeEfficiencyPercent);
         }
         return Math.max(0,DAMAGE_NOT_BOOSTED - 0.01 * Math.min(pDistance,pShapeMaxEfficiency) * pShapeEfficiencyPercent);
      }
      
      public static function getPortalsSpellEfficiencyBonus(pSpellImpactCell:int) : Number
      {
         var usingPortals:Boolean = false;
         var mp:* = null;
         var portals:* = null;
         var i:int = 0;
         var portal:* = null;
         var previousPortal:* = null;
         var bonus:int = 0;
         var dist:int = 0;
         var bonusCoeff:* = 1;
         var mpWithPortals:Vector.<MapPoint> = MarkedCellsManager.getInstance().getMarksMapPoint(GameActionMarkTypeEnum.PORTAL);
         for each(mp in mpWithPortals)
         {
            if(mp.cellId == pSpellImpactCell)
            {
               usingPortals = true;
               break;
            }
         }
         if(!usingPortals)
         {
            return bonusCoeff;
         }
         var portalsCellIds:Vector.<uint> = LinkedCellsManager.getInstance().getLinks(MapPoint.fromCellId(pSpellImpactCell),mpWithPortals);
         var nbPortals:int = portalsCellIds.length;
         if(nbPortals > 1)
         {
            portals = new Vector.<MarkInstance>(0);
            for(i = 0; i < nbPortals; i++)
            {
               portals.push(MarkedCellsManager.getInstance().getMarkAtCellId(portalsCellIds[i],GameActionMarkTypeEnum.PORTAL));
            }
            for(i = 0; i < nbPortals; i++)
            {
               portal = portals[i];
               bonus = Math.max(bonus,int(portal.associatedSpellLevel.effects[0].parameter2));
               if(previousPortal)
               {
                  dist = dist + MapPoint.fromCellId(portal.cells[0]).distanceToCell(MapPoint.fromCellId(previousPortal.cells[0]));
               }
               previousPortal = portal;
            }
            bonusCoeff = Number(1 + (bonus + 2 * dist) / 100);
         }
         return bonusCoeff;
      }
      
      public static function getSplashDamages(pTriggeredSpells:Vector.<TriggeredSpell>, pSourceSpellInfo:SpellDamageInfo, pCritical:Boolean) : Vector.<SplashDamage>
      {
         var splashDamages:* = null;
         var ts:* = null;
         var sw:* = null;
         var effi:* = null;
         var spellZone:* = null;
         var spellZoneCells:* = null;
         var cell:int = 0;
         var splashTargetsIds:* = null;
         var cellEntities:* = null;
         var cellEntity:* = null;
         var ed:* = null;
         var sourceSpellDamage:* = null;
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         var casterCell:uint = EntitiesManager.getInstance().getEntity(pSourceSpellInfo.casterId).position.cellId;
         for each(ts in pTriggeredSpells)
         {
            sw = ts.spell;
            for each(effi in sw.effects)
            {
               if(SPLASH_EFFECTS_IDS.indexOf(effi.effectId) != -1 && (effi.effectId == SPLASH_HEAL_EFFECT_ID || !pSourceSpellInfo.isHealingSpell))
               {
                  spellZone = SpellZoneManager.getInstance().getSpellZone(sw,false,false,ts.targetCell,fef.getEntityInfos(ts.casterId).disposition.cellId);
                  spellZoneCells = spellZone.getCells(ts.targetCell);
                  splashTargetsIds = null;
                  if(effi.targetMask && effi.targetMask.indexOf("O") != -1 && spellZoneCells.indexOf(casterCell) == -1)
                  {
                     spellZoneCells.push(casterCell);
                  }
                  for each(cell in spellZoneCells)
                  {
                     cellEntities = EntitiesManager.getInstance().getEntitiesOnCell(cell,AnimatedCharacter);
                     for each(cellEntity in cellEntities)
                     {
                        if(fef.getEntityInfos(cellEntity.id) && verifySpellEffectMask(sw.playerId,cellEntity.id,effi,ts.targetCell,pSourceSpellInfo.casterId))
                        {
                           if(!splashDamages)
                           {
                              splashDamages = new Vector.<SplashDamage>(0);
                           }
                           if(!splashTargetsIds)
                           {
                              splashTargetsIds = new Vector.<Number>(0);
                           }
                           splashTargetsIds.push(cellEntity.id);
                        }
                     }
                  }
                  if(splashTargetsIds)
                  {
                     sourceSpellDamage = DamageUtil.getSpellDamage(pSourceSpellInfo,false,false,false);
                     if(!pCritical)
                     {
                        for each(ed in sourceSpellDamage.effectDamages)
                        {
                           ed.minCriticalDamage = ed.maxCriticalDamage = ed.minCriticalErosionDamage = ed.maxCriticalErosionDamage = 0;
                           for each(ed in ed.computedEffects)
                           {
                              ed.minCriticalDamage = ed.maxCriticalDamage = ed.minCriticalErosionDamage = ed.maxCriticalErosionDamage = 0;
                           }
                        }
                        sourceSpellDamage.minCriticalDamage = sourceSpellDamage.maxCriticalDamage = 0;
                     }
                     else
                     {
                        for each(ed in sourceSpellDamage.effectDamages)
                        {
                           ed.minDamage = ed.maxDamage = ed.minErosionDamage = ed.maxErosionDamage = 0;
                           for each(ed in ed.computedEffects)
                           {
                              ed.minDamage = ed.maxDamage = ed.minErosionDamage = ed.maxErosionDamage = 0;
                           }
                        }
                        sourceSpellDamage.minDamage = sourceSpellDamage.maxDamage = 0;
                     }
                     splashDamages.push(new SplashDamage(sw.id,sw.playerId,splashTargetsIds,sourceSpellDamage,effi as EffectInstanceDice,pSourceSpellInfo));
                  }
               }
            }
         }
         return splashDamages;
      }
      
      public static function getAverageElementResistance(pElement:uint, pEntitiesIds:Vector.<Number>) : int
      {
         var statName:* = null;
         switch(pElement)
         {
            case NEUTRAL_ELEMENT:
               statName = "neutralElementResistPercent";
               break;
            case EARTH_ELEMENT:
               statName = "earthElementResistPercent";
               break;
            case FIRE_ELEMENT:
               statName = "fireElementResistPercent";
               break;
            case WATER_ELEMENT:
               statName = "waterElementResistPercent";
               break;
            case AIR_ELEMENT:
               statName = "airElementResistPercent";
         }
         return getAverageStat(statName,pEntitiesIds);
      }
      
      public static function getAverageElementReduction(pElement:uint, pEntitiesIds:Vector.<Number>) : int
      {
         var statName:* = null;
         switch(pElement)
         {
            case NEUTRAL_ELEMENT:
               statName = "neutralElementReduction";
               break;
            case EARTH_ELEMENT:
               statName = "earthElementReduction";
               break;
            case FIRE_ELEMENT:
               statName = "fireElementReduction";
               break;
            case WATER_ELEMENT:
               statName = "waterElementReduction";
               break;
            case AIR_ELEMENT:
               statName = "airElementReduction";
         }
         return getAverageStat(statName,pEntitiesIds);
      }
      
      public static function getAverageBuffElementReduction(pSpellInfo:SpellDamageInfo, pEffectInstance:EffectInstance, pEntitiesIds:Vector.<Number>) : int
      {
         var totalBuffReduction:int = 0;
         var targetId:Number = NaN;
         for each(targetId in pEntitiesIds)
         {
            totalBuffReduction = totalBuffReduction + getBuffElementReduction(pSpellInfo,pEffectInstance,targetId);
         }
         return totalBuffReduction / pEntitiesIds.length;
      }
      
      public static function getBuffElementReduction(pSpellInfo:SpellDamageInfo, pEffectInstance:EffectInstance, pTargetId:Number) : int
      {
         var buff:* = null;
         var trigger:* = null;
         var triggers:* = null;
         var triggersList:* = null;
         var reduction:int = 0;
         var buffEffectDispelled:Boolean = false;
         var targetBuffs:Array = BuffManager.getInstance().getAllBuff(pTargetId);
         var buffSpellElementsReduced:Dictionary = new Dictionary(true);
         for each(buff in targetBuffs)
         {
            triggers = buff.effect.triggers;
            buffEffectDispelled = buff.canBeDispell() && buff.effect.duration - pSpellInfo.spellTargetEffectsDurationReduction <= 0;
            if(!buffEffectDispelled && triggers)
            {
               triggersList = triggers.split("|");
               if(!buffSpellElementsReduced[buff.castingSpell.spell.id])
               {
                  buffSpellElementsReduced[buff.castingSpell.spell.id] = new Vector.<int>(0);
               }
               for each(trigger in triggersList)
               {
                  if(buff.actionId == ActionIdEnum.ACTION_CHARACTER_LIFE_LOST_CASTER_MODERATOR && verifyEffectTrigger(pSpellInfo.casterId,pTargetId,null,pEffectInstance,pSpellInfo.isWeapon,trigger,pSpellInfo.spellCenterCell))
                  {
                     if(buffSpellElementsReduced[buff.castingSpell.spell.id].indexOf(pEffectInstance.effectElement) == -1)
                     {
                        reduction = reduction + (pSpellInfo.targetLevel / 20 + 1) * (buff.effect as EffectInstanceInteger).value;
                        if(buffSpellElementsReduced[buff.castingSpell.spell.id].indexOf(pEffectInstance.effectElement) == -1)
                        {
                           buffSpellElementsReduced[buff.castingSpell.spell.id].push(pEffectInstance.effectElement);
                        }
                     }
                  }
               }
            }
         }
         return reduction;
      }
      
      public static function getAverageStat(pStatName:String, pEntitiesIds:Vector.<Number>) : int
      {
         var entityId:Number = NaN;
         var fightEntityInfo:* = null;
         var totalStat:int = 0;
         var fef:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!fef || !pEntitiesIds || pEntitiesIds.length == 0)
         {
            return -1;
         }
         if(pStatName)
         {
            for each(entityId in pEntitiesIds)
            {
               fightEntityInfo = fef.getEntityInfos(entityId) as GameFightFighterInformations;
               totalStat = totalStat + fightEntityInfo.stats[pStatName];
            }
         }
         return totalStat / pEntitiesIds.length;
      }
      
      public static function hasMinSize(pZoneShape:int) : Boolean
      {
         return pZoneShape == SpellShapeEnum.C || pZoneShape == SpellShapeEnum.X || pZoneShape == SpellShapeEnum.Q || pZoneShape == SpellShapeEnum.plus || pZoneShape == SpellShapeEnum.sharp;
      }
      
      public static function getEntityCellBeforeIndex(pEntityId:Number, pCasterId:Number, pTargetId:Number, pSpellEffects:Vector.<EffectInstance>, pSpellEffectIndex:uint, pSpellImpactCell:int) : int
      {
         var fcf:* = null;
         var entityInfos:* = null;
         var casterInfos:* = null;
         var targetInfos:* = null;
         var casterPos:* = null;
         var targetPos:* = null;
         var effect:* = null;
         var numEffects:* = 0;
         var i:int = 0;
         var j:int = 0;
         var cellData:* = null;
         var oldPos:* = 0;
         var direction:* = 0;
         var effectZone:* = null;
         var entities:* = null;
         var entity:* = null;
         var effectZoneCells:* = null;
         var cellId:int = 0;
         var cellEntities:* = null;
         var cellEntity:* = null;
         var entityId:Number = NaN;
         var targetId:Number = NaN;
         var casterCell:* = 0;
         var previousPosition:int = 0;
         var targetCell:* = 0;
         fcf = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         if(!fcf)
         {
            return 0;
         }
         entityInfos = fcf.entitiesFrame.getEntityInfos(pEntityId) as GameFightFighterInformations;
         casterInfos = fcf.entitiesFrame.getEntityInfos(pCasterId) as GameFightFighterInformations;
         targetInfos = fcf.entitiesFrame.getEntityInfos(pTargetId) as GameFightFighterInformations;
         if(!entityInfos)
         {
            return 0;
         }
         casterPos = MapPoint.fromCellId(casterInfos.disposition.cellId);
         targetPos = !!targetInfos?MapPoint.fromCellId(targetInfos.disposition.cellId):MapPoint.fromCellId(entityInfos.disposition.cellId);
         numEffects = uint(pSpellEffects.length);
         for(i = 0; i < numEffects; )
         {
            effect = pSpellEffects[i];
            if(i <= pSpellEffectIndex)
            {
               effectZone = SpellZoneManager.getInstance().getZone(effect.zoneShape,effect.zoneSize as uint,effect.zoneMinSize as uint);
               entities = new Vector.<IEntity>(0);
               if(effectZone.radius != 63)
               {
                  effectZoneCells = effectZone.getCells(pSpellImpactCell);
                  for each(cellId in effectZoneCells)
                  {
                     cellEntities = EntitiesManager.getInstance().getEntitiesOnCell(cellId,IEntity);
                     for each(cellEntity in cellEntities)
                     {
                        entities.push(cellEntity);
                     }
                  }
               }
               else
               {
                  for each(entityId in fcf.entitiesFrame.getEntitiesIdsList())
                  {
                     entities.push(EntitiesManager.getInstance().getEntity(entityId));
                  }
               }
               for each(entity in entities)
               {
                  targetId = NaN;
                  if(!isNaN(pTargetId) && entity.id == pTargetId)
                  {
                     targetId = pTargetId;
                  }
                  else if(pEntityId != pCasterId && entity.id == pEntityId)
                  {
                     targetId = pEntityId;
                  }
                  if(!isNaN(targetId) && DamageUtil.verifySpellEffectMask(pCasterId,targetId,effect,pSpellImpactCell) && (PushUtil.PUSH_EFFECTS_IDS.indexOf(effect.effectId) != -1 && effect.targetMask != "MD" || DamageUtil.verifyEffectTrigger(pCasterId,targetId,pSpellEffects,effect,false,effect.triggers,pSpellImpactCell)))
                  {
                     switch(effect.effectId)
                     {
                        case ActionIdEnum.ACTION_CHARACTER_EXCHANGE_PLACES:
                           if(TeleportationUtil.canTeleport(pCasterId) && TeleportationUtil.canTeleport(targetId))
                           {
                              targetPos.cellId = casterPos.cellId;
                           }
                           continue;
                        case ActionIdEnum.ACTION_TELEPORT_TO_PREVIOUS_POSITION:
                           if(TeleportationUtil.canTeleport(targetId))
                           {
                              previousPosition = fcf.getFighterPreviousPosition(targetId);
                              if(previousPosition != -1)
                              {
                                 targetPos.cellId = previousPosition;
                              }
                           }
                           continue;
                        case ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_TARGET:
                           if(TeleportationUtil.canTeleport(pCasterId))
                           {
                              oldPos = uint(casterPos.cellId);
                              casterPos.cellId = casterPos.pointSymetry(targetPos).cellId;
                              if(MapDisplayManager.getInstance().getDataMapContainer())
                              {
                                 cellData = MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[casterPos.cellId];
                                 if(!cellData.mov || cellData.nonWalkableDuringFight)
                                 {
                                    casterPos.cellId = oldPos;
                                 }
                              }
                           }
                           continue;
                        case ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_CASTER:
                           if(TeleportationUtil.canTeleport(targetId))
                           {
                              oldPos = uint(targetPos.cellId);
                              targetPos.cellId = targetPos.pointSymetry(casterPos).cellId;
                              if(MapDisplayManager.getInstance().getDataMapContainer())
                              {
                                 cellData = MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[targetPos.cellId];
                                 if(!cellData.mov || cellData.nonWalkableDuringFight)
                                 {
                                    targetPos.cellId = oldPos;
                                 }
                              }
                           }
                           continue;
                        case ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_AREA_CENTER:
                           if(TeleportationUtil.canTeleport(targetId))
                           {
                              oldPos = uint(targetPos.cellId);
                              targetPos.cellId = targetPos.pointSymetry(MapPoint.fromCellId(pSpellImpactCell)).cellId;
                              if(MapDisplayManager.getInstance().getDataMapContainer())
                              {
                                 cellData = MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[targetPos.cellId];
                                 if(!cellData.mov || cellData.nonWalkableDuringFight)
                                 {
                                    targetPos.cellId = oldPos;
                                 }
                              }
                           }
                           continue;
                        case ActionIdEnum.ACTION_CHARACTER_GET_PULLED:
                           direction = uint(casterPos.advancedOrientationTo(targetPos));
                           casterCell = uint(casterPos.cellId);
                           for(j = 0; j < effect.parameter0; )
                           {
                              casterPos = casterPos.getNearestCellInDirection(direction);
                              if(casterPos && !PushUtil.isBlockingCell(casterPos.cellId,-1,false))
                              {
                                 casterCell = uint(casterPos.cellId);
                                 j++;
                                 continue;
                              }
                              break;
                           }
                           casterPos.cellId = casterCell;
                           continue;
                        default:
                           if(effect.effectId == ActionIdEnum.ACTION_CHARACTER_PULL || PushUtil.PUSH_EFFECTS_IDS.indexOf(effect.effectId) != -1)
                           {
                              direction = uint(effect.effectId == ActionIdEnum.ACTION_CHARACTER_PULL?uint(targetPos.advancedOrientationTo(casterPos)):uint(casterPos.advancedOrientationTo(targetPos)));
                              targetCell = uint(targetPos.cellId);
                              for(j = 0; j < effect.parameter0; )
                              {
                                 targetPos = targetPos.getNearestCellInDirection(direction);
                                 if(targetPos && !PushUtil.isBlockingCell(targetPos.cellId,-1,false))
                                 {
                                    targetCell = uint(targetPos.cellId);
                                    j++;
                                    continue;
                                 }
                                 break;
                              }
                              targetPos.cellId = targetCell;
                           }
                           continue;
                     }
                  }
                  else
                  {
                     continue;
                  }
               }
            }
            i++;
         }
         return pEntityId == pCasterId?int(casterPos.cellId):int(targetPos.cellId);
      }
   }
}
