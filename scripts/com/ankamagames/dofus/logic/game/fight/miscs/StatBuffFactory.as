package com.ankamagames.dofus.logic.game.fight.miscs
{
   import com.ankamagames.dofus.logic.game.fight.types.BlockEvadeBuff;
   import com.ankamagames.dofus.logic.game.fight.types.CastingSpell;
   import com.ankamagames.dofus.logic.game.fight.types.StatBuff;
   import com.ankamagames.dofus.network.types.game.actions.fight.FightTemporaryBoostEffect;
   
   public class StatBuffFactory
   {
       
      
      public function StatBuffFactory()
      {
         super();
      }
      
      public static function createStatBuff(pEffect:FightTemporaryBoostEffect, pCastingSpell:CastingSpell, pActionId:uint) : StatBuff
      {
         var buff:* = null;
         switch(pActionId)
         {
            case ActionIdEnum.ACTION_CHARACTER_BOOST_DODGE:
            case ActionIdEnum.ACTION_CHARACTER_BOOST_TACKLE:
            case ActionIdEnum.ACTION_CHARACTER_DEBOOST_DODGE:
            case ActionIdEnum.ACTION_CHARACTER_DEBOOST_TACKLE:
               buff = new BlockEvadeBuff(pEffect,pCastingSpell,pActionId);
               break;
            default:
               buff = new StatBuff(pEffect,pCastingSpell,pActionId);
         }
         return buff;
      }
   }
}
