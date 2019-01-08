package com.ankamagames.dofus.logic.game.fight.types
{
   public class SpellDamageList
   {
       
      
      private var _spellDamages:Vector.<SpellDamage>;
      
      private var _finalStr:String;
      
      public var effectIcons:Array;
      
      public function SpellDamageList(pSpellDamages:Vector.<SpellDamage>)
      {
         var i:int = 0;
         var j:int = 0;
         var nbIcons:int = 0;
         super();
         this._spellDamages = pSpellDamages;
         this.effectIcons = new Array();
         var nbSpells:int = this._spellDamages.length;
         this._finalStr = "";
         for(i = 0; i < nbSpells; i++)
         {
            this._finalStr = this._finalStr + this._spellDamages[i].toString();
         }
         for(i = 0; i < nbSpells; i++)
         {
            nbIcons = this._spellDamages[i].effectIcons.length;
            for(j = 0; j < nbIcons; j++)
            {
               this.effectIcons.push(this._spellDamages[i].effectIcons[j]);
            }
         }
      }
      
      public function toString() : String
      {
         return this._finalStr;
      }
   }
}
