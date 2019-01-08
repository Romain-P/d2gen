package com.ankamagames.dofus.console.debug
{
   import com.ankamagames.dofus.datacenter.spells.Spell;
   import com.ankamagames.dofus.misc.utils.GameDebugManager;
   import com.ankamagames.jerakine.console.ConsoleHandler;
   import com.ankamagames.jerakine.console.ConsoleInstructionHandler;
   
   public class FightInstructionHandler implements ConsoleInstructionHandler
   {
       
      
      public function FightInstructionHandler()
      {
         super();
      }
      
      public function handle(console:ConsoleHandler, cmd:String, args:Array) : void
      {
         var spell:* = null;
         var spell2:* = null;
         switch(cmd)
         {
            case "setspellscript":
               if(args.length == 2 || args.length == 3)
               {
                  spell = Spell.getSpellById(parseInt(args[0]));
                  if(!spell)
                  {
                     console.output("Spell " + args[0] + " doesn\'t exist");
                     break;
                  }
                  spell.scriptId = parseInt(args[1]);
                  if(args.length == 3)
                  {
                     spell.scriptIdCritical = parseInt(args[2]);
                     break;
                  }
                  break;
               }
               console.output("Param count error : #1 Spell id, #2 script id, #3 script id (critical hit)");
               break;
            case "setspellscriptparam":
               if(args.length == 2 || args.length == 3)
               {
                  spell2 = Spell.getSpellById(parseInt(args[0]));
                  if(!spell2)
                  {
                     console.output("Spell " + args[0] + " doesn\'t exist");
                     break;
                  }
                  spell2.scriptParams = args[1];
                  if(args.length == 3)
                  {
                     spell2.scriptParamsCritical = args[2];
                  }
                  spell2.useParamCache = false;
                  break;
               }
               console.output("Param count error : #1 Spell id, #2 script string parametters, #3 script string parameters (critical hit)");
               break;
            case "inspectbuffs":
               GameDebugManager.getInstance().buffsDebugActivated = !GameDebugManager.getInstance().buffsDebugActivated;
               console.output("Fight\'s buffs debug mode is " + (!!GameDebugManager.getInstance().buffsDebugActivated?"ON":"OFF"));
         }
      }
      
      public function getHelp(cmd:String) : String
      {
         switch(cmd)
         {
            case "setspellscriptparam":
               return "Change script parametters for given spell";
            case "setspellscript":
               return "Change script id used for given spell";
            case "inspectbuffs":
               return "Show detailled informations about buffs in fight.";
            default:
               return "Unknown command";
         }
      }
      
      public function getParamPossibilities(cmd:String, paramIndex:uint = 0, currentParams:Array = null) : Array
      {
         return [];
      }
   }
}
