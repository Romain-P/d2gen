package com.ankamagames.dofus.kernel.sound.parser
{
   import com.ankamagames.jerakine.types.SoundEventParamWrapper;
   
   public class XMLSoundParser
   {
      
      private static const _IDS_UNLOCALIZED:Array = new Array("20","17","16");
       
      
      private var _xmlBreed:XML;
      
      public function XMLSoundParser()
      {
         super();
      }
      
      public static function parseXMLSoundFile(pXMLFile:XML, pSkins:Vector.<uint>) : SoundEventParamWrapper
      {
         var matchingSoundNode:* = null;
         var sound:* = null;
         var vectorSEPW:* = null;
         var Sounds:* = null;
         var aSounds:* = null;
         var Sound:* = null;
         var randomIndex:* = 0;
         var skinsString:* = null;
         var skins:* = null;
         var skin:* = null;
         var skinGapless:* = null;
         var skinId:int = 0;
         var sepw:* = null;
         var sounds:XMLList = pXMLFile.elements();
         var r:RegExp = /^\s*(.*?)\s*$/g;
         for each(sound in sounds)
         {
            if(matchingSoundNode == null)
            {
               skinsString = sound.@skin;
               skins = skinsString.split(",");
               for each(skin in skins)
               {
                  skinGapless = skin.replace(r,"$1");
                  for each(skinId in pSkins)
                  {
                     if(skinGapless == skinId.toString())
                     {
                        matchingSoundNode = sound;
                     }
                  }
               }
            }
         }
         vectorSEPW = new Vector.<SoundEventParamWrapper>();
         Sounds = matchingSoundNode.elements();
         aSounds = new Vector.<SoundEventParamWrapper>();
         for each(Sound in Sounds)
         {
            if(!Sound.id)
            {
               throw new Error("SoundEventParamWrapper.id will be null " + Sound.valueOf());
            }
            sepw = new SoundEventParamWrapper(Sound.Id,Sound.Volume,Sound.RollOff);
            sepw.berceauDuree = Sound.BerceauDuree;
            sepw.berceauVol = Sound.BerceauVol;
            sepw.berceauFadeIn = Sound.BerceauFadeIn;
            sepw.berceauFadeOut = Sound.BerceauFadeOut;
            vectorSEPW.push(sepw);
         }
         randomIndex = uint(Math.random() * Math.floor(vectorSEPW.length - 1));
         return vectorSEPW[randomIndex];
      }
      
      public static function isLocalized(pSoundId:String) : Boolean
      {
         var patternBegin:* = null;
         for each(patternBegin in _IDS_UNLOCALIZED)
         {
            if(pSoundId.split(patternBegin)[0] == "")
            {
               return false;
            }
         }
         return true;
      }
   }
}
