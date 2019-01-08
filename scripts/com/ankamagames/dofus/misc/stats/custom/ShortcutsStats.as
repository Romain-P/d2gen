package com.ankamagames.dofus.misc.stats.custom
{
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.berilia.managers.BindsManager;
   import com.ankamagames.berilia.types.data.Hook;
   import com.ankamagames.berilia.types.graphic.UiRootContainer;
   import com.ankamagames.berilia.types.listener.GenericListener;
   import com.ankamagames.berilia.types.messages.AllModulesLoadedMessage;
   import com.ankamagames.berilia.utils.BeriliaHookList;
   import com.ankamagames.dofus.logic.common.actions.ChangeCharacterAction;
   import com.ankamagames.dofus.logic.common.actions.ChangeServerAction;
   import com.ankamagames.dofus.logic.common.actions.ResetGameAction;
   import com.ankamagames.dofus.logic.common.managers.PlayerManager;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.misc.stats.IHookStats;
   import com.ankamagames.dofus.misc.stats.IStatsClass;
   import com.ankamagames.dofus.misc.stats.StatsAction;
   import com.ankamagames.dofus.misc.utils.HaapiKeyManager;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.messages.Message;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class ShortcutsStats implements IHookStats, IStatsClass
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(ShortcutsStats));
      
      private static const USE_SHORTCUT_EVENT_ID:uint = 670;
      
      public static const SHORTCUTS:Object = {
         "openCharacterSheet":"characterSheetUi",
         "openBookSpell":"spellList",
         "openInventory":"equipment",
         "openBookQuest":"questBase",
         "openWorldMap":"cartographyUi",
         "openSocialFriends":"friends",
         "openSocialGuild":"guildMembers",
         "openSocialAlliance":"alliance",
         "openSocialSpouse":"spouse",
         "openPvpArena":"pvpArena",
         "openWebBrowser":"webBase",
         "openBookJob":"jobTab",
         "openMount":"mountInfo",
         "toggleRide":null,
         "openSell":"itemMyselfVendor",
         "openAlmanax":"calendarTab",
         "openAchievement":"achievementTab",
         "openTitle":"titleTab",
         "openBestiary":"bestiaryTab",
         "openIdols":"idolsTab",
         "openBookAlignment":"alignmentTab",
         "openHavenbag":null,
         "openBuild":null,
         "shiftCloseUi":null,
         "optionMenu1":"optionContainer",
         "showGrid":null,
         "transparancyMode":null,
         "foldAll":null,
         "showCoord":null,
         "toggleDematerialization":null,
         "cellSelectionOnly":null,
         "showAllNames":null,
         "showEntitiesTooltips":null,
         "highlightInteractiveElements":null,
         "showFightPositions":null
      };
       
      
      private var _usedShortcuts:Dictionary;
      
      private var _shortcutsData:Dictionary;
      
      private var _action:StatsAction;
      
      private var _shortcutsList:Object;
      
      public function ShortcutsStats(pArgs:Array)
      {
         this._usedShortcuts = new Dictionary();
         this._shortcutsData = new Dictionary();
         this._shortcutsList = new Object();
         super();
      }
      
      public function onHook(pHook:Hook, pArgs:Array) : void
      {
         var shortcutName:* = undefined;
         var useShortcut:Boolean = false;
         var uiName:* = undefined;
         var tooltipUi:* = null;
         if(pHook.name == BeriliaHookList.KeyDown.name && pArgs[1] == Keyboard.CONTROL)
         {
            for(uiName in Berilia.getInstance().uiList)
            {
               if(uiName == "tooltip_standard")
               {
                  tooltipUi = Berilia.getInstance().getUi("tooltip_standard");
                  if(tooltipUi && getQualifiedClassName(tooltipUi.uiClass).split("::")[1] == "ItemTooltipUi")
                  {
                     useShortcut = true;
                  }
               }
               else if(uiName.indexOf("_pin@") != -1)
               {
                  useShortcut = true;
               }
               if(useShortcut)
               {
                  this.onShortcut("showTheoreticalEffects");
                  break;
               }
            }
         }
         else if(pHook.name == BeriliaHookList.UiLoaded.name)
         {
            for(shortcutName in SHORTCUTS)
            {
               if(pArgs[0] == SHORTCUTS[shortcutName] && !this._usedShortcuts[shortcutName])
               {
                  this.onShortcut(shortcutName,false);
               }
            }
         }
         else if(pHook.name == BeriliaHookList.UiUnloaded.name)
         {
            for(shortcutName in SHORTCUTS)
            {
               if(pArgs[0] == SHORTCUTS[shortcutName])
               {
                  this._usedShortcuts[shortcutName] = false;
               }
            }
         }
      }
      
      public function process(pMessage:Message, pArgs:Array = null) : void
      {
         if(pMessage is AllModulesLoadedMessage)
         {
            BindsManager.getInstance().registerEvent(new GenericListener("ALL","ShortcutsStats",this.onShortcut,int.MAX_VALUE));
         }
         else if(this._action && (pMessage is ChangeCharacterAction || pMessage is ChangeServerAction || pMessage is ResetGameAction))
         {
            this._action.sendOnExit = false;
            this._action.send();
         }
      }
      
      public function remove() : void
      {
      }
      
      private function onShortcut(pShortcutName:String, pFromKeyboard:Boolean = true) : Boolean
      {
         if(!this._usedShortcuts[pShortcutName] && SHORTCUTS.hasOwnProperty(pShortcutName))
         {
            if(!this._shortcutsData[pShortcutName])
            {
               this._shortcutsData[pShortcutName] = {
                  "numfromShortcut":0,
                  "numfromUi":0
               };
               this._shortcutsList[pShortcutName] = new Object();
               this._shortcutsList[pShortcutName]["use"] = 0;
               this._shortcutsList[pShortcutName]["ratio"] = 0;
            }
            if(pFromKeyboard)
            {
               this._shortcutsData[pShortcutName].numfromShortcut++;
            }
            else
            {
               this._shortcutsData[pShortcutName].numfromUi++;
            }
            this._shortcutsList[pShortcutName]["use"] = this._shortcutsData[pShortcutName].numfromShortcut + this._shortcutsData[pShortcutName].numfromUi;
            this._shortcutsList[pShortcutName]["ratio"] = this._shortcutsData[pShortcutName].numfromShortcut / this._shortcutsList[pShortcutName]["use"];
            this._usedShortcuts[pShortcutName] = true;
            if(!this._action)
            {
               this._action = new StatsAction(USE_SHORTCUT_EVENT_ID,false,false,false,true);
               this._action.gameSessionId = HaapiKeyManager.getInstance().getGameSessionId();
               this._action.setParam("account_id",PlayerManager.getInstance().accountId);
               this._action.setParam("character_id",PlayedCharacterManager.getInstance().extractedServerCharacterIdFromInterserverCharacterId);
               this._action.setParam("character_level",PlayedCharacterManager.getInstance().infos.level);
               this._action.setParam("keyboard",BindsManager.getInstance().currentLocale);
               this._action.setParam("shortcuts_list",this._shortcutsList);
               this._action.send();
            }
         }
         else
         {
            this._usedShortcuts[pShortcutName] = false;
         }
         return false;
      }
   }
}
