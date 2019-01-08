package com.ankamagames.dofus.kernel.sound.manager
{
   import com.ankamagames.dofus.BuildInfos;
   import com.ankamagames.dofus.kernel.sound.SoundManager;
   import com.ankamagames.dofus.network.enums.BuildTypeEnum;
   import com.ankamagames.dofus.pools.PoolableSoundCommand;
   import com.ankamagames.dofus.pools.PoolsManager;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.protocolAudio.ProtocolEnum;
   import com.ankamagames.jerakine.utils.misc.CallWithParameters;
   import com.ankamagames.jerakine.utils.system.CommandLineArguments;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.Socket;
   import flash.utils.clearTimeout;
   import flash.utils.getQualifiedClassName;
   import flash.utils.setTimeout;
   
   public class RegConnectionManager
   {
      
      private static var _log:Logger = Log.getLogger(getQualifiedClassName(RegConnectionManager));
      
      private static var _self:RegConnectionManager;
       
      
      private var _sock:Socket;
      
      private var _legacySock:Socket;
      
      private var _socketClientID:uint;
      
      private var _socketAvaible:Boolean;
      
      private var _buffer:Vector.<PoolableSoundCommand>;
      
      private var _isMain:Boolean = true;
      
      private var _retryTimeout:uint;
      
      public function RegConnectionManager(pSingletonEnforcer:SingletonEnforcer)
      {
         super();
         if(_self)
         {
            throw new Error("RegConnectionManager is a Singleton");
         }
         this.init();
      }
      
      public static function getInstance() : RegConnectionManager
      {
         if(_self == null)
         {
            _self = new RegConnectionManager(new SingletonEnforcer());
         }
         return _self;
      }
      
      public function get socketClientID() : uint
      {
         return this._socketClientID;
      }
      
      public function get socketAvailable() : Boolean
      {
         return this._socketAvaible;
      }
      
      public function get isMain() : Boolean
      {
         return this._isMain;
      }
      
      public function send(pMethodName:String, ... params) : void
      {
         var data:* = null;
         var soundCmd:* = null;
         if(!this._socketAvaible)
         {
            this.updateBuffer();
            soundCmd = PoolsManager.getInstance().getSoundCommandPool().checkOut() as PoolableSoundCommand;
            soundCmd.init(pMethodName,params);
            this._buffer.push(soundCmd);
            return;
         }
         if(pMethodName == ProtocolEnum.SAY_GOODBYE)
         {
            data = String(0) + "=>" + pMethodName + "();" + this._socketClientID + "=>" + ProtocolEnum.PLAY_SOUND + "(10,100)|";
         }
         else
         {
            data = this._socketClientID + "=>" + pMethodName + "(" + params + ")|";
         }
         this._sock.writeUTFBytes(data);
         this._sock.flush();
         if(this._legacySock && this._legacySock.connected)
         {
            this._legacySock.writeUTFBytes(data);
            this._legacySock.flush();
         }
      }
      
      private function init() : void
      {
         this._socketClientID = uint.MAX_VALUE * Math.random();
         this.connect();
         if(CommandLineArguments.getInstance().hasArgument("reg-client-port"))
         {
            this._legacySock = new Socket();
            this._legacySock.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void
            {
            });
            this._legacySock.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function(e:SecurityErrorEvent):void
            {
            });
            this._legacySock.connect("127.0.0.1",int(CommandLineArguments.getInstance().getArgument("reg-client-port")));
         }
         this._buffer = new Vector.<PoolableSoundCommand>();
      }
      
      private function connect() : void
      {
         var portsFile:File = new File(File.applicationStorageDirectory.nativePath).parent.parent.resolvePath("RegPorts-" + BuildInfos.BUILD_TYPE);
         if(!portsFile.exists)
         {
            _log.error("no Reg port available");
            this.retry();
            return;
         }
         var portsFileStream:FileStream = new FileStream();
         portsFileStream.open(portsFile,FileMode.READ);
         var ports:Array = portsFileStream.readUTF().split("/");
         portsFileStream.close();
         _log.debug("init socket");
         if(this._sock != null)
         {
            this.removeListeners(this._sock);
            if(this._sock.connected)
            {
               this._sock.close();
            }
         }
         this._sock = new Socket();
         this.addListeners(this._sock);
         this._sock.connect(ports[0],int(ports[1]));
      }
      
      private function addListeners(socket:Socket) : void
      {
         socket.addEventListener(ProgressEvent.SOCKET_DATA,this.onData);
         socket.addEventListener(Event.CONNECT,this.onSocketConnect);
         socket.addEventListener(Event.CLOSE,this.onSocketClose);
         socket.addEventListener(IOErrorEvent.IO_ERROR,this.onSocketError);
         socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSocketSecurityError);
      }
      
      private function removeListeners(socket:Socket) : void
      {
         socket.removeEventListener(ProgressEvent.SOCKET_DATA,this.onData);
         socket.removeEventListener(Event.CONNECT,this.onSocketConnect);
         socket.removeEventListener(Event.CLOSE,this.onSocketClose);
         socket.removeEventListener(IOErrorEvent.IO_ERROR,this.onSocketError);
         socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSocketSecurityError);
      }
      
      private function setAsMain(pMain:Boolean) : void
      {
         if(pMain == this._isMain)
         {
            return;
         }
         this._isMain = pMain;
         if(pMain == true)
         {
            _log.warn("[" + this._socketClientID + "] Je passe en main");
            if(SoundManager.getInstance().manager is RegSoundManager)
            {
               (SoundManager.getInstance().manager as RegSoundManager).playMainClientSounds();
            }
         }
         else
         {
            _log.warn("[" + this._socketClientID + "] Je ne suis plus main");
            if(SoundManager.getInstance().manager is RegSoundManager)
            {
               (SoundManager.getInstance().manager as RegSoundManager).stopMainClientSounds();
            }
         }
      }
      
      private function updateBuffer() : void
      {
         while(this._buffer.length)
         {
            if(this._buffer[0].hasExpired)
            {
               PoolsManager.getInstance().getSoundCommandPool().checkIn(this._buffer.shift());
               continue;
            }
            break;
         }
      }
      
      private function onSocketClose(e:Event) : void
      {
         this._socketAvaible = false;
         _log.error("The socket has been closed");
         this.retry();
      }
      
      private function onData(pEvent:ProgressEvent) : void
      {
         var cmd:* = null;
         var functionName:* = null;
         var clientId:Number = NaN;
         var soundID:int = 0;
         var cmds:Array = this._sock.readUTFBytes(pEvent.bytesLoaded).split("|");
         for each(cmd in cmds)
         {
            if(cmd == "")
            {
               return;
            }
            functionName = cmd.split("(")[0];
            switch(functionName)
            {
               case ProtocolEnum.PING:
                  this.send(ProtocolEnum.PONG);
                  continue;
               case ProtocolEnum.MAIN_CLIENT_IS:
                  clientId = Number(cmd.split(":")[1]);
                  if(clientId == this._socketClientID)
                  {
                     this.setAsMain(true);
                  }
                  else
                  {
                     this.setAsMain(false);
                  }
                  continue;
               case ProtocolEnum.ENDOFSONG:
                  soundID = Number(cmd.split(":")[1]);
                  if(this._isMain)
                  {
                     SoundManager.getInstance().manager.endOfSound(soundID);
                  }
               default:
                  continue;
            }
         }
      }
      
      private function onSocketError(e:IOErrorEvent) : void
      {
         this._socketAvaible = false;
         if(BuildInfos.BUILD_TYPE != BuildTypeEnum.DEBUG)
         {
            _log.error("Connection to Reg failed. " + e.text);
         }
         this.retry();
      }
      
      private function onSocketSecurityError(e:SecurityErrorEvent) : void
      {
         this._socketAvaible = false;
         _log.error("Connection to Reg failed. " + e.text);
         this.retry();
      }
      
      private function retry() : void
      {
         clearTimeout(this._retryTimeout);
         this._retryTimeout = setTimeout(this.connect,2000);
      }
      
      private function onSocketConnect(e:Event) : void
      {
         var cmd:* = null;
         this._socketAvaible = true;
         if(SoundManager.getInstance().manager is RegSoundManager)
         {
            RegSoundManager(SoundManager.getInstance().manager).sayHello();
         }
         if(this._buffer && this._buffer.length)
         {
            while(this._buffer.length)
            {
               cmd = this._buffer.shift();
               CallWithParameters.call(this.send,([cmd.method] as Array).concat(cmd.params));
               PoolsManager.getInstance().getSoundCommandPool().checkIn(cmd);
            }
         }
      }
   }
}

class SingletonEnforcer
{
    
   
   function SingletonEnforcer()
   {
      super();
   }
}
