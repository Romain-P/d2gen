package com.ankamagames.dofus.logic.game.fight.types
{
   public class ReflectDamage
   {
       
      
      private var _effects:Vector.<EffectDamage>;
      
      private var _sourceId:Number;
      
      private var _reflectValue:uint;
      
      private var _boosted:Boolean;
      
      public function ReflectDamage(pSourceId:Number, pReflectValue:uint, pBoosted:Boolean)
      {
         super();
         this._sourceId = pSourceId;
         this._reflectValue = pReflectValue;
         this._boosted = pBoosted;
      }
      
      public function get sourceId() : Number
      {
         return this._sourceId;
      }
      
      public function get effects() : Vector.<EffectDamage>
      {
         return this._effects;
      }
      
      public function get reflectValue() : uint
      {
         return this._reflectValue;
      }
      
      public function get boosted() : Boolean
      {
         return this._boosted;
      }
      
      public function addEffect(pEffect:EffectDamage) : void
      {
         if(!this._effects)
         {
            this._effects = new Vector.<EffectDamage>(0);
         }
         this._effects.push(pEffect);
      }
   }
}
