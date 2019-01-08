package com.ankamagames.dofus.pools
{
   import com.ankamagames.jerakine.pools.Poolable;
   import flash.utils.getTimer;
   
   public class PoolableSoundCommand implements Poolable
   {
      
      private static const COMMAND_LIFETIME:uint = 240000;
       
      
      public var method:String;
      
      public var params:Array;
      
      public var creationTime:int;
      
      public function PoolableSoundCommand()
      {
         super();
      }
      
      public function get hasExpired() : Boolean
      {
         return getTimer() - this.creationTime > COMMAND_LIFETIME;
      }
      
      public function init(pMethod:String, pParams:Array) : void
      {
         this.method = pMethod;
         this.params = pParams;
         this.creationTime = getTimer();
      }
      
      public function free() : void
      {
         this.method = null;
         this.params = null;
         this.creationTime = 0;
      }
   }
}
