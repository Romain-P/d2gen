package com.ankamagames.dofus.datacenter.effects
{
   import com.ankamagames.dofus.datacenter.alignments.AlignmentSide;
   import com.ankamagames.dofus.datacenter.appearance.Title;
   import com.ankamagames.dofus.datacenter.communication.Emoticon;
   import com.ankamagames.dofus.datacenter.documents.Document;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceInteger;
   import com.ankamagames.dofus.datacenter.items.Item;
   import com.ankamagames.dofus.datacenter.items.ItemType;
   import com.ankamagames.dofus.datacenter.jobs.Job;
   import com.ankamagames.dofus.datacenter.monsters.Companion;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.datacenter.monsters.MonsterRace;
   import com.ankamagames.dofus.datacenter.monsters.MonsterSuperRace;
   import com.ankamagames.dofus.datacenter.mounts.MountFamily;
   import com.ankamagames.dofus.datacenter.spells.Spell;
   import com.ankamagames.dofus.datacenter.spells.SpellLevel;
   import com.ankamagames.dofus.datacenter.spells.SpellState;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   import com.ankamagames.dofus.types.enums.LanguageEnum;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import com.ankamagames.jerakine.utils.pattern.PatternDecoder;
   import flash.utils.getQualifiedClassName;
   
   public class EffectInstance implements IDataCenter
   {
      
      private static const UNKNOWN_NAME:String = "???";
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(EffectInstance));
      
      private static const UNDEFINED_CATEGORY:int = -2;
      
      private static const UNDEFINED_SHOW:int = -1;
      
      private static const UNDEFINED_DESCRIPTION:String = "undefined";
       
      
      public var effectUid:uint;
      
      public var effectId:uint;
      
      public var targetId:int;
      
      public var targetMask:String;
      
      public var duration:int;
      
      public var delay:int;
      
      public var random:int;
      
      public var group:int;
      
      public var modificator:int;
      
      public var trigger:Boolean;
      
      public var triggers:String;
      
      public var visibleInTooltip:Boolean = true;
      
      public var visibleInBuffUi:Boolean = true;
      
      public var visibleInFightLog:Boolean = true;
      
      public var zoneSize:Object;
      
      public var zoneShape:uint;
      
      public var zoneMinSize:Object;
      
      public var zoneEfficiencyPercent:Object;
      
      public var zoneMaxEfficiency:Object;
      
      public var zoneStopAtTarget:Object;
      
      public var effectElement:int;
      
      public var spellId:int;
      
      private var _effectData:Effect;
      
      private var _durationStringValue:int;
      
      private var _delayStringValue:int;
      
      private var _durationString:String;
      
      private var _order:int = 0;
      
      private var _bonusType:int = -2;
      
      private var _oppositeId:int = -1;
      
      private var _category:int = -2;
      
      private var _description:String = "undefined";
      
      private var _theoricDescription:String = "undefined";
      
      private var _descriptionForTooltip:String = "undefined";
      
      private var _theoricDescriptionForTooltip:String = "undefined";
      
      private var _showSet:int = -1;
      
      private var _rawZone:String;
      
      private var _theoricShortDescriptionForTooltip:String = "undefined";
      
      public function EffectInstance()
      {
         super();
      }
      
      public function set rawZone(data:String) : void
      {
         this._rawZone = data;
         this.parseZone();
      }
      
      public function get rawZone() : String
      {
         return this._rawZone;
      }
      
      public function get durationString() : String
      {
         if(!this._durationString || this._durationStringValue != this.duration || this._delayStringValue != this.delay)
         {
            this._durationStringValue = this.duration;
            this._delayStringValue = this.delay;
            this._durationString = this.getTurnCountStr(false);
         }
         return this._durationString;
      }
      
      public function get category() : int
      {
         if(this._category == UNDEFINED_CATEGORY)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            this._category = !!this._effectData?int(this._effectData.category):-1;
         }
         return this._category;
      }
      
      public function get order() : int
      {
         if(this._order == 0)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            this._order = !!this._effectData?int(this._effectData.effectPriority):0;
         }
         return this._order;
      }
      
      public function get bonusType() : int
      {
         if(this._bonusType == -2)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            this._bonusType = !!this._effectData?int(this._effectData.bonusType):-2;
         }
         return this._bonusType;
      }
      
      public function get oppositeId() : int
      {
         if(this._oppositeId == -1)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            this._oppositeId = !!this._effectData?int(this._effectData.oppositeId):-1;
         }
         return this._oppositeId;
      }
      
      public function get showInSet() : int
      {
         if(this._showSet == UNDEFINED_SHOW)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            this._showSet = !!this._effectData?!!this._effectData.showInSet?1:0:0;
         }
         return this._showSet;
      }
      
      public function get parameter0() : Object
      {
         return null;
      }
      
      public function get parameter1() : Object
      {
         return null;
      }
      
      public function get parameter2() : Object
      {
         return null;
      }
      
      public function get parameter3() : Object
      {
         return null;
      }
      
      public function get parameter4() : Object
      {
         return null;
      }
      
      public function get description() : String
      {
         if(this._description == UNDEFINED_DESCRIPTION)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            if(!this._effectData)
            {
               this._description = null;
               return null;
            }
            this._description = this.prepareDescription(this._effectData.description,this.effectId);
         }
         return this._description;
      }
      
      public function get theoreticalDescription() : String
      {
         var sSourceDesc:* = null;
         if(this._theoricDescription == UNDEFINED_DESCRIPTION)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            if(!this._effectData)
            {
               this._theoricDescription = null;
               return null;
            }
            if(this._effectData.theoreticalPattern == 0)
            {
               this._theoricDescription = null;
               return null;
            }
            if(this._effectData.theoreticalPattern == 1)
            {
               sSourceDesc = this._effectData.description;
            }
            else
            {
               sSourceDesc = this._effectData.theoreticalDescription;
            }
            this._theoricDescription = this.prepareDescription(sSourceDesc,this.effectId);
         }
         return this._theoricDescription;
      }
      
      public function get descriptionForTooltip() : String
      {
         if(this._descriptionForTooltip == UNDEFINED_DESCRIPTION)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            if(!this._effectData)
            {
               this._descriptionForTooltip = null;
               return null;
            }
            this._descriptionForTooltip = this.prepareDescription(this._effectData.description,this.effectId,true);
         }
         return this._descriptionForTooltip;
      }
      
      public function get theoreticalDescriptionForTooltip() : String
      {
         var sSourceDesc:* = null;
         if(this._theoricDescriptionForTooltip == UNDEFINED_DESCRIPTION)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            if(!this._effectData)
            {
               this._theoricDescriptionForTooltip = null;
               return null;
            }
            if(this._effectData.theoreticalPattern == 0)
            {
               this._theoricDescriptionForTooltip = null;
               return null;
            }
            if(this._effectData.theoreticalPattern == 1)
            {
               sSourceDesc = this._effectData.description;
            }
            else
            {
               sSourceDesc = this._effectData.theoreticalDescription;
            }
            this._theoricDescriptionForTooltip = this.prepareDescription(sSourceDesc,this.effectId,true);
         }
         return this._theoricDescriptionForTooltip;
      }
      
      public function get theoreticalShortDescriptionForTooltip() : String
      {
         var sSourceDesc:* = null;
         if(this._theoricShortDescriptionForTooltip == UNDEFINED_DESCRIPTION)
         {
            if(!this._effectData)
            {
               this._effectData = Effect.getEffectById(this.effectId);
            }
            if(!this._effectData)
            {
               this._theoricShortDescriptionForTooltip = null;
               return null;
            }
            if(this._effectData.theoreticalPattern == 0)
            {
               this._theoricShortDescriptionForTooltip = null;
               return null;
            }
            if(this._effectData.theoreticalPattern == 1)
            {
               sSourceDesc = this._effectData.description;
            }
            else
            {
               sSourceDesc = this._effectData.theoreticalDescription;
            }
            this._theoricShortDescriptionForTooltip = this.prepareDescription(sSourceDesc,this.effectId,true,true);
         }
         return this._theoricShortDescriptionForTooltip;
      }
      
      public function clone() : EffectInstance
      {
         var o:EffectInstance = new EffectInstance();
         o.zoneShape = this.zoneShape;
         o.zoneSize = this.zoneSize;
         o.zoneMinSize = this.zoneMinSize;
         o.zoneEfficiencyPercent = this.zoneEfficiencyPercent;
         o.zoneMaxEfficiency = this.zoneMaxEfficiency;
         o.effectUid = this.effectUid;
         o.effectId = this.effectId;
         o.duration = this.duration;
         o.random = this.random;
         o.group = this.group;
         o.targetId = this.targetId;
         o.targetMask = this.targetMask;
         o.delay = this.delay;
         o.triggers = this.triggers;
         o.visibleInTooltip = this.visibleInTooltip;
         o.visibleInBuffUi = this.visibleInBuffUi;
         o.visibleInFightLog = this.visibleInFightLog;
         return o;
      }
      
      public function add(effect:*) : EffectInstance
      {
         return new EffectInstance();
      }
      
      public function setParameter(paramIndex:uint, value:*) : void
      {
      }
      
      public function forceDescriptionRefresh() : void
      {
         this._description = UNDEFINED_DESCRIPTION;
         this._theoricDescription = UNDEFINED_DESCRIPTION;
      }
      
      private function getTurnCountStr(bShowLast:Boolean) : String
      {
         var sTmp:String = new String();
         if(this.delay > 0)
         {
            return PatternDecoder.combine(I18n.getUiText("ui.common.delayTurn",[this.delay]),"n",this.delay <= 1);
         }
         var d:int = this.duration;
         if(isNaN(d))
         {
            return "";
         }
         if(d > -1)
         {
            if(d > 1)
            {
               return PatternDecoder.combine(I18n.getUiText("ui.common.turn",[d]),"n",false);
            }
            if(d == 0)
            {
               return "";
            }
            if(bShowLast)
            {
               return I18n.getUiText("ui.common.lastTurn");
            }
            return PatternDecoder.combine(I18n.getUiText("ui.common.turn",[d]),"n",true);
         }
         return I18n.getUiText("ui.common.infinit");
      }
      
      private function getEmoticonName(id:int) : String
      {
         var o:Emoticon = Emoticon.getEmoticonById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getItemTypeName(id:int) : String
      {
         var o:ItemType = ItemType.getItemTypeById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getMonsterName(id:int) : String
      {
         var o:Monster = Monster.getMonsterById(id);
         return !!o?o.name:I18n.getUiText("ui.effect.unknownMonster");
      }
      
      private function getCompanionName(id:int) : String
      {
         var o:Companion = Companion.getCompanionById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getMonsterGrade(pId:int, pGrade:int) : String
      {
         var m:Monster = Monster.getMonsterById(pId);
         return !!m?m.getMonsterGrade(pGrade).level.toString():UNKNOWN_NAME;
      }
      
      private function getSpellName(id:int) : String
      {
         var o:Spell = Spell.getSpellById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getSpellLevelName(id:int) : String
      {
         var o:SpellLevel = SpellLevel.getLevelById(id);
         var name:String = !!o?this.getSpellName(o.spellId):UNKNOWN_NAME;
         return !!o?this.getSpellName(o.spellId):UNKNOWN_NAME;
      }
      
      private function getJobName(id:int) : String
      {
         var o:Job = Job.getJobById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getDocumentTitle(id:int) : String
      {
         var o:Document = Document.getDocumentById(id);
         return !!o?o.title:UNKNOWN_NAME;
      }
      
      private function getAlignmentSideName(id:int) : String
      {
         var o:AlignmentSide = AlignmentSide.getAlignmentSideById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getItemName(id:int) : String
      {
         var o:Item = Item.getItemById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getMonsterSuperRaceName(id:int) : String
      {
         var o:MonsterSuperRace = MonsterSuperRace.getMonsterSuperRaceById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getMonsterRaceName(id:int) : String
      {
         var o:MonsterRace = MonsterRace.getMonsterRaceById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getTitleName(id:int) : String
      {
         var o:Title = Title.getTitleById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function getMountFamilyName(id:int) : String
      {
         var o:MountFamily = MountFamily.getMountFamilyById(id);
         return !!o?o.name:UNKNOWN_NAME;
      }
      
      private function parseZone() : void
      {
         var params:* = null;
         var hasMinSize:Boolean = false;
         if(this.rawZone && this.rawZone.length)
         {
            this.zoneShape = this.rawZone.charCodeAt(0);
            params = this.rawZone.substr(1).split(",");
            switch(this.zoneShape)
            {
               case SpellShapeEnum.l:
                  this.zoneMinSize = parseInt(params[0]);
                  this.zoneSize = parseInt(params[1]);
                  if(params.length > 2)
                  {
                     this.zoneEfficiencyPercent = parseInt(params[2]);
                     this.zoneMaxEfficiency = parseInt(params[3]);
                  }
                  if(params.length == 5)
                  {
                     this.zoneStopAtTarget = parseInt(params[4]);
                  }
                  return;
               default:
                  hasMinSize = this.zoneShape == SpellShapeEnum.C || this.zoneShape == SpellShapeEnum.X || this.zoneShape == SpellShapeEnum.Q || this.zoneShape == SpellShapeEnum.plus || this.zoneShape == SpellShapeEnum.sharp;
                  switch(params.length)
                  {
                     case 1:
                        this.zoneSize = parseInt(params[0]);
                        break;
                     case 2:
                        this.zoneSize = parseInt(params[0]);
                        if(hasMinSize)
                        {
                           this.zoneMinSize = parseInt(params[1]);
                           break;
                        }
                        this.zoneEfficiencyPercent = parseInt(params[1]);
                        break;
                     case 3:
                        this.zoneSize = parseInt(params[0]);
                        if(hasMinSize)
                        {
                           this.zoneMinSize = parseInt(params[1]);
                           this.zoneEfficiencyPercent = parseInt(params[2]);
                           break;
                        }
                        this.zoneEfficiencyPercent = parseInt(params[1]);
                        this.zoneMaxEfficiency = parseInt(params[2]);
                        break;
                     case 4:
                        this.zoneSize = parseInt(params[0]);
                        this.zoneMinSize = parseInt(params[1]);
                        this.zoneEfficiencyPercent = parseInt(params[2]);
                        this.zoneMaxEfficiency = parseInt(params[3]);
                  }
            }
         }
         else
         {
            _log.error("Zone incorrect (" + this.rawZone + ")");
         }
      }
      
      private function prepareDescription(desc:String, effectId:uint, forTooltip:Boolean = false, short:Boolean = false) : String
      {
         var aTmp:* = null;
         var spellState:* = null;
         var nYear:* = null;
         var nMonth:* = null;
         var nDay:* = null;
         var nHours:* = null;
         var nMinutes:* = null;
         var lang:* = null;
         var firstValue:int = 0;
         var lastValue:int = 0;
         if(desc == null)
         {
            return "";
         }
         var sEffect:String = "";
         var hasAddedSpanTag:Boolean = false;
         var spellModif:Boolean = false;
         if(desc.indexOf("#") != -1)
         {
            aTmp = [this.parameter0,this.parameter1,this.parameter2,this.parameter3,this.parameter4];
            if(this.parameter0 > 0 && this.parameter1 > 0 && this.bonusType == -1)
            {
               aTmp = [this.parameter1,this.parameter0,this.parameter2,this.parameter3,this.parameter4];
            }
            loop0:
            switch(effectId)
            {
               case ActionIdEnum.ACTION_CHARACTER_REMOVE_ALL_SPELL_EFFECTS:
                  aTmp[1] = this.getSpellName(aTmp[2]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_LEARN_EMOTICON:
                  aTmp[2] = this.getEmoticonName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_BOOST_WEAPON_DAMAGE_PERCENT:
               case ActionIdEnum.ACTION_ITEM_GIFT_CONTENT:
               case ActionIdEnum.ACTION_WRAPPER_OBJECT_CATEGORY:
                  aTmp[0] = this.getItemTypeName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_TRANSFORM:
               case ActionIdEnum.ACTION_SUMMON_CREATURE:
               case ActionIdEnum.ACTION_SUMMON_STATIC_CREATURE:
               case ActionIdEnum.ACTION_KILL_AND_SUMMON_CREATURE:
               case ActionIdEnum.ACTION_KILL_AND_SUMMON_SLAVE:
               case ActionIdEnum.ACTION_LADDER_ID:
               case ActionIdEnum.ACTION_SUMMON_BOMB:
               case ActionIdEnum.ACTION_SUMMON_SLAVE:
                  aTmp[0] = this.getMonsterName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_REFLECTOR_UNBOOSTED:
                  if(!aTmp[0] && !aTmp[1] && aTmp[2])
                  {
                     aTmp[0] = aTmp[2];
                     break;
                  }
                  break;
               case ActionIdEnum.ACTION_ITEM_CHANGE_DURABILITY:
                  if(aTmp[2] && aTmp[1] == null)
                  {
                     aTmp[1] = 0;
                  }
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
               case ActionIdEnum.ACTION_BOOST_SPELL_BASE_DMG:
               case ActionIdEnum.ACTION_DEBOOST_SPELL_RANGE:
               case ActionIdEnum.ACTION_CASTER_EXECUTE_SPELL:
                  aTmp[0] = this.getSpellName(aTmp[0]);
                  spellModif = true;
                  break;
               case ActionIdEnum.ACTION_CAST_SPELL_AT_FIGHT_START:
                  aTmp[0] = "{spellNoLvl," + aTmp[0] + "," + aTmp[1] + "}";
                  break;
               case ActionIdEnum.ACTION_CHARACTER_LEARN_SPELL:
                  if(aTmp[2] == null)
                  {
                     aTmp[2] = aTmp[0];
                  }
                  aTmp[2] = this.getSpellLevelName(aTmp[2]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_GAIN_JOB_XP:
               case ActionIdEnum.ACTION_CHARACTER_GAIN_JOB_LEVEL:
                  aTmp[0] = aTmp[2];
                  aTmp[1] = this.getJobName(aTmp[1]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_UNBOOST_SPELL:
               case ActionIdEnum.ACTION_CHARACTER_UNLEARN_GUILDSPELL:
                  aTmp[2] = this.getSpellName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_READ_BOOK:
                  aTmp[2] = this.getDocumentTitle(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_SUMMON_MONSTER:
                  aTmp[2] = this.getMonsterName(aTmp[1]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_SUMMON_MONSTER_GROUP:
               case ActionIdEnum.ACTION_CHARACTER_SUMMON_MONSTER_GROUP_DYNAMIC:
                  aTmp[1] = this.getMonsterGrade(aTmp[2],aTmp[0]);
                  aTmp[2] = this.getMonsterName(aTmp[2]);
                  break;
               case ActionIdEnum.ACTION_FAKE_ALIGNMENT:
               case ActionIdEnum.ACTION_SHOW_ALIGNMENT:
                  aTmp[2] = this.getAlignmentSideName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_CHARACTER_JOB_REFERENCEMENT:
                  aTmp[0] = this.getJobName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_LADDER_SUPERRACE:
                  aTmp[0] = this.getMonsterSuperRaceName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_LADDER_RACE:
                  aTmp[0] = this.getMonsterRaceName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_GAIN_TITLE:
                  aTmp[2] = this.getTitleName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_TARGET_CASTS_SPELL:
               case ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM:
               case ActionIdEnum.ACTION_TARGET_EXECUTE_SPELL_ON_SOURCE:
               case ActionIdEnum.ACTION_SOURCE_EXECUTE_SPELL_ON_TARGET:
               case ActionIdEnum.ACTION_SOURCE_EXECUTE_SPELL_ON_SOURCE:
               case ActionIdEnum.ACTION_CHARACTER_ADD_SPELL_COOLDOWN:
               case ActionIdEnum.ACTION_CHARACTER_REMOVE_SPELL_COOLDOWN:
               case ActionIdEnum.ACTION_CHARACTER_IMMUNITY_AGAINST_SPELL:
               case ActionIdEnum.ACTION_CHARACTER_SET_SPELL_COOLDOWN:
               case ActionIdEnum.ACTION_TARGET_CAST_SPELL_ON_TARGETED_CELL:
               case ActionIdEnum.ACTION_CHARACTER_PLAY_SPELL_ANIMATION:
                  aTmp[0] = this.getSpellName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_ITEM_CHANGE_PETS_LIFE:
               case ActionIdEnum.ACTION_SHOW_GRADE:
               case ActionIdEnum.ACTION_SHOW_LEVEL:
               case ActionIdEnum.ACTION_ITEM_LOOT_COUNT:
                  aTmp[2] = aTmp[0];
                  break;
               case ActionIdEnum.ACTION_ITEM_PETS_SHAPE:
                  if(aTmp[1] > 6)
                  {
                     aTmp[0] = I18n.getUiText("ui.petWeight.fat",[aTmp[1]]);
                     break;
                  }
                  if(aTmp[2] > 6)
                  {
                     aTmp[0] = I18n.getUiText("ui.petWeight.lean",[aTmp[2]]);
                     break;
                  }
                  if(this is EffectInstanceInteger && aTmp[0] > 6)
                  {
                     aTmp[0] = I18n.getUiText("ui.petWeight.lean",[aTmp[0]]);
                     break;
                  }
                  aTmp[0] = I18n.getUiText("ui.petWeight.nominal");
                  break;
               case ActionIdEnum.ACTION_ITEM_PETS_EAT:
                  if(aTmp[0])
                  {
                     aTmp[0] = this.getItemName(aTmp[0]);
                     break;
                  }
                  aTmp[0] = I18n.getUiText("ui.common.none");
                  break;
               case ActionIdEnum.ACTION_ITEM_DUNGEON_KEY_DATE:
               case ActionIdEnum.ACTION_ITEM_SKIN_ITEM:
               case ActionIdEnum.ACTION_WRAPPER_OBJECT_GID:
               case ActionIdEnum.ACTION_MOUNT_HARNESS_GID:
                  aTmp[0] = this.getItemName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_MOUNT_ADD_CAPACITY:
                  aTmp[0] = this.getMountFamilyName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_FIGHT_CHALLENGE_AGAINST_MONSTER:
                  aTmp[1] = this.getMonsterName(aTmp[1]);
                  break;
               case ActionIdEnum.ACTION_PET_SET_POWER_BOOST:
               case ActionIdEnum.ACTION_PET_POWER_BOOST:
                  aTmp[2] = this.getItemName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_FIGHT_SET_STATE:
               case ActionIdEnum.ACTION_FIGHT_UNSET_STATE:
               case ActionIdEnum.ACTION_FIGHT_DISABLE_STATE:
                  spellState = aTmp[2] != null?SpellState.getSpellStateById(aTmp[2]):SpellState.getSpellStateById(aTmp[0]);
                  if(spellState)
                  {
                     if(spellState.isSilent)
                     {
                        return "";
                     }
                     aTmp[2] = spellState.name;
                     break;
                  }
                  aTmp[2] = UNKNOWN_NAME;
                  break;
               case ActionIdEnum.ACTION_NAME_MAGE:
               case ActionIdEnum.ACTION_NAME_OWNER:
               case ActionIdEnum.ACTION_NAME_CRAFTER:
               case ActionIdEnum.ACTION_MOUNT_DESCRIPTION_OWNER:
                  aTmp[3] = "{player," + aTmp[3] + "}";
                  break;
               case ActionIdEnum.ACTION_CHARACTER_COMPANION:
                  aTmp[0] = this.getCompanionName(aTmp[0]);
                  break;
               case ActionIdEnum.ACTION_EVOLVING_EXPERIENCE_POINTS:
                  if(!aTmp[2])
                  {
                     aTmp[2] = 0;
                  }
                  if(!aTmp[1])
                  {
                     aTmp[1] = 0;
                  }
                  if(aTmp[1] == 0)
                  {
                     aTmp[2] = I18n.getUiText("ui.common.maximum");
                     break;
                  }
                  aTmp[2] = I18n.getUiText("ui.tooltip.monsterXpAlone",[aTmp[2] + " / " + aTmp[1]]);
                  break;
               case ActionIdEnum.ACTION_EVOLVING_LEVEL:
                  aTmp[0] = this.getItemTypeName(aTmp[0]);
                  aTmp[2] = aTmp[2] - 1;
                  break;
               case ActionIdEnum.ACTION_ITEM_GIVEN_EXPERIENCE_AS_SUPERFOOD:
                  aTmp[2] = aTmp[0];
                  break;
               case ActionIdEnum.ACTION_ITEM_CHANGE_DURATION:
               case ActionIdEnum.ACTION_PETS_LAST_MEAL:
               case ActionIdEnum.ACTION_LINKED_UNTIL_DATE:
                  if(aTmp[0] == undefined && aTmp[1] == undefined && aTmp[2] > 0)
                  {
                     aTmp[0] = aTmp[2];
                     break;
                  }
                  if(aTmp[0] == null && aTmp[1] == null && aTmp[2] == null)
                  {
                     break;
                  }
                  aTmp[2] = aTmp[2] == undefined?0:aTmp[2];
                  nYear = aTmp[0];
                  nMonth = aTmp[1].substr(0,2);
                  nDay = aTmp[1].substr(2,2);
                  nHours = aTmp[2].substr(0,2);
                  nMinutes = aTmp[2].substr(2,2);
                  lang = XmlConfig.getInstance().getEntry("config.lang.current");
                  switch(lang)
                  {
                     case LanguageEnum.LANG_FR:
                        aTmp[0] = nDay + "/" + nMonth + "/" + nYear + " " + nHours + ":" + nMinutes;
                        break loop0;
                     case LanguageEnum.LANG_EN:
                        aTmp[0] = nMonth + "/" + nDay + "/" + nYear + " " + nHours + ":" + nMinutes;
                        break loop0;
                     default:
                        aTmp[0] = nMonth + "/" + nDay + "/" + nYear + " " + nHours + ":" + nMinutes;
                        break loop0;
                  }
            }
            if(forTooltip && aTmp)
            {
               if(spellModif && aTmp[2] != null)
               {
                  hasAddedSpanTag = true;
                  aTmp[2] = aTmp[2] + "</span>";
               }
               else if(aTmp[1] != null)
               {
                  hasAddedSpanTag = true;
                  aTmp[1] = aTmp[1] + "</span>";
               }
               else if(aTmp[0] != null)
               {
                  hasAddedSpanTag = true;
                  aTmp[0] = aTmp[0] + "</span>";
               }
            }
            sEffect = PatternDecoder.getDescription(desc,aTmp);
            if(sEffect == null || sEffect == "")
            {
               return "";
            }
         }
         else
         {
            if(short)
            {
               return "";
            }
            sEffect = desc;
         }
         if(forTooltip)
         {
            if(hasAddedSpanTag && sEffect.indexOf("</span>") != -1)
            {
               if(short)
               {
                  firstValue = desc.indexOf("#");
                  lastValue = desc.lastIndexOf("#");
                  if(firstValue != lastValue && firstValue >= 0 && lastValue >= 0)
                  {
                     sEffect = sEffect.substring(0,sEffect.indexOf("</span>"));
                  }
               }
               else if(spellModif)
               {
                  sEffect = sEffect.replace(aTmp[2],"<span class=\'#valueCssClass\'>" + aTmp[2] + "</span>");
               }
               else
               {
                  sEffect = "<span class=\'#valueCssClass\'>" + sEffect;
               }
            }
            if(hasAddedSpanTag && sEffect.indexOf("%") != -1)
            {
               sEffect = sEffect.replace("%","<span class=\'#valueCssClass\'>%</span>");
            }
         }
         if(this.modificator != 0)
         {
            sEffect = sEffect + (" " + I18n.getUiText("ui.effect.boosted.spell.complement",[this.modificator],"%"));
         }
         if(this.random > 0)
         {
            if(this.group > 0)
            {
               sEffect = sEffect + (" (" + I18n.getUiText("ui.common.random") + ")");
            }
            else
            {
               sEffect = sEffect + (" " + I18n.getUiText("ui.effect.randomProbability",[this.random],"%"));
            }
         }
         return sEffect;
      }
   }
}
