package com.ankamagames.tiphon.types
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class EquipmentSprite extends DynamicSprite
   {
      
      public static var enableLiveReference:Boolean = false;
      
      public static var liveReference:Dictionary = new Dictionary(false);
      
      private static const _handlerRef:Dictionary = new Dictionary(true);
       
      
      public function EquipmentSprite()
      {
         super();
      }
      
      public function updateTransform() : void
      {
         if(_handlerRef["[object EquipmentSprite]"])
         {
            this.makeChild(_handlerRef["[object EquipmentSprite]"]);
         }
      }
      
      override public function init(handler:IAnimationSpriteHandler) : void
      {
         if(getQualifiedClassName(parent) == getQualifiedClassName(this))
         {
            return;
         }
         var c:DisplayObject = this.makeChild(handler);
         if(c && enableLiveReference)
         {
            if(!liveReference[getQualifiedClassName(c)])
            {
               liveReference[getQualifiedClassName(c)] = new Dictionary(true);
            }
            liveReference[getQualifiedClassName(c)]["[object EquipmentSprite]"] = 1;
            _handlerRef["[object EquipmentSprite]"] = handler;
         }
      }
      
      private function makeChild(handler:IAnimationSpriteHandler) : DisplayObject
      {
         var lastNumChild:* = 0;
         var c:Sprite = handler.getSkinSprite(this);
         if(c && c != this)
         {
            lastNumChild = 0;
            while(numChildren && lastNumChild != numChildren)
            {
               lastNumChild = uint(numChildren);
               removeChildAt(0);
            }
            return addChild(c);
         }
         return null;
      }
   }
}
