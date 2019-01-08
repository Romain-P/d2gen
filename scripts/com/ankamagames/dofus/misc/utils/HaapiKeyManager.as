package com.ankamagames.dofus.misc.utils
{
   import com.ankama.codegen.client.api.AccountApi;
   import com.ankama.codegen.client.api.ApiClient;
   import com.ankama.codegen.client.api.event.ApiClientEvent;
   import com.ankama.codegen.client.model.Token;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.misc.utils.events.AccountSessionReadyEvent;
   import com.ankamagames.dofus.misc.utils.events.ApiKeyReadyEvent;
   import com.ankamagames.dofus.misc.utils.events.GameSessionReadyEvent;
   import com.ankamagames.dofus.misc.utils.events.TokenReadyEvent;
   import com.ankamagames.dofus.network.messages.web.haapi.HaapiApiKeyRequestMessage;
   import com.ankamagames.jerakine.interfaces.IDestroyable;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class HaapiKeyManager extends EventDispatcher implements IDestroyable
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(HaapiKeyManager));
      
      private static var _instance:HaapiKeyManager;
       
      
      private var _apiKey:String = null;
      
      private var _gameSessionId:Number = 0;
      
      private var _accountSessionId:String = null;
      
      private var _tokens:Dictionary;
      
      private var _askedApiKey:Boolean = false;
      
      private var _askedTokens:Vector.<int>;
      
      private var _accountApi:AccountApi;
      
      public function HaapiKeyManager()
      {
         this._tokens = new Dictionary();
         this._askedTokens = new Vector.<int>();
         super();
         var accountClient:ApiClient = new ApiClient();
         accountClient.setBasePath("https://haapi.ankama." + RpcServiceCenter.getInstance().apiDomainExtension + "/json/Ankama/v2");
         this._accountApi = new AccountApi(accountClient);
         this._accountApi.getApiClient().addEventListener(ApiClientEvent.API_CALL_RESULT,this.onAccountApiCallResult);
         this._accountApi.getApiClient().addEventListener(ApiClientEvent.API_CALL_ERROR,this.onAccountApiCallError);
      }
      
      public static function getInstance() : HaapiKeyManager
      {
         if(!_instance)
         {
            _instance = new HaapiKeyManager();
         }
         return _instance;
      }
      
      private function onAccountApiCallError(event:ApiClientEvent) : void
      {
         if(event.result != null)
         {
            _log.debug("Account Api Error : " + event.errorMsg);
            this.nextToken();
         }
      }
      
      private function onAccountApiCallResult(event:ApiClientEvent) : void
      {
         var token:* = null;
         var gameId:int = 0;
         if(event.result is Token)
         {
            token = Token(event.result).token;
            gameId = this._askedTokens.shift();
            this._tokens[gameId] = token;
            dispatchEvent(new TokenReadyEvent(gameId));
            this.nextToken();
         }
      }
      
      public function getApiKey() : String
      {
         return this._apiKey;
      }
      
      public function getAccountSessionId() : String
      {
         return this._accountSessionId;
      }
      
      public function getGameSessionId() : Number
      {
         return this._gameSessionId;
      }
      
      public function pullToken(gameId:int) : String
      {
         if(!this._tokens[gameId])
         {
            _log.error("No token available for gameID " + GameID.getName(gameId));
            return null;
         }
         var value:String = this._tokens[gameId];
         delete this._tokens[gameId];
         return value;
      }
      
      public function askToken(gameId:int) : void
      {
         if(this._askedTokens.indexOf(gameId) != -1)
         {
            return;
         }
         this._askedTokens.push(gameId);
         if(!this._apiKey)
         {
            if(!this._askedApiKey)
            {
               this.askApiKey();
            }
         }
         else if(this._askedTokens.length == 1)
         {
            this.nextToken();
         }
      }
      
      private function nextToken() : void
      {
         if(this._askedTokens.length > 0)
         {
            this._accountApi.createTokenApiCall(this._askedTokens[0]);
         }
      }
      
      public function askApiKey() : void
      {
         if(this._askedApiKey)
         {
            return;
         }
         ConnectionsHandler.getConnection().send(new HaapiApiKeyRequestMessage());
         this._askedApiKey = true;
      }
      
      public function saveApiKey(pHaapiKey:String) : void
      {
         this._apiKey = pHaapiKey;
         this._askedApiKey = false;
         this._accountApi.getApiClient().setApiKey(this._apiKey);
         dispatchEvent(new ApiKeyReadyEvent(pHaapiKey));
         this.nextToken();
      }
      
      public function saveGameSessionId(key:String) : void
      {
         this._gameSessionId = parseInt(key);
         dispatchEvent(new GameSessionReadyEvent(this._gameSessionId));
      }
      
      public function saveAccountSessionId(key:String) : void
      {
         this._accountSessionId = key;
         dispatchEvent(new AccountSessionReadyEvent(this._accountSessionId));
      }
      
      public function destroy() : void
      {
         this._accountApi.getApiClient().removeEventListener(ApiClientEvent.API_CALL_RESULT,this.onAccountApiCallResult);
         this._accountApi.getApiClient().removeEventListener(ApiClientEvent.API_CALL_ERROR,this.onAccountApiCallError);
         _instance = null;
      }
   }
}
