package com.ankamagames.dofus.logic.game.fight.types
{
   public class ReflectValues
   {
       
      
      private var _reflectValue:uint;
      
      private var _boostedReflectValue:uint;
      
      public function ReflectValues(pReflectValue:uint, pBoostedReflectValue:uint)
      {
         super();
         this._reflectValue = pReflectValue;
         this._boostedReflectValue = pBoostedReflectValue;
      }
      
      public function get reflectValue() : uint
      {
         return this._reflectValue;
      }
      
      public function get boostedReflectValue() : uint
      {
         return this._boostedReflectValue;
      }
   }
}
