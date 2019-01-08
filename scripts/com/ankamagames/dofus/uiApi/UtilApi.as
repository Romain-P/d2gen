package com.ankamagames.dofus.uiApi
{
   import com.ankamagames.atouin.Atouin;
   import com.ankamagames.berilia.components.Texture;
   import com.ankamagames.berilia.interfaces.IApi;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.dofus.datacenter.breeds.Breed;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.internalDatacenter.DataEnum;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.logic.game.common.managers.EntitiesLooksManager;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.logic.game.fight.managers.CurrentPlayedFighterManager;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   import com.ankamagames.dofus.logic.game.fight.miscs.DamageUtil;
   import com.ankamagames.dofus.logic.game.fight.types.EffectDamage;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamage;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageInfo;
   import com.ankamagames.dofus.misc.utils.ParamsDecoder;
   import com.ankamagames.dofus.network.enums.BoostableCharacteristicEnum;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.pools.PoolsManager;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.jerakine.utils.misc.CallWithParameters;
   import com.ankamagames.jerakine.utils.misc.StringUtils;
   import com.ankamagames.tiphon.types.look.TiphonEntityLook;
   import flash.display.DisplayObject;
   import flash.geom.ColorTransform;
   import flash.globalization.Collator;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   [InstanciedApi]
   public class UtilApi implements IApi
   {
       
      
      protected var _log:Logger;
      
      private var _module:UiModule;
      
      private var _stringSorter:Collator;
      
      private var _triggeredSpells:Dictionary;
      
      public function UtilApi()
      {
         this._log = Log.getLogger(getQualifiedClassName(UtilApi));
         this._triggeredSpells = new Dictionary(true);
         super();
      }
      
      [ApiData(name="module")]
      public function set module(value:UiModule) : void
      {
         this._module = value;
      }
      
      [Trusted]
      public function destroy() : void
      {
         this._module = null;
      }
      
      [Untrusted]
      public function callWithParameters(method:Function, parameters:Array) : void
      {
         CallWithParameters.call(method,parameters);
      }
      
      [Untrusted]
      public function callConstructorWithParameters(callClass:Class, parameters:Array) : *
      {
         return CallWithParameters.callConstructor(callClass,parameters);
      }
      
      [Untrusted]
      public function callRWithParameters(method:Function, parameters:Array) : *
      {
         return CallWithParameters.callR(method,parameters);
      }
      
      [Untrusted]
      public function kamasToString(kamas:Number, unit:String = "-") : String
      {
         return StringUtils.kamasToString(kamas,unit);
      }
      
      [Untrusted]
      public function formateIntToString(val:Number, precision:int = 2) : String
      {
         return StringUtils.formateIntToString(val,precision);
      }
      
      [Untrusted]
      public function stringToKamas(string:String, unit:String = "-") : Number
      {
         return StringUtils.stringToKamas(string,unit);
      }
      
      [Untrusted]
      public function getTextWithParams(textId:int, params:Array, replace:String = "%") : String
      {
         var msgContent:String = I18n.getText(textId);
         if(msgContent)
         {
            return ParamsDecoder.applyParams(msgContent,params,replace);
         }
         return "";
      }
      
      [Untrusted]
      public function applyTextParams(pText:String, pParams:Array, pReplace:String = "%") : String
      {
         return ParamsDecoder.applyParams(pText,pParams,pReplace);
      }
      
      [Trusted]
      public function noAccent(str:String) : String
      {
         return StringUtils.noAccent(str);
      }
      
      [Trusted]
      public function getAllIndexOf(pStringLookFor:String, pWholeString:String) : Array
      {
         return StringUtils.getAllIndexOf(pStringLookFor,pWholeString);
      }
      
      [Untrusted]
      public function changeColor(obj:Object, color:Number, depth:int, unColor:Boolean = false) : void
      {
         var t0:* = null;
         var R:* = 0;
         var V:* = 0;
         var B:* = 0;
         var t:* = null;
         if(obj != null)
         {
            if(unColor)
            {
               t0 = new ColorTransform(1,1,1,1,0,0,0);
               if(obj is Texture)
               {
                  Texture(obj).colorTransform = t0;
               }
               else if(obj is DisplayObject)
               {
                  DisplayObject(obj).transform.colorTransform = t0;
               }
            }
            else
            {
               R = color >> 16 & 255;
               V = color >> 8 & 255;
               B = color >> 0 & 255;
               t = new ColorTransform(0,0,0,1,R,V,B);
               if(obj is Texture)
               {
                  Texture(obj).colorTransform = t;
               }
               else if(obj is DisplayObject)
               {
                  DisplayObject(obj).transform.colorTransform = t;
               }
            }
         }
      }
      
      [Untrusted]
      public function sortOnString(list:*, field:String = "", ascending:Boolean = true) : void
      {
         if(!(list is Array) && !(list is Vector.<*>))
         {
            this._log.error("Tried to sort something different than an Array or a Vector!");
            return;
         }
         if(!this._stringSorter)
         {
            this._stringSorter = new Collator(XmlConfig.getInstance().getEntry("config.lang.current"));
         }
         if(field)
         {
            list.sort(function(a:*, b:*):int
            {
               var result:int = _stringSorter.compare(a[field],b[field]);
               return !!ascending?int(result):int(result * -1);
            });
         }
         else
         {
            list.sort(this._stringSorter.compare);
         }
      }
      
      [Untrusted]
      public function sort(target:*, field:String, ascendand:Boolean = true, isNumeric:Boolean = false) : *
      {
         var result:* = undefined;
         var sup:int = 0;
         var inf:int = 0;
         if(target is Array)
         {
            result = (target as Array).concat();
            result.sortOn(field,(!!ascendand?0:Array.DESCENDING) | (!!isNumeric?Array.NUMERIC:Array.CASEINSENSITIVE));
            return result;
         }
         if(target is Vector.<*>)
         {
            result = target.concat();
            sup = !!ascendand?1:-1;
            inf = !!ascendand?-1:1;
            if(isNumeric)
            {
               result.sort(function(a:*, b:*):int
               {
                  if(a[field] > b[field])
                  {
                     return sup;
                  }
                  if(a[field] < b[field])
                  {
                     return inf;
                  }
                  return 0;
               });
            }
            else
            {
               result.sort(function(a:*, b:*):int
               {
                  var astr:String = a[field].toLocaleLowerCase();
                  var bstr:String = b[field].toLocaleLowerCase();
                  if(astr > bstr)
                  {
                     return sup;
                  }
                  if(astr < bstr)
                  {
                     return inf;
                  }
                  return 0;
               });
            }
            return result;
         }
         return null;
      }
      
      [Untrusted]
      public function filter(target:*, pattern:*, field:String) : *
      {
         var searchFor:* = null;
         if(!target)
         {
            return null;
         }
         var result:* = new (target.constructor as Class)();
         var len:uint = target.length;
         var i:int = 0;
         if(pattern is String)
         {
            for(searchFor = String(pattern).toLowerCase(); i < len; )
            {
               if(String(target[i][field]).toLowerCase().indexOf(searchFor) != -1)
               {
                  result.push(target[i]);
               }
               i++;
            }
         }
         else
         {
            while(i < len)
            {
               if(target[i][field] == pattern)
               {
                  result.push(target[i]);
               }
               i++;
            }
         }
         return result;
      }
      
      [Untrusted]
      public function getTiphonEntityLook(pEntityId:Number) : TiphonEntityLook
      {
         return EntitiesLooksManager.getInstance().getTiphonEntityLook(pEntityId);
      }
      
      [Untrusted]
      public function getRealTiphonEntityLook(pEntityId:Number, pWithoutMount:Boolean = false) : TiphonEntityLook
      {
         return EntitiesLooksManager.getInstance().getRealTiphonEntityLook(pEntityId,pWithoutMount);
      }
      
      [Untrusted]
      public function getLookFromContext(pEntityId:Number, pForceCreature:Boolean = false) : TiphonEntityLook
      {
         return EntitiesLooksManager.getInstance().getLookFromContext(pEntityId,pForceCreature);
      }
      
      [Untrusted]
      public function getLookFromContextInfos(pInfos:GameContextActorInformations, pForceCreature:Boolean = false) : TiphonEntityLook
      {
         return EntitiesLooksManager.getInstance().getLookFromContextInfos(pInfos,pForceCreature);
      }
      
      [Untrusted]
      public function isCreature(pEntityId:Number) : Boolean
      {
         return EntitiesLooksManager.getInstance().isCreature(pEntityId);
      }
      
      [Untrusted]
      public function isCreatureFromLook(pLook:TiphonEntityLook) : Boolean
      {
         return EntitiesLooksManager.getInstance().isCreatureFromLook(pLook);
      }
      
      [Untrusted]
      public function isIncarnation(pEntityId:Number) : Boolean
      {
         return EntitiesLooksManager.getInstance().isIncarnation(pEntityId);
      }
      
      [Untrusted]
      public function isIncarnationFromLook(pLook:TiphonEntityLook) : Boolean
      {
         return EntitiesLooksManager.getInstance().isIncarnationFromLook(pLook);
      }
      
      [Untrusted]
      public function isCreatureMode() : Boolean
      {
         return EntitiesLooksManager.getInstance().isCreatureMode();
      }
      
      [Untrusted]
      public function getCreatureLook(pEntityId:Number) : TiphonEntityLook
      {
         return EntitiesLooksManager.getInstance().getCreatureLook(pEntityId);
      }
      
      [Untrusted]
      public function getGfxUri(pGfxId:int) : String
      {
         return Atouin.getInstance().options.elementsPath + "/" + Atouin.getInstance().options.pngSubPath + "/" + pGfxId + "." + Atouin.getInstance().options.mapPictoExtension;
      }
      
      [Untrusted]
      public function encodeToJson(value:*) : String
      {
         return by.blooddy.crypto.serialization.JSON.encode(value);
      }
      
      [Untrusted]
      public function decodeJson(value:String) : *
      {
         return by.blooddy.crypto.serialization.JSON.decode(value);
      }
      
      [Untrusted]
      public function getObjectsUnderPoint() : Array
      {
         return StageShareManager.stage.getObjectsUnderPoint(PoolsManager.getInstance().getPointPool().checkOut()["renew"](StageShareManager.mouseX,StageShareManager.mouseY));
      }
      
      [Untrusted]
      public function isCharacteristicSpell(pSpellWrapper:SpellWrapper, pCharacteristicId:int, pRecursive:Boolean = false) : Boolean
      {
         var effect:* = null;
         var triggeredSpell:* = null;
         var spellId:* = undefined;
         var characteristicTriggeredSpell:Boolean = false;
         var result:* = false;
         if(!pRecursive)
         {
            for(spellId in this._triggeredSpells)
            {
               delete this._triggeredSpells[spellId];
            }
         }
         for each(effect in pSpellWrapper.effects)
         {
            if(effect != null)
            {
               if(pSpellWrapper.typeId != DataEnum.SPELL_TYPE_TEST && pSpellWrapper.id != DataEnum.SPELL_SRAM_TRAPS && (effect.effectId != ActionIdEnum.ACTION_GAIN_LIFE_ON_TARGET_LIFE_PERCENT && DamageUtil.TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effect.effectId) == -1))
               {
                  if(effect.effectId == ActionIdEnum.ACTION_CASTER_EXECUTE_SPELL || effect.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL && effect.targetMask && effect.targetMask.indexOf("C") != -1 || effect.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM || effect.effectId == ActionIdEnum.ACTION_FIGHT_ADD_TRAP_CASTING_SPELL)
                  {
                     triggeredSpell = SpellWrapper.create(effect.parameter0 as uint,effect.parameter1 as int);
                     if(triggeredSpell != null)
                     {
                        if(!this._triggeredSpells[triggeredSpell.spellId] && triggeredSpell.spellId != pSpellWrapper.spellId)
                        {
                           this._triggeredSpells[triggeredSpell.spellId] = true;
                           characteristicTriggeredSpell = this.isCharacteristicSpell(triggeredSpell,pCharacteristicId,true);
                           if(characteristicTriggeredSpell)
                           {
                              return true;
                           }
                        }
                        else
                        {
                           delete this._triggeredSpells[triggeredSpell.spellId];
                        }
                     }
                  }
                  else
                  {
                     if(pCharacteristicId == BoostableCharacteristicEnum.BOOSTABLE_CHARAC_VITALITY && (effect.effectId == ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT || DamageUtil.HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effect.effectId) != -1))
                     {
                        return true;
                     }
                     if(DamageUtil.HEALING_EFFECTS_IDS.indexOf(effect.effectId) != -1 && (effect.effectId != ActionIdEnum.ACTION_CHARACTER_DISPATCH_LIFE_POINTS_PERCENT && pCharacteristicId == BoostableCharacteristicEnum.BOOSTABLE_CHARAC_INTELLIGENCE))
                     {
                        return true;
                     }
                     if(DamageUtil.HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(effect.effectId) == -1 && DamageUtil.ERODED_HP_BASED_DAMAGE_EFFETS_IDS.indexOf(effect.effectId) == -1 && DamageUtil.HEALING_EFFECTS_IDS.indexOf(effect.effectId) == -1 && effect.category == DataEnum.ACTION_TYPE_DAMAGES)
                     {
                        result = false;
                        switch(pCharacteristicId)
                        {
                           case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_STRENGTH:
                              result = Boolean(effect.effectElement == DamageUtil.NEUTRAL_ELEMENT || effect.effectElement == DamageUtil.EARTH_ELEMENT);
                              break;
                           case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_INTELLIGENCE:
                              result = effect.effectElement == DamageUtil.FIRE_ELEMENT;
                              break;
                           case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_CHANCE:
                              result = effect.effectElement == DamageUtil.WATER_ELEMENT;
                              break;
                           case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_AGILITY:
                              result = effect.effectElement == DamageUtil.AIR_ELEMENT;
                        }
                        if(result)
                        {
                           return true;
                        }
                     }
                  }
               }
            }
         }
         return false;
      }
      
      [Untrusted]
      public function getSpellBoost(pSpellWrapper:SpellWrapper, pCharacteristicId:int) : Object
      {
         var boostValue:Number = NaN;
         var boostType:* = null;
         var spelldamage:* = null;
         var currentValue:Number = NaN;
         var afterBoostValue:Number = NaN;
         var damageBeforeBoost:* = null;
         var damageAfterBoost:* = null;
         var healBeforeBoost:* = null;
         var healAfterBoost:* = null;
         var boost:Object = new Object();
         var sdi:SpellDamageInfo = SpellDamageInfo.fromCurrentPlayer(pSpellWrapper,CurrentPlayedFighterManager.getInstance().currentFighterId);
         var spellDamages:Vector.<SpellDamage> = new Vector.<SpellDamage>(0);
         var statsNames:* = new Array();
         boostType = I18n.getUiText("ui.common.damageShort");
         switch(pCharacteristicId)
         {
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_STRENGTH:
               statsNames = ["casterStrength"];
               spellDamages.push(sdi.neutralDamage,sdi.earthDamage);
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_VITALITY:
               sdi.casterLifePoints = sdi.casterBaseMaxLifePoints / 2;
               statsNames = ["casterLifePoints","casterBaseMaxLifePoints","casterMaxLifePoints"];
               if(!sdi.isHealingSpell)
               {
                  spellDamages.push(sdi.hpBasedDamage);
                  break;
               }
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_CHANCE:
               statsNames = ["casterChance"];
               spellDamages.push(sdi.waterDamage);
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_AGILITY:
               statsNames = ["casterAgility"];
               spellDamages.push(sdi.airDamage);
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_INTELLIGENCE:
               statsNames = ["casterIntelligence"];
               if(!sdi.isHealingSpell)
               {
                  spellDamages.push(sdi.fireDamage);
                  break;
               }
         }
         if(!sdi.isHealingSpell)
         {
            damageBeforeBoost = new EffectDamage();
            damageAfterBoost = new EffectDamage();
            for each(spelldamage in spellDamages)
            {
               damageBeforeBoost.addDamage(DamageUtil.computeDamage(spelldamage,sdi,1,false,true,true,true,true,true));
            }
            currentValue = damageBeforeBoost.minDamage + damageBeforeBoost.maxDamage + damageBeforeBoost.minCriticalDamage + damageBeforeBoost.maxCriticalDamage;
            this.increaseStats(sdi,pCharacteristicId,statsNames);
            for each(spelldamage in spellDamages)
            {
               damageAfterBoost.addDamage(DamageUtil.computeDamage(spelldamage,sdi,1,false,true,true,true,true,true));
            }
            afterBoostValue = damageAfterBoost.minDamage + damageAfterBoost.maxDamage + damageAfterBoost.minCriticalDamage + damageAfterBoost.maxCriticalDamage;
         }
         else
         {
            boostType = I18n.getUiText("ui.stats.healBonus");
            this.computeLifePointsBasedOnLifePercent(sdi,sdi.casterBaseMaxLifePoints);
            healBeforeBoost = DamageUtil.getHealEffectDamage(sdi);
            currentValue = healBeforeBoost.minLifePointsAdded + healBeforeBoost.maxLifePointsAdded + healBeforeBoost.minCriticalLifePointsAdded + healBeforeBoost.maxCriticalLifePointsAdded + healBeforeBoost.lifePointsAddedBasedOnLifePercent + healBeforeBoost.criticalLifePointsAddedBasedOnLifePercent;
            this.increaseStats(sdi,pCharacteristicId,statsNames);
            this.computeLifePointsBasedOnLifePercent(sdi,sdi.casterBaseMaxLifePoints);
            healAfterBoost = DamageUtil.getHealEffectDamage(sdi);
            afterBoostValue = healAfterBoost.minLifePointsAdded + healAfterBoost.maxLifePointsAdded + healAfterBoost.minCriticalLifePointsAdded + healAfterBoost.maxCriticalLifePointsAdded + healAfterBoost.lifePointsAddedBasedOnLifePercent + healAfterBoost.criticalLifePointsAddedBasedOnLifePercent;
         }
         boostValue = afterBoostValue > 0 && currentValue > 0?Number((afterBoostValue / currentValue - 1) * 100):Number(0);
         boost.value = Math.round(boostValue * 100) / 100;
         boost.type = boostType;
         return boost;
      }
      
      private function increaseStats(pSpellDamageInfo:SpellDamageInfo, pCharacteristicId:int, pStatsNames:Array) : void
      {
         var statName:* = null;
         var statIncrease:* = 0;
         var base:int = 0;
         var statPoints:* = undefined;
         var i:int = 0;
         var breed:Breed = Breed.getBreedById(PlayedCharacterManager.getInstance().infos.breed);
         switch(pCharacteristicId)
         {
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_VITALITY:
               statPoints = breed.statsPointsForVitality;
               base = PlayedCharacterManager.getInstance().characteristics.vitality.base;
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_WISDOM:
               statPoints = breed..statsPointsForWisdom;
               base = PlayedCharacterManager.getInstance().characteristics.vitality.base;
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_STRENGTH:
               statPoints = breed.statsPointsForStrength;
               base = PlayedCharacterManager.getInstance().characteristics.vitality.base;
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_INTELLIGENCE:
               statPoints = breed.statsPointsForIntelligence;
               base = PlayedCharacterManager.getInstance().characteristics.vitality.base;
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_CHANCE:
               statPoints = breed.statsPointsForChance;
               base = PlayedCharacterManager.getInstance().characteristics.vitality.base;
               break;
            case BoostableCharacteristicEnum.BOOSTABLE_CHARAC_AGILITY:
               statPoints = breed.statsPointsForAgility;
               base = PlayedCharacterManager.getInstance().characteristics.vitality.base;
         }
         for(i = 0; i < statPoints.length; )
         {
            if(base >= statPoints[i][0] && (i + 1 >= statPoints.length || base < statPoints[i + 1][0]))
            {
               statIncrease = uint(statPoints[i].length == 3?uint(statPoints[i][2]):uint(1));
               break;
            }
            i++;
         }
         for each(statName in pStatsNames)
         {
            pSpellDamageInfo[statName] = pSpellDamageInfo[statName] + statIncrease;
         }
      }
      
      private function computeLifePointsBasedOnLifePercent(pSpellDamageInfo:SpellDamageInfo, pCurrentLife:uint) : void
      {
         var effect:* = null;
         var spellEffect:* = null;
         for each(spellEffect in pSpellDamageInfo.spellEffects)
         {
            if(spellEffect.effectId == 90)
            {
               for each(effect in pSpellDamageInfo.heal.effectDamages)
               {
                  if(effect.effectId == 90 && effect.criticalLifePointsAddedBasedOnLifePercent == 0 && effect.spellEffectOrder == pSpellDamageInfo.spellEffects.indexOf(spellEffect))
                  {
                     effect.lifePointsAddedBasedOnLifePercent = (spellEffect as EffectInstanceDice).diceNum * pCurrentLife / 100;
                     break;
                  }
               }
               break;
            }
         }
         for each(spellEffect in pSpellDamageInfo.spellCriticalEffects)
         {
            if(spellEffect.effectId == 90)
            {
               for each(effect in pSpellDamageInfo.heal.effectDamages)
               {
                  if(effect.effectId == 90 && effect.lifePointsAddedBasedOnLifePercent == 0 && effect.spellEffectOrder == pSpellDamageInfo.spellCriticalEffects.indexOf(spellEffect))
                  {
                     effect.criticalLifePointsAddedBasedOnLifePercent = (spellEffect as EffectInstanceDice).diceNum * pCurrentLife / 100;
                     break;
                  }
               }
               break;
            }
         }
      }
   }
}
