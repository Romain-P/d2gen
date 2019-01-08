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
   public class TeleportDestinationsListMessage extends NetworkMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 5960;
       
      
      private var _isInitialized:Boolean = false;
      
      public var teleporterType:uint = 0;
      
      public var mapIds:Vector.<Number>;
      
      public var subAreaIds:Vector.<uint>;
      
      public var costs:Vector.<uint>;
      
      public var destTeleporterType:Vector.<uint>;
      
      private var _mapIdstree:FuncTree;
      
      private var _subAreaIdstree:FuncTree;
      
      private var _coststree:FuncTree;
      
      private var _destTeleporterTypetree:FuncTree;
      
      public function TeleportDestinationsListMessage()
      {
         this.mapIds = new Vector.<Number>();
         this.subAreaIds = new Vector.<uint>();
         this.costs = new Vector.<uint>();
         this.destTeleporterType = new Vector.<uint>();
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 5960;
      }
      
      public function initTeleportDestinationsListMessage(teleporterType:uint = 0, mapIds:Vector.<Number> = null, subAreaIds:Vector.<uint> = null, costs:Vector.<uint> = null, destTeleporterType:Vector.<uint> = null) : TeleportDestinationsListMessage
      {
         this.teleporterType = teleporterType;
         this.mapIds = mapIds;
         this.subAreaIds = subAreaIds;
         this.costs = costs;
         this.destTeleporterType = destTeleporterType;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         this.teleporterType = 0;
         this.mapIds = new Vector.<Number>();
         this.subAreaIds = new Vector.<uint>();
         this.costs = new Vector.<uint>();
         this.destTeleporterType = new Vector.<uint>();
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
         this.serializeAs_TeleportDestinationsListMessage(output);
      }
      
      public function serializeAs_TeleportDestinationsListMessage(output:ICustomDataOutput) : void
      {
         output.writeByte(this.teleporterType);
         output.writeShort(this.mapIds.length);
         for(var _i2:int = 0; _i2 < this.mapIds.length; _i2++)
         {
            if(this.mapIds[_i2] < 0 || this.mapIds[_i2] > 9007199254740990)
            {
               throw new Error("Forbidden value (" + this.mapIds[_i2] + ") on element 2 (starting at 1) of mapIds.");
            }
            output.writeDouble(this.mapIds[_i2]);
         }
         output.writeShort(this.subAreaIds.length);
         for(var _i3:int = 0; _i3 < this.subAreaIds.length; _i3++)
         {
            if(this.subAreaIds[_i3] < 0)
            {
               throw new Error("Forbidden value (" + this.subAreaIds[_i3] + ") on element 3 (starting at 1) of subAreaIds.");
            }
            output.writeVarShort(this.subAreaIds[_i3]);
         }
         output.writeShort(this.costs.length);
         for(var _i4:int = 0; _i4 < this.costs.length; _i4++)
         {
            if(this.costs[_i4] < 0)
            {
               throw new Error("Forbidden value (" + this.costs[_i4] + ") on element 4 (starting at 1) of costs.");
            }
            output.writeVarShort(this.costs[_i4]);
         }
         output.writeShort(this.destTeleporterType.length);
         for(var _i5:int = 0; _i5 < this.destTeleporterType.length; _i5++)
         {
            output.writeByte(this.destTeleporterType[_i5]);
         }
      }
      
      public function deserialize(input:ICustomDataInput) : void
      {
         this.deserializeAs_TeleportDestinationsListMessage(input);
      }
      
      public function deserializeAs_TeleportDestinationsListMessage(input:ICustomDataInput) : void
      {
         var _val2:Number = NaN;
         var _val3:* = 0;
         var _val4:* = 0;
         var _val5:* = 0;
         this._teleporterTypeFunc(input);
         var _mapIdsLen:uint = input.readUnsignedShort();
         for(var _i2:int = 0; _i2 < _mapIdsLen; _i2++)
         {
            _val2 = input.readDouble();
            if(_val2 < 0 || _val2 > 9007199254740990)
            {
               throw new Error("Forbidden value (" + _val2 + ") on elements of mapIds.");
            }
            this.mapIds.push(_val2);
         }
         var _subAreaIdsLen:uint = input.readUnsignedShort();
         for(var _i3:int = 0; _i3 < _subAreaIdsLen; _i3++)
         {
            _val3 = uint(input.readVarUhShort());
            if(_val3 < 0)
            {
               throw new Error("Forbidden value (" + _val3 + ") on elements of subAreaIds.");
            }
            this.subAreaIds.push(_val3);
         }
         var _costsLen:uint = input.readUnsignedShort();
         for(var _i4:int = 0; _i4 < _costsLen; _i4++)
         {
            _val4 = uint(input.readVarUhShort());
            if(_val4 < 0)
            {
               throw new Error("Forbidden value (" + _val4 + ") on elements of costs.");
            }
            this.costs.push(_val4);
         }
         var _destTeleporterTypeLen:uint = input.readUnsignedShort();
         for(var _i5:int = 0; _i5 < _destTeleporterTypeLen; _i5++)
         {
            _val5 = uint(input.readByte());
            if(_val5 < 0)
            {
               throw new Error("Forbidden value (" + _val5 + ") on elements of destTeleporterType.");
            }
            this.destTeleporterType.push(_val5);
         }
      }
      
      public function deserializeAsync(tree:FuncTree) : void
      {
         this.deserializeAsyncAs_TeleportDestinationsListMessage(tree);
      }
      
      public function deserializeAsyncAs_TeleportDestinationsListMessage(tree:FuncTree) : void
      {
         tree.addChild(this._teleporterTypeFunc);
         this._mapIdstree = tree.addChild(this._mapIdstreeFunc);
         this._subAreaIdstree = tree.addChild(this._subAreaIdstreeFunc);
         this._coststree = tree.addChild(this._coststreeFunc);
         this._destTeleporterTypetree = tree.addChild(this._destTeleporterTypetreeFunc);
      }
      
      private function _teleporterTypeFunc(input:ICustomDataInput) : void
      {
         this.teleporterType = input.readByte();
         if(this.teleporterType < 0)
         {
            throw new Error("Forbidden value (" + this.teleporterType + ") on element of TeleportDestinationsListMessage.teleporterType.");
         }
      }
      
      private function _mapIdstreeFunc(input:ICustomDataInput) : void
      {
         var length:uint = input.readUnsignedShort();
         for(var i:int = 0; i < length; i++)
         {
            this._mapIdstree.addChild(this._mapIdsFunc);
         }
      }
      
      private function _mapIdsFunc(input:ICustomDataInput) : void
      {
         var _val:Number = input.readDouble();
         if(_val < 0 || _val > 9007199254740990)
         {
            throw new Error("Forbidden value (" + _val + ") on elements of mapIds.");
         }
         this.mapIds.push(_val);
      }
      
      private function _subAreaIdstreeFunc(input:ICustomDataInput) : void
      {
         var length:uint = input.readUnsignedShort();
         for(var i:int = 0; i < length; i++)
         {
            this._subAreaIdstree.addChild(this._subAreaIdsFunc);
         }
      }
      
      private function _subAreaIdsFunc(input:ICustomDataInput) : void
      {
         var _val:uint = input.readVarUhShort();
         if(_val < 0)
         {
            throw new Error("Forbidden value (" + _val + ") on elements of subAreaIds.");
         }
         this.subAreaIds.push(_val);
      }
      
      private function _coststreeFunc(input:ICustomDataInput) : void
      {
         var length:uint = input.readUnsignedShort();
         for(var i:int = 0; i < length; i++)
         {
            this._coststree.addChild(this._costsFunc);
         }
      }
      
      private function _costsFunc(input:ICustomDataInput) : void
      {
         var _val:uint = input.readVarUhShort();
         if(_val < 0)
         {
            throw new Error("Forbidden value (" + _val + ") on elements of costs.");
         }
         this.costs.push(_val);
      }
      
      private function _destTeleporterTypetreeFunc(input:ICustomDataInput) : void
      {
         var length:uint = input.readUnsignedShort();
         for(var i:int = 0; i < length; i++)
         {
            this._destTeleporterTypetree.addChild(this._destTeleporterTypeFunc);
         }
      }
      
      private function _destTeleporterTypeFunc(input:ICustomDataInput) : void
      {
         var _val:uint = input.readByte();
         if(_val < 0)
         {
            throw new Error("Forbidden value (" + _val + ") on elements of destTeleporterType.");
         }
         this.destTeleporterType.push(_val);
      }
   }
}
