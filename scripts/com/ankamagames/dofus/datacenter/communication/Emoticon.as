package com.ankamagames.dofus.datacenter.communication
{
   import com.ankamagames.jerakine.data.GameData;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.Swl;
   import com.ankamagames.tiphon.engine.BoneIndexManager;
   import com.ankamagames.tiphon.engine.Tiphon;
   import com.ankamagames.tiphon.types.look.TiphonEntityLook;
   import flash.utils.getQualifiedClassName;
   
   public class Emoticon implements IDataCenter
   {
      
      public static const MODULE:String = "Emoticons";
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(Emoticon));
       
      
      public var id:uint;
      
      public var nameId:uint;
      
      public var shortcutId:uint;
      
      public var order:uint;
      
      public var defaultAnim:String;
      
      public var persistancy:Boolean;
      
      public var eight_directions:Boolean;
      
      public var aura:Boolean;
      
      public var anims:Vector.<String>;
      
      public var cooldown:uint = 1000;
      
      public var duration:uint = 0;
      
      public var weight:uint;
      
      public var spellLevelId:uint = 0;
      
      private var _name:String;
      
      private var _shortcut:String;
      
      public function Emoticon()
      {
         super();
      }
      
      public static function getEmoticonById(id:int) : Emoticon
      {
         return GameData.getObject(MODULE,id) as Emoticon;
      }
      
      public static function getEmoticons() : Array
      {
         return GameData.getObjects(MODULE);
      }
      
      public function get name() : String
      {
         if(!this._name)
         {
            this._name = I18n.getText(this.nameId);
         }
         return this._name;
      }
      
      public function get shortcut() : String
      {
         if(!this._shortcut)
         {
            this._shortcut = I18n.getText(this.shortcutId);
         }
         if(!this._shortcut || this._shortcut == "")
         {
            return this.defaultAnim;
         }
         return this._shortcut;
      }
      
      public function getAnimName(look:TiphonEntityLook) : String
      {
         var animName:* = null;
         var lookBoneId:* = 0;
         var l:int = 0;
         var i:int = 0;
         var anim:* = null;
         var animCase:* = null;
         var caseBoneId:* = 0;
         var caseSkins:* = null;
         var matchingSkin:int = 0;
         var skin:* = null;
         var skinId:* = 0;
         var lookSkin:* = undefined;
         var boneAnims:* = null;
         var resource:* = null;
         var animEmoteNameLowerCase:* = null;
         var boneAnim:* = null;
         if(this.spellLevelId != 0 && !this.defaultAnim && this.anims.length == 0)
         {
            return null;
         }
         if(look)
         {
            lookBoneId = uint(look.getBone());
            l = this.anims.length;
            for(i = 0; i < l; )
            {
               anim = this.anims[i];
               animCase = anim.split(";");
               caseBoneId = uint(parseInt(animCase[0]));
               if(caseBoneId == lookBoneId)
               {
                  caseSkins = animCase[1].split(",");
                  matchingSkin = 0;
                  for each(skin in caseSkins)
                  {
                     skinId = uint(parseInt(skin));
                     for each(lookSkin in look.skins)
                     {
                        if(skinId == lookSkin)
                        {
                           matchingSkin++;
                        }
                     }
                  }
                  if(matchingSkin > 0)
                  {
                     animName = "AnimEmote" + animCase[2];
                  }
               }
               i++;
            }
            if(!animName)
            {
               if(BoneIndexManager.getInstance().hasCustomBone(lookBoneId))
               {
                  boneAnims = BoneIndexManager.getInstance().getAllCustomAnimations(lookBoneId);
               }
               if(!boneAnims)
               {
                  resource = Tiphon.skullLibrary.getResourceById(look.getBone());
                  boneAnims = !!resource?resource.getDefinitions():null;
               }
               if(boneAnims)
               {
                  animEmoteNameLowerCase = ("AnimEmote" + this.defaultAnim + "_0").toLowerCase();
                  for each(boneAnim in boneAnims)
                  {
                     if(boneAnim.toLowerCase().indexOf(animEmoteNameLowerCase) == 0)
                     {
                        return boneAnim;
                     }
                  }
               }
            }
         }
         if(!animName)
         {
            animName = "AnimEmote" + this.defaultAnim.charAt(0).toUpperCase() + this.defaultAnim.substr(1).toLowerCase() + "_0";
         }
         return animName;
      }
   }
}
