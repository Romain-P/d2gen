package com.ankamagames.dofus.datacenter.misc
{
   import com.ankamagames.jerakine.data.GameData;
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   
   public class TypeAction implements IDataCenter
   {
      
      public static const MODULE:String = "TypeActions";
       
      
      public var id:int;
      
      public var elementName:String;
      
      public var elementId:int;
      
      public function TypeAction()
      {
         super();
      }
      
      public static function getTypeActionById(id:int) : TypeAction
      {
         return GameData.getObject(MODULE,id) as TypeAction;
      }
      
      public static function getAllTypeAction() : Array
      {
         return GameData.getObjects(MODULE);
      }
   }
}
