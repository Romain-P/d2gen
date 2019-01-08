package com.ankamagames.dofus.network.messages.game.interactive.zaap
{
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.network.NetworkMessage;
   import com.ankamagames.jerakine.network.utils.FuncTree;
   import flash.utils.ByteArray;
   
   [Trusted]
   public class TeleportRequestMessage extends NetworkMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 5961;
       
      
      private var _isInitialized:Boolean = false;
      
      public var teleporterType:uint = 0;
      
      public var mapId:Number = 0;
      
      public function TeleportRequestMessage()
      {
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 5961;
      }
      
      public function initTeleportRequestMessage(teleporterType:uint = 0, mapId:Number = 0) : TeleportRequestMessage
      {
         this.teleporterType = teleporterType;
         this.mapId = mapId;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         this.teleporterType = 0;
         this.mapId = 0;
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
      
      public function serialize(output:ICustomDataOutput) : void
      {
         this.serializeAs_TeleportRequestMessage(output);
      }
      
      public function serializeAs_TeleportRequestMessage(output:ICustomDataOutput) : void
      {
         output.writeByte(this.teleporterType);
         if(this.mapId < 0 || this.mapId > 9007199254740990)
         {
            throw new Error("Forbidden value (" + this.mapId + ") on element mapId.");
         }
         output.writeDouble(this.mapId);
      }
      
      public function deserialize(input:ICustomDataInput) : void
      {
         this.deserializeAs_TeleportRequestMessage(input);
      }
      
      public function deserializeAs_TeleportRequestMessage(input:ICustomDataInput) : void
      {
         this._teleporterTypeFunc(input);
         this._mapIdFunc(input);
      }
      
      public function deserializeAsync(tree:FuncTree) : void
      {
         this.deserializeAsyncAs_TeleportRequestMessage(tree);
      }
      
      public function deserializeAsyncAs_TeleportRequestMessage(tree:FuncTree) : void
      {
         tree.addChild(this._teleporterTypeFunc);
         tree.addChild(this._mapIdFunc);
      }
      
      private function _teleporterTypeFunc(input:ICustomDataInput) : void
      {
         this.teleporterType = input.readByte();
         if(this.teleporterType < 0)
         {
            throw new Error("Forbidden value (" + this.teleporterType + ") on element of TeleportRequestMessage.teleporterType.");
         }
      }
      
      private function _mapIdFunc(input:ICustomDataInput) : void
      {
         this.mapId = input.readDouble();
         if(this.mapId < 0 || this.mapId > 9007199254740990)
         {
            throw new Error("Forbidden value (" + this.mapId + ") on element of TeleportRequestMessage.mapId.");
         }
      }
   }
}
