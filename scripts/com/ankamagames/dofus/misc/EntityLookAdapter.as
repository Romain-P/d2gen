package com.ankamagames.dofus.misc
{
   import com.ankamagames.dofus.network.enums.SubEntityBindingPointCategoryEnum;
   import com.ankamagames.dofus.network.types.game.look.EntityLook;
   import com.ankamagames.dofus.network.types.game.look.SubEntity;
   import com.ankamagames.tiphon.types.look.TiphonEntityLook;
   
   public class EntityLookAdapter
   {
       
      
      public function EntityLookAdapter()
      {
         super();
      }
      
      public static function fromNetwork(n:EntityLook) : TiphonEntityLook
      {
         var skin:int = 0;
         var se:* = null;
         var index:* = 0;
         var color:* = 0;
         var o:TiphonEntityLook = new TiphonEntityLook();
         o.lock();
         o.setBone(n.bonesId);
         for each(skin in n.skins)
         {
            o.addSkin(skin);
         }
         if(n.bonesId == 1 || n.bonesId == 2)
         {
            o.defaultSkin = 1965;
         }
         for(var i:int = 0; i < n.indexedColors.length; )
         {
            index = uint(n.indexedColors[i] >> 24 & 255);
            color = uint(n.indexedColors[i] & 16777215);
            o.setColor(index,color);
            i++;
         }
         if(n.scales.length == 1)
         {
            o.setScales(n.scales[0] / 100,n.scales[0] / 100);
         }
         else if(n.scales.length == 2)
         {
            o.setScales(n.scales[0] / 100,n.scales[1] / 100);
         }
         for each(se in n.subentities)
         {
            o.addSubEntity(se.bindingPointCategory,se.bindingPointIndex,EntityLookAdapter.fromNetwork(se.subEntityLook));
         }
         o.unlock(true);
         return o;
      }
      
      public static function toNetwork(o:TiphonEntityLook) : EntityLook
      {
         var colorIndexStr:* = null;
         var subEntities:* = null;
         var catStr:* = null;
         var colorIndex:* = 0;
         var color:* = 0;
         var indexedColor:* = 0;
         var cat:* = 0;
         var indStr:* = null;
         var ind:* = 0;
         var se:* = null;
         var n:EntityLook = new EntityLook();
         n.bonesId = o.getBone();
         n.skins = o.getSkins(false,false);
         var colors:Array = o.getColors(true);
         for(colorIndexStr in colors)
         {
            colorIndex = uint(parseInt(colorIndexStr));
            color = uint(colors[colorIndexStr]);
            indexedColor = uint((colorIndex & 255) << 24 | color & 16777215);
            n.indexedColors.push(indexedColor);
         }
         n.scales.push(uint(o.getScaleX() * 100));
         n.scales.push(uint(o.getScaleY() * 100));
         subEntities = o.getSubEntities(true);
         for(catStr in subEntities)
         {
            cat = uint(parseInt(catStr));
            for(indStr in subEntities[catStr])
            {
               ind = uint(parseInt(indStr));
               se = new SubEntity();
               se.initSubEntity(cat,ind,EntityLookAdapter.toNetwork(subEntities[catStr][indStr]));
               n.subentities.push(se);
            }
         }
         return n;
      }
      
      public static function tiphonizeLook(rawLook:*) : TiphonEntityLook
      {
         var entityLook:* = null;
         if(rawLook is TiphonEntityLook)
         {
            entityLook = rawLook as TiphonEntityLook;
         }
         if(rawLook is EntityLook)
         {
            entityLook = fromNetwork(rawLook);
         }
         if(rawLook is String)
         {
            entityLook = TiphonEntityLook.fromString(rawLook);
         }
         return entityLook;
      }
      
      public static function getRiderLook(rawLook:*) : TiphonEntityLook
      {
         var oldEntityLook:TiphonEntityLook = tiphonizeLook(rawLook);
         var entityLook:TiphonEntityLook = oldEntityLook.clone();
         var ridderLook:TiphonEntityLook = entityLook.getSubEntity(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0);
         if(ridderLook)
         {
            if(ridderLook.getBone() == 2)
            {
               ridderLook.setBone(1);
            }
            entityLook = ridderLook;
         }
         return entityLook;
      }
   }
}
