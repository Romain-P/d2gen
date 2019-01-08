package com.ankamagames.berilia.types.graphic
{
   import com.ankamagames.berilia.components.Texture;
   import com.ankamagames.berilia.components.TextureBase;
   import flash.geom.Rectangle;
   
   public class MapIconElement extends MapDisplayableElement
   {
       
      
      public var legend:String;
      
      public var follow:Boolean;
      
      public var canBeGrouped:Boolean = true;
      
      public var canBeAutoSize:Boolean = true;
      
      public var canBeManuallyRemoved:Boolean = true;
      
      public var allowDuplicate:Boolean;
      
      public var priority:uint;
      
      public var color:int;
      
      private var _boundsRef:TextureBase;
      
      public function MapIconElement(id:String, x:int, y:int, layer:String, texture:TextureBase, color:int, legend:String, owner:*, canBeManuallyRemoved:Boolean = true, mouseEnabled:Boolean = false, allowDuplicate:Boolean = false, priority:uint = 0)
      {
         super(id,x,y,layer,owner,texture);
         this.legend = legend;
         this.canBeManuallyRemoved = canBeManuallyRemoved;
         this.allowDuplicate = allowDuplicate;
         this.priority = priority;
         this.color = color;
         _texture.mouseEnabled = mouseEnabled;
      }
      
      public function get bounds() : Rectangle
      {
         return !!this._boundsRef?this._boundsRef.getStageRect():this.getRealBounds;
      }
      
      public function get getRealBounds() : Rectangle
      {
         return !!_texture?_texture.getStageRect():null;
      }
      
      public function set boundsRef(v:Texture) : void
      {
         this._boundsRef = v;
      }
      
      override public function remove() : void
      {
         this._boundsRef = null;
         super.remove();
      }
      
      public function get key() : String
      {
         return x + "_" + y;
      }
   }
}
