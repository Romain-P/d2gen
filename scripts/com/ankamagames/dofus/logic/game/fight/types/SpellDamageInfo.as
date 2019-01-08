package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.dofus.datacenter.effects.Effect;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceMinMax;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.datacenter.monsters.MonsterGrade;
   import com.ankamagames.dofus.internalDatacenter.DataEnum;
   import com.ankamagames.dofus.internalDatacenter.items.WeaponWrapper;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
   import com.ankamagames.dofus.logic.game.fight.managers.CurrentPlayedFighterManager;
   import com.ankamagames.dofus.logic.game.fight.managers.FightersStateManager;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   import com.ankamagames.dofus.logic.game.fight.miscs.DamageUtil;
   import com.ankamagames.dofus.logic.game.fight.miscs.PushUtil;
   import com.ankamagames.dofus.network.ProtocolConstantsEnum;
   import com.ankamagames.dofus.network.enums.CharacterSpellModificationTypeEnum;
   import com.ankamagames.dofus.network.types.game.character.characteristic.CharacterBaseCharacteristic;
   import com.ankamagames.dofus.network.types.game.character.characteristic.CharacterCharacteristicsInformations;
   import com.ankamagames.dofus.network.types.game.character.characteristic.CharacterSpellModification;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMinimalStats;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.types.zones.IZone;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class SpellDamageInfo
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(SpellDamageInfo));
      
      private static var _allTriggeredSpells:Vector.<TriggeredSpell> = new Vector.<TriggeredSpell>(0);
       
      
      private var _targetId:Number;
      
      private var _targetInfos:GameFightFighterInformations;
      
      private var _originalTargetsIds:Vector.<Number>;
      
      private var _effectsModifications:Vector.<EffectModification>;
      
      private var _criticalEffectsModifications:Vector.<EffectModification>;
      
      public var isWeapon:Boolean;
      
      public var isHealingSpell:Boolean;
      
      public var casterId:Number;
      
      public var casterLevel:int;
      
      public var casterPosition:int;
      
      public var casterStrength:int;
      
      public var casterChance:int;
      
      public var casterAgility:int;
      
      public var casterIntelligence:int;
      
      public var casterLifePoints:uint;
      
      public var casterBaseMaxLifePoints:uint;
      
      public var casterMaxLifePoints:uint;
      
      public var casterLifePointsAfterNormalMinDamage:uint;
      
      public var casterLifePointsAfterNormalMaxDamage:uint;
      
      public var casterLifePointsAfterCriticalMinDamage:uint;
      
      public var casterLifePointsAfterCriticalMaxDamage:uint;
      
      public var casterErosionLifePoints:int;
      
      public var casterMovementPoints:int;
      
      public var casterMaxMovementPoints:int;
      
      public var targetLifePoints:uint;
      
      public var targetBaseMaxLifePoints:uint;
      
      public var targetMaxLifePoints:uint;
      
      public var targetLifePointsAfterNormalMinDamage:uint;
      
      public var targetLifePointsAfterNormalMaxDamage:uint;
      
      public var targetLifePointsAfterCriticalMinDamage:uint;
      
      public var targetLifePointsAfterCriticalMaxDamage:uint;
      
      public var casterStrengthBonus:int;
      
      public var casterChanceBonus:int;
      
      public var casterAgilityBonus:int;
      
      public var casterIntelligenceBonus:int;
      
      public var casterCriticalStrengthBonus:int;
      
      public var casterCriticalChanceBonus:int;
      
      public var casterCriticalAgilityBonus:int;
      
      public var casterCriticalIntelligenceBonus:int;
      
      public var casterCriticalHit:int;
      
      public var casterCriticalHitWeapon:int;
      
      public var casterHealBonus:int;
      
      public var casterAllDamagesBonus:int;
      
      public var casterDamagesBonus:int;
      
      public var casterSpellDamagesBonus:int;
      
      public var casterWeaponDamagesBonus:int;
      
      public var casterTrapBonus:int;
      
      public var casterTrapBonusPercent:int;
      
      public var casterGlyphBonusPercent:int;
      
      public var casterPermanentDamagePercent:int;
      
      public var casterPushDamageBonus:int;
      
      public var casterCriticalPushDamageBonus:int;
      
      public var casterCriticalDamageBonus:int;
      
      public var casterNeutralDamageBonus:int;
      
      public var casterEarthDamageBonus:int;
      
      public var casterWaterDamageBonus:int;
      
      public var casterAirDamageBonus:int;
      
      public var casterFireDamageBonus:int;
      
      public var casterDamageBoostPercent:int;
      
      public var casterDamageDeboostPercent:int;
      
      public var casterMeleeDamageDonePercent:int;
      
      public var casterMeleeDamageReceivedPercent:int;
      
      public var casterRangedDamageDonePercent:int;
      
      public var casterRangedDamageReceivedPercent:int;
      
      public var casterWeaponDamageDonePercent:int;
      
      public var casterweaponDamageReceivedPercent:int;
      
      public var casterSpellDamageDonePercent:int;
      
      public var casterSpellDamageReceivedPercent:int;
      
      public var casterStates:Array;
      
      public var casterStatus:FighterStatus;
      
      public var spell:Object;
      
      public var spellEffects:Vector.<EffectInstance>;
      
      public var spellCriticalEffects:Vector.<EffectInstance>;
      
      public var spellCenterCell:int;
      
      public var neutralDamage:SpellDamage;
      
      public var earthDamage:SpellDamage;
      
      public var fireDamage:SpellDamage;
      
      public var waterDamage:SpellDamage;
      
      public var airDamage:SpellDamage;
      
      public var hpBasedDamage:SpellDamage;
      
      public var interceptedDamage:SpellDamage;
      
      public var spellWeaponCriticalBonus:int;
      
      public var spellWeaponMultiplier:Number = 1;
      
      public var weaponShapeEfficiencyPercent:Object;
      
      public var heal:SpellDamage;
      
      public var shield:SpellDamage;
      
      public var spellHasCriticalDamage:Boolean;
      
      public var spellHasCriticalHeal:Boolean;
      
      public var criticalHitRate:int;
      
      public var spellHasRandomEffects:Boolean;
      
      public var spellDamageModifications:Vector.<CharacterSpellModification>;
      
      public var minimizedEffects:Boolean;
      
      public var maximizedEffects:Boolean;
      
      public var triggeredSpell:TriggeredSpell;
      
      public var spellHasLifeSteal:Boolean;
      
      public var spellHasTriggered:Boolean;
      
      public var targetLevel:int;
      
      public var targetIsMonster:Boolean;
      
      public var targetIsInvulnerable:Boolean;
      
      public var targetIsInvulnerableToMelee:Boolean;
      
      public var targetIsInvulnerableToRange:Boolean;
      
      public var targetIsUnhealable:Boolean;
      
      public var targetCell:int = -1;
      
      public var targetShieldPoints:uint;
      
      public var targetTriggeredShieldPoints:uint;
      
      public var targetNeutralElementResistPercent:int;
      
      public var targetEarthElementResistPercent:int;
      
      public var targetWaterElementResistPercent:int;
      
      public var targetAirElementResistPercent:int;
      
      public var targetFireElementResistPercent:int;
      
      public var targetBuffs:Array;
      
      public var targetStates:Array;
      
      public var targetStatus:FighterStatus;
      
      public var targetNeutralElementReduction:int;
      
      public var targetEarthElementReduction:int;
      
      public var targetWaterElementReduction:int;
      
      public var targetAirElementReduction:int;
      
      public var targetFireElementReduction:int;
      
      public var targetCriticalDamageFixedResist:int;
      
      public var targetPushDamageFixedResist:int;
      
      public var targetErosionLifePoints:int;
      
      public var targetSpellMinErosionLifePoints:int;
      
      public var targetSpellMaxErosionLifePoints:int;
      
      public var targetSpellMinCriticalErosionLifePoints:int;
      
      public var targetSpellMaxCriticalErosionLifePoints:int;
      
      public var targetErosionPercentBonus:int;
      
      public var targetMeleeDamageReceivedPercent:int;
      
      public var targetRangedDamageReceivedPercent:int;
      
      public var targetWeaponDamageReceivedPercent:int;
      
      public var targetSpellDamageReceivedPercent:int;
      
      public var pushedEntities:Vector.<PushedEntity>;
      
      public var splashDamages:Vector.<SplashDamage>;
      
      public var criticalSplashDamages:Vector.<SplashDamage>;
      
      public var reflectDamages:Vector.<ReflectDamage>;
      
      public var sharedDamage:SpellDamage;
      
      public var damageSharingTargets:Vector.<Number>;
      
      public var portalsSpellEfficiencyBonus:Number = 1;
      
      public var spellTargetEffectsDurationReduction:int;
      
      public var spellTargetEffectsDurationCriticalReduction:int;
      
      public var interceptedDamages:Vector.<InterceptedDamage>;
      
      public var interceptedEntityId:Number;
      
      public var distanceBetweenCasterAndTarget:int;
      
      public var isInterceptedDamage:Boolean;
      
      public var casterAffectedOutOfZone:Boolean;
      
      public function SpellDamageInfo()
      {
         this.interceptedDamages = new Vector.<InterceptedDamage>();
         super();
      }
      
      private static function getTriggeredSpells(pEffects:Vector.<EffectInstance>, pCasterId:Number, pTargetId:Number, pSpellCenterCell:int, parentSpellId:int, casterCell:int) : Vector.<TriggeredSpell>
      {
         var triggeredSpells:* = null;
         var spellId:int = 0;
         var spellLevel:int = 0;
         var eff:* = null;
         var triggeredSpellCaster:Number = NaN;
         var triggeredSpellTarget:Number = NaN;
         var i:int = 0;
         var stateIndex:int = 0;
         var target:* = undefined;
         var state:int = 0;
         if(!pEffects)
         {
            return null;
         }
         var numEffects:uint = pEffects.length;
         var tmpStates:Dictionary = new Dictionary();
         for(i = 0; i < numEffects; i++)
         {
            eff = pEffects[i];
            if((!eff.targetMask || eff.targetMask.indexOf("C") != -1 && DamageUtil.verifySpellEffectMask(pCasterId,pCasterId,eff,pSpellCenterCell) || DamageUtil.verifySpellEffectMask(pCasterId,pTargetId,eff,pSpellCenterCell)) && DamageUtil.verifyEffectTrigger(pCasterId,pTargetId,pEffects,eff,false,eff.triggers,pSpellCenterCell) && DamageUtil.verifySpellEffectZone(pTargetId,eff,pSpellCenterCell,casterCell))
            {
               if(eff.effectId == ActionIdEnum.ACTION_FIGHT_SET_STATE)
               {
                  if(!tmpStates[pTargetId])
                  {
                     tmpStates[pTargetId] = new Vector.<int>(0);
                  }
                  tmpStates[pTargetId].push(eff.parameter2 as int);
               }
               else if(eff.effectId == ActionIdEnum.ACTION_FIGHT_UNSET_STATE)
               {
                  if(tmpStates[pTargetId])
                  {
                     stateIndex = tmpStates[pTargetId].indexOf(eff.parameter2 as int);
                     if(stateIndex != -1)
                     {
                        tmpStates[pTargetId].splice(stateIndex,1);
                        continue;
                     }
                     continue;
                  }
               }
               else if(DamageUtil.CAST_SPELL_EFFECTS_IDS.indexOf(eff.effectId) != -1)
               {
                  switch(eff.effectId)
                  {
                     case ActionIdEnum.ACTION_TARGET_CASTS_SPELL:
                     case ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM:
                        if(eff.duration > 0)
                        {
                           continue;
                        }
                        triggeredSpellCaster = eff.targetMask.indexOf("C") != -1?Number(pCasterId):Number(pTargetId);
                        triggeredSpellTarget = pTargetId;
                        break;
                     case ActionIdEnum.ACTION_CASTER_EXECUTE_SPELL:
                        triggeredSpellCaster = pCasterId;
                        triggeredSpellTarget = eff.targetMask.indexOf("C") != -1?Number(pCasterId):Number(pTargetId);
                        break;
                     case ActionIdEnum.ACTION_TARGET_EXECUTE_SPELL_ON_SOURCE:
                        triggeredSpellCaster = pTargetId;
                        triggeredSpellTarget = pCasterId;
                  }
                  spellId = int(eff.parameter0);
                  spellLevel = int(eff.parameter1);
                  if(!triggeredSpells)
                  {
                     triggeredSpells = new Vector.<TriggeredSpell>();
                  }
                  if(tmpStates[pTargetId])
                  {
                     if(!DamageUtil.fightersStates[pTargetId])
                     {
                        DamageUtil.fightersStates[pTargetId] = new FighterStates();
                     }
                     for each(state in tmpStates[pTargetId])
                     {
                        DamageUtil.fightersStates[pTargetId].addState(state,spellId);
                     }
                  }
                  for(target in DamageUtil.fightersStates)
                  {
                     DamageUtil.fightersStates[target].addTriggeredSpell(spellId,parentSpellId);
                  }
                  triggeredSpells.push(TriggeredSpell.create(eff.triggers,spellId,spellLevel,triggeredSpellCaster,triggeredSpellTarget,eff,eff.targetMask.indexOf("C") != -1,pEffects,pCasterId,pSpellCenterCell));
                  continue;
               }
               continue;
            }
         }
         return triggeredSpells;
      }
      
      public static function fromCurrentPlayer(pSpell:Object, pCasterId:Number, pTargetId:Number = NaN, pSpellImpactCell:int = -1, pCasterAffectedOutOfZone:Boolean = false) : SpellDamageInfo
      {
         var sdi:* = null;
         var effi:* = null;
         var minimalStats:* = null;
         var effid:* = null;
         var effiMinMax:* = null;
         var ed:* = null;
         var isHealingSpell:Boolean = false;
         var casterBuffs:* = null;
         var buff:* = null;
         var spellReachedMaxStacks:* = false;
         var i:int = 0;
         var f:int = 0;
         var buffs:* = null;
         var spellId:* = undefined;
         var spellDamageModif:* = null;
         var casterInfos:* = null;
         var level:int = 0;
         var spellZone:* = null;
         var entitiesIds:* = null;
         var entityId:Number = NaN;
         var minSize:* = 0;
         var minSizeCells:* = null;
         var minSizeZone:* = null;
         var spellZoneCells:* = null;
         var effect:* = null;
         var charStats:* = null;
         var spellNumStacks:* = 0;
         var weapon:* = null;
         var hasInterceptedDamage:Boolean = false;
         var interceptedDmg:* = null;
         var triggeredSpells:* = null;
         var allTriggeredSpells:* = null;
         var triggeredSpell:* = null;
         var triggeredEffectOrder:int = 0;
         var buffValue:int = 0;
         var stackBuff:* = null;
         var triggeredSpellModifValue:int = 0;
         var spellModif:* = null;
         var spellModifValue:* = null;
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         sdi = new SpellDamageInfo();
         sdi._originalTargetsIds = new Vector.<Number>(0);
         sdi.casterId = pCasterId;
         sdi.spellEffects = pSpell.effects;
         sdi.targetId = pTargetId;
         sdi.casterStates = FightersStateManager.getInstance().getStates(sdi.casterId);
         sdi.casterStatus = FightersStateManager.getInstance().getStatus(sdi.casterId);
         sdi.spell = pSpell;
         sdi.isWeapon = !(pSpell is SpellWrapper) || pSpell.id == 0;
         sdi.spellCriticalEffects = !sdi.isWeapon?pSpell.criticalEffect:sdi.spellEffects;
         sdi.casterAffectedOutOfZone = pCasterAffectedOutOfZone;
         if(fightContextFrame)
         {
            casterInfos = fightContextFrame.entitiesFrame.getEntityInfos(sdi.casterId) as GameFightFighterInformations;
            minimalStats = casterInfos.stats;
            if(casterInfos.hasOwnProperty("level"))
            {
               level = casterInfos["level"];
            }
            else
            {
               level = PlayedCharacterManager.getInstance().infos.level;
            }
            sdi.casterLevel = Math.min(level,ProtocolConstantsEnum.MAX_LEVEL);
            sdi.casterLifePoints = minimalStats.lifePoints;
            sdi.casterBaseMaxLifePoints = sdi.casterMaxLifePoints = minimalStats.maxLifePoints;
            sdi.casterPosition = casterInfos.disposition.cellId;
            sdi.casterLifePoints = casterInfos.stats.lifePoints;
            sdi.casterBaseMaxLifePoints = casterInfos.stats.baseMaxLifePoints;
            sdi.casterMaxLifePoints = casterInfos.stats.maxLifePoints;
            sdi.casterErosionLifePoints = sdi.casterBaseMaxLifePoints - sdi.casterMaxLifePoints;
            if(!sdi.isWeapon)
            {
               for each(effi in sdi.spellEffects)
               {
                  if((effi.category == DataEnum.ACTION_TYPE_DAMAGES || DamageUtil.HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1 || PushUtil.PUSH_EFFECTS_IDS.indexOf(effi.effectId) != -1) && DamageUtil.verifySpellEffectMask(sdi.casterId,sdi.targetId,effi,pSpellImpactCell) && DamageUtil.verifySpellEffectZone(sdi.targetId,effi,pSpellImpactCell,sdi.casterPosition))
                  {
                     if(effi.rawZone)
                     {
                        spellZone = SpellZoneManager.getInstance().getZone(effi.rawZone.charCodeAt(0),effi.zoneSize as uint,effi.zoneMinSize as uint,false,effi.zoneStopAtTarget as uint,sdi.isWeapon);
                        break;
                     }
                  }
               }
            }
            else
            {
               spellZone = SpellZoneManager.getInstance().getSpellZone(pSpell,false,false,pSpellImpactCell,casterInfos.disposition.cellId);
            }
            if(spellZone)
            {
               entitiesIds = fightContextFrame.entitiesFrame.getEntitiesIdsList();
               spellZone.direction = MapPoint.fromCellId(casterInfos.disposition.cellId).advancedOrientationTo(MapPoint.fromCellId(FightContextFrame.currentCell),false);
               if(spellZone.radius == 63)
               {
                  minSize = uint(effi.zoneShape == SpellShapeEnum.I?uint(effi.zoneSize as uint):uint(effi.zoneMinSize as uint));
                  if(minSize)
                  {
                     minSizeZone = SpellZoneManager.getInstance().getZone(SpellShapeEnum.C,minSize,0);
                     minSizeCells = minSizeZone.getCells(pSpellImpactCell);
                  }
                  for each(entityId in entitiesIds)
                  {
                     if(fightContextFrame.entitiesFrame.getEntityInfos(entityId) && (!minSizeCells || minSizeCells.indexOf(fightContextFrame.entitiesFrame.getEntityInfos(entityId).disposition.cellId) == -1) && sdi._originalTargetsIds.indexOf(entityId) == -1 && DamageUtil.isDamagedOrHealedBySpell(sdi.casterId,entityId,pSpell,pSpellImpactCell))
                     {
                        sdi._originalTargetsIds.push(entityId);
                     }
                  }
               }
               else
               {
                  spellZoneCells = spellZone.getCells(pSpellImpactCell);
                  for each(entityId in entitiesIds)
                  {
                     if(fightContextFrame.entitiesFrame.getEntityInfos(entityId) && spellZoneCells.indexOf(fightContextFrame.entitiesFrame.getEntityInfos(entityId).disposition.cellId) != -1 && sdi._originalTargetsIds.indexOf(entityId) == -1 && DamageUtil.isDamagedOrHealedBySpell(sdi.casterId,entityId,pSpell,pSpellImpactCell))
                     {
                        sdi._originalTargetsIds.push(entityId);
                     }
                  }
               }
            }
            if(sdi._originalTargetsIds.indexOf(sdi.casterId) == -1 && pSpell is SpellWrapper && (pSpell as SpellWrapper).canTargetCasterOutOfZone)
            {
               sdi._originalTargetsIds.push(sdi.casterId);
            }
            if(pSpell is SpellWrapper)
            {
               for each(effect in pSpell.effects)
               {
                  if(effect.targetMask.indexOf("E263") != -1 && spellZone && spellZone.radius == 63 && sdi._targetInfos.disposition.cellId == -1)
                  {
                     sdi._originalTargetsIds.push(pTargetId);
                     break;
                  }
               }
            }
         }
         var targetIsCaster:* = sdi.targetId == sdi.casterId;
         if(pCasterId == CurrentPlayedFighterManager.getInstance().currentFighterId)
         {
            charStats = CurrentPlayedFighterManager.getInstance().getCharacteristicsInformations();
            sdi.casterMovementPoints = charStats.movementPointsCurrent;
            sdi.casterMaxMovementPoints = charStats.movementPoints.base + charStats.movementPoints.additionnal + charStats.movementPoints.objectsAndMountBonus + charStats.movementPoints.alignGiftBonus + charStats.movementPoints.contextModif;
            sdi.casterStrength = charStats.strength.base + charStats.strength.additionnal + charStats.strength.objectsAndMountBonus + charStats.strength.alignGiftBonus;
            sdi.casterChance = charStats.chance.base + charStats.chance.additionnal + charStats.chance.objectsAndMountBonus + charStats.chance.alignGiftBonus;
            sdi.casterAgility = charStats.agility.base + charStats.agility.additionnal + charStats.agility.objectsAndMountBonus + charStats.agility.alignGiftBonus;
            sdi.casterIntelligence = charStats.intelligence.base + charStats.intelligence.additionnal + charStats.intelligence.objectsAndMountBonus + charStats.intelligence.alignGiftBonus;
            sdi.casterCriticalHit = charStats.criticalHit.base + charStats.criticalHit.additionnal + charStats.criticalHit.objectsAndMountBonus + charStats.criticalHit.alignGiftBonus + charStats.criticalHit.contextModif;
            sdi.casterCriticalHitWeapon = charStats.criticalHitWeapon;
            sdi.casterHealBonus = charStats.healBonus.base + charStats.healBonus.additionnal + charStats.healBonus.objectsAndMountBonus + charStats.healBonus.alignGiftBonus + charStats.healBonus.contextModif;
            sdi.casterAllDamagesBonus = charStats.allDamagesBonus.base + charStats.allDamagesBonus.additionnal + charStats.allDamagesBonus.objectsAndMountBonus + charStats.allDamagesBonus.alignGiftBonus + charStats.allDamagesBonus.contextModif;
            sdi.casterDamagesBonus = charStats.damagesBonusPercent.base + charStats.damagesBonusPercent.additionnal + charStats.damagesBonusPercent.objectsAndMountBonus + charStats.damagesBonusPercent.alignGiftBonus + charStats.damagesBonusPercent.contextModif;
            sdi.casterTrapBonus = charStats.trapBonus.base + charStats.trapBonus.additionnal + charStats.trapBonus.objectsAndMountBonus + charStats.trapBonus.alignGiftBonus + charStats.trapBonus.contextModif;
            sdi.casterTrapBonusPercent = charStats.trapBonusPercent.base + charStats.trapBonusPercent.additionnal + charStats.trapBonusPercent.objectsAndMountBonus + charStats.trapBonusPercent.alignGiftBonus + charStats.trapBonusPercent.contextModif;
            sdi.casterGlyphBonusPercent = charStats.glyphBonusPercent.base + charStats.glyphBonusPercent.additionnal + charStats.glyphBonusPercent.objectsAndMountBonus + charStats.glyphBonusPercent.alignGiftBonus + charStats.glyphBonusPercent.contextModif;
            sdi.casterPermanentDamagePercent = charStats.permanentDamagePercent.base + charStats.permanentDamagePercent.additionnal + charStats.permanentDamagePercent.objectsAndMountBonus + charStats.permanentDamagePercent.alignGiftBonus + charStats.permanentDamagePercent.contextModif;
            sdi.casterPushDamageBonus = charStats.pushDamageBonus.base + charStats.pushDamageBonus.additionnal + charStats.pushDamageBonus.objectsAndMountBonus + charStats.pushDamageBonus.alignGiftBonus + charStats.pushDamageBonus.contextModif;
            sdi.casterCriticalPushDamageBonus = charStats.pushDamageBonus.base + charStats.pushDamageBonus.additionnal + charStats.pushDamageBonus.objectsAndMountBonus + charStats.pushDamageBonus.alignGiftBonus + charStats.pushDamageBonus.contextModif;
            sdi.casterCriticalDamageBonus = charStats.criticalDamageBonus.base + charStats.criticalDamageBonus.additionnal + charStats.criticalDamageBonus.objectsAndMountBonus + charStats.criticalDamageBonus.alignGiftBonus + charStats.criticalDamageBonus.contextModif;
            sdi.casterNeutralDamageBonus = charStats.neutralDamageBonus.base + charStats.neutralDamageBonus.additionnal + charStats.neutralDamageBonus.objectsAndMountBonus + charStats.neutralDamageBonus.alignGiftBonus + charStats.neutralDamageBonus.contextModif;
            sdi.casterEarthDamageBonus = charStats.earthDamageBonus.base + charStats.earthDamageBonus.additionnal + charStats.earthDamageBonus.objectsAndMountBonus + charStats.earthDamageBonus.alignGiftBonus + charStats.earthDamageBonus.contextModif;
            sdi.casterWaterDamageBonus = charStats.waterDamageBonus.base + charStats.waterDamageBonus.additionnal + charStats.waterDamageBonus.objectsAndMountBonus + charStats.waterDamageBonus.alignGiftBonus + charStats.waterDamageBonus.contextModif;
            sdi.casterAirDamageBonus = charStats.airDamageBonus.base + charStats.airDamageBonus.additionnal + charStats.airDamageBonus.objectsAndMountBonus + charStats.airDamageBonus.alignGiftBonus + charStats.airDamageBonus.contextModif;
            sdi.casterFireDamageBonus = charStats.fireDamageBonus.base + charStats.fireDamageBonus.additionnal + charStats.fireDamageBonus.objectsAndMountBonus + charStats.fireDamageBonus.alignGiftBonus + charStats.fireDamageBonus.contextModif;
            sdi.casterMeleeDamageDonePercent = charStats.meleeDamageDonePercent.base + charStats.meleeDamageDonePercent.additionnal + charStats.meleeDamageDonePercent.objectsAndMountBonus + charStats.meleeDamageDonePercent.alignGiftBonus;
            sdi.casterMeleeDamageReceivedPercent = charStats.meleeDamageReceivedPercent.base + charStats.meleeDamageReceivedPercent.additionnal + charStats.meleeDamageReceivedPercent.objectsAndMountBonus + charStats.meleeDamageReceivedPercent.alignGiftBonus;
            sdi.casterRangedDamageDonePercent = charStats.rangedDamageDonePercent.base + charStats.rangedDamageDonePercent.additionnal + charStats.rangedDamageDonePercent.objectsAndMountBonus + charStats.rangedDamageDonePercent.alignGiftBonus;
            sdi.casterRangedDamageReceivedPercent = charStats.rangedDamageReceivedPercent.base + charStats.rangedDamageReceivedPercent.additionnal + charStats.rangedDamageReceivedPercent.objectsAndMountBonus + charStats.rangedDamageReceivedPercent.alignGiftBonus;
            sdi.casterWeaponDamageDonePercent = charStats.weaponDamageDonePercent.base + charStats.weaponDamageDonePercent.additionnal + charStats.weaponDamageDonePercent.objectsAndMountBonus + charStats.weaponDamageDonePercent.alignGiftBonus;
            sdi.casterweaponDamageReceivedPercent = charStats.weaponDamageReceivedPercent.base + charStats.weaponDamageReceivedPercent.additionnal + charStats.weaponDamageReceivedPercent.objectsAndMountBonus + charStats.weaponDamageReceivedPercent.alignGiftBonus;
            sdi.casterSpellDamageDonePercent = charStats.spellDamageDonePercent.base + charStats.spellDamageDonePercent.additionnal + charStats.spellDamageDonePercent.objectsAndMountBonus + charStats.spellDamageDonePercent.alignGiftBonus;
            sdi.casterSpellDamageReceivedPercent = charStats.spellDamageReceivedPercent.base + charStats.spellDamageReceivedPercent.additionnal + charStats.spellDamageReceivedPercent.objectsAndMountBonus + charStats.spellDamageReceivedPercent.alignGiftBonus;
         }
         else if(fightContextFrame)
         {
            sdi.casterMovementPoints = minimalStats.movementPoints;
            sdi.casterMaxMovementPoints = minimalStats.maxMovementPoints;
            sdi.casterMeleeDamageReceivedPercent = minimalStats.meleeDamageReceivedPercent;
            sdi.casterRangedDamageReceivedPercent = minimalStats.rangedDamageReceivedPercent;
            sdi.casterWeaponDamageDonePercent = minimalStats.weaponDamageReceivedPercent;
            sdi.casterSpellDamageReceivedPercent = minimalStats.spellDamageReceivedPercent;
         }
         if(fightContextFrame)
         {
            sdi.portalsSpellEfficiencyBonus = DamageUtil.getPortalsSpellEfficiencyBonus(FightContextFrame.currentCell);
         }
         sdi.neutralDamage = DamageUtil.getSpellElementDamage(pSpell,DamageUtil.NEUTRAL_ELEMENT,sdi.casterId,pTargetId,pSpellImpactCell,sdi.casterPosition);
         sdi.earthDamage = DamageUtil.getSpellElementDamage(pSpell,DamageUtil.EARTH_ELEMENT,sdi.casterId,pTargetId,pSpellImpactCell,sdi.casterPosition);
         sdi.fireDamage = DamageUtil.getSpellElementDamage(pSpell,DamageUtil.FIRE_ELEMENT,sdi.casterId,pTargetId,pSpellImpactCell,sdi.casterPosition);
         sdi.waterDamage = DamageUtil.getSpellElementDamage(pSpell,DamageUtil.WATER_ELEMENT,sdi.casterId,pTargetId,pSpellImpactCell,sdi.casterPosition);
         sdi.airDamage = DamageUtil.getSpellElementDamage(pSpell,DamageUtil.AIR_ELEMENT,sdi.casterId,pTargetId,pSpellImpactCell,sdi.casterPosition);
         sdi.spellHasCriticalDamage = sdi.isWeapon && !targetIsCaster && PlayedCharacterManager.getInstance().currentWeapon && PlayedCharacterManager.getInstance().currentWeapon.criticalHitProbability > 0 || sdi.neutralDamage.hasCriticalDamage || sdi.earthDamage.hasCriticalDamage || sdi.fireDamage.hasCriticalDamage || sdi.waterDamage.hasCriticalDamage || sdi.airDamage.hasCriticalDamage;
         var criticalHitRate:int = sdi.isWeapon && pSpell.id != 0?int(55 - (!!PlayedCharacterManager.getInstance().currentWeapon?PlayedCharacterManager.getInstance().currentWeapon.criticalHitProbability:0) - sdi.casterCriticalHit):int(pSpell.playerCriticalRate);
         if(criticalHitRate > 55)
         {
            criticalHitRate = 55;
         }
         sdi.criticalHitRate = 55 - 1 / (1 / criticalHitRate);
         sdi.criticalHitRate = sdi.criticalHitRate > 100?100:int(sdi.criticalHitRate);
         sdi.shield = new SpellDamage();
         if(targetIsCaster)
         {
            sdi.reflectDamages = sdi.getReflectDamages();
            sdi.spellHasLifeSteal = sdi.hasLifeSteal();
         }
         sdi.hpBasedDamage = new SpellDamage();
         sdi.heal = new SpellDamage();
         for each(effi in pSpell.effects)
         {
            if(DamageUtil.HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1 && (effi.effectId != ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT || pTargetId != sdi.casterId))
            {
               if(sdi.isWeapon && !targetIsCaster || DamageUtil.verifySpellEffectMask(sdi.casterId,pTargetId,effi,pSpellImpactCell))
               {
                  isHealingSpell = true;
               }
            }
            else if(effi.category == DataEnum.ACTION_TYPE_DAMAGES && (sdi.isWeapon && !targetIsCaster || DamageUtil.verifySpellEffectMask(sdi.casterId,pTargetId,effi,pSpellImpactCell)))
            {
               isHealingSpell = false;
               break;
            }
         }
         sdi.isHealingSpell = isHealingSpell;
         casterBuffs = BuffManager.getInstance().getAllBuff(sdi.casterId);
         if(!sdi.isWeapon)
         {
            for each(buff in casterBuffs)
            {
               if(buff.castingSpell.spell.id == pSpell.id)
               {
                  if(buff.stack && buff.stack.length > 1)
                  {
                     spellNumStacks = uint(buff.stack.length);
                     break;
                  }
                  spellNumStacks++;
               }
            }
            spellReachedMaxStacks = spellNumStacks == pSpell.spellLevelInfos.maxStack;
         }
         var sortedBuffs:Array = !!casterBuffs?casterBuffs.sortOn("uid"):null;
         var firstDamageEffectOrder:int = getMinimumDamageEffectOrder(sdi.casterId,pTargetId,pSpell.effects,pSpellImpactCell);
         var numEffects:int = pSpell.effects.length;
         var effectsBeforeDamage:Vector.<EffectInstance> = new Vector.<EffectInstance>(0);
         var numTargetsMultiplier:uint = Math.max(sdi.originalTargetsIds.length,1);
         for(i = 0; i < numEffects; )
         {
            effi = pSpell.effects[i];
            if(sdi.isWeapon && !targetIsCaster || effi.effectId != ActionIdEnum.ACTION_CHARACTER_LIFE_POINTS_LOST_BASED_ON_CASTER_LIFE && effi.effectId != ActionIdEnum.ACTION_CHARACTER_BOOST_SHIELD_BASED_ON_CASTER_LIFE && effi.targetMask && effi.targetMask.indexOf("C") != -1 && DamageUtil.verifySpellEffectMask(sdi.casterId,sdi.casterId,effi,pSpellImpactCell) || DamageUtil.verifySpellEffectMask(sdi.casterId,pTargetId,effi,pSpellImpactCell))
            {
               effid = effi as EffectInstanceDice;
               if(i < firstDamageEffectOrder)
               {
                  effectsBeforeDamage.push(effi);
               }
               if(DamageUtil.HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1 && (effi.effectId != ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT || pTargetId != sdi.casterId))
               {
                  ed = new EffectDamage(effi.effectId,-1,effi.random,effi.duration);
                  ed.spellEffectOrder = i;
                  if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT)
                  {
                     sdi.heal.addEffectDamage(ed);
                     ed.lifePointsAddedBasedOnLifePercent = ed.lifePointsAddedBasedOnLifePercent + effid.diceNum * sdi.casterLifePoints / 100;
                  }
                  else
                  {
                     sdi.heal.addEffectDamage(ed);
                     if(effi.effectId == ActionIdEnum.ACTION_GAIN_LIFE_ON_TARGET_LIFE_PERCENT)
                     {
                        if(sdi.targetInfos)
                        {
                           ed.lifePointsAddedBasedOnLifePercent = ed.lifePointsAddedBasedOnLifePercent + effid.diceNum * sdi.targetInfos.stats.maxLifePoints / 100;
                        }
                     }
                     else if(effi is EffectInstanceDice)
                     {
                        ed.minLifePointsAdded = ed.minLifePointsAdded + effid.diceNum;
                        ed.maxLifePointsAdded = ed.maxLifePointsAdded + (effid.diceSide == 0?effid.diceNum:effid.diceSide);
                     }
                     else if(effi is EffectInstanceMinMax)
                     {
                        effiMinMax = effi as EffectInstanceMinMax;
                        ed.minLifePointsAdded = ed.minLifePointsAdded + effiMinMax.min;
                        ed.maxLifePointsAdded = ed.maxLifePointsAdded + effiMinMax.max;
                     }
                  }
               }
               else if(DamageUtil.IMMEDIATE_BOOST_EFFECTS_IDS.indexOf(effi.effectId) != -1 && i < firstDamageEffectOrder)
               {
                  addImmediateBoost(sdi,sortedBuffs,effid,spellReachedMaxStacks,numTargetsMultiplier,false);
               }
               else if(effi.triggers == "I" && (DamageUtil.TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) != -1 || DamageUtil.HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) != -1))
               {
                  ed = new EffectDamage(effi.effectId,effi.effectElement,effi.random,effi.duration);
                  ed.spellEffectOrder = i;
                  sdi.hpBasedDamage.addEffectDamage(ed);
                  ed.minDamage = ed.maxDamage = effid.diceNum;
               }
               else if(DamageUtil.SHIELD_GAIN_EFFECTS_IDS.indexOf(effi.effectId) != -1)
               {
                  ed = new EffectDamage(effi.effectId,-1,effi.random,effi.duration);
                  ed.spellEffectOrder = i;
                  sdi.shield.addEffectDamage(ed);
                  if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_BOOST_SHIELD_BASED_ON_CASTER_LIFE)
                  {
                     ed.minShieldPointsAdded = ed.maxShieldPointsAdded = effid.diceNum * sdi.casterMaxLifePoints / 100;
                  }
                  else if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_BOOST_SHIELD)
                  {
                     if(effi is EffectInstanceDice)
                     {
                        ed.minShieldPointsAdded = ed.minShieldPointsAdded + effid.diceNum;
                        ed.maxShieldPointsAdded = ed.maxShieldPointsAdded + (effid.diceSide == 0?effid.diceNum:effid.diceSide);
                     }
                     else if(effi is EffectInstanceMinMax)
                     {
                        effiMinMax = effi as EffectInstanceMinMax;
                        ed.minShieldPointsAdded = ed.minShieldPointsAdded + effiMinMax.min;
                        ed.maxShieldPointsAdded = ed.maxShieldPointsAdded + effiMinMax.max;
                     }
                  }
               }
               if((firstDamageEffectOrder == -1 || i < firstDamageEffectOrder) && effi.effectId == ActionIdEnum.ACTION_CHARACTER_SHORTEN_ACTIVE_EFFECTS_DURATION)
               {
                  sdi.spellTargetEffectsDurationReduction = effid.diceNum;
               }
            }
            i++;
         }
         var numHealingEffectDamages:int = sdi.heal.effectDamages.length;
         var numShieldEffectDamages:int = sdi.shield.effectDamages.length;
         var numCriticalEffects:int = !!pSpell.criticalEffect?int(pSpell.criticalEffect.length):0;
         var criticalFirstDamageEffectOrder:int = numCriticalEffects > 0?int(getMinimumDamageEffectOrder(sdi.casterId,pTargetId,pSpell.criticalEffect,pSpellImpactCell)):0;
         for(i = 0; i < numCriticalEffects; )
         {
            effi = pSpell.criticalEffect[i];
            if(DamageUtil.verifySpellEffectMask(sdi.casterId,pTargetId,effi,pSpellImpactCell))
            {
               effid = effi as EffectInstanceDice;
               if(DamageUtil.HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1 && (effi.effectId != ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT || pTargetId != sdi.casterId))
               {
                  if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT)
                  {
                     if(i < numHealingEffectDamages)
                     {
                        ed = sdi.heal.effectDamages[i];
                     }
                     else
                     {
                        ed = new EffectDamage(effi.effectId,-1,effi.random,effi.duration);
                        ed.spellEffectOrder = i;
                        sdi.heal.addEffectDamage(ed);
                     }
                  }
                  if(effi.effectId == ActionIdEnum.ACTION_GAIN_LIFE_ON_TARGET_LIFE_PERCENT)
                  {
                     if(sdi.targetInfos)
                     {
                        ed.criticalLifePointsAddedBasedOnLifePercent = ed.criticalLifePointsAddedBasedOnLifePercent + effid.diceNum * sdi.targetInfos.stats.maxLifePoints / 100;
                     }
                  }
                  else if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT && pTargetId != sdi.casterId)
                  {
                     ed.criticalLifePointsAddedBasedOnLifePercent = ed.criticalLifePointsAddedBasedOnLifePercent + effid.diceNum * sdi.casterLifePoints / 100;
                  }
                  else if(effi is EffectInstanceDice)
                  {
                     ed.minCriticalLifePointsAdded = ed.minCriticalLifePointsAdded + effid.diceNum;
                     ed.maxCriticalLifePointsAdded = ed.maxCriticalLifePointsAdded + (effid.diceSide == 0?effid.diceNum:effid.diceSide);
                  }
                  else if(effi is EffectInstanceMinMax)
                  {
                     effiMinMax = effi as EffectInstanceMinMax;
                     ed.minCriticalLifePointsAdded = ed.minCriticalLifePointsAdded + effiMinMax.min;
                     ed.maxCriticalLifePointsAdded = ed.maxCriticalLifePointsAdded + effiMinMax.max;
                  }
                  sdi.spellHasCriticalHeal = true;
               }
               else if(DamageUtil.IMMEDIATE_BOOST_EFFECTS_IDS.indexOf(effi.effectId) != -1 && i < criticalFirstDamageEffectOrder)
               {
                  addImmediateBoost(sdi,sortedBuffs,effid,spellReachedMaxStacks,numTargetsMultiplier,true);
               }
               else if(effi.triggers == "I" && (DamageUtil.TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) != -1 || DamageUtil.HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effi.effectId) != -1))
               {
                  ed = sdi.hpBasedDamage.effectDamages[f];
                  f++;
                  ed.minCriticalDamage = ed.maxCriticalDamage = effid.diceNum;
                  sdi.spellHasCriticalDamage = sdi.hpBasedDamage.hasCriticalDamage = ed.hasCritical = true;
               }
               else if(DamageUtil.SHIELD_GAIN_EFFECTS_IDS.indexOf(effi.effectId) != -1)
               {
                  if(i < numShieldEffectDamages)
                  {
                     ed = sdi.shield.effectDamages[i];
                  }
                  else
                  {
                     ed = new EffectDamage(effi.effectId,-1,effi.random,effi.duration);
                     ed.spellEffectOrder = i;
                     sdi.shield.addEffectDamage(ed);
                  }
                  if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_BOOST_SHIELD_BASED_ON_CASTER_LIFE)
                  {
                     ed.minCriticalShieldPointsAdded = ed.maxCriticalShieldPointsAdded = effid.diceNum * sdi.casterMaxLifePoints / 100;
                  }
                  else if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_BOOST_SHIELD)
                  {
                     if(effi is EffectInstanceDice)
                     {
                        ed.minCriticalShieldPointsAdded = ed.minCriticalShieldPointsAdded + effid.diceNum;
                        ed.maxCriticalShieldPointsAdded = ed.maxCriticalShieldPointsAdded + (effid.diceSide == 0?effid.diceNum:effid.diceSide);
                     }
                     else if(effi is EffectInstanceMinMax)
                     {
                        effiMinMax = effi as EffectInstanceMinMax;
                        ed.minCriticalShieldPointsAdded = ed.minCriticalShieldPointsAdded + effiMinMax.min;
                        ed.maxCriticalShieldPointsAdded = ed.maxCriticalShieldPointsAdded + effiMinMax.max;
                     }
                  }
               }
               if((criticalFirstDamageEffectOrder == -1 || i < criticalFirstDamageEffectOrder) && effi.effectId == ActionIdEnum.ACTION_CHARACTER_SHORTEN_ACTIVE_EFFECTS_DURATION)
               {
                  sdi.spellTargetEffectsDurationCriticalReduction = effid.diceNum;
               }
            }
            i++;
         }
         sdi.spellHasRandomEffects = sdi.neutralDamage.hasRandomEffects || sdi.earthDamage.hasRandomEffects || sdi.fireDamage.hasRandomEffects || sdi.waterDamage.hasRandomEffects || sdi.airDamage.hasRandomEffects || sdi.heal.hasRandomEffects;
         if(sdi.isWeapon && pSpell.id != 0)
         {
            weapon = PlayedCharacterManager.getInstance().currentWeapon;
            sdi.spellWeaponCriticalBonus = weapon.criticalHitBonus;
            if(weapon.type.id == DataEnum.ITEM_TYPE_HAMMER)
            {
               sdi.weaponShapeEfficiencyPercent = 25;
            }
         }
         sdi.spellCenterCell = pSpellImpactCell;
         var groupedBuffs:Dictionary = groupBuffsBySpell(casterBuffs);
         for(spellId in groupedBuffs)
         {
            buffs = groupedBuffs[spellId];
            sdi.interceptedDamages.length = 0;
            for each(buff in buffs)
            {
               if((buff.effect.triggers == "I" || !buff.trigger) && buff.active && (!buff.hasOwnProperty("delay") || buff["delay"] == 0))
               {
                  switch(buff.actionId)
                  {
                     case ActionIdEnum.ACTION_BOOST_SPELL_DAMAGES_PERCENT:
                        sdi.casterSpellDamagesBonus = sdi.casterSpellDamagesBonus + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_FIGHT_BOOST_WEAPON_DAMAGE_POWER:
                        sdi.casterWeaponDamagesBonus = sdi.casterWeaponDamagesBonus + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_BOOST_FINAL_DAMAGES_PERCENT:
                        sdi.casterDamageBoostPercent = sdi.casterDamageBoostPercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_DEBOOST_FINAL_DAMAGES_PERCENT:
                        sdi.casterDamageDeboostPercent = sdi.casterDamageDeboostPercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_UNLUCKY:
                        sdi.minimizedEffects = true;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_SACRIFY:
                        if(sdi.targetId != buff.source)
                        {
                           hasInterceptedDamage = false;
                           for each(interceptedDmg in sdi.interceptedDamages)
                           {
                              if(interceptedDmg.buffId == buff.id)
                              {
                                 hasInterceptedDamage = true;
                              }
                           }
                           if(!hasInterceptedDamage)
                           {
                              sdi.interceptedDamages.push(new InterceptedDamage(buff.id,buff.source,sdi.casterId));
                           }
                        }
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_DEALT_DAMAGE_PERCENT_MULTIPLIER_MELEE:
                        sdi.casterMeleeDamageDonePercent = sdi.casterMeleeDamageDonePercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_RECEIVED_DAMAGE_PERCENT_MULTIPLIER_MELEE:
                        sdi.casterMeleeDamageReceivedPercent = sdi.casterMeleeDamageReceivedPercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_DEALT_DAMAGE_PERCENT_MULTIPLIER_DISTANCE:
                        sdi.casterRangedDamageDonePercent = sdi.casterRangedDamageDonePercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_RECEIVED_DAMAGE_PERCENT_MULTIPLIER_DISTANCE:
                        sdi.casterRangedDamageReceivedPercent = sdi.casterRangedDamageReceivedPercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_DEALT_DAMAGE_PERCENT_MULTIPLIER_WEAPON:
                        sdi.casterWeaponDamageDonePercent = sdi.casterWeaponDamageDonePercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_RECEIVED_DAMAGE_PERCENT_MULTIPLIER_WEAPON:
                        sdi.casterweaponDamageReceivedPercent = sdi.casterweaponDamageReceivedPercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_DEALT_DAMAGE_PERCENT_MULTIPLIER_SPELLS:
                        sdi.casterSpellDamageDonePercent = sdi.casterSpellDamageDonePercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_RECEIVED_DAMAGE_PERCENT_MULTIPLIER_SPELLS:
                        sdi.casterSpellDamageReceivedPercent = sdi.casterSpellDamageReceivedPercent + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_STRENGTH:
                        sdi.casterStrength = sdi.casterStrength + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_CHANCE:
                        sdi.casterChance = sdi.casterChance + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_AGILITY:
                        sdi.casterAgility = sdi.casterAgility + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_INTELLIGENCE:
                        sdi.casterIntelligence = sdi.casterIntelligence + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_VITALITY:
                        sdi.casterLifePoints = sdi.casterLifePoints + buff.param1;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_BOOST_DEALT_DAMAGE_PERCENT_MULTIPLIER_WEAPON:
                        sdi.spellWeaponMultiplier = sdi.spellWeaponMultiplier + buff.param1 / 100;
                        continue;
                     case ActionIdEnum.ACTION_CHARACTER_DEBOOST_DEALT_DAMAGE_PERCENT_MULTIPLIER_WEAPON:
                        sdi.spellWeaponMultiplier = sdi.spellWeaponMultiplier - buff.param1 / 100;
                        continue;
                     default:
                        continue;
                  }
               }
               else
               {
                  continue;
               }
            }
         }
         sdi.spellDamageModifications = new Vector.<CharacterSpellModification>(0);
         spellDamageModif = CurrentPlayedFighterManager.getInstance().getSpellModifications(pSpell.id,CharacterSpellModificationTypeEnum.DAMAGE);
         if(spellDamageModif)
         {
            sdi.spellDamageModifications.push(spellDamageModif);
         }
         var spellBaseDamageModif:CharacterSpellModification = CurrentPlayedFighterManager.getInstance().getSpellModifications(pSpell.id,CharacterSpellModificationTypeEnum.BASE_DAMAGE);
         if(spellBaseDamageModif)
         {
            sdi.spellDamageModifications.push(spellBaseDamageModif);
         }
         if(effectsBeforeDamage.length)
         {
            triggeredSpells = getTriggeredSpells(effectsBeforeDamage,sdi.casterId,sdi.targetId,sdi.spellCenterCell,sdi.spell.id,sdi.casterPosition);
            if(triggeredSpells)
            {
               allTriggeredSpells = getAllTriggeredSpells(triggeredSpells,sdi.spellCenterCell);
               for each(triggeredSpell in allTriggeredSpells)
               {
                  for each(effect in triggeredSpell.spell.effects)
                  {
                     if(effect.targetMask.indexOf("C") != -1 && DamageUtil.verifySpellEffectMask(sdi.casterId,sdi.casterId,effect,sdi.spellCenterCell) && DamageUtil.verifyEffectTrigger(sdi.casterId,sdi.targetId,triggeredSpell.spell.effects,effect,sdi.isWeapon,effect.triggers,sdi.spellCenterCell))
                     {
                        switch(effect.effectId)
                        {
                           case ActionIdEnum.ACTION_BOOST_FINAL_DAMAGES_PERCENT:
                              triggeredEffectOrder = triggeredSpell.spell.effects.indexOf(effect);
                              if(groupedBuffs)
                              {
                                 for each(buff in groupedBuffs[triggeredSpell.spell.id])
                                 {
                                    if(buff.effect.effectId == ActionIdEnum.ACTION_BOOST_FINAL_DAMAGES_PERCENT && buff.effect.triggers == "I" && (!buff.hasOwnProperty("delay") || buff["delay"] == 0))
                                    {
                                       buffValue = 0;
                                       if(!buff.stack && buff.effectOrder == triggeredEffectOrder)
                                       {
                                          buffValue = buff.param1;
                                       }
                                       for each(stackBuff in buff.stack)
                                       {
                                          if(stackBuff.effectOrder == triggeredEffectOrder)
                                          {
                                             buffValue = stackBuff.param1;
                                             break;
                                          }
                                       }
                                       sdi.casterDamageBoostPercent = sdi.casterDamageBoostPercent - buffValue;
                                    }
                                 }
                              }
                              sdi.casterDamageBoostPercent = sdi.casterDamageBoostPercent + (effect as EffectInstanceDice).diceNum;
                              continue;
                           case ActionIdEnum.ACTION_BOOST_SPELL_BASE_DMG:
                              if(effect.parameter0 == pSpell.id)
                              {
                                 triggeredSpellModifValue = effect.parameter2 as int;
                                 if(spellBaseDamageModif)
                                 {
                                    for(spellId in groupedBuffs)
                                    {
                                       for each(buff in groupedBuffs[spellId])
                                       {
                                          if(buff.actionId == ActionIdEnum.ACTION_BOOST_SPELL_BASE_DMG && buff.param1 == pSpell.id)
                                          {
                                             if(spellId == triggeredSpell.spell.id)
                                             {
                                                triggeredSpellModifValue = triggeredSpellModifValue - buff.param3;
                                             }
                                          }
                                       }
                                    }
                                 }
                                 for(i = 0; i < sdi.originalTargetsIds.length; )
                                 {
                                    spellModif = new CharacterSpellModification();
                                    spellModifValue = new CharacterBaseCharacteristic();
                                    spellModifValue.initCharacterBaseCharacteristic(0,0,0,0,triggeredSpellModifValue);
                                    spellModif.initCharacterSpellModification(CharacterSpellModificationTypeEnum.BASE_DAMAGE,pSpell.id,spellModifValue);
                                    sdi.spellDamageModifications.push(spellModif);
                                    i++;
                                 }
                              }
                              continue;
                           default:
                              continue;
                        }
                     }
                     else
                     {
                        continue;
                     }
                  }
               }
            }
         }
         return sdi;
      }
      
      public static function fromBuff(pBuff:BasicBuff, pSpellImpactCell:int = -1, pCasterAffectedOutOfZone:Boolean = false) : SpellDamageInfo
      {
         var sdi:* = null;
         var monster:* = null;
         var monsterGrade:* = null;
         var spell:SpellWrapper = SpellWrapper.create(pBuff.castingSpell.spell.id,pBuff.castingSpell.spellRank.grade,false,pBuff.source);
         var monsterInfos:GameFightMonsterInformations = (Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame).getEntityInfos(pBuff.source) as GameFightMonsterInformations;
         if(monsterInfos)
         {
            monster = Monster.getMonsterById(monsterInfos.creatureGenericId);
            monsterGrade = monster.getMonsterGrade(monsterInfos.creatureGrade);
            sdi = new SpellDamageInfo();
            sdi.spellEffects = spell.effects;
            sdi.casterId = pBuff.source;
            sdi.targetId = pBuff.targetId;
            sdi.casterLifePoints = monsterInfos.stats.lifePoints;
            sdi.casterMaxLifePoints = monsterInfos.stats.maxLifePoints;
            sdi.casterStrength = monsterGrade.strength;
            sdi.casterIntelligence = monsterGrade.intelligence;
            sdi.casterChance = monsterGrade.chance;
            sdi.casterAgility = monsterGrade.agility;
         }
         else
         {
            sdi = fromCurrentPlayer(spell,pBuff.source,pBuff.targetId,pSpellImpactCell,pCasterAffectedOutOfZone);
         }
         return sdi;
      }
      
      private static function getAllTriggeredSpells(pTriggeredSpells:Vector.<TriggeredSpell>, pSpellCenterCell:int, pRecursive:Boolean = false) : Vector.<TriggeredSpell>
      {
         var triggeredSpell:* = null;
         var currentTriggeredSpell:* = null;
         var triggerSpellInAll:* = null;
         var targetAlreadyInList:Boolean = false;
         var targetId:Number = NaN;
         var triggeredSpellsByTriggeredSpell:* = null;
         if(!pRecursive)
         {
            _allTriggeredSpells.length = 0;
         }
         if(!pTriggeredSpells)
         {
            return _allTriggeredSpells;
         }
         _allTriggeredSpells = _allTriggeredSpells.concat(pTriggeredSpells);
         var triggeredSpells:Vector.<TriggeredSpell> = new Vector.<TriggeredSpell>(0);
         for each(triggeredSpell in pTriggeredSpells)
         {
            for each(targetId in triggeredSpell.targets)
            {
               triggeredSpellsByTriggeredSpell = getTriggeredSpells(triggeredSpell.spell.effects,triggeredSpell.casterId,targetId,pSpellCenterCell,triggeredSpell.spell.id,triggeredSpell.casterPosition);
               if(triggeredSpellsByTriggeredSpell)
               {
                  for each(currentTriggeredSpell in triggeredSpellsByTriggeredSpell)
                  {
                     targetAlreadyInList = false;
                     for each(triggerSpellInAll in _allTriggeredSpells)
                     {
                        if(triggerSpellInAll.targetId == currentTriggeredSpell.targetId && triggerSpellInAll.effectId == currentTriggeredSpell.effectId && triggerSpellInAll.casterId == currentTriggeredSpell.casterId)
                        {
                           targetAlreadyInList = true;
                           break;
                        }
                     }
                     if(!targetAlreadyInList)
                     {
                        triggeredSpells.push(currentTriggeredSpell);
                     }
                  }
               }
            }
         }
         return !!triggeredSpells.length?getAllTriggeredSpells(triggeredSpells,pSpellCenterCell,true):_allTriggeredSpells;
      }
      
      private static function groupBuffsBySpell(pBuffs:Array) : Dictionary
      {
         var spellBuffs:* = null;
         var buff:* = null;
         for each(buff in pBuffs)
         {
            if(!spellBuffs)
            {
               spellBuffs = new Dictionary();
            }
            if(!spellBuffs[buff.castingSpell.spell.id])
            {
               spellBuffs[buff.castingSpell.spell.id] = new Vector.<BasicBuff>(0);
            }
            spellBuffs[buff.castingSpell.spell.id].push(buff);
         }
         return spellBuffs;
      }
      
      private static function getMinimumDamageEffectOrder(pCasterId:Number, pTargetId:Number, pEffects:Vector.<EffectInstance>, pSpellImpactCell:int) : int
      {
         var effi:* = null;
         var i:int = 0;
         var numEffects:uint = pEffects.length;
         for(i = 0; i < numEffects; )
         {
            effi = pEffects[i];
            if((effi.category == DataEnum.ACTION_TYPE_DAMAGES || DamageUtil.HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1 || effi.effectId == ActionIdEnum.ACTION_CHARACTER_PUSH) && DamageUtil.verifySpellEffectMask(pCasterId,pTargetId,effi,pSpellImpactCell))
            {
               return i;
            }
            i++;
         }
         return -1;
      }
      
      private static function addImmediateBoost(pSpellDamageInfo:SpellDamageInfo, pCasterBuffs:Array, pEffect:EffectInstanceDice, pSpellReachedMaxStacks:Boolean, pNumTargetsMultiplier:int, pCritical:Boolean) : void
      {
         var statName:* = null;
         var i:int = 0;
         switch(pEffect.effectId)
         {
            case ActionIdEnum.ACTION_CHARACTER_STEAL_CHANCE:
               statName = !pCritical?"casterChanceBonus":"casterCriticalChanceBonus";
               break;
            case ActionIdEnum.ACTION_CHARACTER_STEAL_AGILITY:
               statName = !pCritical?"casterAgilityBonus":"casterCriticalAgilityBonus";
               break;
            case ActionIdEnum.ACTION_CHARACTER_STEAL_INTELLIGENCE:
               statName = !pCritical?"casterIntelligenceBonus":"casterCriticalIntelligenceBonus";
               break;
            case ActionIdEnum.ACTION_CHARACTER_STEAL_STRENGTH:
               statName = !pCritical?"casterStrengthBonus":"casterCriticalStrengthBonus";
               break;
            case ActionIdEnum.ACTION_BOOST_PUSH_DMG:
               statName = !pCritical?"casterPushDamageBonus":"casterCriticalPushDamageBonus";
         }
         if(!statName)
         {
            return;
         }
         if(pSpellReachedMaxStacks)
         {
            for(i = 0; i < pCasterBuffs.length; )
            {
               if(pCasterBuffs[i].castingSpell.spell.id == pEffect.spellId)
               {
                  if(pCasterBuffs[i].stack && pCasterBuffs[i].stack.length > 1)
                  {
                     pSpellDamageInfo[statName] = -(pCasterBuffs[i].stack[0].delta - pEffect.diceNum * pNumTargetsMultiplier);
                     break;
                  }
                  pSpellDamageInfo[statName] = -(pCasterBuffs[i].delta - pEffect.diceNum * pNumTargetsMultiplier);
                  break;
               }
               i++;
            }
         }
         else
         {
            pSpellDamageInfo[statName] = pSpellDamageInfo[statName] + pEffect.diceNum * pNumTargetsMultiplier;
         }
      }
      
      public function getEffectModification(pEffectId:int, pEffectOrder:int, pHasCritical:Boolean) : EffectModification
      {
         var i:int = 0;
         var numEffectsModifications:int = !!this._effectsModifications?int(this._effectsModifications.length):0;
         var numCriticalEffectsModifications:int = !!this._criticalEffectsModifications?int(this._criticalEffectsModifications.length):0;
         var remainingEffects:int = pEffectOrder;
         if(!pHasCritical && this._effectsModifications)
         {
            for(i = 0; i < numEffectsModifications; )
            {
               if(this._effectsModifications[i].effectId == pEffectId)
               {
                  if(remainingEffects == 0)
                  {
                     return this._effectsModifications[i];
                  }
                  remainingEffects--;
               }
               i++;
            }
         }
         else if(this._criticalEffectsModifications)
         {
            for(i = 0; i < numCriticalEffectsModifications; )
            {
               if(this._criticalEffectsModifications[i].effectId == pEffectId)
               {
                  if(remainingEffects == 0)
                  {
                     return this._criticalEffectsModifications[i];
                  }
                  remainingEffects--;
               }
               i++;
            }
         }
         return null;
      }
      
      public function get targetId() : Number
      {
         return this._targetId;
      }
      
      public function set targetId(pTargetId:Number) : void
      {
         var buff:* = null;
         var i:int = 0;
         var deleteIndex:int = 0;
         var effi:* = null;
         this._targetId = pTargetId;
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         if(fightContextFrame)
         {
            this.targetLevel = fightContextFrame.getFighterLevel(this._targetId);
            this._targetInfos = fightContextFrame.entitiesFrame.getEntityInfos(this._targetId) as GameFightFighterInformations;
         }
         if(this.targetInfos)
         {
            this.targetIsMonster = this.targetInfos is GameFightMonsterInformations;
            this.targetShieldPoints = this.targetInfos.stats.shieldPoints;
            this.targetNeutralElementResistPercent = this.targetInfos.stats.neutralElementResistPercent + (!this.targetIsMonster?this.targetInfos.stats.pvpNeutralElementResistPercent:0);
            this.targetEarthElementResistPercent = this.targetInfos.stats.earthElementResistPercent + (!this.targetIsMonster?this.targetInfos.stats.pvpEarthElementResistPercent:0);
            this.targetWaterElementResistPercent = this.targetInfos.stats.waterElementResistPercent + (!this.targetIsMonster?this.targetInfos.stats.pvpWaterElementResistPercent:0);
            this.targetAirElementResistPercent = this.targetInfos.stats.airElementResistPercent + (!this.targetIsMonster?this.targetInfos.stats.pvpAirElementResistPercent:0);
            this.targetFireElementResistPercent = this.targetInfos.stats.fireElementResistPercent + (!this.targetIsMonster?this.targetInfos.stats.pvpFireElementResistPercent:0);
            this.targetNeutralElementReduction = this.targetInfos.stats.neutralElementReduction + (!this.targetIsMonster?this.targetInfos.stats.pvpNeutralElementReduction:0);
            this.targetEarthElementReduction = this.targetInfos.stats.earthElementReduction + (!this.targetIsMonster?this.targetInfos.stats.pvpEarthElementReduction:0);
            this.targetWaterElementReduction = this.targetInfos.stats.waterElementReduction + (!this.targetIsMonster?this.targetInfos.stats.pvpWaterElementReduction:0);
            this.targetAirElementReduction = this.targetInfos.stats.airElementReduction + (!this.targetIsMonster?this.targetInfos.stats.pvpAirElementReduction:0);
            this.targetFireElementReduction = this.targetInfos.stats.fireElementReduction + (!this.targetIsMonster?this.targetInfos.stats.pvpFireElementReduction:0);
            this.targetCriticalDamageFixedResist = this.targetInfos.stats.criticalDamageFixedResist;
            this.targetPushDamageFixedResist = this.targetInfos.stats.pushDamageFixedResist;
            this.targetErosionLifePoints = this.targetInfos.stats.baseMaxLifePoints - this.targetInfos.stats.maxLifePoints;
            this.targetLifePoints = this.targetInfos.stats.lifePoints;
            this.targetBaseMaxLifePoints = this.targetInfos.stats.baseMaxLifePoints;
            this.targetMaxLifePoints = this.targetInfos.stats.maxLifePoints;
            this.targetMeleeDamageReceivedPercent = this.targetInfos.stats.meleeDamageReceivedPercent;
            this.targetRangedDamageReceivedPercent = this.targetInfos.stats.rangedDamageReceivedPercent;
            this.targetWeaponDamageReceivedPercent = this.targetInfos.stats.weaponDamageReceivedPercent;
            this.targetSpellDamageReceivedPercent = this.targetInfos.stats.spellDamageReceivedPercent;
            this.targetCell = this.targetInfos.disposition.cellId;
            this.distanceBetweenCasterAndTarget = this.targetCell != -1?int(MapPoint.fromCellId(fightContextFrame.entitiesFrame.getEntityInfos(this.casterId).disposition.cellId).distanceToCell(MapPoint.fromCellId(this.targetCell))):-1;
         }
         this.targetBuffs = BuffManager.getInstance().getAllBuff(this._targetId);
         if(this.targetBuffs)
         {
            this.targetBuffs = this.targetBuffs.concat();
         }
         var deleteIndexes:Vector.<int> = new Vector.<int>(0);
         for(i = 0; i < this.spellEffects.length; )
         {
            effi = this.spellEffects[i];
            if(effi.effectId == ActionIdEnum.ACTION_CHARACTER_SHORTEN_ACTIVE_EFFECTS_DURATION)
            {
               for each(buff in this.targetBuffs)
               {
                  if(!(buff.duration >= 63 || buff.duration == -1000))
                  {
                     if(buff.duration - (effi.parameter0 as Number) <= 0)
                     {
                        deleteIndexes.push(this.targetBuffs.indexOf(buff));
                        if(DamageUtil.SHIELD_GAIN_EFFECTS_IDS.indexOf(buff.actionId) != -1)
                        {
                           if(this.targetShieldPoints - buff.param1 < 0)
                           {
                              this.targetShieldPoints = 0;
                           }
                           else
                           {
                              this.targetShieldPoints = this.targetShieldPoints - buff.param1;
                           }
                        }
                     }
                  }
               }
               i++;
               continue;
            }
            break;
         }
         for each(deleteIndex in deleteIndexes)
         {
            this.targetBuffs.splice(deleteIndex,1);
         }
         this.targetIsInvulnerable = false;
         this.targetIsUnhealable = false;
         this.targetStates = FightersStateManager.getInstance().getStates(pTargetId);
         this.targetStatus = FightersStateManager.getInstance().getStatus(pTargetId);
         this.targetIsInvulnerable = this.targetStatus.invulnerable;
         this.targetIsInvulnerableToMelee = this.targetStatus.invulnerableMelee;
         this.targetIsInvulnerableToRange = this.targetStatus.invulnerableRange;
         this.targetIsUnhealable = this.targetStatus.incurable;
         this.maximizedEffects = false;
         for each(buff in this.targetBuffs)
         {
            if(buff.actionId == ActionIdEnum.ACTION_CHARACTER_BOOST_PERMANENT_DAMAGE_PERCENT)
            {
               this.targetErosionPercentBonus = this.targetErosionPercentBonus + buff.param1;
            }
            if(buff.actionId == ActionIdEnum.ACTION_CHARACTER_MAXIMIZE_ROLL)
            {
               this.maximizedEffects = true;
            }
         }
      }
      
      public function get targetInfos() : GameFightFighterInformations
      {
         return this._targetInfos;
      }
      
      public function get originalTargetsIds() : Vector.<Number>
      {
         if(!this._originalTargetsIds)
         {
            this._originalTargetsIds = new Vector.<Number>(0);
         }
         return this._originalTargetsIds;
      }
      
      public function set originalTargetsIds(pOriginalTargetsIds:Vector.<Number>) : void
      {
         this._originalTargetsIds = pOriginalTargetsIds;
      }
      
      public function get triggeredSpells() : Vector.<TriggeredSpell>
      {
         var allSpells:* = null;
         var spells:Vector.<TriggeredSpell> = getAllTriggeredSpells(getTriggeredSpells(this.spellEffects,this.casterId,this.targetId,this.spellCenterCell,this.spell.id,this.casterPosition),this.spellCenterCell);
         var buffSpells:Vector.<TriggeredSpell> = this.getTargetBuffsTriggeredSpells(this.spellEffects);
         if(spells || buffSpells)
         {
            allSpells = new Vector.<TriggeredSpell>();
            if(spells)
            {
               allSpells = allSpells.concat(spells);
            }
            if(buffSpells)
            {
               allSpells = allSpells.concat(buffSpells);
            }
         }
         return allSpells;
      }
      
      public function get criticalTriggeredSpells() : Vector.<TriggeredSpell>
      {
         var allSpells:* = null;
         var spells:Vector.<TriggeredSpell> = getAllTriggeredSpells(getTriggeredSpells(this.spellCriticalEffects,this.casterId,this.targetId,this.spellCenterCell,this.spell.id,this.casterPosition),this.spellCenterCell);
         var buffSpells:Vector.<TriggeredSpell> = this.getTargetBuffsTriggeredSpells(this.spellCriticalEffects);
         if(spells || buffSpells)
         {
            allSpells = new Vector.<TriggeredSpell>();
            if(spells)
            {
               allSpells = allSpells.concat(spells);
            }
            if(buffSpells)
            {
               allSpells = allSpells.concat(buffSpells);
            }
         }
         return allSpells;
      }
      
      private function getTargetBuffsTriggeredSpells(pEffects:Vector.<EffectInstance>) : Vector.<TriggeredSpell>
      {
         var buff:* = null;
         var triggeredSpells:* = null;
         var spellId:int = 0;
         for each(buff in this.targetBuffs)
         {
            if((!buff.hasOwnProperty("delay") || buff["delay"] == 0) && (buff.effect.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL || buff.effect.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM || buff.effect.effectId == ActionIdEnum.ACTION_TARGET_EXECUTE_SPELL_ON_SOURCE) && DamageUtil.verifyBuffTriggers(buff,pEffects,this.casterId,this.targetId,this.isWeapon,this.spellCenterCell,null))
            {
               if(!triggeredSpells)
               {
                  triggeredSpells = new Vector.<TriggeredSpell>(0);
               }
               spellId = int(buff.effect.parameter0);
               triggeredSpells.push(TriggeredSpell.create(buff.effect.triggers,spellId,int(buff.effect.parameter1),this.targetId,this.targetId,buff.effect,buff.effect.targetMask.indexOf("C") != -1,pEffects,this.casterId,this.spellCenterCell));
            }
         }
         return triggeredSpells;
      }
      
      public function addTriggeredSpellsEffects(pTriggeredSpells:Vector.<TriggeredSpell>, pCritical:Boolean) : Boolean
      {
         var damageModifications:Boolean = false;
         var ts:* = null;
         var effect:* = null;
         var triggeredEffect:* = null;
         var i:int = 0;
         var efm:* = null;
         var damagesBonus:int = 0;
         var shieldPoints:int = 0;
         var effectOnCaster:Boolean = false;
         var effectOnTarget:Boolean = false;
         var modifications:* = null;
         var effects:Vector.<EffectInstance> = !pCritical?this.spellEffects:this.spellCriticalEffects;
         var numEffects:int = effects.length;
         for each(ts in pTriggeredSpells)
         {
            damagesBonus = 0;
            shieldPoints = 0;
            for(i = 0; i < numEffects; )
            {
               effect = effects[i];
               if(effect.random == 0 && DamageUtil.verifyEffectTrigger(this.casterId,this.targetId,effects,effect,this.isWeapon,ts.triggers,this.spellCenterCell))
               {
                  for each(triggeredEffect in ts.spell.effects)
                  {
                     if(DamageUtil.TRIGGERED_EFFECTS_IDS.indexOf(triggeredEffect.effectId) != -1)
                     {
                        effectOnCaster = DamageUtil.verifySpellEffectMask(ts.spell.playerId,this.casterId,triggeredEffect,this.spellCenterCell,this.casterId);
                        effectOnTarget = DamageUtil.verifySpellEffectMask(ts.spell.playerId,ts.spell.playerId,triggeredEffect,this.spellCenterCell,this.casterId);
                        if(!pCritical)
                        {
                           if(!this._effectsModifications)
                           {
                              this._effectsModifications = new Vector.<EffectModification>(0);
                           }
                           modifications = this._effectsModifications;
                        }
                        else
                        {
                           if(!this._criticalEffectsModifications)
                           {
                              this._criticalEffectsModifications = new Vector.<EffectModification>(0);
                           }
                           modifications = this._criticalEffectsModifications;
                        }
                        efm = i + 1 <= modifications.length?modifications[i]:null;
                        if(!efm)
                        {
                           efm = new EffectModification(effect.effectId);
                           modifications.push(efm);
                        }
                        if(Effect.getEffectById(triggeredEffect.effectId).active && effectOnCaster)
                        {
                           switch(triggeredEffect.effectId)
                           {
                              case ActionIdEnum.ACTION_CHARACTER_BOOST_DAMAGES_PERCENT:
                                 efm.damagesBonus = efm.damagesBonus + damagesBonus;
                                 damagesBonus = damagesBonus + (triggeredEffect as EffectInstanceDice).diceNum;
                           }
                        }
                        if(effectOnTarget)
                        {
                           switch(triggeredEffect.effectId)
                           {
                              case ActionIdEnum.ACTION_CHARACTER_BOOST_SHIELD:
                                 efm.shieldPoints = efm.shieldPoints + shieldPoints;
                                 shieldPoints = shieldPoints + (triggeredEffect as EffectInstanceDice).diceNum;
                           }
                        }
                        damageModifications = true;
                     }
                  }
               }
               i++;
            }
         }
         return damageModifications;
      }
      
      public function getDamageSharingTargets() : Vector.<Number>
      {
         var targets:* = null;
         var targetBuff:* = null;
         var entityBuff:* = null;
         var fightEntities:* = null;
         var entityId:Number = NaN;
         var buffs:* = null;
         var hasSplashDamage:Boolean = false;
         var splashDmg:* = null;
         if(this.splashDamages)
         {
            for each(splashDmg in this.splashDamages)
            {
               if(splashDmg.targets.indexOf(this.targetId) != -1)
               {
                  hasSplashDamage = true;
                  break;
               }
            }
         }
         for each(targetBuff in this.targetBuffs)
         {
            if(targetBuff.actionId == ActionIdEnum.ACTION_SHARE_DAMAGES && (DamageUtil.verifyBuffTriggers(targetBuff,this.spellEffects,this.casterId,this.targetId,this.isWeapon,this.spellCenterCell,this.splashDamages) || hasSplashDamage))
            {
               targets = new Vector.<Number>(0);
               if(this._originalTargetsIds.indexOf(this.targetId) != -1 || hasSplashDamage)
               {
                  targets.push(this.targetId);
               }
               fightEntities = (Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame).getEntitiesIdsList();
               for each(entityId in fightEntities)
               {
                  if(entityId != this.targetId)
                  {
                     buffs = BuffManager.getInstance().getAllBuff(entityId);
                     for each(entityBuff in buffs)
                     {
                        if(entityBuff.actionId == ActionIdEnum.ACTION_SHARE_DAMAGES && entityBuff.source == targetBuff.source)
                        {
                           targets.push(entityId);
                           break;
                        }
                     }
                  }
               }
               break;
            }
         }
         return targets;
      }
      
      public function getReflectDamages() : Vector.<ReflectDamage>
      {
         var finalReflectDamages:* = null;
         var reflectDamages:* = null;
         var boostedReflectDamages:* = null;
         var reflectDamageValues:* = null;
         var originalTargetId:Number = NaN;
         var reflectDmg:SpellDamage = new SpellDamage();
         for each(originalTargetId in this._originalTargetsIds)
         {
            reflectDamageValues = DamageUtil.getReflectDamageValues(originalTargetId);
            if(originalTargetId != this.casterId && reflectDamageValues)
            {
               if(reflectDamageValues.reflectValue > 0)
               {
                  if(!reflectDamages)
                  {
                     reflectDamages = new Vector.<ReflectDamage>(0);
                  }
                  this.addReflectDamage(reflectDamages,this.neutralDamage,reflectDamageValues.reflectValue,false,originalTargetId);
                  this.addReflectDamage(reflectDamages,this.earthDamage,reflectDamageValues.reflectValue,false,originalTargetId);
                  this.addReflectDamage(reflectDamages,this.fireDamage,reflectDamageValues.reflectValue,false,originalTargetId);
                  this.addReflectDamage(reflectDamages,this.waterDamage,reflectDamageValues.reflectValue,false,originalTargetId);
                  this.addReflectDamage(reflectDamages,this.airDamage,reflectDamageValues.reflectValue,false,originalTargetId);
               }
               if(reflectDamageValues.boostedReflectValue > 0)
               {
                  if(!boostedReflectDamages)
                  {
                     boostedReflectDamages = new Vector.<ReflectDamage>(0);
                  }
                  this.addReflectDamage(boostedReflectDamages,this.neutralDamage,reflectDamageValues.boostedReflectValue,true,originalTargetId);
                  this.addReflectDamage(boostedReflectDamages,this.earthDamage,reflectDamageValues.boostedReflectValue,true,originalTargetId);
                  this.addReflectDamage(boostedReflectDamages,this.fireDamage,reflectDamageValues.boostedReflectValue,true,originalTargetId);
                  this.addReflectDamage(boostedReflectDamages,this.waterDamage,reflectDamageValues.boostedReflectValue,true,originalTargetId);
                  this.addReflectDamage(boostedReflectDamages,this.airDamage,reflectDamageValues.boostedReflectValue,true,originalTargetId);
               }
            }
         }
         if(reflectDamages)
         {
            if(!finalReflectDamages)
            {
               finalReflectDamages = new Vector.<ReflectDamage>(0);
            }
            finalReflectDamages = finalReflectDamages.concat(reflectDamages);
         }
         if(boostedReflectDamages)
         {
            if(!finalReflectDamages)
            {
               finalReflectDamages = new Vector.<ReflectDamage>(0);
            }
            finalReflectDamages = finalReflectDamages.concat(boostedReflectDamages);
         }
         return finalReflectDamages;
      }
      
      private function addReflectDamage(pReflectDamages:Vector.<ReflectDamage>, pSourceSpellDamage:SpellDamage, pReflectValue:uint, pBoosted:Boolean, pSourceId:Number) : void
      {
         var ed:* = null;
         var rd:* = null;
         var reflectExists:Boolean = false;
         var spellEffectDmg:* = null;
         for each(spellEffectDmg in pSourceSpellDamage.effectDamages)
         {
            ed = new EffectDamage(-1,spellEffectDmg.element,spellEffectDmg.random);
            ed.minDamage = spellEffectDmg.minDamage;
            ed.minCriticalDamage = spellEffectDmg.minCriticalDamage;
            ed.maxDamage = spellEffectDmg.maxDamage;
            ed.maxCriticalDamage = spellEffectDmg.maxCriticalDamage;
            ed.hasCritical = spellEffectDmg.hasCritical;
            reflectExists = false;
            for each(rd in pReflectDamages)
            {
               if(rd.sourceId == pSourceId)
               {
                  rd.addEffect(ed);
                  reflectExists = true;
                  break;
               }
            }
            if(!reflectExists)
            {
               rd = new ReflectDamage(pSourceId,pReflectValue,pBoosted);
               rd.addEffect(ed);
               pReflectDamages.push(rd);
            }
         }
      }
      
      public function hasLifeSteal() : Boolean
      {
         var spellDamage:* = null;
         var effect:* = null;
         var spellDamages:Vector.<SpellDamage> = new Vector.<SpellDamage>(0);
         spellDamages.push(this.neutralDamage,this.earthDamage,this.fireDamage,this.waterDamage,this.airDamage);
         for each(spellDamage in spellDamages)
         {
            for each(effect in spellDamage.effectDamages)
            {
               if(DamageUtil.LIFE_STEAL_EFFECTS_IDS.indexOf(effect.effectId) != -1)
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}
