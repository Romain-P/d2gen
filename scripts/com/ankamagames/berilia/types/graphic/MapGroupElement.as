package com.ankamagames.berilia.types.graphic
{
   import com.ankamagames.berilia.components.Label;
   import com.ankamagames.berilia.components.MapViewer;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.Uri;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   import gs.TweenMax;
   import gs.events.TweenEvent;
   
   public class MapGroupElement extends Sprite
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(MapGroupElement));
      
      protected static var glowFilter:GlowFilter;
      
      protected static var cssUri:Uri;
       
      
      private var _icons:Vector.<MapIconElement>;
      
      private var _initialPos:Array;
      
      private var _tween:Array;
      
      private var _shape:Shape;
      
      private var _open:Boolean;
      
      private var _mapviewer:MapViewer;
      
      private var _iconsNumberLabel:Label;
      
      public function MapGroupElement(mapViewer:MapViewer)
      {
         super();
         this._icons = new Vector.<MapIconElement>();
         this._mapviewer = mapViewer;
         mouseEnabled = false;
         mouseChildren = false;
         if(!glowFilter)
         {
            glowFilter = new GlowFilter(XmlConfig.getInstance().getEntry("colors.text.glow"),1,4,4,6,3);
         }
         if(!cssUri)
         {
            cssUri = new Uri(XmlConfig.getInstance().getEntry("config.ui.skin") + "css/normal.css");
         }
         this.addNumberIconsLabel();
      }
      
      public function get opened() : Boolean
      {
         return this._open;
      }
      
      public function open(pTweenTime:Number = NaN) : void
      {
         var icon:* = null;
         var sens:int = 0;
         var inc:int = 0;
         var destRot:Number = NaN;
         var destX:Number = NaN;
         var destY:Number = NaN;
         if(!this._icons || !this._icons.length)
         {
            return;
         }
         if(this._iconsNumberLabel)
         {
            this._iconsNumberLabel.visible = false;
         }
         var radius:uint = this._icons.length * 5;
         var center:Point = new Point(0,0);
         var mapWidth:uint = this._icons[0].textureWidth * 1.5;
         var mapHeight:uint = this._icons[0].textureHeight * 1.5;
         if(radius < mapWidth * 3 / 4)
         {
            radius = mapWidth * 3 / 4;
         }
         if(radius < mapHeight * 3 / 4)
         {
            radius = mapHeight * 3 / 4;
         }
         var tweenTime:Number = !!isNaN(pTweenTime)?Number(Math.min(0.1 * this._icons.length,0.5)):Number(pTweenTime);
         if(!this._shape)
         {
            this._shape = new Shape();
         }
         else
         {
            this._shape.graphics.clear();
         }
         radius = radius * (1 / this._mapviewer.zoomFactor);
         this._shape.graphics.beginFill(16777215,0);
         this._shape.graphics.drawCircle(center.x,center.y,40);
         super.addChildAt(this._shape,0);
         this.killAllTween();
         this._tween.push(new TweenMax(this._shape,tweenTime,{
            "alpha":1,
            "onCompleteListener":this.openingEnd
         }));
         var saveInitialPosition:Boolean = false;
         if(!this._initialPos)
         {
            this._initialPos = new Array();
            saveInitialPosition = true;
         }
         var step:Number = Math.PI * 2 / this._icons.length;
         var offset:Number = Math.PI / 2 + Math.PI / 4;
         for(var i:int = this._icons.length - 1; i >= 0; i--)
         {
            icon = this._icons[i];
            if(saveInitialPosition)
            {
               this._initialPos.push({
                  "icon":this._icons[i],
                  "textureX":icon.textureX,
                  "textureY":icon.textureY
               });
            }
            offset = this._icons.length % 2 == 0?30:Number(0);
            sens = i % 2 == 0?1:-1;
            inc = (i + 1) / 2;
            destRot = offset + sens * inc * 60;
            destX = Math.sin(destRot * Math.PI / 180) * 30 / this._mapviewer.zoomFactor;
            destY = -Math.cos(destRot * Math.PI / 180) * 30 / this._mapviewer.zoomFactor;
            this._tween.push(new TweenMax(icon,tweenTime,{
               "textureX":destX,
               "textureY":destY
            }));
         }
      }
      
      private function openingEnd(e:TweenEvent) : void
      {
         this._open = true;
      }
      
      private function getInitialPos(pIcon:Object) : Object
      {
         var iconPos:* = null;
         for each(iconPos in this._initialPos)
         {
            if(iconPos.icon == pIcon)
            {
               return iconPos;
            }
         }
         return null;
      }
      
      public function close() : void
      {
         var icon:* = null;
         if(this._iconsNumberLabel)
         {
            this._iconsNumberLabel.visible = true;
         }
         this.killAllTween();
         if(this._shape)
         {
            this._tween.push(new TweenMax(this._shape,0.2,{
               "alpha":0,
               "onCompleteListener":this.shapeTweenFinished
            }));
         }
         for each(icon in this._initialPos)
         {
            this._tween.push(new TweenMax(icon.icon,0.2,{
               "textureX":icon.textureX,
               "textureY":icon.textureY
            }));
         }
         this._open = false;
      }
      
      public function addElement(element:MapIconElement) : void
      {
         this._icons.push(element);
         element.group = this;
      }
      
      public function remove() : void
      {
         while(numChildren)
         {
            removeChildAt(0);
         }
         this._icons = null;
         this.killAllTween();
      }
      
      public function display() : void
      {
         var i:int = 0;
         var iconIndex:* = 0;
         var pos:int = 0;
         this._icons.sort(this.compareIconsPriority);
         var numIcons:uint = this._icons.length;
         var numVisibleIcons:int = 0;
         var visibleIconsCount:uint = numIcons > 2?2:uint(numIcons);
         for(i = numIcons - 1; i >= 0; i--)
         {
            if(this._icons[i].uri)
            {
               numVisibleIcons++;
            }
            iconIndex = uint(Math.min(visibleIconsCount,i));
            pos = -4 * iconIndex;
            this._icons[i].setTextureParent(this);
            this._icons[i].setTexturePosition(0,pos);
         }
         this.updateIconsNumber(numVisibleIcons);
      }
      
      private function updateIconsNumber(pNumIcons:uint) : void
      {
         if(pNumIcons > 1)
         {
            if(!this._iconsNumberLabel)
            {
               this.addNumberIconsLabel();
            }
            if(pNumIcons.toString() != this._iconsNumberLabel.text)
            {
               this._iconsNumberLabel.text = pNumIcons.toString();
               this._iconsNumberLabel.filters = [glowFilter];
               setChildIndex(this._iconsNumberLabel,numChildren - 1);
            }
         }
         else
         {
            this.removeNumberIconsLabel();
         }
      }
      
      private function addNumberIconsLabel() : void
      {
         this._iconsNumberLabel = new Label();
         this._iconsNumberLabel.width = 30;
         this._iconsNumberLabel.height = 20;
         this._iconsNumberLabel.x = -15;
         this._iconsNumberLabel.y = -10;
         this._iconsNumberLabel.css = cssUri;
         addChild(this._iconsNumberLabel);
      }
      
      private function removeNumberIconsLabel() : void
      {
         if(this._iconsNumberLabel)
         {
            this._iconsNumberLabel.filters = null;
            this._iconsNumberLabel.remove();
            this._iconsNumberLabel = null;
         }
      }
      
      private function compareIconsPriority(pIconA:MapIconElement, pIconB:MapIconElement) : int
      {
         if(pIconA.priority < pIconB.priority)
         {
            return -1;
         }
         if(pIconA.priority > pIconB.priority)
         {
            return 1;
         }
         return 0;
      }
      
      private function killAllTween() : void
      {
         var t:* = null;
         for each(t in this._tween)
         {
            t.kill();
            t.gc = true;
         }
         this._tween = new Array();
      }
      
      private function shapeTweenFinished(e:TweenEvent) : void
      {
         this._shape.graphics.clear();
      }
      
      public function get icons() : Vector.<MapIconElement>
      {
         return this._icons;
      }
   }
}
