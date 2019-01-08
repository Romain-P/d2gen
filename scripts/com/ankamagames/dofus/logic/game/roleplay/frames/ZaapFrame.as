package com.ankamagames.dofus.logic.game.roleplay.frames
{
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.datacenter.world.Hint;
   import com.ankamagames.dofus.internalDatacenter.taxi.TeleportDestinationWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.logic.common.actions.ChangeWorldInteractionAction;
   import com.ankamagames.dofus.logic.game.common.frames.ChatFrame;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.logic.game.common.managers.TimeManager;
   import com.ankamagames.dofus.logic.game.roleplay.actions.LeaveDialogRequestAction;
   import com.ankamagames.dofus.logic.game.roleplay.actions.TeleportRequestAction;
   import com.ankamagames.dofus.logic.game.roleplay.actions.ZaapRespawnSaveRequestAction;
   import com.ankamagames.dofus.misc.lists.ChatHookList;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.misc.lists.RoleplayHookList;
   import com.ankamagames.dofus.network.enums.DialogTypeEnum;
   import com.ankamagames.dofus.network.enums.TeleporterTypeEnum;
   import com.ankamagames.dofus.network.messages.game.dialog.LeaveDialogMessage;
   import com.ankamagames.dofus.network.messages.game.dialog.LeaveDialogRequestMessage;
   import com.ankamagames.dofus.network.messages.game.interactive.zaap.TeleportDestinationsListMessage;
   import com.ankamagames.dofus.network.messages.game.interactive.zaap.TeleportRequestMessage;
   import com.ankamagames.dofus.network.messages.game.interactive.zaap.ZaapListMessage;
   import com.ankamagames.dofus.network.messages.game.interactive.zaap.ZaapRespawnSaveRequestMessage;
   import com.ankamagames.dofus.network.messages.game.interactive.zaap.ZaapRespawnUpdatedMessage;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.messages.Message;
   import flash.utils.getQualifiedClassName;
   
   public class ZaapFrame implements Frame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(NpcDialogFrame));
       
      
      private var _priority:int = 0;
      
      private var _spawnMapId:Number;
      
      private var _zaapsList:Array;
      
      public function ZaapFrame()
      {
         super();
      }
      
      public function get spawnMapId() : Number
      {
         return this._spawnMapId;
      }
      
      public function get priority() : int
      {
         return this._priority;
      }
      
      public function set priority(p:int) : void
      {
         this._priority = p;
      }
      
      public function pushed() : Boolean
      {
         this._zaapsList = new Array();
         return true;
      }
      
      public function process(msg:Message) : Boolean
      {
         var zlmsg:* = null;
         var tdlmsg:* = null;
         var destinations:* = null;
         var hints:* = null;
         var hint:* = null;
         var tra:* = null;
         var zrsra:* = null;
         var zrsrmsg:* = null;
         var zrumsg:* = null;
         var ldm:* = null;
         var i:int = 0;
         var trmsg:* = null;
         var zaap:* = null;
         switch(true)
         {
            case msg is ZaapListMessage:
               zlmsg = msg as ZaapListMessage;
               this._zaapsList = new Array();
               for(i = 0; i < zlmsg.mapIds.length; i++)
               {
                  this._zaapsList.push(new TeleportDestinationWrapper(zlmsg.teleporterType,zlmsg.mapIds[i],zlmsg.subAreaIds[i],zlmsg.destTeleporterType[i],zlmsg.costs[i],zlmsg.spawnMapId == zlmsg.mapIds[i]));
               }
               this._spawnMapId = zlmsg.spawnMapId;
               KernelEventsManager.getInstance().processCallback(RoleplayHookList.TeleportDestinationList,this._zaapsList,zlmsg.teleporterType == TeleporterTypeEnum.TELEPORTER_HAVENBAG?TeleporterTypeEnum.TELEPORTER_HAVENBAG:TeleporterTypeEnum.TELEPORTER_ZAAP);
               return true;
            case msg is TeleportDestinationsListMessage:
               tdlmsg = msg as TeleportDestinationsListMessage;
               destinations = new Array();
               for(i = 0; i < tdlmsg.mapIds.length; i++)
               {
                  if(tdlmsg.teleporterType == TeleporterTypeEnum.TELEPORTER_SUBWAY)
                  {
                     hints = TeleportDestinationWrapper.getHintsFromMapId(tdlmsg.mapIds[i]);
                     for each(hint in hints)
                     {
                        destinations.push(new TeleportDestinationWrapper(tdlmsg.teleporterType,tdlmsg.mapIds[i],tdlmsg.subAreaIds[i],TeleporterTypeEnum.TELEPORTER_SUBWAY,tdlmsg.costs[i],false,hint));
                     }
                  }
                  else
                  {
                     destinations.push(new TeleportDestinationWrapper(tdlmsg.teleporterType,tdlmsg.mapIds[i],tdlmsg.subAreaIds[i],tdlmsg.destTeleporterType[i],tdlmsg.costs[i]));
                  }
               }
               KernelEventsManager.getInstance().processCallback(RoleplayHookList.TeleportDestinationList,destinations,tdlmsg.teleporterType);
               return true;
            case msg is TeleportRequestAction:
               tra = msg as TeleportRequestAction;
               if(tra.cost <= PlayedCharacterManager.getInstance().characteristics.kamas)
               {
                  trmsg = new TeleportRequestMessage();
                  trmsg.initTeleportRequestMessage(tra.teleportType,tra.mapId);
                  ConnectionsHandler.getConnection().send(trmsg);
               }
               else
               {
                  KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,I18n.getUiText("ui.popup.not_enough_rich"),ChatFrame.RED_CHANNEL_ID,TimeManager.getInstance().getTimestamp());
               }
               return true;
            case msg is ZaapRespawnSaveRequestAction:
               zrsra = msg as ZaapRespawnSaveRequestAction;
               zrsrmsg = new ZaapRespawnSaveRequestMessage();
               zrsrmsg.initZaapRespawnSaveRequestMessage();
               ConnectionsHandler.getConnection().send(zrsrmsg);
               return true;
            case msg is ZaapRespawnUpdatedMessage:
               zrumsg = msg as ZaapRespawnUpdatedMessage;
               for each(zaap in this._zaapsList)
               {
                  if(zaap.mapId == zrumsg.mapId)
                  {
                     zaap.spawn = true;
                  }
                  else
                  {
                     zaap.spawn = false;
                  }
               }
               this._spawnMapId = zrumsg.mapId;
               KernelEventsManager.getInstance().processCallback(RoleplayHookList.TeleportDestinationList,this._zaapsList,TeleporterTypeEnum.TELEPORTER_ZAAP);
               return true;
            case msg is LeaveDialogRequestAction:
               ConnectionsHandler.getConnection().send(new LeaveDialogRequestMessage());
               return true;
            case msg is LeaveDialogMessage:
               ldm = msg as LeaveDialogMessage;
               if(ldm.dialogType == DialogTypeEnum.DIALOG_TELEPORTER)
               {
                  Kernel.getWorker().process(ChangeWorldInteractionAction.create(true));
                  Kernel.getWorker().removeFrame(this);
               }
               return true;
            default:
               return false;
         }
      }
      
      public function pulled() : Boolean
      {
         KernelEventsManager.getInstance().processCallback(HookList.LeaveDialog);
         return true;
      }
   }
}
