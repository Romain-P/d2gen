package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   
   public class PushedEntity
   {
       
      
      private var _id:Number;
      
      private var _spellId:int;
      
      private var _pushedIndexes:Vector.<uint>;
      
      private var _force:int;
      
      private var _pushingEntity:PushedEntity;
      
      private var _damage:int;
      
      private var _criticalDamage:int;
      
      private var _pushEffect:EffectInstance;
      
      private var _pushedDistance:int = -1;
      
      public function PushedEntity(pEntityId:Number, pSpellId:int, pFirstIndex:uint, pForce:int, pPushEffect:EffectInstance)
      {
         super();
         this._id = pEntityId;
         this._spellId = pSpellId;
         this._pushedIndexes = new Vector.<uint>(0);
         this._pushedIndexes.push(pFirstIndex);
         this._force = pForce;
         this._pushEffect = pPushEffect;
      }
      
      public function get id() : Number
      {
         return this._id;
      }
      
      public function set id(value:Number) : void
      {
         this._id = value;
      }
      
      public function get spellId() : int
      {
         return this._spellId;
      }
      
      public function get pushedIndexes() : Vector.<uint>
      {
         return this._pushedIndexes;
      }
      
      public function set pushedIndexes(value:Vector.<uint>) : void
      {
         this._pushedIndexes = value;
      }
      
      public function get force() : int
      {
         return this._force;
      }
      
      public function set force(value:int) : void
      {
         this._force = value;
      }
      
      public function get pushingEntity() : PushedEntity
      {
         return this._pushingEntity;
      }
      
      public function set pushingEntity(value:PushedEntity) : void
      {
         this._pushingEntity = value;
      }
      
      public function get pushEffect() : EffectInstance
      {
         return this._pushEffect;
      }
      
      public function get pushedDistance() : int
      {
         return this._pushedDistance;
      }
      
      public function set pushedDistance(pPushedDistance:int) : void
      {
         this._pushedDistance = pPushedDistance;
      }
   }
}
