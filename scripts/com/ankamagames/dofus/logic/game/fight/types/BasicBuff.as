package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceInteger;
   import com.ankamagames.dofus.datacenter.spells.SpellLevel;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.logic.game.fight.frames.FightBattleFrame;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   import com.ankamagames.dofus.misc.utils.GameDebugManager;
   import com.ankamagames.dofus.network.enums.FightDispellableEnum;
   import com.ankamagames.dofus.network.types.game.actions.fight.AbstractFightDispellableEffect;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import flash.utils.getQualifiedClassName;
   
   public class BasicBuff
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(BasicBuff));
       
      
      protected var _effect:EffectInstance;
      
      protected var _disabled:Boolean = false;
      
      protected var _removed:Boolean = false;
      
      public var uid:uint;
      
      public var duration:int;
      
      public var castingSpell:CastingSpell;
      
      public var targetId:Number;
      
      public var critical:Boolean = false;
      
      public var dispelable:int;
      
      public var actionId:uint;
      
      public var id:uint;
      
      public var source:Number;
      
      public var aliveSource:Number;
      
      public var sourceJustReaffected:Boolean = false;
      
      public var stack:Vector.<BasicBuff>;
      
      public var parentBoostUid:uint;
      
      public var dataUid:int;
      
      public function BasicBuff(effect:AbstractFightDispellableEffect = null, castingSpell:CastingSpell = null, actionId:uint = 0, param1:* = null, param2:* = null, param3:* = null)
      {
         super();
         if(!effect)
         {
            return;
         }
         this.id = effect.uid;
         this.uid = effect.uid;
         this.actionId = actionId;
         this.targetId = effect.targetId;
         this.castingSpell = castingSpell;
         this.duration = effect.turnDuration;
         this.dispelable = effect.dispelable;
         this.source = castingSpell.casterId;
         this.dataUid = effect.effectId;
         var fightBattleFrame:FightBattleFrame = Kernel.getWorker().getFrame(FightBattleFrame) as FightBattleFrame;
         if(Kernel.beingInReconection || PlayedCharacterManager.getInstance().isSpectator || fightBattleFrame.currentPlayerId == 0)
         {
            this.aliveSource = this.source;
         }
         else
         {
            this.aliveSource = fightBattleFrame.currentPlayerId;
         }
         this.parentBoostUid = this.parentBoostUid;
         this.initParam(param1,param2,param3);
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            _log.debug("[BUFFS DEBUG] Buff " + this.id + " créé ! Params " + param1 + ", " + param2 + ", " + param3 + ", aliveSource " + this.aliveSource + "     \'" + this._effect.description + "\'");
         }
      }
      
      public function get effect() : EffectInstance
      {
         return this._effect;
      }
      
      public function get type() : String
      {
         return "BasicBuff";
      }
      
      public function get param1() : *
      {
         if(this._effect is EffectInstanceDice)
         {
            return EffectInstanceDice(this._effect).diceNum;
         }
         return null;
      }
      
      public function get param2() : *
      {
         if(this._effect is EffectInstanceDice)
         {
            return EffectInstanceDice(this._effect).diceSide;
         }
         return null;
      }
      
      public function get param3() : *
      {
         if(this._effect is EffectInstanceInteger)
         {
            return EffectInstanceInteger(this._effect).value;
         }
         return null;
      }
      
      public function set param1(v:*) : void
      {
         this._effect.setParameter(0,v == 0?null:v);
      }
      
      public function set param2(v:*) : void
      {
         this._effect.setParameter(1,v == 0?null:v);
      }
      
      public function set param3(v:*) : void
      {
         this._effect.setParameter(2,v == 0?null:v);
      }
      
      public function get unusableNextTurn() : Boolean
      {
         var currentPlayerId:Number = NaN;
         var playerId:Number = NaN;
         var playerPos:int = 0;
         var currentPos:int = 0;
         var casterPos:int = 0;
         var i:int = 0;
         var fighter:Number = NaN;
         if(this.duration > 1 || this.duration < 0)
         {
            return false;
         }
         var frame:FightBattleFrame = Kernel.getWorker().getFrame(FightBattleFrame) as FightBattleFrame;
         if(frame)
         {
            currentPlayerId = frame.currentPlayerId;
            playerId = PlayedCharacterManager.getInstance().id;
            if(currentPlayerId == playerId || currentPlayerId == this.source)
            {
               return false;
            }
            playerPos = -1;
            currentPos = -1;
            casterPos = -1;
            for(i = 0; i < frame.fightersList.length; )
            {
               fighter = frame.fightersList[i];
               if(fighter == playerId)
               {
                  playerPos = i;
               }
               if(fighter == currentPlayerId)
               {
                  currentPos = i;
               }
               if(fighter == this.source)
               {
                  casterPos = i;
               }
               i++;
            }
            if(casterPos < currentPos)
            {
               casterPos = casterPos + frame.fightersList.length;
            }
            if(playerPos < currentPos)
            {
               playerPos = playerPos + frame.fightersList.length;
            }
            if(playerPos > currentPos && playerPos <= casterPos)
            {
               return false;
            }
            return true;
         }
         return false;
      }
      
      public function get trigger() : Boolean
      {
         return false;
      }
      
      public function get effectOrder() : int
      {
         var effect:* = null;
         for(var i:int = 0; i < this.castingSpell.spellRank.effects.length; )
         {
            effect = this.castingSpell.spellRank.effects[i];
            if(effect.effectUid == this.dataUid)
            {
               return i;
            }
            i++;
         }
         return -1;
      }
      
      public function get disabled() : Boolean
      {
         return this._disabled;
      }
      
      public function initParam(param1:int, param2:int, param3:int) : void
      {
         var sl:* = null;
         var slId:int = 0;
         var ei:* = null;
         if(param1 && param1 != 0 || param2 && param2 != 0)
         {
            this._effect = new EffectInstanceDice();
            this._effect.effectId = this.actionId;
            this._effect.duration = this.duration;
            (this._effect as EffectInstanceDice).diceNum = param1;
            (this._effect as EffectInstanceDice).diceSide = param2;
            (this._effect as EffectInstanceDice).value = param3;
            this._effect.trigger = this.trigger;
         }
         else
         {
            this._effect = new EffectInstanceInteger();
            this._effect.effectId = this.actionId;
            this._effect.duration = this.duration;
            (this._effect as EffectInstanceInteger).value = param3;
            this._effect.trigger = this.trigger;
         }
         for each(slId in this.castingSpell.spell.spellLevels)
         {
            sl = SpellLevel.getLevelById(slId);
            if(sl)
            {
               for each(ei in sl.effects)
               {
                  if(ei.effectUid == this.dataUid)
                  {
                     this._effect.visibleInTooltip = ei.visibleInTooltip;
                     this._effect.visibleInBuffUi = ei.visibleInBuffUi;
                     this._effect.visibleInFightLog = ei.visibleInFightLog;
                  }
               }
            }
         }
      }
      
      public function canBeDispell(forceUndispellable:Boolean = false, targetBuffId:int = -2147483648, dying:Boolean = false) : Boolean
      {
         if(targetBuffId == this.id)
         {
            return true;
         }
         switch(this.dispelable)
         {
            case FightDispellableEnum.DISPELLABLE:
               return true;
            case FightDispellableEnum.DISPELLABLE_BY_STRONG_DISPEL:
               return forceUndispellable;
            case FightDispellableEnum.DISPELLABLE_BY_DEATH:
               return dying || forceUndispellable;
            case FightDispellableEnum.REALLY_NOT_DISPELLABLE:
               return targetBuffId == this.id;
            default:
               return false;
         }
      }
      
      public function dispellableByDeath() : Boolean
      {
         return this.dispelable == FightDispellableEnum.DISPELLABLE_BY_DEATH || this.dispelable == FightDispellableEnum.DISPELLABLE;
      }
      
      public function onDisabled() : void
      {
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            _log.debug("[BUFFS DEBUG] Buff " + this.uid + " desactivé");
         }
         this._disabled = true;
      }
      
      public function undisable() : void
      {
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            _log.debug("[BUFFS DEBUG] Buff " + this.uid + " réactivé");
         }
         this._disabled = false;
      }
      
      public function onRemoved() : void
      {
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            _log.debug("[BUFFS DEBUG] Buff " + this.uid + " retiré");
         }
         this._removed = true;
         if(!this._disabled)
         {
            this.onDisabled();
         }
      }
      
      public function onApplyed() : void
      {
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            _log.debug("[BUFFS DEBUG] Buff " + this.uid + " appliqué");
         }
         this._disabled = false;
         this._removed = false;
      }
      
      public function equals(other:BasicBuff, osefSpell:Boolean = false) : Boolean
      {
         var sb1:* = null;
         var sb2:* = null;
         if(this.targetId != other.targetId || this.aliveSource != other.aliveSource || this.effect.effectId != other.actionId || this.duration != other.duration || this.effect.hasOwnProperty("delay") && other.effect.hasOwnProperty("delay") && this.effect.delay != other.effect.delay || this.castingSpell.spellRank && other.castingSpell.spellRank && !osefSpell && this.castingSpell.spellRank.id != other.castingSpell.spellRank.id || !osefSpell && this.castingSpell.spell.id != other.castingSpell.spell.id || getQualifiedClassName(this) != getQualifiedClassName(other) || this.source != other.source || this.trigger && (this.effect.triggers.indexOf("|") == -1 || this.dataUid != other.dataUid))
         {
            return false;
         }
         var thisActionId:uint = this.actionId;
         if(thisActionId == ActionIdEnum.ACTION_CHARACTER_CHATIMENT)
         {
            if(this.param1 != other.param1)
            {
               return false;
            }
         }
         else if(thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_RANGE || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_RANGEABLE || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_DMG || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_HEAL || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_AP_COST || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_CAST_INTVL || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_CC || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_CASTOUTLINE || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_NOLINEOFSIGHT || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_MAXPERTURN || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_MAXPERTARGET || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_CAST_INTVL_SET || thisActionId == ActionIdEnum.ACTION_BOOST_SPELL_BASE_DMG || thisActionId == ActionIdEnum.ACTION_DEBOOST_SPELL_RANGE || thisActionId == ActionIdEnum.ACTION_CHARACTER_REMOVE_ALL_SPELL_EFFECTS || thisActionId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL || thisActionId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM || thisActionId == ActionIdEnum.ACTION_TARGET_EXECUTE_SPELL_ON_SOURCE || thisActionId == ActionIdEnum.ACTION_SOURCE_EXECUTE_SPELL_ON_TARGET || thisActionId == ActionIdEnum.ACTION_SOURCE_EXECUTE_SPELL_ON_SOURCE || thisActionId == ActionIdEnum.ACTION_CHARACTER_ADD_SPELL_COOLDOWN || thisActionId == ActionIdEnum.ACTION_CHARACTER_REMOVE_SPELL_COOLDOWN || thisActionId == ActionIdEnum.ACTION_CHARACTER_IMMUNITY_AGAINST_SPELL || thisActionId == ActionIdEnum.ACTION_CHARACTER_SET_SPELL_COOLDOWN)
         {
            if(this.param1 != other.param1)
            {
               return false;
            }
         }
         else
         {
            if(thisActionId == ActionIdEnum.ACTION_CHARACTER_BOOST_WEAPON_DAMAGE_PERCENT)
            {
               return false;
            }
            if(thisActionId == ActionIdEnum.ACTION_CHARACTER_ADD_APPEARANCE)
            {
               if(this.dataUid != other.dataUid)
               {
                  return false;
               }
            }
            else if(thisActionId == other.actionId && (thisActionId == ActionIdEnum.ACTION_FIGHT_DISABLE_STATE || thisActionId == ActionIdEnum.ACTION_FIGHT_UNSET_STATE || thisActionId == ActionIdEnum.ACTION_FIGHT_SET_STATE))
            {
               sb1 = this as StateBuff;
               sb2 = other as StateBuff;
               if(sb1 && sb2)
               {
                  if(sb1.stateId != sb2.stateId)
                  {
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      public function add(buff:BasicBuff) : void
      {
         if(!this.stack)
         {
            this.stack = new Vector.<BasicBuff>();
            this.stack.push(this.clone(this.id));
         }
         this.stack.push(buff);
         var additionDetails:String = "";
         switch(this.actionId)
         {
            case ActionIdEnum.ACTION_BOOST_SPELL_BASE_DMG:
            case ActionIdEnum.ACTION_BOOST_SPELL_RANGE:
            case ActionIdEnum.ACTION_BOOST_SPELL_RANGEABLE:
            case ActionIdEnum.ACTION_BOOST_SPELL_DMG:
            case ActionIdEnum.ACTION_BOOST_SPELL_HEAL:
            case ActionIdEnum.ACTION_BOOST_SPELL_AP_COST:
            case ActionIdEnum.ACTION_BOOST_SPELL_CAST_INTVL:
            case ActionIdEnum.ACTION_BOOST_SPELL_CC:
            case ActionIdEnum.ACTION_BOOST_SPELL_CASTOUTLINE:
            case ActionIdEnum.ACTION_BOOST_SPELL_NOLINEOFSIGHT:
            case ActionIdEnum.ACTION_BOOST_SPELL_MAXPERTURN:
            case ActionIdEnum.ACTION_BOOST_SPELL_MAXPERTARGET:
            case ActionIdEnum.ACTION_BOOST_SPELL_CAST_INTVL_SET:
            case ActionIdEnum.ACTION_DEBOOST_SPELL_RANGE:
               additionDetails = additionDetails + ("\rparam2 : " + this.param2 + " à " + (this.param2 + buff.param2));
               additionDetails = additionDetails + ("\rparam3 : " + this.param3 + " à " + (this.param3 + buff.param3));
               this.param1 = buff.param1;
               this.param2 = this.param2 + buff.param2;
               this.param3 = this.param3 + buff.param3;
               break;
            case ActionIdEnum.ACTION_CHARACTER_CHATIMENT:
               additionDetails = additionDetails + ("\rparam1 : " + this.param1 + " à " + (this.param1 + buff.param2));
               this.param1 = this.param1 + buff.param2;
               break;
            case ActionIdEnum.ACTION_FIGHT_SET_STATE:
            case ActionIdEnum.ACTION_FIGHT_UNSET_STATE:
            case ActionIdEnum.ACTION_FIGHT_DISABLE_STATE:
               if(this is StateBuff && buff is StateBuff)
               {
                  additionDetails = additionDetails + ("\rdelta : " + (this as StateBuff).delta + " à " + ((this as StateBuff).delta + (buff as StateBuff).delta));
                  (this as StateBuff).delta = (this as StateBuff).delta + (buff as StateBuff).delta;
                  break;
               }
               break;
            default:
               additionDetails = additionDetails + ("\rparam1 : " + this.param1 + " à " + (this.param1 + buff.param1));
               additionDetails = additionDetails + ("\rparam2 : " + this.param2 + " à " + (this.param2 + buff.param2));
               additionDetails = additionDetails + ("\rparam3 : " + this.param3 + " à " + (this.param3 + buff.param3));
               this.param1 = this.param1 + buff.param1;
               this.param2 = this.param2 + buff.param2;
               this.param3 = this.param3 + buff.param3;
         }
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            _log.debug("[BUFFS DEBUG] Buff " + this.uid + " : ajout du buff " + buff.uid + " " + additionDetails);
         }
         this.refreshDescription();
      }
      
      public function updateParam(value1:int = 0, value2:int = 0, value3:int = 0, buffId:int = -1) : void
      {
         var stackBuff:* = null;
         var p1:int = 0;
         var p2:int = 0;
         var p3:int = 0;
         if(buffId == -1)
         {
            p1 = value1;
            p2 = value2;
            p3 = value3;
         }
         else if(this.stack && this.stack.length < 1)
         {
            for each(stackBuff in this.stack)
            {
               if(stackBuff.id == buffId)
               {
                  switch(stackBuff.actionId)
                  {
                     case ActionIdEnum.ACTION_CHARACTER_CHATIMENT:
                     case ActionIdEnum.ACTION_FIGHT_SET_STATE:
                     case ActionIdEnum.ACTION_FIGHT_UNSET_STATE:
                     case ActionIdEnum.ACTION_FIGHT_DISABLE_STATE:
                        break;
                     default:
                        stackBuff.param1 = value1;
                        stackBuff.param2 = value2;
                        stackBuff.param3 = value3;
                  }
               }
               p1 = p1 + stackBuff.param1;
               p2 = p2 + stackBuff.param2;
               p3 = p3 + stackBuff.param3;
            }
         }
         else
         {
            p1 = value1;
            p2 = value2;
            p3 = value3;
         }
         switch(this.actionId)
         {
            case ActionIdEnum.ACTION_CHARACTER_CHATIMENT:
               this.param1 = p2;
               break;
            case ActionIdEnum.ACTION_FIGHT_SET_STATE:
            case ActionIdEnum.ACTION_FIGHT_UNSET_STATE:
            case ActionIdEnum.ACTION_FIGHT_DISABLE_STATE:
               break;
            default:
               this.param1 = p1;
               this.param2 = p2;
               this.param3 = p3;
         }
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            _log.debug("[BUFFS DEBUG] Buff " + this.id + " rafraichissement des params " + this.param1 + ", " + this.param2 + ", " + this.param3);
         }
         this.refreshDescription();
      }
      
      public function refreshDescription() : void
      {
         this._effect.forceDescriptionRefresh();
      }
      
      public function incrementDuration(delta:int, dispellEffect:Boolean = false) : Boolean
      {
         var oldDuration:int = 0;
         if(GameDebugManager.getInstance().buffsDebugActivated)
         {
            if(dispellEffect)
            {
               _log.debug("[BUFFS DEBUG] Buff " + this.id + " durée modifiée de " + delta + " (desenvoutement de l\'effet)");
            }
         }
         if(!dispellEffect || this.canBeDispell())
         {
            if(this.duration >= 63 || this.duration == -1000)
            {
               return false;
            }
            oldDuration = this.duration;
            if(this.duration + delta > 0)
            {
               this.duration = this.duration + delta;
               this.effect.duration = this.effect.duration + delta;
               if(GameDebugManager.getInstance().buffsDebugActivated)
               {
                  _log.debug("[BUFFS DEBUG] Buff " + this.id + " durée modifiée de " + oldDuration + " à " + this.duration);
               }
               return true;
            }
            if(this.duration > 0)
            {
               this.duration = 0;
               this.effect.duration = 0;
               if(GameDebugManager.getInstance().buffsDebugActivated)
               {
                  _log.debug("[BUFFS DEBUG] Buff " + this.id + " durée modifiée de " + oldDuration + " à " + this.duration);
               }
               return true;
            }
            return false;
         }
         return false;
      }
      
      public function get active() : Boolean
      {
         return this.duration != 0;
      }
      
      public function clone(id:int = 0) : BasicBuff
      {
         var bb:BasicBuff = new BasicBuff();
         bb.id = this.uid;
         bb.uid = this.uid;
         bb.dataUid = this.dataUid;
         bb.actionId = this.actionId;
         bb.targetId = this.targetId;
         bb.castingSpell = this.castingSpell;
         bb.duration = this.duration;
         bb.dispelable = this.dispelable;
         bb.source = this.source;
         bb.aliveSource = this.aliveSource;
         bb.sourceJustReaffected = this.sourceJustReaffected;
         bb.parentBoostUid = this.parentBoostUid;
         bb.initParam(this.param1,this.param2,this.param3);
         return bb;
      }
      
      public function toString() : String
      {
         return "[BasicBuff id=" + this.id + ", uid=" + this.uid + ", targetId=" + this.targetId + ", sourceId=" + this.source + ", duration=" + this.duration + ", stack.length=" + (!!this.stack?this.stack.length:"0") + "]";
      }
   }
}
