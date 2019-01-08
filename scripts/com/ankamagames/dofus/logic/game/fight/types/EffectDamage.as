package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.dofus.datacenter.effects.Effect;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import flash.net.registerClassAlias;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class EffectDamage
   {
       
      
      private var _effect:EffectInstance;
      
      private var _effectId:int;
      
      private var _element:int;
      
      private var _random:int;
      
      private var _duration:int;
      
      private var _boostable:Boolean;
      
      public var computedEffects:Vector.<EffectDamage>;
      
      public var spellEffectOrder:int;
      
      public var efficiencyMultiplier:Number;
      
      public var minDamage:int;
      
      public var minDamageList:Vector.<int>;
      
      public var maxDamage:int;
      
      public var maxDamageList:Vector.<int>;
      
      public var minCriticalDamage:int;
      
      public var minCriticalDamageList:Vector.<int>;
      
      public var maxCriticalDamage:int;
      
      public var maxCriticalDamageList:Vector.<int>;
      
      public var minErosionPercent:int;
      
      public var maxErosionPercent:int;
      
      public var minCriticalErosionPercent:int;
      
      public var maxCriticalErosionPercent:int;
      
      public var minErosionDamage:int;
      
      public var maxErosionDamage:int;
      
      public var minCriticalErosionDamage:int;
      
      public var maxCriticalErosionDamage:int;
      
      public var minBaseDamage:int;
      
      public var minBaseDamageList:Vector.<int>;
      
      public var maxBaseDamage:int;
      
      public var minBaseCriticalDamage:int;
      
      public var maxBaseCriticalDamage:int;
      
      public var minShieldPointsRemoved:int;
      
      public var maxShieldPointsRemoved:int;
      
      public var minCriticalShieldPointsRemoved:int;
      
      public var maxCriticalShieldPointsRemoved:int;
      
      public var minShieldPointsAdded:int;
      
      public var maxShieldPointsAdded:int;
      
      public var minCriticalShieldPointsAdded:int;
      
      public var maxCriticalShieldPointsAdded:int;
      
      public var minLifePointsAdded:int;
      
      public var maxLifePointsAdded:int;
      
      public var minCriticalLifePointsAdded:int;
      
      public var maxCriticalLifePointsAdded:int;
      
      public var lifePointsAddedBasedOnLifePercent:int;
      
      public var criticalLifePointsAddedBasedOnLifePercent:int;
      
      public var hasCritical:Boolean;
      
      public var damageConvertedToHeal:Boolean;
      
      public var lifeSteal:Boolean;
      
      public var damageDistance:int = -1;
      
      public function EffectDamage(pEffectId:int = -1, pElementId:int = -1, pRandom:int = -1, pDuration:int = -1, pBoostable:Boolean = true)
      {
         super();
         this._effectId = pEffectId;
         this._element = pElementId;
         this._random = pRandom <= 0?-1:int(pRandom);
         this._duration = pDuration;
         this._boostable = pBoostable;
         this.computedEffects = new Vector.<EffectDamage>(0);
      }
      
      public static function fromEffectInstance(pEffectInstance:EffectInstance) : EffectDamage
      {
         var ed:EffectDamage = new EffectDamage(pEffectInstance.effectId,Effect.getEffectById(pEffectInstance.effectId).elementId,pEffectInstance.random,pEffectInstance.duration);
         ed._effect = pEffectInstance;
         return ed;
      }
      
      public function get effectId() : int
      {
         return this._effectId;
      }
      
      public function set effectId(pEffectId:int) : void
      {
         this._effectId = pEffectId;
      }
      
      public function get element() : int
      {
         return this._element;
      }
      
      public function set element(pElement:int) : void
      {
         this._element = pElement;
      }
      
      public function get random() : int
      {
         return this._random;
      }
      
      public function set random(pRandom:int) : void
      {
         this._random = pRandom;
      }
      
      public function get duration() : int
      {
         return this._duration;
      }
      
      public function get boostable() : Boolean
      {
         return this._boostable;
      }
      
      public function get effect() : EffectInstance
      {
         return this._effect;
      }
      
      public function applyDamageMultiplier(pMultiplier:Number) : void
      {
         var effect:* = null;
         var minDamageBoostDiff:int = 0;
         var maxDamageBoostDiff:int = 0;
         var minCriticalDamageBoostDiff:int = 0;
         var maxCriticalDamageBoostDiff:int = 0;
         var unboostedListIndexes:Vector.<int> = new Vector.<int>(0);
         for each(effect in this.computedEffects)
         {
            if(effect.boostable)
            {
               effect.minDamage = effect.minDamage * pMultiplier;
               effect.maxDamage = effect.maxDamage * pMultiplier;
               effect.minCriticalDamage = effect.minCriticalDamage * pMultiplier;
               effect.maxCriticalDamage = effect.maxCriticalDamage * pMultiplier;
            }
            else
            {
               unboostedListIndexes.push(this.computedEffects.indexOf(effect));
               minDamageBoostDiff = minDamageBoostDiff + (effect.minDamage * pMultiplier - effect.minDamage);
               maxDamageBoostDiff = maxDamageBoostDiff + (effect.maxDamage * pMultiplier - effect.maxDamage);
               minCriticalDamageBoostDiff = minCriticalDamageBoostDiff + (effect.minCriticalDamage * pMultiplier - effect.minCriticalDamage);
               maxCriticalDamageBoostDiff = maxCriticalDamageBoostDiff + (effect.maxCriticalDamage * pMultiplier - effect.maxCriticalDamage);
            }
         }
         this.applyTotalDamageMultiplier("minDamage",this.minDamageList,pMultiplier,unboostedListIndexes,minDamageBoostDiff);
         this.applyTotalDamageMultiplier("maxDamage",this.maxDamageList,pMultiplier,unboostedListIndexes,maxDamageBoostDiff);
         this.applyTotalDamageMultiplier("minCriticalDamage",this.minCriticalDamageList,pMultiplier,unboostedListIndexes,minCriticalDamageBoostDiff);
         this.applyTotalDamageMultiplier("maxCriticalDamage",this.maxCriticalDamageList,pMultiplier,unboostedListIndexes,maxCriticalDamageBoostDiff);
      }
      
      private function applyTotalDamageMultiplier(pPropertyName:String, pDamageList:Vector.<int>, pMultiplier:Number, pUnboostedListIndexes:Vector.<int>, pBoostDiff:int) : void
      {
         var i:int = 0;
         var len:int = !!pDamageList?int(pDamageList.length):0;
         if(len > 0)
         {
            this[pPropertyName] = 0;
            for(i = 0; i < len; i++)
            {
               if(pUnboostedListIndexes.indexOf(i) == -1)
               {
                  pDamageList[i] = pDamageList[i] * pMultiplier;
               }
               this[pPropertyName] = this[pPropertyName] + pDamageList[i];
            }
         }
         else
         {
            this[pPropertyName] = this[pPropertyName] * pMultiplier;
            this[pPropertyName] = this[pPropertyName] - pBoostDiff;
         }
      }
      
      public function applyHealMultiplier(pMultiplier:Number) : void
      {
         var effect:* = null;
         var minLifePointsBoostDiff:int = 0;
         var maxLifePointsBoostDiff:int = 0;
         var minCriticalLifePointsBoostDiff:int = 0;
         var maxCriticalLifePointsBoostDiff:int = 0;
         for each(effect in this.computedEffects)
         {
            if(effect.boostable)
            {
               effect.minLifePointsAdded = effect.minLifePointsAdded * pMultiplier;
               effect.maxLifePointsAdded = effect.maxLifePointsAdded * pMultiplier;
               effect.minCriticalLifePointsAdded = effect.minCriticalLifePointsAdded * pMultiplier;
               effect.maxCriticalLifePointsAdded = effect.maxCriticalLifePointsAdded * pMultiplier;
            }
            else
            {
               minLifePointsBoostDiff = minLifePointsBoostDiff + (effect.minLifePointsAdded * pMultiplier - effect.minLifePointsAdded);
               maxLifePointsBoostDiff = maxLifePointsBoostDiff + (effect.maxLifePointsAdded * pMultiplier - effect.maxLifePointsAdded);
               minCriticalLifePointsBoostDiff = minCriticalLifePointsBoostDiff + (effect.minCriticalLifePointsAdded * pMultiplier - effect.minCriticalLifePointsAdded);
               maxCriticalLifePointsBoostDiff = maxCriticalLifePointsBoostDiff + (effect.maxCriticalLifePointsAdded * pMultiplier - effect.maxCriticalLifePointsAdded);
            }
         }
         this.minLifePointsAdded = this.minLifePointsAdded * pMultiplier;
         this.minLifePointsAdded = this.minLifePointsAdded - minLifePointsBoostDiff;
         this.maxLifePointsAdded = this.maxLifePointsAdded * pMultiplier;
         this.maxLifePointsAdded = this.maxLifePointsAdded - maxLifePointsBoostDiff;
         this.minCriticalLifePointsAdded = this.minCriticalLifePointsAdded * pMultiplier;
         this.minCriticalLifePointsAdded = this.minCriticalLifePointsAdded - minCriticalLifePointsBoostDiff;
         this.maxCriticalLifePointsAdded = this.maxCriticalLifePointsAdded * pMultiplier;
         this.maxCriticalLifePointsAdded = this.maxCriticalLifePointsAdded - maxCriticalLifePointsBoostDiff;
      }
      
      public function convertDamageToHeal() : void
      {
         var computedEffect:* = null;
         this.minLifePointsAdded = this.minLifePointsAdded + this.minDamage;
         this.minDamage = 0;
         this.maxLifePointsAdded = this.maxLifePointsAdded + this.maxDamage;
         this.maxDamage = 0;
         this.minCriticalLifePointsAdded = this.minCriticalLifePointsAdded + this.minCriticalDamage;
         this.minCriticalDamage = 0;
         this.maxCriticalLifePointsAdded = this.maxCriticalLifePointsAdded + this.maxCriticalDamage;
         this.maxCriticalDamage = 0;
         if(this.minDamageList)
         {
            this.minDamageList.length = 0;
         }
         if(this.maxDamageList)
         {
            this.maxDamageList.length = 0;
         }
         if(this.minCriticalDamageList)
         {
            this.minCriticalDamageList.length = 0;
         }
         if(this.maxCriticalDamageList)
         {
            this.maxCriticalDamageList.length = 0;
         }
         this.damageConvertedToHeal = true;
         for each(computedEffect in this.computedEffects)
         {
            computedEffect.convertDamageToHeal();
         }
      }
      
      public function get hasDamage() : Boolean
      {
         return !(this.minDamage == 0 && this.maxDamage == 0 && this.minCriticalDamage == 0 && this.maxCriticalDamage == 0);
      }
      
      public function get hasHeal() : Boolean
      {
         return !(this.minLifePointsAdded == 0 && this.maxLifePointsAdded == 0 && this.minCriticalLifePointsAdded == 0 && this.maxCriticalLifePointsAdded == 0);
      }
      
      public function get hasShield() : Boolean
      {
         return !(this.minShieldPointsAdded == 0 && this.maxShieldPointsAdded == 0 && this.minCriticalShieldPointsAdded == 0 && this.maxCriticalShieldPointsAdded == 0);
      }
      
      public function clone() : *
      {
         var className:String = getQualifiedClassName(this);
         var classToClone:Class = this["constructor"];
         registerClassAlias(className,classToClone);
         var b:ByteArray = new ByteArray();
         b.writeObject(this);
         b.position = 0;
         return b.readObject() as classToClone;
      }
      
      public function addDamage(pEffect:EffectDamage) : void
      {
         this.minDamage = this.minDamage + pEffect.minDamage;
         this.maxDamage = this.maxDamage + pEffect.maxDamage;
         this.minCriticalDamage = this.minCriticalDamage + pEffect.minCriticalDamage;
         this.maxCriticalDamage = this.maxCriticalDamage + pEffect.maxCriticalDamage;
      }
      
      public function addHeal(pEffect:EffectDamage) : void
      {
         this.minLifePointsAdded = this.minLifePointsAdded + pEffect.minLifePointsAdded;
         this.maxLifePointsAdded = this.maxLifePointsAdded + pEffect.maxLifePointsAdded;
         this.minCriticalLifePointsAdded = this.minCriticalLifePointsAdded + pEffect.minCriticalLifePointsAdded;
         this.maxCriticalLifePointsAdded = this.maxCriticalLifePointsAdded + pEffect.maxCriticalLifePointsAdded;
      }
      
      public function toString() : String
      {
         return "[Effect id=" + this.effectId + " element=" + this.element + " random=" + this.random + " spellEffectOrder=" + this.spellEffectOrder + " min=" + this.minDamage + " max=" + this.maxDamage + " minCrit=" + this.minCriticalDamage + " maxCrit=" + this.maxCriticalDamage + " minLife=" + this.minLifePointsAdded + " maxLife=" + this.maxLifePointsAdded + " minCritLife=" + this.minCriticalLifePointsAdded + " maxCritLife=" + this.maxCriticalLifePointsAdded + "]";
      }
   }
}
