package com.ankamagames.dofus.pools
{
   import com.ankamagames.jerakine.pools.Pool;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   
   public class PoolsManager
   {
      
      private static var _self:PoolsManager;
       
      
      private var _soundCommandsContainerPool:Pool;
      
      public function PoolsManager()
      {
         super();
         if(_self)
         {
            throw new SingletonError("Direct initialization of singleton is forbidden. Please access PoolsManager using the getInstance method.");
         }
      }
      
      public static function getInstance() : PoolsManager
      {
         if(_self == null)
         {
            _self = new PoolsManager();
         }
         return _self;
      }
      
      public function getSoundCommandPool() : Pool
      {
         if(this._soundCommandsContainerPool == null)
         {
            this._soundCommandsContainerPool = new Pool(PoolableSoundCommand,20,10);
         }
         return this._soundCommandsContainerPool;
      }
   }
}
