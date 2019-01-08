package com.ankamagames.atouin.types
{
   import com.ankamagames.atouin.AtouinConstants;
   import com.ankamagames.atouin.managers.EntitiesDisplayManager;
   import com.ankamagames.jerakine.entities.behaviours.IDisplayBehavior;
   import com.ankamagames.jerakine.entities.interfaces.IDisplayable;
   import com.ankamagames.jerakine.interfaces.IRectangle;
   import com.ankamagames.jerakine.interfaces.ITransparency;
   import com.ankamagames.jerakine.managers.FontManager;
   import com.ankamagames.jerakine.types.ARGBColor;
   import com.ankamagames.jerakine.types.Color;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class ZoneTile extends Sprite implements IDisplayable, ITransparency
   {
      
      private static const _cell:Class = ZoneTile__cell;
       
      
      private var _displayBehavior:IDisplayBehavior;
      
      protected var _displayed:Boolean;
      
      private var _currentCell:Point;
      
      private var _cellId:uint;
      
      protected var _cellInstance:Sprite;
      
      private var _tf:TextField;
      
      private var _color:Color;
      
      public var text:String;
      
      public var format:TextFormat;
      
      public var strata:uint = 0;
      
      public function ZoneTile()
      {
         super();
         mouseEnabled = false;
         mouseChildren = false;
      }
      
      public function get displayBehaviors() : IDisplayBehavior
      {
         return this._displayBehavior;
      }
      
      public function set displayBehaviors(oValue:IDisplayBehavior) : void
      {
         this._displayBehavior = oValue;
      }
      
      public function get currentCellPosition() : Point
      {
         return this._currentCell;
      }
      
      public function set currentCellPosition(pValue:Point) : void
      {
         this._currentCell = pValue;
      }
      
      public function get displayed() : Boolean
      {
         return this._displayed;
      }
      
      public function get absoluteBounds() : IRectangle
      {
         return this._displayBehavior.getAbsoluteBounds(this);
      }
      
      public function set color(c:Color) : void
      {
         this._color = c;
      }
      
      public function get color() : Color
      {
         return this._color;
      }
      
      public function get cellId() : uint
      {
         return this._cellId;
      }
      
      public function set cellId(nValue:uint) : void
      {
         this._cellId = nValue;
      }
      
      public function display(wishedStrata:uint = 0) : void
      {
         this.removeAllChildren();
         if(this.text)
         {
            if(!this.format)
            {
               this.format = new TextFormat(FontManager.getInstance().getFontInfo("Verdana").className,20,16777215,true);
               this.format.align = TextFormatAlign.CENTER;
            }
            this._tf = new TextField();
            this._tf.selectable = false;
            this._tf.defaultTextFormat = this.format;
            this._tf.setTextFormat(this.format);
            this._tf.embedFonts = true;
            this._tf.text = this.text;
            this._tf.width = AtouinConstants.CELL_WIDTH;
            this._tf.height = AtouinConstants.CELL_HEIGHT;
            this._tf.x = -AtouinConstants.CELL_HALF_WIDTH;
            this._tf.y = -AtouinConstants.CELL_HALF_HEIGHT + 7;
            this._tf.alpha = 0.8;
            addChild(this._tf);
         }
         this._cellInstance = new _cell();
         var ct:ColorTransform = new ColorTransform();
         ct.color = this._color.color;
         if(this._color is ARGBColor)
         {
            ct.alphaMultiplier = (this._color as ARGBColor).alpha;
         }
         this._cellInstance.transform.colorTransform = ct;
         addChildAt(this._cellInstance,0);
         EntitiesDisplayManager.getInstance().displayEntity(this,MapPoint.fromCellId(this._cellId),this.strata);
         this._displayed = true;
      }
      
      public function remove() : void
      {
         this._displayed = false;
         this.removeAllChildren();
         EntitiesDisplayManager.getInstance().removeEntity(this);
      }
      
      public function getIsTransparencyAllowed() : Boolean
      {
         return false;
      }
      
      private function removeAllChildren() : void
      {
         while(numChildren > 0)
         {
            removeChildAt(0);
         }
         this._tf = null;
         this._cellInstance = null;
      }
   }
}
