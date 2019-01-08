package com.ankamagames.dofus.logic.game.fight.frames
{
   import com.ankamagames.atouin.Atouin;
   import com.ankamagames.atouin.enums.PlacementStrataEnums;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.atouin.managers.InteractiveCellManager;
   import com.ankamagames.atouin.managers.MapDisplayManager;
   import com.ankamagames.atouin.managers.SelectionManager;
   import com.ankamagames.atouin.messages.CellOutMessage;
   import com.ankamagames.atouin.messages.CellOverMessage;
   import com.ankamagames.atouin.messages.MapLoadedMessage;
   import com.ankamagames.atouin.messages.MapsLoadingCompleteMessage;
   import com.ankamagames.atouin.renderers.ZoneDARenderer;
   import com.ankamagames.atouin.types.Selection;
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.berilia.enums.StrataEnum;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.berilia.managers.SecureCenter;
   import com.ankamagames.berilia.managers.TooltipManager;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.berilia.types.LocationEnum;
   import com.ankamagames.berilia.types.event.UiUnloadEvent;
   import com.ankamagames.berilia.types.tooltip.TooltipPlacer;
   import com.ankamagames.berilia.types.tooltip.event.TooltipEvent;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.datacenter.monsters.Companion;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.datacenter.npcs.TaxCollectorFirstname;
   import com.ankamagames.dofus.datacenter.npcs.TaxCollectorName;
   import com.ankamagames.dofus.datacenter.spells.Spell;
   import com.ankamagames.dofus.datacenter.spells.SpellLevel;
   import com.ankamagames.dofus.datacenter.world.SubArea;
   import com.ankamagames.dofus.internalDatacenter.fight.ChallengeWrapper;
   import com.ankamagames.dofus.internalDatacenter.fight.FightResultEntryWrapper;
   import com.ankamagames.dofus.internalDatacenter.items.ItemWrapper;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.internalDatacenter.world.WorldPointWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.kernel.sound.SoundManager;
   import com.ankamagames.dofus.kernel.sound.enum.UISoundEnum;
   import com.ankamagames.dofus.logic.common.managers.HyperlinkShowCellManager;
   import com.ankamagames.dofus.logic.common.managers.PlayerManager;
   import com.ankamagames.dofus.logic.game.common.frames.PartyManagementFrame;
   import com.ankamagames.dofus.logic.game.common.frames.PointCellFrame;
   import com.ankamagames.dofus.logic.game.common.frames.QuestFrame;
   import com.ankamagames.dofus.logic.game.common.frames.SpellInventoryManagementFrame;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.logic.game.common.managers.SpeakingItemManager;
   import com.ankamagames.dofus.logic.game.common.managers.SubhintManager;
   import com.ankamagames.dofus.logic.game.common.messages.FightEndingMessage;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.dofus.logic.game.fight.actions.ChallengeTargetsListRequestAction;
   import com.ankamagames.dofus.logic.game.fight.actions.ShowTacticModeAction;
   import com.ankamagames.dofus.logic.game.fight.actions.TimelineEntityOutAction;
   import com.ankamagames.dofus.logic.game.fight.actions.TimelineEntityOverAction;
   import com.ankamagames.dofus.logic.game.fight.actions.TogglePointCellAction;
   import com.ankamagames.dofus.logic.game.fight.fightEvents.FightEventsHelper;
   import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
   import com.ankamagames.dofus.logic.game.fight.managers.CurrentPlayedFighterManager;
   import com.ankamagames.dofus.logic.game.fight.managers.LinkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.managers.MarkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellDamagesManager;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
   import com.ankamagames.dofus.logic.game.fight.managers.TacticModeManager;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   import com.ankamagames.dofus.logic.game.fight.miscs.DamageUtil;
   import com.ankamagames.dofus.logic.game.fight.miscs.FightReachableCellsMaker;
   import com.ankamagames.dofus.logic.game.fight.miscs.PushUtil;
   import com.ankamagames.dofus.logic.game.fight.types.BasicBuff;
   import com.ankamagames.dofus.logic.game.fight.types.CastingSpell;
   import com.ankamagames.dofus.logic.game.fight.types.EffectDamage;
   import com.ankamagames.dofus.logic.game.fight.types.FightEventEnum;
   import com.ankamagames.dofus.logic.game.fight.types.InterceptedDamage;
   import com.ankamagames.dofus.logic.game.fight.types.MarkInstance;
   import com.ankamagames.dofus.logic.game.fight.types.PushedEntity;
   import com.ankamagames.dofus.logic.game.fight.types.SpellCastInFightManager;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamage;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageInfo;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageList;
   import com.ankamagames.dofus.logic.game.fight.types.SplashDamage;
   import com.ankamagames.dofus.logic.game.fight.types.StatBuff;
   import com.ankamagames.dofus.logic.game.fight.types.TriggeredSpell;
   import com.ankamagames.dofus.logic.game.roleplay.frames.EntitiesTooltipsFrame;
   import com.ankamagames.dofus.logic.game.roleplay.managers.MountAutoTripManager;
   import com.ankamagames.dofus.misc.lists.FightHookList;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.misc.lists.TriggerHookList;
   import com.ankamagames.dofus.network.enums.FightOutcomeEnum;
   import com.ankamagames.dofus.network.enums.GameActionFightInvisibilityStateEnum;
   import com.ankamagames.dofus.network.enums.GameActionMarkTypeEnum;
   import com.ankamagames.dofus.network.enums.MapObstacleStateEnum;
   import com.ankamagames.dofus.network.enums.TeamEnum;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightCarryCharacterMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightNoSpellCastMessage;
   import com.ankamagames.dofus.network.messages.game.context.GameContextDestroyMessage;
   import com.ankamagames.dofus.network.messages.game.context.GameContextReadyMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightEndMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightJoinMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightLeaveMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightResumeMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightResumeWithSlavesMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightSpectateMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightSpectatorJoinMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightStartMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightStartingMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightUpdateTeamMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.arena.ArenaFighterLeaveMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeInfoMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeResultMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeTargetUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeTargetsListMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeTargetsListRequestMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.CurrentMapInstanceMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.CurrentMapMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.MapObstacleUpdateMessage;
   import com.ankamagames.dofus.network.types.game.action.fight.FightDispellableEffectExtendedInformations;
   import com.ankamagames.dofus.network.types.game.actions.fight.GameActionMark;
   import com.ankamagames.dofus.network.types.game.actions.fight.GameActionMarkedCell;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultFighterListEntry;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultListEntry;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultPlayerListEntry;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultTaxCollectorListEntry;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCharacterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightEntityInformation;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterNamedInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMutantInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightResumeSlaveInfo;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightTaxCollectorInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.party.NamedPartyTeam;
   import com.ankamagames.dofus.network.types.game.context.roleplay.party.NamedPartyTeamWithOutcome;
   import com.ankamagames.dofus.network.types.game.idol.Idol;
   import com.ankamagames.dofus.network.types.game.interactive.MapObstacle;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.dofus.types.entities.Glyph;
   import com.ankamagames.dofus.types.sequences.AddGlyphGfxStep;
   import com.ankamagames.dofus.uiApi.PlayedCharacterApi;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.jerakine.entities.interfaces.IDisplayable;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.entities.interfaces.IInteractive;
   import com.ankamagames.jerakine.entities.messages.EntityMouseOutMessage;
   import com.ankamagames.jerakine.entities.messages.EntityMouseOverMessage;
   import com.ankamagames.jerakine.interfaces.IRectangle;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.managers.OptionManager;
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.sequencer.SerialSequencer;
   import com.ankamagames.jerakine.types.Color;
   import com.ankamagames.jerakine.types.enums.Priority;
   import com.ankamagames.jerakine.types.events.PropertyChangeEvent;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.types.zones.Custom;
   import com.ankamagames.jerakine.types.zones.IZone;
   import com.ankamagames.jerakine.utils.display.Rectangle2;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import com.ankamagames.jerakine.utils.memory.WeakReference;
   import com.hurlant.util.Hex;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class FightContextFrame implements Frame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(FightContextFrame));
      
      public static var preFightIsActive:Boolean = true;
      
      public static var fighterEntityTooltipId:Number;
      
      public static var currentCell:int = -1;
       
      
      private const TYPE_LOG_FIGHT:uint = 30000.0;
      
      private const INVISIBLE_POSITION_SELECTION:String = "invisible_position";
      
      protected const REACHABLE_CELL_COLOR:int = 26112;
      
      protected const UNREACHABLE_CELL_COLOR:int = 6684672;
      
      private var _entitiesFrame:FightEntitiesFrame;
      
      private var _preparationFrame:FightPreparationFrame;
      
      private var _battleFrame:FightBattleFrame;
      
      private var _overEffectOk:GlowFilter;
      
      private var _overEffectKo:GlowFilter;
      
      private var _linkedEffect:ColorMatrixFilter;
      
      private var _linkedMainEffect:ColorMatrixFilter;
      
      private var _lastEffectEntity:WeakReference;
      
      private var _reachableRangeSelection:Selection;
      
      private var _unreachableRangeSelection:Selection;
      
      private var _timerFighterInfo:Timer;
      
      private var _timerMovementRange:Timer;
      
      private var _currentFighterInfo:GameFightFighterInformations;
      
      private var _currentMapRenderId:int = -1;
      
      private var _timelineOverEntity:Boolean;
      
      private var _timelineOverEntityId:Number;
      
      private var _showPermanentTooltips:Boolean;
      
      private var _hiddenEntites:Array;
      
      public var _challengesList:Array;
      
      private var _fightType:uint;
      
      private var _fightAttackerId:Number;
      
      private var _spellTargetsTooltips:Dictionary;
      
      private var _tooltipLastUpdate:Dictionary;
      
      private var _namedPartyTeams:Vector.<NamedPartyTeam>;
      
      private var _fightersPositionsHistory:Dictionary;
      
      private var _fightersRoundStartPosition:Dictionary;
      
      private var _fightIdols:Vector.<Idol>;
      
      private var _mustShowTreasureHuntMask:Boolean = false;
      
      private var _roleplayGridDisplayed:Boolean;
      
      public var isFightLeader:Boolean;
      
      public var onlyTheOtherTeamCanPlace:Boolean = false;
      
      public function FightContextFrame()
      {
         this._hiddenEntites = [];
         this._spellTargetsTooltips = new Dictionary();
         this._tooltipLastUpdate = new Dictionary();
         this._fightersPositionsHistory = new Dictionary();
         this._fightersRoundStartPosition = new Dictionary();
         super();
      }
      
      public function get priority() : int
      {
         return Priority.NORMAL;
      }
      
      public function get entitiesFrame() : FightEntitiesFrame
      {
         return this._entitiesFrame;
      }
      
      public function get battleFrame() : FightBattleFrame
      {
         return this._battleFrame;
      }
      
      public function get preparationFrame() : FightPreparationFrame
      {
         return this._preparationFrame;
      }
      
      public function get challengesList() : Array
      {
         return this._challengesList;
      }
      
      public function get fightType() : uint
      {
         return this._fightType;
      }
      
      public function set fightType(t:uint) : void
      {
         this._fightType = t;
         var partyFrame:PartyManagementFrame = Kernel.getWorker().getFrame(PartyManagementFrame) as PartyManagementFrame;
         partyFrame.lastFightType = t;
      }
      
      public function get timelineOverEntity() : Boolean
      {
         return this._timelineOverEntity;
      }
      
      public function get timelineOverEntityId() : Number
      {
         return this._timelineOverEntityId;
      }
      
      public function get showPermanentTooltips() : Boolean
      {
         return this._showPermanentTooltips;
      }
      
      public function get hiddenEntites() : Array
      {
         return this._hiddenEntites;
      }
      
      public function get fightersPositionsHistory() : Dictionary
      {
         return this._fightersPositionsHistory;
      }
      
      public function pushed() : Boolean
      {
         if(!Kernel.beingInReconection)
         {
            this._roleplayGridDisplayed = Atouin.getInstance().options.alwaysShowGrid;
            Atouin.getInstance().displayGrid(Berilia.getInstance().getUi("banner").uiClass.tacticModeActivated && OptionManager.getOptionManager("dofus")["useNewTacticalMode"]?false:true,true);
         }
         currentCell = -1;
         this._overEffectOk = new GlowFilter(16777215,1,4,4,3,1);
         this._overEffectKo = new GlowFilter(14090240,1,4,4,3,1);
         var matrix:Array = new Array();
         matrix = matrix.concat([0.5,0,0,0,100]);
         matrix = matrix.concat([0,0.5,0,0,100]);
         matrix = matrix.concat([0,0,0.5,0,100]);
         matrix = matrix.concat([0,0,0,1,0]);
         this._linkedEffect = new ColorMatrixFilter(matrix);
         var matrix2:Array = new Array();
         matrix2 = matrix2.concat([0.5,0,0,0,0]);
         matrix2 = matrix2.concat([0,0.5,0,0,0]);
         matrix2 = matrix2.concat([0,0,0.5,0,0]);
         matrix2 = matrix2.concat([0,0,0,1,0]);
         this._linkedMainEffect = new ColorMatrixFilter(matrix2);
         this._entitiesFrame = new FightEntitiesFrame();
         this._preparationFrame = new FightPreparationFrame(this);
         this._battleFrame = new FightBattleFrame();
         this._challengesList = new Array();
         this._timerFighterInfo = new Timer(100,1);
         this._timerFighterInfo.addEventListener(TimerEvent.TIMER,this.showFighterInfo,false,0,true);
         this._timerMovementRange = new Timer(200,1);
         this._timerMovementRange.addEventListener(TimerEvent.TIMER,this.showMovementRange,false,0,true);
         if(MapDisplayManager.getInstance().getDataMapContainer())
         {
            MapDisplayManager.getInstance().getDataMapContainer().setTemporaryAnimatedElementState(false);
         }
         if(Kernel.getWorker().contains(EntitiesTooltipsFrame))
         {
            Kernel.getWorker().removeFrame(Kernel.getWorker().getFrame(EntitiesTooltipsFrame) as EntitiesTooltipsFrame);
         }
         this._showPermanentTooltips = OptionManager.getOptionManager("dofus")["showPermanentTargetsTooltips"];
         OptionManager.getOptionManager("dofus").addEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
         Berilia.getInstance().addEventListener(UiUnloadEvent.UNLOAD_UI_COMPLETE,this.onUiUnloaded);
         Berilia.getInstance().addEventListener(UiUnloadEvent.UNLOAD_UI_STARTED,this.onUiUnloadStarted);
         Berilia.getInstance().addEventListener(TooltipEvent.TOOLTIPS_ORDERED,this.onTooltipsOrdered);
         try
         {
            Berilia.getInstance().uiSavedModificationPresetName = "fight";
         }
         catch(error:Error)
         {
            _log.error("Failed to set uiSavedModificationPresetName to \'fight\'!\n" + error.message + "\n" + error.getStackTrace());
         }
         return true;
      }
      
      private function onUiUnloaded(pEvent:UiUnloadEvent) : void
      {
         var entityId:Number = NaN;
         if(this._showPermanentTooltips && this.battleFrame)
         {
            for each(entityId in this.battleFrame.targetedEntities)
            {
               this.displayEntityTooltip(entityId);
            }
         }
      }
      
      public function getFighterName(fighterId:Number) : String
      {
         var fighterInfos:* = null;
         var compInfos:* = null;
         var name:* = null;
         var genericName:* = null;
         var taxInfos:* = null;
         var masterName:* = null;
         fighterInfos = this.getFighterInfos(fighterId);
         if(!fighterInfos)
         {
            return "Unknown Fighter";
         }
         switch(true)
         {
            case fighterInfos is GameFightFighterNamedInformations:
               return (fighterInfos as GameFightFighterNamedInformations).name;
            case fighterInfos is GameFightMonsterInformations:
               return Monster.getMonsterById((fighterInfos as GameFightMonsterInformations).creatureGenericId).name;
            case fighterInfos is GameFightEntityInformation:
               compInfos = fighterInfos as GameFightEntityInformation;
               genericName = Companion.getCompanionById(compInfos.entityModelId).name;
               if(compInfos.masterId != PlayedCharacterManager.getInstance().id)
               {
                  masterName = this.getFighterName(compInfos.masterId);
                  name = I18n.getUiText("ui.common.belonging",[genericName,masterName]);
               }
               else
               {
                  name = genericName;
               }
               return name;
            case fighterInfos is GameFightTaxCollectorInformations:
               taxInfos = fighterInfos as GameFightTaxCollectorInformations;
               return TaxCollectorFirstname.getTaxCollectorFirstnameById(taxInfos.firstNameId).firstname + " " + TaxCollectorName.getTaxCollectorNameById(taxInfos.lastNameId).name;
            default:
               return "Unknown Fighter Type";
         }
      }
      
      public function getFighterStatus(fighterId:Number) : uint
      {
         var fighterInfos:GameFightFighterInformations = this.getFighterInfos(fighterId);
         if(!fighterInfos)
         {
            return 1;
         }
         switch(true)
         {
            case fighterInfos is GameFightFighterNamedInformations:
               return (fighterInfos as GameFightFighterNamedInformations).status.statusId;
            default:
               return 1;
         }
      }
      
      public function getFighterLevel(fighterId:Number) : uint
      {
         var fighterInfos:* = null;
         var monster:* = null;
         fighterInfos = this.getFighterInfos(fighterId);
         if(!fighterInfos)
         {
            return 0;
         }
         switch(true)
         {
            case fighterInfos is GameFightMutantInformations:
               return (fighterInfos as GameFightMutantInformations).powerLevel;
            case fighterInfos is GameFightCharacterInformations:
               return (fighterInfos as GameFightCharacterInformations).level;
            case fighterInfos is GameFightEntityInformation:
               return (fighterInfos as GameFightEntityInformation).level;
            case fighterInfos is GameFightMonsterInformations:
               if(fighterInfos.stats.summoned)
               {
                  return this.getFighterLevel(fighterInfos.stats.summoner);
               }
               monster = Monster.getMonsterById((fighterInfos as GameFightMonsterInformations).creatureGenericId);
               return monster.getMonsterGrade((fighterInfos as GameFightMonsterInformations).creatureGrade).level;
            case fighterInfos is GameFightTaxCollectorInformations:
               return (fighterInfos as GameFightTaxCollectorInformations).level;
            default:
               return 0;
         }
      }
      
      public function getChallengeById(challengeId:uint) : ChallengeWrapper
      {
         var challenge:* = null;
         for each(challenge in this._challengesList)
         {
            if(challenge.id == challengeId)
            {
               return challenge;
            }
         }
         return null;
      }
      
      public function process(msg:Message) : Boolean
      {
         /*
          * Decompilation error
          * Timeout (1 minute) was reached
          * Instruction count: 3882
          */
         throw new flash.errors.IllegalOperationError("Not decompiled due to timeout");
      }
      
      public function pulled() : Boolean
      {
         if(TacticModeManager.getInstance().tacticModeActivated)
         {
            TacticModeManager.getInstance().hide(true);
         }
         if(this._entitiesFrame)
         {
            Kernel.getWorker().removeFrame(this._entitiesFrame);
         }
         if(this._preparationFrame)
         {
            Kernel.getWorker().removeFrame(this._preparationFrame);
         }
         if(this._battleFrame)
         {
            Kernel.getWorker().removeFrame(this._battleFrame);
         }
         SerialSequencer.clearByType(FightSequenceFrame.FIGHT_SEQUENCERS_CATEGORY);
         this._preparationFrame = null;
         this._battleFrame = null;
         this._lastEffectEntity = null;
         this.removeSpellTargetsTooltips();
         TooltipManager.hideAll();
         this._timerFighterInfo.reset();
         this._timerFighterInfo.removeEventListener(TimerEvent.TIMER,this.showFighterInfo);
         this._timerFighterInfo = null;
         this._timerMovementRange.reset();
         this._timerMovementRange.removeEventListener(TimerEvent.TIMER,this.showMovementRange);
         this._timerMovementRange = null;
         this._currentFighterInfo = null;
         if(MapDisplayManager.getInstance().getDataMapContainer())
         {
            MapDisplayManager.getInstance().getDataMapContainer().setTemporaryAnimatedElementState(true);
         }
         Atouin.getInstance().displayGrid(this._roleplayGridDisplayed);
         OptionManager.getOptionManager("dofus").removeEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
         Berilia.getInstance().removeEventListener(UiUnloadEvent.UNLOAD_UI_COMPLETE,this.onUiUnloaded);
         var simf:SpellInventoryManagementFrame = Kernel.getWorker().getFrame(SpellInventoryManagementFrame) as SpellInventoryManagementFrame;
         simf.deleteSpellsGlobalCoolDownsData();
         PlayedCharacterManager.getInstance().isSpectator = false;
         Berilia.getInstance().removeEventListener(UiUnloadEvent.UNLOAD_UI_STARTED,this.onUiUnloadStarted);
         Berilia.getInstance().removeEventListener(TooltipEvent.TOOLTIPS_ORDERED,this.onTooltipsOrdered);
         try
         {
            Berilia.getInstance().uiSavedModificationPresetName = null;
         }
         catch(error:Error)
         {
            _log.error("Failed to reset uiSavedModificationPresetName!\n" + error.message + "\n" + error.getStackTrace());
         }
         return true;
      }
      
      public function outEntity(id:Number) : void
      {
         var entityId:Number = NaN;
         var ttName:* = null;
         var entitiesOnCell:* = null;
         var entityOnCell:* = null;
         this._timerFighterInfo.reset();
         this._timerMovementRange.reset();
         var tooltipsEntitiesIds:Vector.<Number> = new Vector.<Number>(0);
         tooltipsEntitiesIds.push(id);
         var entitiesIdsList:Vector.<Number> = this._entitiesFrame.getEntitiesIdsList();
         fighterEntityTooltipId = id;
         var entity:IEntity = DofusEntities.getEntity(fighterEntityTooltipId);
         if(!entity || !entity.position)
         {
            if(entitiesIdsList.indexOf(fighterEntityTooltipId) == -1)
            {
               _log.info("Mouse out an unknown entity : " + id);
               return;
            }
         }
         else
         {
            entitiesOnCell = EntitiesManager.getInstance().getEntitiesOnCell(entity.position.cellId,AnimatedCharacter);
            for each(entityOnCell in entitiesOnCell)
            {
               if(tooltipsEntitiesIds.indexOf(entityOnCell.id) == -1)
               {
                  tooltipsEntitiesIds.push(entityOnCell.id);
               }
            }
         }
         if(this._lastEffectEntity && this._lastEffectEntity.object)
         {
            Sprite(this._lastEffectEntity.object).filters = [];
         }
         this._lastEffectEntity = null;
         for each(entityId in tooltipsEntitiesIds)
         {
            ttName = "tooltipOverEntity_" + entityId;
            if((!this._showPermanentTooltips || this._showPermanentTooltips && this.battleFrame.targetedEntities.indexOf(entityId) == -1) && TooltipManager.isVisible(ttName))
            {
               TooltipManager.hide(ttName);
            }
         }
         if(this._showPermanentTooltips)
         {
            for each(entityId in this.battleFrame.targetedEntities)
            {
               this.displayEntityTooltip(entityId);
            }
         }
         if(entity != null)
         {
            Sprite(entity).filters = [];
         }
         this.hideMovementRange();
         var inviSel:Selection = SelectionManager.getInstance().getSelection(this.INVISIBLE_POSITION_SELECTION);
         if(inviSel)
         {
            inviSel.remove();
         }
         this.removeAsLinkEntityEffect();
         if(this._currentFighterInfo && this._currentFighterInfo.contextualId == id)
         {
            KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,null);
            if(PlayedCharacterManager.getInstance().isSpectator && OptionManager.getOptionManager("dofus")["spectatorAutoShowCurrentFighterInfo"] == true)
            {
               KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,FightEntitiesFrame.getCurrentInstance().getEntityInfos(this._battleFrame.currentPlayerId) as GameFightFighterInformations);
            }
         }
         var fightPreparationFrame:FightPreparationFrame = Kernel.getWorker().getFrame(FightPreparationFrame) as FightPreparationFrame;
         if(fightPreparationFrame)
         {
            fightPreparationFrame.updateSwapPositionRequestsIcons();
         }
      }
      
      public function removeSpellTargetsTooltips() : void
      {
         var ttEntityId:* = undefined;
         PushUtil.reset();
         for(ttEntityId in this._spellTargetsTooltips)
         {
            TooltipPlacer.removeTooltipPositionByName("tooltip_tooltipOverEntity_" + ttEntityId);
            delete this._spellTargetsTooltips[ttEntityId];
            TooltipManager.hide("tooltipOverEntity_" + ttEntityId);
            SpellDamagesManager.getInstance().removeSpellDamages(ttEntityId);
            if(this._showPermanentTooltips && this._battleFrame && this._battleFrame.targetedEntities.indexOf(ttEntityId) != -1)
            {
               this.displayEntityTooltip(ttEntityId);
            }
         }
      }
      
      public function displayEntityTooltip(pEntityId:Number, pSpell:Object = null, pSpellInfo:SpellDamageInfo = null, pForceRefresh:Boolean = false, pSpellImpactCell:int = -1, pMakerParams:Object = null) : void
      {
         var updateTime:uint = 0;
         var params:Object = null;
         var spellImpactCell:int = 0;
         var entityDamagedOrHealedBySpell:Boolean = false;
         var showDamages:Boolean = false;
         var hideTooltip:Boolean = false;
         var emptySpellDamage:Boolean = false;
         var entitiesOnCell:Array = null;
         var ac:AnimatedCharacter = null;
         var sdi:SpellDamageInfo = null;
         var currentSpellDamage:SpellDamage = null;
         var targetId:Number = NaN;
         var entitySpellDamage:Object = null;
         var ed:EffectDamage = null;
         var entityId:Number = NaN;
         var directDamageSpell:SpellWrapper = null;
         var nbPushedEntities:uint = 0;
         var i:int = 0;
         var entityPushed:Boolean = false;
         var pushedEntitySdi:SpellDamageInfo = null;
         var pushedEntitiesIds:Vector.<Number> = null;
         var allTargets:Vector.<Number> = null;
         var ts:TriggeredSpell = null;
         var damageSharingMultiplier:Number = NaN;
         var checkTargetTriggeredSpells:Boolean = false;
         var triggeredSpells:Vector.<TriggeredSpell> = null;
         var criticalTriggeredSpells:Vector.<TriggeredSpell> = null;
         var splashdmg:SplashDamage = null;
         var splashDamages:Vector.<SplashDamage> = null;
         var damageSharingTargets:Vector.<Number> = null;
         var originalTarget:Number = NaN;
         var sharedDamage:SpellDamage = null;
         var targetDamage:SpellDamage = null;
         var targetDamageEffect:EffectDamage = null;
         var targetsIds:Vector.<Number> = null;
         var targetsDamages:Dictionary = null;
         var finalSharedDamage:EffectDamage = null;
         var targetHeal:EffectDamage = null;
         var splashDmg:SplashDamage = null;
         var fighterId:* = undefined;
         var triggeredSpellOnTargetSdi:SpellDamageInfo = null;
         var triggeredSpellDamageShared:Boolean = false;
         var entitySdi:SpellDamageInfo = null;
         var interceptedDmg:InterceptedDamage = null;
         var computedEffect:EffectDamage = null;
         var targetCell:int = 0;
         var hasCriticalTriggeredSpell:Boolean = false;
         var criticalTriggeredSpell:TriggeredSpell = null;
         var triggeredSpellDamage:SpellDamage = null;
         var criticalTriggeredSpellDamage:SpellDamage = null;
         var esd:Object = null;
         var critEffects:Vector.<EffectDamage> = null;
         var critEffect:EffectDamage = null;
         var casterIndex:int = 0;
         var idx:int = 0;
         var numTargets:uint = 0;
         var allTargetsTooltipsVisible:Boolean = false;
         var hasInterceptedDamage:Boolean = false;
         var pushedEntity:PushedEntity = null;
         var casterSdi:SpellDamageInfo = null;
         var spell:SpellWrapper = null;
         var effi:EffectInstance = null;
         var spellDamageInfo:SpellDamageInfo = null;
         var intercepted:InterceptedDamage = null;
         var interceptedMaximizedEffects:Boolean = false;
         var interceptorSpellDamages:Object = null;
         var interceptorSdi:SpellDamageInfo = null;
         var interceptedDamageIndex:int = 0;
         var interceptorIndex:int = 0;
         var spellZone:IZone = null;
         var spellZoneCells:Vector.<uint> = null;
         var spellDamage:SpellDamage = null;
         var delta:int = 0;
         var entity:IDisplayable = DofusEntities.getEntity(pEntityId) as IDisplayable;
         var infos:GameFightFighterInformations = this._entitiesFrame.getEntityInfos(pEntityId) as GameFightFighterInformations;
         try
         {
            updateTime = getTimer();
            this._tooltipLastUpdate[pEntityId] = updateTime;
            if(!infos || this._battleFrame.targetedEntities.indexOf(pEntityId) != -1 && this._hiddenEntites.indexOf(pEntityId) != -1)
            {
               return;
            }
            params = pMakerParams;
            if(infos.disposition.cellId != currentCell && !(this._timelineOverEntity && pEntityId == this.timelineOverEntityId))
            {
               if(!params)
               {
                  params = new Object();
               }
               params.showName = false;
            }
            spellImpactCell = pSpellImpactCell != -1?int(pSpellImpactCell):int(currentCell);
            if(pSpell && spellImpactCell == -1)
            {
               return;
            }
            if(pSpell is SpellWrapper)
            {
               entitiesOnCell = EntitiesManager.getInstance().getEntitiesOnCell(spellImpactCell,AnimatedCharacter);
               if((pSpell.spellLevelInfos as SpellLevel).needTakenCell && entitiesOnCell.length == 0)
               {
                  return;
               }
            }
            if(pSpell && !pSpellInfo)
            {
               ac = entity as AnimatedCharacter;
               entityDamagedOrHealedBySpell = pSpell && DamageUtil.isDamagedOrHealedBySpell(CurrentPlayedFighterManager.getInstance().currentFighterId,pEntityId,pSpell,spellImpactCell);
               if(ac && ac.parentSprite && ac.parentSprite.carriedEntity == ac && !entityDamagedOrHealedBySpell)
               {
                  TooltipPlacer.removeTooltipPositionByName("tooltip_tooltipOverEntity_" + pEntityId);
                  return;
               }
            }
            showDamages = pSpell && OptionManager.getOptionManager("dofus")["showDamagesPreview"] == true && FightSpellCastFrame.isCurrentTargetTargetable();
            if(showDamages)
            {
               if(!pForceRefresh && this._spellTargetsTooltips[pEntityId])
               {
                  return;
               }
               if(!pSpellInfo)
               {
                  if(entityDamagedOrHealedBySpell)
                  {
                     if(DamageUtil.BOMB_SPELLS_IDS.indexOf(pSpell.id) != -1)
                     {
                        directDamageSpell = DamageUtil.getBombDirectDamageSpellWrapper(pSpell as SpellWrapper);
                        sdi = SpellDamageInfo.fromCurrentPlayer(directDamageSpell,CurrentPlayedFighterManager.getInstance().currentFighterId,pEntityId,spellImpactCell);
                        for each(targetId in sdi.originalTargetsIds)
                        {
                           this.displayEntityTooltip(targetId,directDamageSpell,sdi);
                        }
                        return;
                     }
                     sdi = SpellDamageInfo.fromCurrentPlayer(pSpell,CurrentPlayedFighterManager.getInstance().currentFighterId,pEntityId,spellImpactCell);
                     if(PushUtil.getPushSpells().indexOf(pSpell.id) == -1)
                     {
                        sdi.pushedEntities = PushUtil.getPushedEntities(pSpell,sdi.casterId,spellImpactCell,sdi.originalTargetsIds);
                        nbPushedEntities = !!sdi.pushedEntities?uint(sdi.pushedEntities.length):uint(0);
                        if(nbPushedEntities > 0)
                        {
                           pushedEntitiesIds = new Vector.<Number>();
                           for(i = 0; i < nbPushedEntities; )
                           {
                              if(pushedEntitiesIds.indexOf(sdi.pushedEntities[i].id) == -1)
                              {
                                 pushedEntitiesIds.push(sdi.pushedEntities[i].id);
                              }
                              i++;
                           }
                           nbPushedEntities = pushedEntitiesIds.length;
                           for(i = 0; i < nbPushedEntities; i++)
                           {
                              if(!entityPushed)
                              {
                                 entityPushed = pEntityId == pushedEntitiesIds[i];
                              }
                              if(pushedEntitiesIds[i] == pEntityId)
                              {
                                 this.displayEntityTooltip(pushedEntitiesIds[i],pSpell,sdi,true);
                              }
                              else
                              {
                                 pushedEntitySdi = SpellDamageInfo.fromCurrentPlayer(pSpell,CurrentPlayedFighterManager.getInstance().currentFighterId,pushedEntitiesIds[i],spellImpactCell);
                                 pushedEntitySdi.pushedEntities = sdi.pushedEntities;
                                 this.displayEntityTooltip(pushedEntitiesIds[i],pSpell,pushedEntitySdi,true);
                              }
                           }
                           if(entityPushed)
                           {
                              return;
                           }
                        }
                     }
                  }
               }
               else
               {
                  sdi = pSpellInfo;
               }
               this._spellTargetsTooltips[pEntityId] = true;
               if(sdi)
               {
                  if(!params)
                  {
                     params = new Object();
                  }
                  if(sdi.targetId != pEntityId)
                  {
                     sdi.targetId = pEntityId;
                  }
                  allTargets = new Vector.<Number>(0);
                  if(!sdi.damageSharingTargets)
                  {
                     damageSharingTargets = sdi.getDamageSharingTargets();
                     sdi.damageSharingTargets = damageSharingTargets;
                     if(damageSharingTargets && damageSharingTargets.length > 1)
                     {
                        damageSharingMultiplier = 1 / damageSharingTargets.length;
                        sharedDamage = new SpellDamage();
                        targetsIds = new Vector.<Number>();
                        for each(originalTarget in sdi.originalTargetsIds)
                        {
                           if(damageSharingTargets.indexOf(originalTarget) != -1)
                           {
                              targetsIds.push(originalTarget);
                           }
                        }
                        if(targetsIds.indexOf(pEntityId) == -1 && sdi.splashDamages)
                        {
                           for each(splashdmg in sdi.splashDamages)
                           {
                              if(splashdmg.targets.indexOf(pEntityId) != -1)
                              {
                                 targetsIds.push(pEntityId);
                                 break;
                              }
                           }
                        }
                        targetsDamages = new Dictionary();
                        for each(originalTarget in targetsIds)
                        {
                           sdi.targetId = originalTarget;
                           sdi.spellHasLifeSteal = sdi.hasLifeSteal();
                           targetDamage = DamageUtil.getSpellDamage(sdi);
                           targetsDamages[originalTarget] = targetDamage;
                           for each(targetDamageEffect in targetDamage.effectDamages)
                           {
                              targetDamageEffect.applyDamageMultiplier(damageSharingMultiplier);
                              sharedDamage.addEffectDamage(targetDamageEffect);
                           }
                        }
                        sharedDamage.updateDamage();
                        finalSharedDamage = new EffectDamage(-1,sharedDamage.element);
                        finalSharedDamage.minDamage = sharedDamage.minDamage;
                        finalSharedDamage.maxDamage = sharedDamage.maxDamage;
                        finalSharedDamage.minCriticalDamage = sharedDamage.minCriticalDamage;
                        finalSharedDamage.maxCriticalDamage = sharedDamage.maxCriticalDamage;
                        finalSharedDamage.computedEffects.push(finalSharedDamage);
                        for each(targetId in damageSharingTargets)
                        {
                           sdi.sharedDamage = new SpellDamage();
                           sdi.sharedDamage.criticalHitRate = targetDamage.criticalHitRate;
                           sdi.sharedDamage.hasCriticalDamage = targetDamage.hasCriticalDamage;
                           sdi.sharedDamage.addEffectDamage(finalSharedDamage);
                           sdi.sharedDamage.updateDamage();
                           if(targetsDamages[targetId])
                           {
                              targetHeal = new EffectDamage();
                              for each(targetDamageEffect in targetsDamages[targetId].effectDamages)
                              {
                                 for each(targetDamageEffect in targetDamageEffect.computedEffects)
                                 {
                                    targetHeal.minLifePointsAdded = targetHeal.minLifePointsAdded + targetDamageEffect.minLifePointsAdded;
                                    targetHeal.maxLifePointsAdded = targetHeal.maxLifePointsAdded + targetDamageEffect.maxLifePointsAdded;
                                    targetHeal.minCriticalLifePointsAdded = targetHeal.minCriticalLifePointsAdded + targetDamageEffect.minCriticalLifePointsAdded;
                                    targetHeal.maxCriticalLifePointsAdded = targetHeal.maxCriticalLifePointsAdded + targetDamageEffect.maxCriticalLifePointsAdded;
                                 }
                              }
                              sdi.sharedDamage.addEffectDamage(targetHeal);
                              sdi.sharedDamage.hasHeal = targetHeal.minLifePointsAdded > 0 || targetHeal.maxLifePointsAdded > 0 || targetHeal.minCriticalLifePointsAdded > 0 || targetHeal.maxCriticalLifePointsAdded > 0;
                              sdi.sharedDamage.hasCriticalLifePointsAdded = targetsDamages[targetId].hasCriticalLifePointsAdded;
                           }
                           allTargets.push(targetId);
                        }
                     }
                  }
                  currentSpellDamage = DamageUtil.getSpellDamage(sdi);
                  checkTargetTriggeredSpells = !sdi.spellHasTriggered && (!sdi.damageSharingTargets || sdi.damageSharingTargets.indexOf(pEntityId) != -1 && sdi.originalTargetsIds.indexOf(pEntityId) != -1);
                  if(checkTargetTriggeredSpells)
                  {
                     for(fighterId in DamageUtil.fightersStates)
                     {
                        delete DamageUtil.fightersStates[fighterId];
                     }
                     triggeredSpells = this.getTriggeredSpellsOnTarget(sdi.targetLifePoints,currentSpellDamage,sdi.triggeredSpells,false);
                     criticalTriggeredSpells = this.getTriggeredSpellsOnTarget(sdi.targetLifePoints,currentSpellDamage,sdi.criticalTriggeredSpells,true);
                     for each(ts in triggeredSpells)
                     {
                        triggeredSpellDamageShared = false;
                        for each(criticalTriggeredSpell in criticalTriggeredSpells)
                        {
                           if(criticalTriggeredSpell.spell.id == ts.spell.id)
                           {
                              hasCriticalTriggeredSpell = true;
                              break;
                           }
                        }
                        for each(targetId in ts.targets)
                        {
                           targetCell = ts.targetCell;
                           if(!DamageUtil.isDamagedOrHealedBySpell(ts.casterId,targetId,ts.spell,ts.targetCell,false))
                           {
                              if(ts.targets.indexOf(ts.casterId) == -1 && ts.spell.canTargetCasterOutOfZone && DamageUtil.isDamagedOrHealedBySpell(ts.casterId,ts.casterId,ts.spell,this._entitiesFrame.getEntityInfos(ts.casterId).disposition.cellId))
                              {
                                 ts.entityCellCallback.args[0] = ts.casterId;
                                 targetCell = ts.entityCellCallback.exec();
                                 targetId = ts.casterId;
                              }
                              else
                              {
                                 continue;
                              }
                           }
                           triggeredSpellOnTargetSdi = SpellDamageInfo.fromCurrentPlayer(ts.spell,ts.casterId,targetId,targetCell,ts.casterAffectedOutOfZone);
                           triggeredSpellOnTargetSdi.triggeredSpell = ts;
                           triggeredSpellOnTargetSdi.criticalHitRate = sdi.criticalHitRate;
                           triggeredSpellOnTargetSdi.spellHasCriticalDamage = true;
                           triggeredSpellOnTargetSdi.spellHasCriticalHeal = true;
                           triggeredSpellDamage = DamageUtil.getSpellDamage(triggeredSpellOnTargetSdi);
                           for each(ed in triggeredSpellDamage.effectDamages)
                           {
                              if(!isNaN(damageSharingMultiplier))
                              {
                                 ed.applyDamageMultiplier(damageSharingMultiplier);
                              }
                              if(hasCriticalTriggeredSpell)
                              {
                                 ed.minCriticalDamage = ed.maxCriticalDamage = 0;
                                 ed.minCriticalLifePointsAdded = ed.maxCriticalLifePointsAdded = 0;
                                 for each(computedEffect in ed.computedEffects)
                                 {
                                    computedEffect.minCriticalDamage = computedEffect.maxCriticalDamage = 0;
                                    computedEffect.minCriticalLifePointsAdded = computedEffect.maxCriticalLifePointsAdded = 0;
                                 }
                              }
                           }
                           SpellDamagesManager.getInstance().addSpellDamage(triggeredSpellOnTargetSdi,triggeredSpellDamage);
                           if(sdi.originalTargetsIds.indexOf(pEntityId) != -1 && pEntityId != targetId)
                           {
                              entitySdi = SpellDamageInfo.fromCurrentPlayer(ts.spell,ts.casterId,pEntityId,sdi.spellCenterCell);
                              entitySdi.criticalHitRate = sdi.criticalHitRate;
                              entitySdi.spellHasCriticalDamage = sdi.spellHasCriticalDamage;
                              for each(interceptedDmg in triggeredSpellOnTargetSdi.interceptedDamages)
                              {
                                 if(interceptedDmg.interceptorEntityId == pEntityId)
                                 {
                                    SpellDamagesManager.getInstance().addSpellDamage(entitySdi,interceptedDmg.damage);
                                 }
                              }
                           }
                           if(sdi.damageSharingTargets && sdi.damageSharingTargets.indexOf(targetId) != -1 && !triggeredSpellDamageShared)
                           {
                              for each(entityId in sdi.damageSharingTargets)
                              {
                                 if(entityId != targetId)
                                 {
                                    triggeredSpellOnTargetSdi.targetId = entityId;
                                    SpellDamagesManager.getInstance().addSpellDamage(triggeredSpellOnTargetSdi,triggeredSpellDamage);
                                 }
                              }
                              triggeredSpellDamageShared = true;
                           }
                           if(allTargets.indexOf(targetId) == -1)
                           {
                              allTargets.push(targetId);
                           }
                        }
                     }
                     for each(ts in criticalTriggeredSpells)
                     {
                        triggeredSpellDamageShared = false;
                        for each(targetId in ts.targets)
                        {
                           targetCell = ts.targetCell;
                           if(!DamageUtil.isDamagedOrHealedBySpell(ts.casterId,targetId,ts.spell,ts.targetCell,false))
                           {
                              if(ts.targets.indexOf(ts.casterId) == -1 && ts.spell.canTargetCasterOutOfZone && DamageUtil.isDamagedOrHealedBySpell(ts.casterId,ts.casterId,ts.spell,this._entitiesFrame.getEntityInfos(ts.casterId).disposition.cellId))
                              {
                                 ts.entityCellCallback.args[0] = ts.casterId;
                                 targetCell = ts.entityCellCallback.exec();
                                 targetId = ts.casterId;
                              }
                              else
                              {
                                 continue;
                              }
                           }
                           triggeredSpellOnTargetSdi = SpellDamageInfo.fromCurrentPlayer(ts.spell,ts.casterId,targetId,targetCell,ts.casterAffectedOutOfZone);
                           triggeredSpellOnTargetSdi.triggeredSpell = ts;
                           triggeredSpellOnTargetSdi.criticalHitRate = sdi.criticalHitRate;
                           triggeredSpellOnTargetSdi.spellHasCriticalDamage = true;
                           triggeredSpellOnTargetSdi.spellHasCriticalHeal = true;
                           criticalTriggeredSpellDamage = DamageUtil.getSpellDamage(triggeredSpellOnTargetSdi);
                           for each(ed in criticalTriggeredSpellDamage.effectDamages)
                           {
                              if(!isNaN(damageSharingMultiplier))
                              {
                                 ed.applyDamageMultiplier(damageSharingMultiplier);
                              }
                              ed.minCriticalDamage = ed.minDamage;
                              ed.maxCriticalDamage = ed.maxDamage;
                              ed.minDamage = ed.maxDamage = 0;
                              ed.minCriticalLifePointsAdded = ed.minLifePointsAdded;
                              ed.maxCriticalLifePointsAdded = ed.maxLifePointsAdded;
                              ed.minLifePointsAdded = ed.maxLifePointsAdded = 0;
                              for each(computedEffect in ed.computedEffects)
                              {
                                 computedEffect.minCriticalDamage = computedEffect.minDamage;
                                 computedEffect.maxCriticalDamage = computedEffect.maxDamage;
                                 computedEffect.minDamage = computedEffect.maxDamage = 0;
                                 computedEffect.minCriticalLifePointsAdded = computedEffect.minLifePointsAdded;
                                 computedEffect.maxCriticalLifePointsAdded = computedEffect.maxLifePointsAdded;
                                 computedEffect.minLifePointsAdded = computedEffect.maxLifePointsAdded = 0;
                              }
                           }
                           if(sdi.originalTargetsIds.indexOf(pEntityId) != -1 && pEntityId != targetId)
                           {
                              for each(interceptedDmg in triggeredSpellOnTargetSdi.interceptedDamages)
                              {
                                 if(interceptedDmg.interceptorEntityId == pEntityId)
                                 {
                                    esd = SpellDamagesManager.getInstance().getSpellDamageBySpellId(pEntityId,ts.spell.id);
                                    if(esd)
                                    {
                                       critEffects = new Vector.<EffectDamage>(0);
                                       for each(ed in esd.spellDamage.effectDamages)
                                       {
                                          critEffect = ed.clone();
                                          critEffect.minCriticalDamage = ed.minDamage;
                                          critEffect.maxCriticalDamage = ed.maxDamage;
                                          critEffect.minDamage = critEffect.maxDamage = 0;
                                          critEffect.minCriticalLifePointsAdded = ed.minLifePointsAdded;
                                          critEffect.maxCriticalLifePointsAdded = ed.maxLifePointsAdded;
                                          critEffect.minLifePointsAdded = critEffect.maxLifePointsAdded = 0;
                                          for each(computedEffect in critEffect.computedEffects)
                                          {
                                             computedEffect.minCriticalDamage = computedEffect.minDamage;
                                             computedEffect.maxCriticalDamage = computedEffect.maxDamage;
                                             computedEffect.minDamage = computedEffect.maxDamage = 0;
                                             computedEffect.minCriticalLifePointsAdded = computedEffect.minLifePointsAdded;
                                             computedEffect.maxCriticalLifePointsAdded = computedEffect.maxLifePointsAdded;
                                             computedEffect.minLifePointsAdded = computedEffect.maxLifePointsAdded = 0;
                                          }
                                          critEffects.push(critEffect);
                                       }
                                       for each(critEffect in critEffects)
                                       {
                                          esd.spellDamage.effectDamages.push(critEffect);
                                       }
                                    }
                                 }
                              }
                           }
                           entitySpellDamage = SpellDamagesManager.getInstance().getSpellDamageBySpellId(targetId,ts.spell.id);
                           if(entitySpellDamage)
                           {
                              for each(ed in criticalTriggeredSpellDamage.effectDamages)
                              {
                                 entitySpellDamage.spellDamage.addEffectDamage(ed);
                              }
                              entitySpellDamage.spellDamage.updateDamage();
                           }
                           else
                           {
                              SpellDamagesManager.getInstance().addSpellDamage(triggeredSpellOnTargetSdi,criticalTriggeredSpellDamage);
                           }
                           if(allTargets.indexOf(targetId) == -1)
                           {
                              allTargets.push(targetId);
                           }
                        }
                     }
                     for(fighterId in DamageUtil.fightersStates)
                     {
                        delete DamageUtil.fightersStates[fighterId];
                     }
                  }
                  if(triggeredSpells)
                  {
                     splashDamages = DamageUtil.getSplashDamages(triggeredSpells,sdi,false);
                     if(splashDamages)
                     {
                        if(!sdi.splashDamages)
                        {
                           sdi.splashDamages = new Vector.<SplashDamage>(0);
                        }
                        for each(splashdmg in splashDamages)
                        {
                           sdi.splashDamages.push(splashdmg);
                           for each(targetId in splashdmg.targets)
                           {
                              if(allTargets.indexOf(targetId) == -1)
                              {
                                 allTargets.push(targetId);
                              }
                           }
                        }
                     }
                     sdi.addTriggeredSpellsEffects(triggeredSpells,false);
                  }
                  if(criticalTriggeredSpells)
                  {
                     splashDamages = DamageUtil.getSplashDamages(criticalTriggeredSpells,sdi,true);
                     if(splashDamages)
                     {
                        if(!sdi.criticalSplashDamages)
                        {
                           sdi.criticalSplashDamages = new Vector.<SplashDamage>(0);
                        }
                        for each(splashdmg in splashDamages)
                        {
                           sdi.criticalSplashDamages.push(splashdmg);
                           for each(targetId in splashdmg.targets)
                           {
                              if(allTargets.indexOf(targetId) == -1)
                              {
                                 allTargets.push(targetId);
                              }
                           }
                        }
                     }
                     sdi.addTriggeredSpellsEffects(criticalTriggeredSpells,true);
                  }
                  if(allTargets.length > 0)
                  {
                     sdi.spellHasTriggered = triggeredSpells.length > 0 || criticalTriggeredSpells.length > 0;
                     if(allTargets.indexOf(pEntityId) == -1)
                     {
                        allTargets.push(pEntityId);
                     }
                     casterIndex = allTargets.indexOf(sdi.casterId);
                     if(casterIndex != -1)
                     {
                        allTargets.splice(casterIndex,1);
                        allTargets.push(sdi.casterId);
                     }
                     numTargets = allTargets.length;
                     for(idx = 0; idx < numTargets; idx++)
                     {
                        if(allTargets[idx] == sdi.casterId)
                        {
                           sdi.reflectDamages = sdi.getReflectDamages();
                           sdi.spellHasLifeSteal = sdi.hasLifeSteal();
                        }
                        this.displayEntityTooltip(allTargets[idx],pSpell,sdi,true);
                     }
                     return;
                  }
               }
               if(currentSpellDamage)
               {
                  if(!currentSpellDamage.empty)
                  {
                     SpellDamagesManager.getInstance().addSpellDamage(sdi,currentSpellDamage);
                     for each(pushedEntity in sdi.pushedEntities)
                     {
                        if(pushedEntity.spellId == sdi.spell.id && pushedEntity.id == sdi.targetId)
                        {
                           sdi.pushedEntities.splice(sdi.pushedEntities.indexOf(pushedEntity),1);
                        }
                     }
                  }
                  params.spellDamage = SpellDamagesManager.getInstance().getTotalSpellDamage(pEntityId);
                  allTargetsTooltipsVisible = true;
                  for each(entityId in sdi.originalTargetsIds)
                  {
                     if(!this._spellTargetsTooltips[entityId])
                     {
                        allTargetsTooltipsVisible = false;
                        break;
                     }
                  }
                  if(!currentSpellDamage.invulnerableState && pEntityId != sdi.casterId && allTargetsTooltipsVisible && sdi.originalTargetsIds.indexOf(sdi.casterId) == -1 && !SpellDamagesManager.getInstance().hasSpellDamages(sdi.casterId))
                  {
                     casterSdi = SpellDamageInfo.fromCurrentPlayer(pSpell,CurrentPlayedFighterManager.getInstance().currentFighterId,sdi.casterId,spellImpactCell);
                     casterSdi.reflectDamages = sdi.getReflectDamages();
                     casterSdi.spellHasLifeSteal = sdi.hasLifeSteal();
                     casterSdi.splashDamages = sdi.splashDamages;
                     casterSdi.spellHasTriggered = sdi.spellHasTriggered;
                     casterSdi.originalTargetsIds = sdi.originalTargetsIds.concat();
                     if(casterSdi.reflectDamages || casterSdi.spellHasLifeSteal)
                     {
                        casterSdi.minimizedEffects = sdi.minimizedEffects;
                        casterSdi.maximizedEffects = sdi.maximizedEffects;
                        this.displayEntityTooltip(sdi.casterId,pSpell,casterSdi,true);
                     }
                     spell = SpellWrapper.create(sdi.spell.id,sdi.spell.spellLevel,false,sdi.casterId);
                     spell.effects.length = 0;
                     spell.criticalEffect.length = 0;
                     for each(effi in sdi.spellEffects)
                     {
                        if(effi.targetMask && effi.targetMask.indexOf("C") != -1)
                        {
                           spell.effects.push(effi);
                        }
                     }
                     if(allTargets.indexOf(sdi.casterId) == -1)
                     {
                        for each(effi in sdi.spellCriticalEffects)
                        {
                           if(effi.targetMask && effi.targetMask.indexOf("C") != -1)
                           {
                              spell.criticalEffect.push(effi);
                           }
                        }
                     }
                     if(spell.effects.length)
                     {
                        spellDamageInfo = SpellDamageInfo.fromCurrentPlayer(spell,sdi.casterId,sdi.casterId,sdi.spellCenterCell,sdi.casterAffectedOutOfZone);
                        spellDamageInfo.originalTargetsIds = new <Number>[spellDamageInfo.casterId];
                        this.displayEntityTooltip(sdi.casterId,spell,spellDamageInfo,true);
                     }
                  }
                  if(!sdi.isInterceptedDamage && (!sdi.damageSharingTargets || !sdi.damageSharingTargets.length))
                  {
                     for each(intercepted in sdi.interceptedDamages)
                     {
                        if(intercepted.interceptedEntityId == pEntityId)
                        {
                           hasInterceptedDamage = true;
                           break;
                        }
                     }
                  }
                  if(hasInterceptedDamage)
                  {
                     interceptedMaximizedEffects = true;
                     for each(intercepted in sdi.interceptedDamages)
                     {
                        if(pEntityId != intercepted.interceptorEntityId && intercepted.interceptedEntityId == pEntityId && !intercepted.damage.isHealingSpell && intercepted.damage.hasDamage)
                        {
                           if(!intercepted.damage.maximizedEffects)
                           {
                              interceptedMaximizedEffects = false;
                           }
                           interceptorSpellDamages = SpellDamagesManager.getInstance().getSpellDamages(intercepted.interceptorEntityId);
                           if(interceptorSpellDamages && intercepted.interceptorEntityId != sdi.interceptedEntityId)
                           {
                              for each(entitySpellDamage in interceptorSpellDamages)
                              {
                                 for each(ed in entitySpellDamage.spellDamage.effectDamages)
                                 {
                                    for each(ed in ed.computedEffects)
                                    {
                                       intercepted.damage.addEffectDamage(ed);
                                    }
                                 }
                                 if(entitySpellDamage.interceptedDamage)
                                 {
                                    if(!entitySpellDamage.spellDamage.maximizedEffects)
                                    {
                                       interceptedMaximizedEffects = false;
                                    }
                                    interceptedDamageIndex = interceptorSpellDamages.indexOf(entitySpellDamage);
                                 }
                                 if(entitySpellDamage.spellDamage.hasCriticalDamage)
                                 {
                                    intercepted.damage.hasCriticalDamage = true;
                                 }
                              }
                              if(interceptedDamageIndex != -1)
                              {
                                 interceptorSpellDamages.splice(interceptedDamageIndex,1);
                              }
                           }
                           interceptorSdi = SpellDamageInfo.fromCurrentPlayer(pSpell,CurrentPlayedFighterManager.getInstance().currentFighterId,intercepted.interceptorEntityId,spellImpactCell);
                           if(interceptorSpellDamages)
                           {
                              interceptorIndex = interceptorSdi.originalTargetsIds.indexOf(intercepted.interceptorEntityId);
                              if(interceptorIndex != -1)
                              {
                                 interceptorSdi.originalTargetsIds.splice(interceptorIndex,1);
                              }
                           }
                           intercepted.damage.updateDamage();
                           interceptorSdi.interceptedDamage = intercepted.damage;
                           interceptorSdi.interceptedDamage.targetId = interceptorSdi.targetId;
                           interceptorSdi.interceptedEntityId = sdi.targetId;
                           interceptorSdi.distanceBetweenCasterAndTarget = sdi.distanceBetweenCasterAndTarget;
                           interceptorSdi.minimizedEffects = sdi.minimizedEffects;
                           interceptorSdi.maximizedEffects = interceptedMaximizedEffects && interceptorSdi.maximizedEffects;
                           interceptorSdi.criticalHitRate = sdi.criticalHitRate;
                           interceptorSdi.spellHasCriticalDamage = sdi.spellHasCriticalDamage;
                           interceptorSdi.isInterceptedDamage = true;
                           this.displayEntityTooltip(interceptorSdi.targetId,pSpell,interceptorSdi,true);
                           if(!currentSpellDamage.hasHeal && !currentSpellDamage.hasDamage)
                           {
                              return;
                           }
                        }
                     }
                  }
               }
            }
            if(pSpell is SpellWrapper && (pSpell as SpellWrapper).canTargetCasterOutOfZone)
            {
               if(!showDamages)
               {
                  spellZone = SpellZoneManager.getInstance().getSpellZone(pSpell,false,true,spellImpactCell,this._entitiesFrame.getEntityInfos((pSpell as SpellWrapper).playerId).disposition.cellId);
                  spellZoneCells = spellZone.getCells(spellImpactCell);
                  hideTooltip = spellZoneCells.indexOf(infos.disposition.cellId) == -1;
               }
               else
               {
                  hideTooltip = !entityDamagedOrHealedBySpell && !pSpellInfo;
               }
            }
            emptySpellDamage = true;
            if(params && params.spellDamage is SpellDamageList)
            {
               for each(spellDamage in params.spellDamage)
               {
                  if(!spellDamage.empty)
                  {
                     emptySpellDamage = false;
                     break;
                  }
               }
            }
            else if(params && params.spellDamage && !params.spellDamage.empty)
            {
               emptySpellDamage = false;
            }
            if(hideTooltip || params && params.spellDamage && emptySpellDamage || updateTime < this._tooltipLastUpdate[pEntityId])
            {
               return;
            }
         }
         catch(e:Error)
         {
            _log.error(e.getStackTrace());
         }
         if((!params || !params.target) && !entity)
         {
            return;
         }
         var target:IRectangle = params && params.target?params.target:entity.absoluteBounds;
         if(this._entitiesFrame.hasIcon(pEntityId))
         {
            if(!params)
            {
               params = new Object();
            }
            delta = this._entitiesFrame.getIcon(pEntityId).height * Atouin.getInstance().currentZoom + 10 * Atouin.getInstance().currentZoom;
            params.offsetRect = new Rectangle2(0,-delta,0,delta);
         }
         var tooltipCacheName:String = "EntityShortInfos" + infos.contextualId;
         if(infos is GameFightCharacterInformations)
         {
            tooltipCacheName = "PlayerShortInfos" + infos.contextualId;
            TooltipManager.show(infos,target,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),false,"tooltipOverEntity_" + infos.contextualId,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,null,null,params,tooltipCacheName,false,StrataEnum.STRATA_WORLD,Atouin.getInstance().currentZoom);
         }
         else if(infos is GameFightEntityInformation)
         {
            TooltipManager.show(infos,target,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),false,"tooltipOverEntity_" + infos.contextualId,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,"companionFighter",null,params,tooltipCacheName,false,StrataEnum.STRATA_WORLD,Atouin.getInstance().currentZoom);
         }
         else
         {
            TooltipManager.show(infos,target,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),false,"tooltipOverEntity_" + infos.contextualId,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,"monsterFighter",null,params,tooltipCacheName,false,StrataEnum.STRATA_WORLD,Atouin.getInstance().currentZoom);
         }
         var fightPreparationFrame:FightPreparationFrame = Kernel.getWorker().getFrame(FightPreparationFrame) as FightPreparationFrame;
         if(fightPreparationFrame)
         {
            fightPreparationFrame.updateSwapPositionRequestsIcons();
         }
         if(tooltipCacheName && TooltipManager.hasCache(tooltipCacheName))
         {
            this._entitiesFrame.updateEntityIconPosition(pEntityId);
         }
      }
      
      public function addToHiddenEntities(entityId:Number) : void
      {
         if(this._hiddenEntites.indexOf(entityId) == -1)
         {
            this._hiddenEntites.push(entityId);
         }
      }
      
      public function removeFromHiddenEntities(entityId:Number) : void
      {
         if(this._hiddenEntites.indexOf(entityId) != -1)
         {
            this._hiddenEntites.splice(this._hiddenEntites.indexOf(entityId),1);
         }
      }
      
      public function getFighterPreviousPosition(pFighterId:Number) : int
      {
         var savedPos:* = null;
         var positions:* = null;
         if(this._fightersPositionsHistory[pFighterId])
         {
            positions = this._fightersPositionsHistory[pFighterId];
            savedPos = positions.length > 0?positions[positions.length - 1]:null;
         }
         return !!savedPos?int(savedPos.cellId):-1;
      }
      
      public function deleteFighterPreviousPosition(pFighterId:Number) : void
      {
         if(this._fightersPositionsHistory[pFighterId])
         {
            this._fightersPositionsHistory[pFighterId].pop();
         }
      }
      
      public function saveFighterPosition(pFighterId:Number, pCellId:uint) : void
      {
         if(!this._fightersPositionsHistory[pFighterId])
         {
            this._fightersPositionsHistory[pFighterId] = new Array();
         }
         this._fightersPositionsHistory[pFighterId].push({
            "cellId":pCellId,
            "lives":2
         });
      }
      
      public function getFighterRoundStartPosition(pFighterId:Number) : int
      {
         return this._fightersRoundStartPosition[pFighterId];
      }
      
      public function setFighterRoundStartPosition(pFighterId:Number, cellId:int) : int
      {
         return this._fightersRoundStartPosition[pFighterId] = cellId;
      }
      
      public function refreshTimelineOverEntityInfos() : void
      {
         var entity:* = null;
         if(this._timelineOverEntity && this._timelineOverEntityId)
         {
            entity = DofusEntities.getEntity(this._timelineOverEntityId);
            if(entity && entity.position)
            {
               FightContextFrame.currentCell = entity.position.cellId;
               this.overEntity(this._timelineOverEntityId);
            }
         }
      }
      
      private function getTriggeredSpellsOnTarget(pTargetLifePoints:uint, pDamage:SpellDamage, pTriggeredSpells:Vector.<TriggeredSpell>, pCritical:Boolean) : Vector.<TriggeredSpell>
      {
         var dmgBeforeIndex:* = null;
         var ts:* = null;
         var triggeredSpells:Vector.<TriggeredSpell> = !!pTriggeredSpells?new Vector.<TriggeredSpell>(0):null;
         for each(ts in pTriggeredSpells)
         {
            if(ts.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL || ts.effectId == ActionIdEnum.ACTION_TARGET_CASTS_SPELL_WITH_ANIM || ts.effectId == ActionIdEnum.ACTION_TARGET_EXECUTE_SPELL_ON_SOURCE)
            {
               dmgBeforeIndex = DamageUtil.getDamageBeforeIndex(DamageUtil.getAllEffectDamages(pDamage),ts.sourceSpellEffectOrder);
               if(!pCritical && dmgBeforeIndex.minDamage > pTargetLifePoints && dmgBeforeIndex.maxDamage > pTargetLifePoints || pCritical && dmgBeforeIndex.minCriticalDamage > pTargetLifePoints && dmgBeforeIndex.maxCriticalDamage > pTargetLifePoints)
               {
                  continue;
               }
            }
            triggeredSpells.push(ts);
         }
         return triggeredSpells;
      }
      
      private function getFighterInfos(fighterId:Number) : GameFightFighterInformations
      {
         return this.entitiesFrame.getEntityInfos(fighterId) as GameFightFighterInformations;
      }
      
      private function showFighterInfo(event:TimerEvent) : void
      {
         this._timerFighterInfo.reset();
         KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,this._currentFighterInfo);
      }
      
      private function showMovementRange(event:TimerEvent) : void
      {
         this._timerMovementRange.reset();
         this._reachableRangeSelection = new Selection();
         this._reachableRangeSelection.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_AREA,0.7);
         this._reachableRangeSelection.color = new Color(this.REACHABLE_CELL_COLOR);
         this._unreachableRangeSelection = new Selection();
         this._unreachableRangeSelection.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_AREA,0.7);
         this._unreachableRangeSelection.color = new Color(this.UNREACHABLE_CELL_COLOR);
         var fightReachableCellsMaker:FightReachableCellsMaker = new FightReachableCellsMaker(this._currentFighterInfo);
         this._reachableRangeSelection.zone = new Custom(fightReachableCellsMaker.reachableCells);
         this._unreachableRangeSelection.zone = new Custom(fightReachableCellsMaker.unreachableCells);
         SelectionManager.getInstance().addSelection(this._reachableRangeSelection,"movementReachableRange",this._currentFighterInfo.disposition.cellId);
         SelectionManager.getInstance().addSelection(this._unreachableRangeSelection,"movementUnreachableRange",this._currentFighterInfo.disposition.cellId);
      }
      
      private function hideMovementRange() : void
      {
         var s:Selection = SelectionManager.getInstance().getSelection("movementReachableRange");
         if(s)
         {
            s.remove();
            this._reachableRangeSelection = null;
         }
         s = SelectionManager.getInstance().getSelection("movementUnreachableRange");
         if(s)
         {
            s.remove();
            this._unreachableRangeSelection = null;
         }
      }
      
      private function addMarks(marks:Vector.<GameActionMark>) : void
      {
         var mark:* = null;
         var spell:* = null;
         var step:* = null;
         var cellZone:* = null;
         for each(mark in marks)
         {
            spell = Spell.getSpellById(mark.markSpellId);
            if(mark.markType == GameActionMarkTypeEnum.WALL || spell.getSpellLevel(mark.markSpellLevel).hasZoneShape(SpellShapeEnum.semicolon))
            {
               if(spell.getParamByName("glyphGfxId"))
               {
                  for each(cellZone in mark.cells)
                  {
                     step = new AddGlyphGfxStep(spell.getParamByName("glyphGfxId"),cellZone.cellId,mark.markId,mark.markType,mark.markTeamId,mark.active);
                     step.start();
                  }
               }
            }
            else if(spell.getParamByName("glyphGfxId") && !MarkedCellsManager.getInstance().getGlyph(mark.markId) && mark.markimpactCell != -1)
            {
               step = new AddGlyphGfxStep(spell.getParamByName("glyphGfxId"),mark.markimpactCell,mark.markId,mark.markType,mark.markTeamId,mark.active);
               step.start();
            }
            MarkedCellsManager.getInstance().addMark(mark.markId,mark.markType,spell,spell.getSpellLevel(mark.markSpellLevel),mark.cells,mark.markTeamId,mark.active,mark.markimpactCell);
         }
      }
      
      private function removeAsLinkEntityEffect() : void
      {
         var entityId:Number = NaN;
         var entity:* = null;
         var index:int = 0;
         loop0:
         for each(entityId in this._entitiesFrame.getEntitiesIdsList())
         {
            entity = DofusEntities.getEntity(entityId) as DisplayObject;
            if(entity && entity.filters && entity.filters.length)
            {
               for(index = 0; index < entity.filters.length; )
               {
                  if(entity.filters[index] is ColorMatrixFilter)
                  {
                     entity.filters = entity.filters.splice(index,index);
                     continue loop0;
                  }
                  index++;
               }
            }
         }
      }
      
      private function highlightAsLinkedEntity(id:Number, isMainEntity:Boolean) : void
      {
         var filter:* = null;
         var entity:IEntity = DofusEntities.getEntity(id);
         if(!entity)
         {
            return;
         }
         var entitySprite:Sprite = entity as Sprite;
         if(entitySprite)
         {
            filter = !!isMainEntity?this._linkedMainEffect:this._linkedEffect;
            if(entitySprite.filters.length)
            {
               if(entitySprite.filters[0] != filter)
               {
                  entitySprite.filters = [filter];
               }
            }
            else
            {
               entitySprite.filters = [filter];
            }
         }
      }
      
      private function overEntity(id:Number, showRange:Boolean = true, highlightTimelineFighter:Boolean = true, timelineTarget:IRectangle = null) : void
      {
         var entityId:Number = NaN;
         var showInfos:* = false;
         var entityInfo:* = null;
         var inviSelection:* = null;
         var pos:int = 0;
         var lastMovPoint:int = 0;
         var reachableCells:* = null;
         var entityInSpellZone:Boolean = false;
         var casterCell:int = 0;
         var eff:* = null;
         var effect:* = null;
         var fightTurnFrame:* = null;
         var myTurn:Boolean = false;
         var entitiesIdsList:Vector.<Number> = this._entitiesFrame.getEntitiesIdsList();
         fighterEntityTooltipId = id;
         var entity:IEntity = DofusEntities.getEntity(fighterEntityTooltipId);
         if(!entity)
         {
            if(entitiesIdsList.indexOf(fighterEntityTooltipId) == -1)
            {
               _log.warn("Mouse over an unknown entity : " + id);
               return;
            }
            showRange = false;
         }
         var infos:GameFightFighterInformations = this._entitiesFrame.getEntityInfos(id) as GameFightFighterInformations;
         if(!infos)
         {
            _log.warn("Mouse over an unknown entity : " + id);
            return;
         }
         var summonerId:Number = infos.stats.summoner;
         if(infos is GameFightEntityInformation)
         {
            summonerId = (infos as GameFightEntityInformation).masterId;
         }
         for each(entityId in entitiesIdsList)
         {
            if(entityId != id)
            {
               entityInfo = this._entitiesFrame.getEntityInfos(entityId) as GameFightFighterInformations;
               if(entityInfo.stats.summoner == id || summonerId == entityId || entityInfo.stats.summoner == summonerId && summonerId || entityInfo is GameFightEntityInformation && (entityInfo as GameFightEntityInformation).masterId == id)
               {
                  this.highlightAsLinkedEntity(entityId,summonerId == entityId);
               }
            }
         }
         this._currentFighterInfo = infos;
         showInfos = true;
         if(PlayedCharacterManager.getInstance().isSpectator && OptionManager.getOptionManager("dofus")["spectatorAutoShowCurrentFighterInfo"] == true)
         {
            showInfos = this._battleFrame.currentPlayerId != id;
         }
         if(showInfos && highlightTimelineFighter)
         {
            this._timerFighterInfo.reset();
            this._timerFighterInfo.start();
         }
         if(infos.stats.invisibilityState == GameActionFightInvisibilityStateEnum.INVISIBLE)
         {
            _log.info("Mouse over an invisible entity in timeline");
            inviSelection = SelectionManager.getInstance().getSelection(this.INVISIBLE_POSITION_SELECTION);
            if(!inviSelection)
            {
               inviSelection = new Selection();
               inviSelection.color = new Color(52326);
               inviSelection.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_AREA);
               SelectionManager.getInstance().addSelection(inviSelection,this.INVISIBLE_POSITION_SELECTION);
            }
            pos = FightEntitiesFrame.getCurrentInstance().getLastKnownEntityPosition(infos.contextualId);
            if(pos > -1)
            {
               lastMovPoint = FightEntitiesFrame.getCurrentInstance().getLastKnownEntityMovementPoint(infos.contextualId);
               reachableCells = new FightReachableCellsMaker(this._currentFighterInfo,pos,lastMovPoint);
               inviSelection.zone = new Custom(reachableCells.reachableCells);
               SelectionManager.getInstance().update(this.INVISIBLE_POSITION_SELECTION,pos);
            }
            return;
         }
         var fscf:FightSpellCastFrame = Kernel.getWorker().getFrame(FightSpellCastFrame) as FightSpellCastFrame;
         var spell:* = null;
         if(fscf)
         {
            casterCell = this.entitiesFrame.getEntityInfos(CurrentPlayedFighterManager.getInstance().currentFighterId).disposition.cellId;
            for each(eff in fscf.currentSpell.effects)
            {
               if(DamageUtil.verifySpellEffectZone(id,eff,currentCell,casterCell))
               {
                  entityInSpellZone = true;
                  break;
               }
            }
            if(entityInSpellZone || this._spellTargetsTooltips[id])
            {
               spell = fscf.currentSpell;
            }
         }
         var makerParams:Object = {"target":timelineTarget};
         this.displayEntityTooltip(id,spell,null,false,-1,makerParams);
         var movementSelection:Selection = SelectionManager.getInstance().getSelection(FightTurnFrame.SELECTION_PATH);
         if(movementSelection)
         {
            movementSelection.remove();
         }
         if(showRange)
         {
            if(Kernel.getWorker().contains(FightBattleFrame) && !Kernel.getWorker().contains(FightSpellCastFrame))
            {
               this._timerMovementRange.reset();
               this._timerMovementRange.start();
            }
         }
         if(this._lastEffectEntity && this._lastEffectEntity.object is Sprite && this._lastEffectEntity.object != entity)
         {
            Sprite(this._lastEffectEntity.object).filters = [];
         }
         var entitySprite:Sprite = entity as Sprite;
         if(entitySprite)
         {
            fightTurnFrame = Kernel.getWorker().getFrame(FightTurnFrame) as FightTurnFrame;
            myTurn = !!fightTurnFrame?Boolean(fightTurnFrame.myTurn):true;
            if((!fscf || FightSpellCastFrame.isCurrentTargetTargetable()) && myTurn)
            {
               effect = this._overEffectOk;
            }
            else
            {
               effect = this._overEffectKo;
            }
            if(entitySprite.filters.length)
            {
               if(entitySprite.filters[0] != effect)
               {
                  entitySprite.filters = [effect];
               }
            }
            else
            {
               entitySprite.filters = [effect];
            }
            this._lastEffectEntity = new WeakReference(entity);
         }
      }
      
      private function tacticModeHandler(forceOpen:Boolean = false) : void
      {
         if(forceOpen && !TacticModeManager.getInstance().tacticModeActivated)
         {
            TacticModeManager.getInstance().show(PlayedCharacterManager.getInstance().currentMap);
         }
         else if(TacticModeManager.getInstance().tacticModeActivated)
         {
            TacticModeManager.getInstance().hide();
         }
      }
      
      private function onPropertyChanged(pEvent:PropertyChangeEvent) : void
      {
         var entityId:Number = NaN;
         var showInfos:Boolean = false;
         switch(pEvent.propertyName)
         {
            case "showPermanentTargetsTooltips":
               this._showPermanentTooltips = pEvent.propertyValue as Boolean;
               for each(entityId in this._battleFrame.targetedEntities)
               {
                  if(!this._showPermanentTooltips)
                  {
                     TooltipManager.hide("tooltipOverEntity_" + entityId);
                  }
                  else
                  {
                     this.displayEntityTooltip(entityId);
                  }
               }
               break;
            case "spectatorAutoShowCurrentFighterInfo":
               if(PlayedCharacterManager.getInstance().isSpectator)
               {
                  showInfos = pEvent.propertyValue as Boolean;
                  if(!showInfos)
                  {
                     KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,null);
                     break;
                  }
                  KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,FightEntitiesFrame.getCurrentInstance().getEntityInfos(this._battleFrame.currentPlayerId) as GameFightFighterInformations);
                  break;
               }
         }
      }
      
      private function onUiUnloadStarted(pEvent:UiUnloadEvent) : void
      {
         var nameSplit:* = null;
         var entityId:Number = NaN;
         var entity:* = null;
         if(pEvent.name && pEvent.name.indexOf("tooltipOverEntity_") != -1)
         {
            nameSplit = pEvent.name.split("_");
            entityId = nameSplit[nameSplit.length - 1];
            entity = DofusEntities.getEntity(entityId) as AnimatedCharacter;
            if(entity && entity.parent && entity.displayed && this._entitiesFrame.hasIcon(entityId))
            {
               this._entitiesFrame.getIcon(entityId).place(this._entitiesFrame.getIconEntityBounds(entity));
            }
         }
      }
      
      private function onTooltipsOrdered(pEvent:TooltipEvent) : void
      {
         var entityId:Number = NaN;
         var entitiesIds:Vector.<Number> = this.entitiesFrame.getEntitiesIdsList();
         for each(entityId in entitiesIds)
         {
            if(Berilia.getInstance().getUi("tooltip_tooltipOverEntity_" + entityId))
            {
               this._entitiesFrame.updateEntityIconPosition(entityId);
            }
         }
      }
   }
}
