package com.ankamagames.dofus.misc.utils.events
{
   import flash.events.Event;
   
   public class ApiKeyReadyEvent extends Event
   {
      
      public static const READY:String = "READY";
       
      
      private var _haapiKey:String;
      
      public function ApiKeyReadyEvent(haapiKey:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this._haapiKey = haapiKey;
         super(READY,bubbles,cancelable);
      }
      
      public function get haapiKey() : String
      {
         return this._haapiKey;
      }
   }
}
