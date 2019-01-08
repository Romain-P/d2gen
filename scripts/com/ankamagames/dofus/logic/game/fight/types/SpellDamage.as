package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.berilia.managers.HtmlManager;
   import com.ankamagames.dofus.datacenter.spells.SpellState;
   import com.ankamagames.dofus.internalDatacenter.DataEnum;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   import com.ankamagames.dofus.logic.game.fight.miscs.DamageUtil;
   import com.ankamagames.dofus.network.enums.ChatActivableChannelsEnum;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.managers.OptionManager;
   import flash.utils.getQualifiedClassName;
   
   public class SpellDamage
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(SpellDamage));
       
      
      public var invulnerableState:Boolean;
      
      public var unhealableState:Boolean;
      
      public var hasCriticalDamage:Boolean;
      
      public var hasCriticalShieldPointsRemoved:Boolean;
      
      public var hasCriticalShieldPointsAdded:Boolean;
      
      public var hasCriticalLifePointsAdded:Boolean;
      
      public var isHealingSpell:Boolean;
      
      public var hasHeal:Boolean;
      
      public var criticalHitRate:int;
      
      public var minimizedEffects:Boolean;
      
      public var maximizedEffects:Boolean;
      
      public var efficiencyMultiplier:Number;
      
      public var targetId:Number = NaN;
      
      private var _effectDamages:Vector.<EffectDamage>;
      
      private var _minDamage:int;
      
      private var _maxDamage:int;
      
      private var _minCriticalDamage:int;
      
      private var _maxCriticalDamage:int;
      
      private var _minShieldPointsRemoved:int;
      
      private var _maxShieldPointsRemoved:int;
      
      private var _minCriticalShieldPointsRemoved:int;
      
      private var _maxCriticalShieldPointsRemoved:int;
      
      private var _minShieldPointsAdded:int;
      
      private var _maxShieldPointsAdded:int;
      
      private var _minCriticalShieldPointsAdded:int;
      
      private var _maxCriticalShieldPointsAdded:int;
      
      public var effectIcons:Array;
      
      public function SpellDamage()
      {
         super();
         this._effectDamages = new Vector.<EffectDamage>();
      }
      
      public function get minDamage() : int
      {
         var ed:* = null;
         this._minDamage = 0;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               this._minDamage = this._minDamage + ed.minDamage;
            }
         }
         return this._minDamage;
      }
      
      public function set minDamage(pMinDamage:int) : void
      {
         this._minDamage = pMinDamage;
      }
      
      public function get maxDamage() : int
      {
         var ed:* = null;
         this._maxDamage = 0;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               this._maxDamage = this._maxDamage + ed.maxDamage;
            }
         }
         return this._maxDamage;
      }
      
      public function set maxDamage(pMaxDamage:int) : void
      {
         this._maxDamage = pMaxDamage;
      }
      
      public function get minCriticalDamage() : int
      {
         var ed:* = null;
         this._minCriticalDamage = 0;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               this._minCriticalDamage = this._minCriticalDamage + ed.minCriticalDamage;
            }
         }
         return this._minCriticalDamage;
      }
      
      public function set minCriticalDamage(pMinCriticalDamage:int) : void
      {
         this._minCriticalDamage = pMinCriticalDamage;
      }
      
      public function get maxCriticalDamage() : int
      {
         var ed:* = null;
         this._maxCriticalDamage = 0;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               this._maxCriticalDamage = this._maxCriticalDamage + ed.maxCriticalDamage;
            }
         }
         return this._maxCriticalDamage;
      }
      
      public function set maxCriticalDamage(pMaxCriticalDamage:int) : void
      {
         this._maxCriticalDamage = pMaxCriticalDamage;
      }
      
      public function get minErosionDamage() : int
      {
         var minErosion:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            minErosion = minErosion + ed.minErosionDamage;
         }
         return minErosion;
      }
      
      public function get maxErosionDamage() : int
      {
         var maxErosion:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            maxErosion = maxErosion + ed.maxErosionDamage;
         }
         return maxErosion;
      }
      
      public function get minCriticalErosionDamage() : int
      {
         var minCriticalErosion:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            minCriticalErosion = minCriticalErosion + ed.minCriticalErosionDamage;
         }
         return minCriticalErosion;
      }
      
      public function get maxCriticalErosionDamage() : int
      {
         var maxCriticalErosion:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            maxCriticalErosion = maxCriticalErosion + ed.maxCriticalErosionDamage;
         }
         return maxCriticalErosion;
      }
      
      public function get minShieldPointsRemoved() : int
      {
         var ed:* = null;
         this._minShieldPointsRemoved = 0;
         for each(ed in this._effectDamages)
         {
            this._minShieldPointsRemoved = this._minShieldPointsRemoved + ed.minShieldPointsRemoved;
         }
         return this._minShieldPointsRemoved;
      }
      
      public function set minShieldPointsRemoved(pMinShieldPointsRemoved:int) : void
      {
         this._minShieldPointsRemoved = pMinShieldPointsRemoved;
      }
      
      public function get maxShieldPointsRemoved() : int
      {
         var ed:* = null;
         this._maxShieldPointsRemoved = 0;
         for each(ed in this._effectDamages)
         {
            this._maxShieldPointsRemoved = this._maxShieldPointsRemoved + ed.maxShieldPointsRemoved;
         }
         return this._maxShieldPointsRemoved;
      }
      
      public function set maxShieldPointsRemoved(pMaxShieldPointsRemoved:int) : void
      {
         this._maxShieldPointsRemoved = pMaxShieldPointsRemoved;
      }
      
      public function get minCriticalShieldPointsRemoved() : int
      {
         var ed:* = null;
         this._minCriticalShieldPointsRemoved = 0;
         for each(ed in this._effectDamages)
         {
            this._minCriticalShieldPointsRemoved = this._minCriticalShieldPointsRemoved + ed.minCriticalShieldPointsRemoved;
         }
         return this._minCriticalShieldPointsRemoved;
      }
      
      public function set minCriticalShieldPointsRemoved(pMinCriticalShieldPointsRemoved:int) : void
      {
         this._minCriticalShieldPointsRemoved = pMinCriticalShieldPointsRemoved;
      }
      
      public function get maxCriticalShieldPointsRemoved() : int
      {
         var ed:* = null;
         this._maxCriticalShieldPointsRemoved = 0;
         for each(ed in this._effectDamages)
         {
            this._maxCriticalShieldPointsRemoved = this._maxCriticalShieldPointsRemoved + ed.maxCriticalShieldPointsRemoved;
         }
         return this._maxCriticalShieldPointsRemoved;
      }
      
      public function set maxCriticalShieldPointsRemoved(pMaxCriticalShieldPointsRemoved:int) : void
      {
         this._maxCriticalShieldPointsRemoved = pMaxCriticalShieldPointsRemoved;
      }
      
      public function get minShieldPointsAdded() : int
      {
         var ed:* = null;
         this._minShieldPointsAdded = 0;
         for each(ed in this._effectDamages)
         {
            this._minShieldPointsAdded = this._minShieldPointsAdded + ed.minShieldPointsAdded;
         }
         return this._minShieldPointsAdded;
      }
      
      public function set minShieldPointsAdded(pMinShieldPointsAdded:int) : void
      {
         this._minShieldPointsAdded = pMinShieldPointsAdded;
      }
      
      public function get maxShieldPointsAdded() : int
      {
         var ed:* = null;
         this._maxShieldPointsAdded = 0;
         for each(ed in this._effectDamages)
         {
            this._maxShieldPointsAdded = this._maxShieldPointsAdded + ed.maxShieldPointsAdded;
         }
         return this._maxShieldPointsAdded;
      }
      
      public function set maxShieldPointsAdded(pMaxShieldPointsAdded:int) : void
      {
         this._maxShieldPointsAdded = pMaxShieldPointsAdded;
      }
      
      public function get minCriticalShieldPointsAdded() : int
      {
         var ed:* = null;
         this._minCriticalShieldPointsAdded = 0;
         for each(ed in this._effectDamages)
         {
            this._minCriticalShieldPointsAdded = this._minCriticalShieldPointsAdded + ed.minCriticalShieldPointsAdded;
         }
         return this._minCriticalShieldPointsAdded;
      }
      
      public function set minCriticalShieldPointsAdded(pMinCriticalShieldPointsAdded:int) : void
      {
         this._minCriticalShieldPointsAdded = pMinCriticalShieldPointsAdded;
      }
      
      public function get maxCriticalShieldPointsAdded() : int
      {
         var ed:* = null;
         this._maxCriticalShieldPointsAdded = 0;
         for each(ed in this._effectDamages)
         {
            this._maxCriticalShieldPointsAdded = this._maxCriticalShieldPointsAdded + ed.maxCriticalShieldPointsAdded;
         }
         return this._maxCriticalShieldPointsAdded;
      }
      
      public function set maxCriticalShieldPointsAdded(pMaxCriticalShieldPointsAdded:int) : void
      {
         this._maxCriticalShieldPointsAdded = pMaxCriticalShieldPointsAdded;
      }
      
      public function get minLifePointsAdded() : int
      {
         var minLife:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               minLife = minLife + ed.minLifePointsAdded;
            }
         }
         return minLife;
      }
      
      public function get maxLifePointsAdded() : int
      {
         var maxLife:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               maxLife = maxLife + ed.maxLifePointsAdded;
            }
         }
         return maxLife;
      }
      
      public function get minCriticalLifePointsAdded() : int
      {
         var minCriticalLife:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               minCriticalLife = minCriticalLife + ed.minCriticalLifePointsAdded;
            }
         }
         return minCriticalLife;
      }
      
      public function get maxCriticalLifePointsAdded() : int
      {
         var maxCriticalLife:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            if(ed.random == -1)
            {
               maxCriticalLife = maxCriticalLife + ed.maxCriticalLifePointsAdded;
            }
         }
         return maxCriticalLife;
      }
      
      public function get lifePointsAddedBasedOnLifePercent() : int
      {
         var lifePointsFromPercent:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            lifePointsFromPercent = lifePointsFromPercent + ed.lifePointsAddedBasedOnLifePercent;
         }
         return lifePointsFromPercent;
      }
      
      public function get criticalLifePointsAddedBasedOnLifePercent() : int
      {
         var criticalLifePointsFromPercent:int = 0;
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            criticalLifePointsFromPercent = criticalLifePointsFromPercent + ed.criticalLifePointsAddedBasedOnLifePercent;
         }
         return criticalLifePointsFromPercent;
      }
      
      public function updateDamage() : void
      {
         this.minDamage;
         this.maxDamage;
         this.minCriticalDamage;
         this.maxCriticalDamage;
         this.minShieldPointsRemoved;
         this.maxShieldPointsRemoved;
         this.minCriticalShieldPointsRemoved;
         this.maxCriticalShieldPointsRemoved;
      }
      
      public function updateShield() : void
      {
         this.minShieldPointsAdded;
         this.maxShieldPointsAdded;
         this.minCriticalShieldPointsAdded;
         this.maxCriticalShieldPointsAdded;
      }
      
      public function addEffectDamage(pEffectDamage:EffectDamage, pIndex:int = 2147483647) : void
      {
         this._effectDamages.splice(pIndex,0,pEffectDamage);
      }
      
      public function get effectDamages() : Vector.<EffectDamage>
      {
         return this._effectDamages;
      }
      
      public function get hasRandomEffects() : Boolean
      {
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            if(ed.random > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get random() : int
      {
         var ed:* = null;
         var r:int = -1;
         var first:Boolean = true;
         for each(ed in this._effectDamages)
         {
            if(ed.random > 0)
            {
               if(first)
               {
                  r = ed.random;
                  first = false;
               }
               else if(ed.random != r)
               {
                  return -1;
               }
            }
         }
         return r;
      }
      
      public function get element() : int
      {
         var ed:* = null;
         var hasPushDamages:Boolean = false;
         var element:int = -1;
         var first:Boolean = true;
         for each(ed in this._effectDamages)
         {
            if(ed.element != -1)
            {
               if(first)
               {
                  element = ed.element;
                  first = false;
               }
               else if(ed.element != element)
               {
                  return -1;
               }
            }
            if(ed.effectId == ActionIdEnum.ACTION_CHARACTER_PUSH)
            {
               hasPushDamages = true;
            }
         }
         if(element != -1 && hasPushDamages)
         {
            element = -1;
         }
         return element;
      }
      
      public function get hasDamage() : Boolean
      {
         var ed:* = null;
         for each(ed in this.effectDamages)
         {
            if(ed.hasDamage)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get empty() : Boolean
      {
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            if(!(ed.effectId == -1 && ed.element == -1 && ed.computedEffects.length == 0 && !ed.hasDamage && !ed.hasHeal && !ed.hasShield))
            {
               return false;
            }
         }
         return true;
      }
      
      public function applyModificator(pModificator:int) : void
      {
         var ed:* = null;
         for each(ed in this._effectDamages)
         {
            ed.minDamage = ed.minDamage + pModificator;
            ed.maxDamage = ed.maxDamage + pModificator;
            ed.minCriticalDamage = ed.minCriticalDamage + pModificator;
            ed.maxCriticalDamage = ed.maxCriticalDamage + pModificator;
         }
      }
      
      private function getElementTextColor(pElementId:int) : String
      {
         var color:* = null;
         if(pElementId == DamageUtil.UNKNOWN_ELEMENT)
         {
            color = "fight.text.multi";
         }
         else
         {
            switch(pElementId)
            {
               case DamageUtil.NEUTRAL_ELEMENT:
                  color = "fight.text.neutral";
                  break;
               case DamageUtil.EARTH_ELEMENT:
                  color = "fight.text.earth";
                  break;
               case DamageUtil.FIRE_ELEMENT:
                  color = "fight.text.fire";
                  break;
               case DamageUtil.WATER_ELEMENT:
                  color = "fight.text.water";
                  break;
               case DamageUtil.AIR_ELEMENT:
                  color = "fight.text.air";
            }
         }
         return XmlConfig.getInstance().getEntry("colors." + color);
      }
      
      private function getEffectString(pMin:int, pMax:int, pMinCritical:int, pMaxCritical:int, pHasCritical:Boolean, pRandom:int = 0) : String
      {
         var normal:* = null;
         var critical:* = null;
         var effectStr:String = "";
         if(this.criticalHitRate < 100 || this.minimizedEffects)
         {
            if(pMin == pMax)
            {
               normal = String(pMax);
            }
            else if(this.maximizedEffects)
            {
               normal = String(pMax);
            }
            else if(this.minimizedEffects)
            {
               normal = String(pMin);
            }
            else
            {
               normal = pMin + (pMax != 0?" - " + pMax:"");
            }
         }
         if(this.criticalHitRate > 0 && pHasCritical && !this.minimizedEffects)
         {
            if(pMinCritical == pMaxCritical)
            {
               critical = String(pMaxCritical);
            }
            else if(this.maximizedEffects)
            {
               critical = String(pMaxCritical);
            }
            else
            {
               critical = pMinCritical + (pMaxCritical != 0?" - " + pMaxCritical:"");
            }
         }
         if(normal)
         {
            effectStr = normal;
         }
         if(critical)
         {
            if(normal != critical)
            {
               effectStr = effectStr + (" (" + critical + ")");
            }
            else
            {
               effectStr = critical;
            }
         }
         if(!effectStr.length)
         {
            effectStr = "0";
         }
         return pRandom > 0?pRandom + "% " + effectStr:effectStr;
      }
      
      public function toString() : String
      {
         var ed:* = null;
         var effText:* = null;
         var healEffect:Boolean = false;
         var allDamageConvertedToHeal:Boolean = false;
         var hasDamage:Boolean = false;
         var dmgStr:* = null;
         var shieldRemovedStr:* = null;
         var shieldAddedStr:* = null;
         var healStr:* = null;
         var finalStr:String = "";
         var damageColor:String = this.getElementTextColor(this.element);
         var shieldColor:String = "0x9966CC";
         var healColor:int = OptionManager.getOptionManager("chat")["channelColor" + ChatActivableChannelsEnum.PSEUDO_CHANNEL_FIGHT_LOG];
         this.effectIcons = new Array();
         var invulnerableStateData:SpellState = SpellState.getSpellStateById(DataEnum.SPELL_STATE_INVULNERABLE);
         var invulnerableStr:String = !!invulnerableStateData?invulnerableStateData.name:I18n.getUiText("ui.prism.state0");
         if(this.hasRandomEffects)
         {
            for each(ed in this._effectDamages)
            {
               effText = null;
               healEffect = ed.damageConvertedToHeal || ed.lifeSteal;
               if(!healEffect && this.invulnerableState)
               {
                  if(finalStr.indexOf(invulnerableStr) == -1)
                  {
                     this.effectIcons.push(null);
                     effText = invulnerableStr;
                     ed.element = this.element;
                  }
                  else
                  {
                     continue;
                  }
               }
               if(!effText && ed.element != -1)
               {
                  if(healEffect)
                  {
                     this.effectIcons.push("lifePoints");
                     effText = this.getEffectString(ed.minLifePointsAdded,ed.maxLifePointsAdded,ed.minCriticalLifePointsAdded,ed.maxCriticalLifePointsAdded,ed.hasCritical,ed.random);
                  }
                  else
                  {
                     this.effectIcons.push(null);
                     effText = this.getEffectString(ed.minDamage,ed.maxDamage,ed.minCriticalDamage,ed.maxCriticalDamage,ed.hasCritical,ed.random);
                  }
               }
               if(effText)
               {
                  finalStr = finalStr + (HtmlManager.addTag(effText,HtmlManager.SPAN,{"color":(!healEffect?this.getElementTextColor(ed.element):healColor)}) + "\n");
               }
            }
         }
         else
         {
            allDamageConvertedToHeal = true;
            for each(ed in this._effectDamages)
            {
               if(!(ed.effectId == -1 && ed.element == -1 && (!ed.hasDamage || ed.computedEffects.length == 0)))
               {
                  hasDamage = true;
                  if(!ed.damageConvertedToHeal)
                  {
                     allDamageConvertedToHeal = false;
                     break;
                  }
               }
            }
            dmgStr = hasDamage && !allDamageConvertedToHeal?this.getEffectString(this._minDamage,this._maxDamage,this._minCriticalDamage,this._maxCriticalDamage,this.hasCriticalDamage):"";
            if(dmgStr != "")
            {
               dmgStr = !this.invulnerableState?dmgStr:invulnerableStr;
               this.effectIcons.push(null);
               finalStr = finalStr + (HtmlManager.addTag(dmgStr,HtmlManager.SPAN,{"color":damageColor}) + "\n");
            }
            if(!this.isHealingSpell && !this.invulnerableState)
            {
               if(this._minShieldPointsRemoved != 0 && this._maxShieldPointsRemoved != 0)
               {
                  shieldRemovedStr = this.getEffectString(this._minShieldPointsRemoved,this._maxShieldPointsRemoved,this._minCriticalShieldPointsRemoved,this._maxCriticalShieldPointsRemoved,this.hasCriticalShieldPointsRemoved);
               }
               if(shieldRemovedStr)
               {
                  this.effectIcons.push(null);
                  finalStr = finalStr + (HtmlManager.addTag(shieldRemovedStr,HtmlManager.SPAN,{"color":shieldColor}) + "\n");
               }
            }
            if(this._minShieldPointsAdded != 0 && this._maxShieldPointsAdded != 0)
            {
               shieldAddedStr = this.getEffectString(this._minShieldPointsAdded,this._maxShieldPointsAdded,this._minCriticalShieldPointsAdded,this._maxCriticalShieldPointsAdded,this.hasCriticalShieldPointsAdded);
            }
            if(shieldAddedStr)
            {
               this.effectIcons.push(null);
               finalStr = finalStr + (HtmlManager.addTag("+" + shieldAddedStr,HtmlManager.SPAN,{"color":shieldColor}) + "\n");
            }
            if(this.hasHeal)
            {
               healStr = this.getEffectString(this.minLifePointsAdded,this.maxLifePointsAdded,this.minCriticalLifePointsAdded,this.maxCriticalLifePointsAdded,this.hasCriticalLifePointsAdded);
               if(this.unhealableState)
               {
                  this.effectIcons.push(null);
                  healStr = SpellState.getSpellStateById(DataEnum.SPELL_STATE_UNHEALABLE).name;
               }
               else
               {
                  this.effectIcons.push("lifePoints");
               }
               finalStr = finalStr + HtmlManager.addTag(healStr,HtmlManager.SPAN,{"color":healColor});
            }
         }
         return finalStr;
      }
   }
}
