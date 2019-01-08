package com.ankamagames.dofus.logic.game.fight.managers
{
   import com.ankamagames.dofus.logic.game.fight.types.EffectDamage;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamage;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageInfo;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageList;
   import flash.utils.Dictionary;
   
   public class SpellDamagesManager
   {
      
      private static var _self:SpellDamagesManager;
       
      
      private var _spellDamages:Dictionary;
      
      public function SpellDamagesManager()
      {
         this._spellDamages = new Dictionary();
         super();
      }
      
      public static function getInstance() : SpellDamagesManager
      {
         if(!_self)
         {
            _self = new SpellDamagesManager();
         }
         return _self;
      }
      
      public function addSpellDamage(pSpellDamageInfo:SpellDamageInfo, pSpellDamage:SpellDamage) : void
      {
         var nbSameSpell:int = 0;
         var entitySpellDamage:* = null;
         if(!this._spellDamages[pSpellDamageInfo.targetId])
         {
            this._spellDamages[pSpellDamageInfo.targetId] = new Vector.<EntitySpellDamage>();
         }
         if(this._spellDamages[pSpellDamageInfo.targetId].length > 1)
         {
            for each(entitySpellDamage in this._spellDamages[pSpellDamageInfo.targetId])
            {
               if(entitySpellDamage.spellId == pSpellDamageInfo.spell.id)
               {
                  nbSameSpell++;
                  if(!pSpellDamageInfo.damageSharingTargets)
                  {
                     break;
                  }
               }
            }
         }
         if(nbSameSpell == 0 || nbSameSpell + 1 <= pSpellDamageInfo.originalTargetsIds.length)
         {
            this._spellDamages[pSpellDamageInfo.targetId].push(new EntitySpellDamage(pSpellDamageInfo.spell.id,pSpellDamage,!!pSpellDamageInfo.interceptedDamage?true:false));
         }
      }
      
      public function removeSpellDamages(pEntityId:Number) : void
      {
         if(this._spellDamages[pEntityId])
         {
            this._spellDamages[pEntityId].length = 0;
         }
      }
      
      public function removeSpellDamageBySpellId(pEntityId:Number, pSpellId:uint) : void
      {
         var esd:* = null;
         if(this._spellDamages[pEntityId])
         {
            for each(esd in this._spellDamages[pEntityId])
            {
               if(esd.spellId == pSpellId)
               {
                  this._spellDamages[pEntityId].splice(this._spellDamages[pEntityId].indexOf(esd),1);
               }
            }
         }
      }
      
      public function hasSpellDamages(pEntityId:Number) : Boolean
      {
         return this._spellDamages[pEntityId] && this._spellDamages[pEntityId].length > 0;
      }
      
      public function getSpellDamages(pEntityId:Number) : Vector.<EntitySpellDamage>
      {
         return this._spellDamages[pEntityId];
      }
      
      public function getSpellDamageBySpellId(pEntityId:Number, pSpellId:int) : EntitySpellDamage
      {
         var entitySpellDamage:* = null;
         if(this._spellDamages[pEntityId])
         {
            for each(entitySpellDamage in this._spellDamages[pEntityId])
            {
               if(entitySpellDamage.spellId == pSpellId)
               {
                  return entitySpellDamage;
               }
            }
         }
         return null;
      }
      
      public function getTotalSpellDamage(pEntityId:Number, pGroupSpells:Boolean = true) : *
      {
         var totalSpellDamage:* = undefined;
         var sd:* = null;
         var entitySpellDamage:* = null;
         var effect:* = null;
         var spelldamages:* = null;
         var i:int = 0;
         var nbSpells:int = 0;
         if(this._spellDamages[pEntityId] && this._spellDamages[pEntityId].length > 1)
         {
            if(pGroupSpells)
            {
               totalSpellDamage = new SpellDamage();
               for each(entitySpellDamage in this._spellDamages[pEntityId])
               {
                  sd = entitySpellDamage.spellDamage;
                  for each(effect in sd.effectDamages)
                  {
                     totalSpellDamage.addEffectDamage(effect);
                  }
                  if(sd.invulnerableState)
                  {
                     totalSpellDamage.invulnerableState = true;
                  }
                  if(sd.unhealableState)
                  {
                     totalSpellDamage.unhealableState = true;
                  }
                  if(sd.hasCriticalDamage)
                  {
                     totalSpellDamage.hasCriticalDamage = true;
                  }
                  if(sd.hasCriticalShieldPointsRemoved)
                  {
                     totalSpellDamage.hasCriticalShieldPointsRemoved = true;
                  }
                  if(sd.hasCriticalLifePointsAdded)
                  {
                     totalSpellDamage.hasCriticalLifePointsAdded = true;
                  }
                  if(sd.isHealingSpell)
                  {
                     totalSpellDamage.isHealingSpell = true;
                  }
                  if(sd.hasHeal)
                  {
                     totalSpellDamage.hasHeal = true;
                  }
                  if(sd.minimizedEffects)
                  {
                     totalSpellDamage.minimizedEffects = true;
                  }
                  if(sd.maximizedEffects)
                  {
                     totalSpellDamage.maximizedEffects = true;
                  }
                  totalSpellDamage.criticalHitRate = sd.criticalHitRate;
               }
               totalSpellDamage.updateDamage();
            }
            else
            {
               spelldamages = new Vector.<SpellDamage>(0);
               nbSpells = this._spellDamages[pEntityId].length;
               for(i = 0; i < nbSpells; i++)
               {
                  spelldamages.push(this._spellDamages[pEntityId][i].spellDamage);
               }
               totalSpellDamage = new SpellDamageList(spelldamages);
            }
         }
         else
         {
            totalSpellDamage = this._spellDamages[pEntityId] && this._spellDamages[pEntityId].length > 0?this._spellDamages[pEntityId][0].spellDamage:null;
         }
         return totalSpellDamage;
      }
   }
}

import com.ankamagames.dofus.logic.game.fight.types.SpellDamage;

class EntitySpellDamage
{
    
   
   public var spellId:int;
   
   public var spellDamage:SpellDamage;
   
   public var interceptedDamage:Boolean;
   
   function EntitySpellDamage(pSpellId:int, pSpellDamage:SpellDamage, pInterceptedDamage:Boolean)
   {
      super();
      this.spellId = pSpellId;
      this.spellDamage = pSpellDamage;
      this.interceptedDamage = pInterceptedDamage;
   }
}
