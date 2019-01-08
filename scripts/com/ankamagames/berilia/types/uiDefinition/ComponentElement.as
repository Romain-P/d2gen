package com.ankamagames.berilia.types.uiDefinition
{
   import flash.utils.Dictionary;
   
   public class ComponentElement extends BasicElement
   {
      
      public static var MEMORY_LOG:Dictionary = new Dictionary(true);
       
      
      public function ComponentElement()
      {
         super();
         MEMORY_LOG["[object ComponentElement]"] = 1;
      }
   }
}
