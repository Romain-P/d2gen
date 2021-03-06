package com.ankamagames.jerakine.utils.parser
{
   import com.ankamagames.jerakine.types.SoundEventParamWrapper;
   
   public class FLAEventLabelParser
   {
      
      private static var BALISE_PARAM_DELIMITER:String = ";";
      
      private static var BALISE_PARAM_ASSIGN:String = "=";
      
      private static var BALISE_PARAM_NEXT_PARAM:String = ",";
      
      private static var PARAM_ID:String = "id";
      
      private static var PARAM_VOLUME:String = "vol";
      
      private static var PARAM_ROLLOFF:String = "rollOff";
      
      private static var PARAM_BERCEAU_DUREE:String = "berceauDuree";
      
      private static var PARAM_BERCEAU_VOL:String = "berceauVol";
      
      private static var PARAM_BERCEAU_FADE_IN:String = "berceauFadeIn";
      
      private static var PARAM_BERCEAU_FADE_OUT:String = "berceauFadeOut";
      
      private static var PARAM_NO_CUT_SILENCE:String = "noCutSilence";
       
      
      public function FLAEventLabelParser()
      {
         super();
      }
      
      public static function parseSoundLabel(pParams:String) : Array
      {
         var rollOff:* = 0;
         var berceauDuree:* = 0;
         var berceauVol:* = 0;
         var berceauFadeIn:* = 0;
         var berceauFadeOut:* = 0;
         var paramName:* = null;
         var r:* = null;
         var temp:* = null;
         var valueParams:* = null;
         var id:* = null;
         var vol:int = 0;
         var sepw:* = null;
         var returnSEPW:Array = new Array();
         var params:Array = pParams.split(BALISE_PARAM_DELIMITER);
         var tabLength:uint = params.length;
         var aIds:Vector.<String> = new Vector.<String>();
         var aVols:Vector.<uint> = new Vector.<uint>();
         var noCutSilence:Boolean = false;
         for(var i:int = 0; i < tabLength; )
         {
            paramName = params[i].split(BALISE_PARAM_ASSIGN)[0];
            r = /^\s*(.*?)\s*$/g;
            paramName = paramName.replace(r,"$1");
            temp = params[i].split(BALISE_PARAM_ASSIGN)[1];
            valueParams = temp.split(BALISE_PARAM_NEXT_PARAM);
            switch(paramName.toUpperCase())
            {
               case PARAM_ID.toUpperCase():
                  for each(id in valueParams)
                  {
                     id = id.replace(r,"$1");
                     aIds.push(id);
                  }
                  break;
               case PARAM_VOLUME.toUpperCase():
                  for each(vol in valueParams)
                  {
                     aVols.push(vol);
                  }
                  break;
               case PARAM_ROLLOFF.toUpperCase():
                  rollOff = uint(valueParams[0]);
                  break;
               case PARAM_BERCEAU_DUREE.toUpperCase():
                  berceauDuree = uint(valueParams[0]);
                  break;
               case PARAM_BERCEAU_VOL.toUpperCase():
                  berceauVol = uint(valueParams[0]);
                  break;
               case PARAM_BERCEAU_FADE_IN.toUpperCase():
                  berceauFadeIn = uint(valueParams[0]);
                  break;
               case PARAM_BERCEAU_FADE_OUT.toUpperCase():
                  berceauFadeOut = uint(valueParams[0]);
                  break;
               case PARAM_NO_CUT_SILENCE.toUpperCase():
                  if(String(valueParams[0]).match("false"))
                  {
                     noCutSilence = false;
                     break;
                  }
                  noCutSilence = true;
                  break;
            }
            i++;
         }
         var size:uint = aIds.length;
         if(aIds.length != aVols.length)
         {
            throw new Error("The number of sound id and volume are differents. Nom : " + paramName + " id des sons : " + aIds);
         }
         for(var compt:int = 0; compt < size; )
         {
            sepw = new SoundEventParamWrapper(aIds[compt],aVols[compt],rollOff);
            sepw.berceauDuree = berceauDuree;
            sepw.berceauVol = berceauVol;
            sepw.berceauFadeIn = berceauFadeIn;
            sepw.berceauFadeOut = berceauFadeOut;
            sepw.noCutSilence = noCutSilence;
            returnSEPW.push(sepw);
            compt++;
         }
         return returnSEPW;
      }
      
      public static function buildSoundLabel(soundEvents:Vector.<SoundEventParamWrapper>) : String
      {
         var soundEvent:* = null;
         var label:* = null;
         var aIds:Vector.<String> = new Vector.<String>();
         var aVols:Vector.<uint> = new Vector.<uint>();
         if(!soundEvents || soundEvents.length == 0)
         {
            return null;
         }
         for each(soundEvent in soundEvents)
         {
            aIds.push(soundEvent.id);
            aVols.push(soundEvent.volume);
         }
         label = PARAM_ID + "=" + aIds.join(",") + "; " + PARAM_VOLUME + "=" + aVols.join(",") + "; " + PARAM_ROLLOFF + "=" + soundEvents[0].rollOff + "; " + PARAM_BERCEAU_DUREE + "=" + soundEvents[0].berceauDuree + "; " + PARAM_BERCEAU_VOL + "=" + soundEvents[0].berceauVol + "; " + PARAM_BERCEAU_FADE_IN + "=" + soundEvents[0].berceauFadeIn + "; " + PARAM_BERCEAU_FADE_OUT + "=" + soundEvents[0].berceauFadeOut + "; " + PARAM_NO_CUT_SILENCE + "=" + soundEvents[0].noCutSilence;
         return label;
      }
   }
}
