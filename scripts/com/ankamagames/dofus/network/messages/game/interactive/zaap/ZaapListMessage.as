package com.ankamagames.dofus.network.messages.game.interactive.zaap
{
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.network.utils.FuncTree;
   import flash.utils.ByteArray;
   
   [Trusted]
   public class ZaapListMessage extends TeleportDestinationsListMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 1604;
       
      
      private var _isInitialized:Boolean = false;
      
      public var spawnMapId:Number = 0;
      
      public function ZaapListMessage()
      {
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return super.isInitialized && this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 1604;
      }
      
      public function initZaapListMessage(teleporterType:uint = 0, mapIds:Vector.<Number> = null, subAreaIds:Vector.<uint> = null, costs:Vector.<uint> = null, destTeleporterType:Vector.<uint> = null, spawnMapId:Number = 0) : ZaapListMessage
      {
         super.initTeleportDestinationsListMessage(teleporterType,mapIds,subAreaIds,costs,destTeleporterType);
         this.spawnMapId = spawnMapId;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         super.reset();
         this.spawnMapId = 0;
         this._isInitialized = false;
      }
      
      override public function pack(output:ICustomDataOutput) : void
      {
         var data:ByteArray = new ByteArray();
         this.serialize(new CustomDataWrapper(data));
         writePacket(output,this.getMessageId(),data);
      }
      
      override public function unpack(input:ICustomDataInput, length:uint) : void
      {
         this.deserialize(input);
      }
      
      override public function unpackAsync(input:ICustomDataInput, length:uint) : FuncTree
      {
         var tree:FuncTree = new FuncTree();
         tree.setRoot(input);
         this.deserializeAsync(tree);
         return tree;
      }
      
      override public function serialize(output:ICustomDataOutput) : void
      {
         this.serializeAs_ZaapListMessage(output);
      }
      
      public function serializeAs_ZaapListMessage(output:ICustomDataOutput) : void
      {
         super.serializeAs_TeleportDestinationsListMessage(output);
         if(this.spawnMapId < 0 || this.spawnMapId > 9007199254740990)
         {
            throw new Error("Forbidden value (" + this.spawnMapId + ") on element spawnMapId.");
         }
         output.writeDouble(this.spawnMapId);
      }
      
      override public function deserialize(input:ICustomDataInput) : void
      {
         this.deserializeAs_ZaapListMessage(input);
      }
      
      public function deserializeAs_ZaapListMessage(input:ICustomDataInput) : void
      {
         super.deserialize(input);
         this._spawnMapIdFunc(input);
      }
      
      override public function deserializeAsync(tree:FuncTree) : void
      {
         this.deserializeAsyncAs_ZaapListMessage(tree);
      }
      
      public function deserializeAsyncAs_ZaapListMessage(tree:FuncTree) : void
      {
         super.deserializeAsync(tree);
         tree.addChild(this._spawnMapIdFunc);
      }
      
      private function _spawnMapIdFunc(input:ICustomDataInput) : void
      {
         this.spawnMapId = input.readDouble();
         if(this.spawnMapId < 0 || this.spawnMapId > 9007199254740990)
         {
            throw new Error("Forbidden value (" + this.spawnMapId + ") on element of ZaapListMessage.spawnMapId.");
         }
      }
   }
}
