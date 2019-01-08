package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.dofus.datacenter.effects.Effect;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   
   public class SplashDamage
   {
       
      
      private var _spellId:int;
      
      private var _casterId:Number;
      
      private var _targets:Vector.<Number>;
      
      private var _damage:SpellDamage;
      
      private var _effect:EffectInstanceDice;
      
      private var _spellShape:uint;
      
      private var _spellShapeSize:Object;
      
      private var _spellShapeMinSize:Object;
      
      private var _spellShapeEfficiencyPercent:Object;
      
      private var _spellShapeMaxEfficiency:Object;
      
      private var _hasCritical:Boolean;
      
      private var _random:int;
      
      private var _casterCell:int;
      
      public function SplashDamage(pSpellId:int, pCasterId:Number, pTargets:Vector.<Number>, pSourceSpellDamage:SpellDamage, pSplashEffect:EffectInstanceDice, pSourceSpellInfo:SpellDamageInfo)
      {
         var ed:* = null;
         var edSplash:* = null;
         var minDamage:int = 0;
         var maxDamage:int = 0;
         var minCriticalDamage:int = 0;
         var maxCriticalDamage:int = 0;
         super();
         this._spellId = pSpellId;
         this._casterId = pCasterId;
         this._targets = pTargets;
         this._damage = new SpellDamage();
         this._effect = pSplashEffect;
         var splashEffectElement:int = Effect.getEffectById(pSplashEffect.effectId).elementId;
         this._spellShape = pSplashEffect.rawZone.charCodeAt(0);
         this._spellShapeSize = pSplashEffect.zoneSize;
         this._spellShapeMinSize = pSplashEffect.zoneMinSize;
         this._spellShapeEfficiencyPercent = pSplashEffect.zoneEfficiencyPercent;
         this._spellShapeMaxEfficiency = pSplashEffect.zoneMaxEfficiency;
         this._random = pSplashEffect.random > 0?int(pSplashEffect.random):-1;
         this._casterCell = pSourceSpellInfo.targetCell;
         for each(ed in pSourceSpellDamage.effectDamages)
         {
            for each(ed in ed.computedEffects)
            {
               if(ed.effectId != ActionIdEnum.ACTION_CHARACTER_SACRIFY || pSourceSpellInfo.originalTargetsIds.indexOf(pCasterId) == -1)
               {
                  edSplash = new EffectDamage(pSplashEffect.effectId,splashEffectElement != -1 && ed.element != -1?int(splashEffectElement):int(ed.element),ed.random);
                  minDamage = pSourceSpellDamage.minDamage == pSourceSpellDamage.minErosionDamage?int(ed.minErosionDamage):int(ed.minDamage);
                  maxDamage = pSourceSpellDamage.maxDamage == pSourceSpellDamage.maxErosionDamage?int(ed.maxErosionDamage):int(ed.maxDamage);
                  minCriticalDamage = pSourceSpellDamage.minCriticalDamage == pSourceSpellDamage.minCriticalErosionDamage?int(ed.minCriticalErosionDamage):int(ed.minCriticalDamage);
                  maxCriticalDamage = pSourceSpellDamage.maxCriticalDamage == pSourceSpellDamage.maxCriticalErosionDamage?int(ed.maxCriticalErosionDamage):int(ed.maxCriticalDamage);
                  edSplash.minDamage = this.getSplashDamage(minDamage,ed.minDamageList,pSplashEffect.diceNum);
                  edSplash.maxDamage = this.getSplashDamage(maxDamage,ed.maxDamageList,pSplashEffect.diceNum);
                  edSplash.minCriticalDamage = this.getSplashDamage(minCriticalDamage,ed.minCriticalDamageList,pSplashEffect.diceNum);
                  edSplash.maxCriticalDamage = this.getSplashDamage(maxCriticalDamage,ed.maxCriticalDamageList,pSplashEffect.diceNum);
                  edSplash.hasCritical = ed.hasCritical;
                  this._damage.addEffectDamage(edSplash);
               }
            }
         }
         this._damage.hasCriticalDamage = pSourceSpellDamage.hasCriticalDamage;
         this._damage.updateDamage();
      }
      
      public function get spellId() : int
      {
         return this._spellId;
      }
      
      public function get casterId() : Number
      {
         return this._casterId;
      }
      
      public function get targets() : Vector.<Number>
      {
         return this._targets;
      }
      
      public function get damage() : SpellDamage
      {
         return this._damage;
      }
      
      public function get effect() : EffectInstanceDice
      {
         return this._effect;
      }
      
      public function get spellShape() : uint
      {
         return this._spellShape;
      }
      
      public function get spellShapeSize() : Object
      {
         return this._spellShapeSize;
      }
      
      public function get spellShapeMinSize() : Object
      {
         return this._spellShapeMinSize;
      }
      
      public function get spellShapeEfficiencyPercent() : Object
      {
         return this._spellShapeEfficiencyPercent;
      }
      
      public function get spellShapeMaxEfficiency() : Object
      {
         return this._spellShapeMaxEfficiency;
      }
      
      public function get random() : int
      {
         return this._random;
      }
      
      public function get casterCell() : int
      {
         return this._casterCell;
      }
      
      private function getSplashDamage(pDamage:int, pDamageList:Vector.<int>, pSplashPercent:int) : int
      {
         var dmg:int = 0;
         var splashDmg:int = 0;
         if(pDamageList)
         {
            for each(dmg in pDamageList)
            {
               splashDmg = splashDmg + dmg * pSplashPercent / 100;
            }
         }
         else
         {
            splashDmg = pDamage * pSplashPercent / 100;
         }
         return splashDmg;
      }
   }
}
