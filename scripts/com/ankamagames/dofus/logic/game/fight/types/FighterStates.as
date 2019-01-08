package com.ankamagames.dofus.logic.game.fight.types
{
   import flash.utils.Dictionary;
   
   public class FighterStates
   {
       
      
      private var _states:Dictionary;
      
      public function FighterStates()
      {
         this._states = new Dictionary();
         super();
      }
      
      public function addState(pStateId:int, pSpellId:int) : void
      {
         if(!this._states[pStateId])
         {
            this._states[pStateId] = new State();
         }
         if(this._states[pStateId].spells.indexOf(pSpellId) == -1)
         {
            this._states[pStateId].spells.push(pSpellId);
         }
      }
      
      public function getStates(pSpellId:int) : Array
      {
         var states:* = null;
         var stateId:* = undefined;
         for(stateId in this._states)
         {
            if(this._states[stateId].spells.indexOf(pSpellId) != -1)
            {
               if(!states)
               {
                  states = [];
               }
               states.push(stateId);
            }
         }
         return states;
      }
      
      public function addTriggeredSpell(pSpellId:int, pParentSpellId:int) : void
      {
         var stateId:* = undefined;
         for(stateId in this._states)
         {
            if(this._states[stateId].spells.indexOf(pParentSpellId) != -1)
            {
               this._states[stateId].spells.push(pSpellId);
            }
         }
      }
   }
}

class State
{
    
   
   public var stateId:int;
   
   public var spells:Vector.<int>;
   
   function State()
   {
      this.spells = new Vector.<int>(0);
      super();
   }
}
