package com.ankamagames.dofus
{
   public class Modules
   {
      
      public static const ANKAMA_ADMIN:Class = Modules_ANKAMA_ADMIN;
      
      public static const ANKAMA_CARTOGRAPHY:Class = Modules_ANKAMA_CARTOGRAPHY;
      
      public static const ANKAMA_CHARACTERSHEET:Class = Modules_ANKAMA_CHARACTERSHEET;
      
      public static const ANKAMA_COMMON:Class = Modules_ANKAMA_COMMON;
      
      public static const ANKAMA_CONFIG:Class = Modules_ANKAMA_CONFIG;
      
      public static const ANKAMA_CONNECTION:Class = Modules_ANKAMA_CONNECTION;
      
      public static const ANKAMA_CONSOLE:Class = Modules_ANKAMA_CONSOLE;
      
      public static const ANKAMA_CONTEXTMENU:Class = Modules_ANKAMA_CONTEXTMENU;
      
      public static const ANKAMA_DOCUMENT:Class = Modules_ANKAMA_DOCUMENT;
      
      public static const ANKAMA_EXCHANGE:Class = Modules_ANKAMA_EXCHANGE;
      
      public static const ANKAMA_FIGHT:Class = Modules_ANKAMA_FIGHT;
      
      public static const ANKAMA_GAMEUICORE:Class = Modules_ANKAMA_GAMEUICORE;
      
      public static const ANKAMA_GRIMOIRE:Class = Modules_ANKAMA_GRIMOIRE;
      
      public static const ANKAMA_HOUSE:Class = Modules_ANKAMA_HOUSE;
      
      public static const ANKAMA_JOB:Class = Modules_ANKAMA_JOB;
      
      public static const ANKAMA_MOUNT:Class = Modules_ANKAMA_MOUNT;
      
      public static const ANKAMA_PARTY:Class = Modules_ANKAMA_PARTY;
      
      public static const ANKAMA_ROLEPLAY:Class = Modules_ANKAMA_ROLEPLAY;
      
      public static const ANKAMA_SOCIAL:Class = Modules_ANKAMA_SOCIAL;
      
      public static const ANKAMA_STORAGE:Class = Modules_ANKAMA_STORAGE;
      
      public static const ANKAMA_TAXI:Class = Modules_ANKAMA_TAXI;
      
      public static const ANKAMA_TOOLTIPS:Class = Modules_ANKAMA_TOOLTIPS;
      
      public static const ANKAMA_TRADECENTER:Class = Modules_ANKAMA_TRADECENTER;
      
      public static const ANKAMA_TUTORIAL:Class = Modules_ANKAMA_TUTORIAL;
      
      public static const ANKAMA_WEB:Class = Modules_ANKAMA_WEB;
      
      private static var _scripts:Array = [];
       
      
      public function Modules()
      {
         super();
      }
      
      public static function get scripts() : Array
      {
         if(!_scripts.length)
         {
            _scripts["ANKAMA_ADMIN"] = ANKAMA_ADMIN;
            _scripts["ANKAMA_CARTOGRAPHY"] = ANKAMA_CARTOGRAPHY;
            _scripts["ANKAMA_CHARACTERSHEET"] = ANKAMA_CHARACTERSHEET;
            _scripts["ANKAMA_COMMON"] = ANKAMA_COMMON;
            _scripts["ANKAMA_CONFIG"] = ANKAMA_CONFIG;
            _scripts["ANKAMA_CONNECTION"] = ANKAMA_CONNECTION;
            _scripts["ANKAMA_CONSOLE"] = ANKAMA_CONSOLE;
            _scripts["ANKAMA_CONTEXTMENU"] = ANKAMA_CONTEXTMENU;
            _scripts["ANKAMA_DOCUMENT"] = ANKAMA_DOCUMENT;
            _scripts["ANKAMA_EXCHANGE"] = ANKAMA_EXCHANGE;
            _scripts["ANKAMA_FIGHT"] = ANKAMA_FIGHT;
            _scripts["ANKAMA_GAMEUICORE"] = ANKAMA_GAMEUICORE;
            _scripts["ANKAMA_GRIMOIRE"] = ANKAMA_GRIMOIRE;
            _scripts["ANKAMA_HOUSE"] = ANKAMA_HOUSE;
            _scripts["ANKAMA_JOB"] = ANKAMA_JOB;
            _scripts["ANKAMA_MOUNT"] = ANKAMA_MOUNT;
            _scripts["ANKAMA_PARTY"] = ANKAMA_PARTY;
            _scripts["ANKAMA_ROLEPLAY"] = ANKAMA_ROLEPLAY;
            _scripts["ANKAMA_SOCIAL"] = ANKAMA_SOCIAL;
            _scripts["ANKAMA_STORAGE"] = ANKAMA_STORAGE;
            _scripts["ANKAMA_TAXI"] = ANKAMA_TAXI;
            _scripts["ANKAMA_TOOLTIPS"] = ANKAMA_TOOLTIPS;
            _scripts["ANKAMA_TRADECENTER"] = ANKAMA_TRADECENTER;
            _scripts["ANKAMA_TUTORIAL"] = ANKAMA_TUTORIAL;
            _scripts["ANKAMA_WEB"] = ANKAMA_WEB;
         }
         return _scripts;
      }
   }
}
