package com.ankamagames.dofus.logic.common.frames
{
   import com.ankamagames.berilia.factories.HyperlinkFactory;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.console.BasicConsoleInstructionRegistar;
   import com.ankamagames.dofus.console.DebugConsoleInstructionRegistar;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.kernel.net.ConnectionType;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.logic.common.actions.AuthorizedCommandAction;
   import com.ankamagames.dofus.logic.common.actions.QuitGameAction;
   import com.ankamagames.dofus.logic.common.managers.HyperlinkAdminManager;
   import com.ankamagames.dofus.misc.lists.GameDataList;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.network.ProtocolConstantsEnum;
   import com.ankamagames.dofus.network.messages.authorized.AdminCommandMessage;
   import com.ankamagames.dofus.network.messages.authorized.ConsoleMessage;
   import com.ankamagames.dofus.network.messages.security.CheckIntegrityMessage;
   import com.ankamagames.jerakine.console.ConsoleHandler;
   import com.ankamagames.jerakine.console.ConsoleOutputMessage;
   import com.ankamagames.jerakine.console.ConsolesManager;
   import com.ankamagames.jerakine.console.UnhandledConsoleInstructionError;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.messages.RegisteringFrame;
   import com.ankamagames.jerakine.types.enums.Priority;
   import com.ankamagames.jerakine.utils.misc.DescribeTypeCache;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AuthorizedFrame extends RegisteringFrame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(AuthorizedFrame));
       
      
      private var _hasRights:Boolean;
      
      private var _include_CheckIntegrityMessage:CheckIntegrityMessage = null;
      
      public function AuthorizedFrame()
      {
         super();
      }
      
      override public function get priority() : int
      {
         return Priority.LOW;
      }
      
      override public function pushed() : Boolean
      {
         this.hasRights = false;
         return true;
      }
      
      override public function pulled() : Boolean
      {
         return true;
      }
      
      public function set hasRights(b:Boolean) : void
      {
         this._hasRights = b;
         if(b)
         {
            HyperlinkFactory.registerProtocol("admin",HyperlinkAdminManager.addCmd);
            ConsolesManager.registerConsole("debug",new ConsoleHandler(Kernel.getWorker()),new DebugConsoleInstructionRegistar());
         }
         else
         {
            ConsolesManager.registerConsole("debug",new ConsoleHandler(Kernel.getWorker()),new BasicConsoleInstructionRegistar());
         }
      }
      
      override protected function registerMessages() : void
      {
         register(ConsoleMessage,this.onConsoleMessage);
         register(AuthorizedCommandAction,this.onAuthorizedCommandAction);
         register(ConsoleOutputMessage,this.onConsoleOutputMessage);
         register(QuitGameAction,this.onQuitGameAction);
      }
      
      private function onConsoleMessage(cmsg:ConsoleMessage) : Boolean
      {
         ConsolesManager.getConsole("debug").output(cmsg.content,cmsg.type);
         return true;
      }
      
      private function onAuthorizedCommandAction(aca:AuthorizedCommandAction) : Boolean
      {
         var acmsg:AdminCommandMessage = null;
         if(aca.command.substr(0,1) == "/")
         {
            try
            {
               ConsolesManager.getConsole("debug").process(ConsolesManager.getMessage(aca.command));
            }
            catch(ucie:UnhandledConsoleInstructionError)
            {
               ConsolesManager.getConsole("debug").output("Unknown command: " + aca.command + "\n");
            }
         }
         else if(ConnectionsHandler.connectionType != ConnectionType.DISCONNECTED)
         {
            if(this._hasRights)
            {
               if(aca.command.length >= 1 && aca.command.length <= ProtocolConstantsEnum.MAX_CMD_LEN)
               {
                  acmsg = new AdminCommandMessage();
                  acmsg.initAdminCommandMessage(aca.command);
                  ConnectionsHandler.getConnection().send(acmsg);
               }
               else
               {
                  ConsolesManager.getConsole("debug").output("Too long command is too long, try again.");
               }
            }
            else
            {
               ConsolesManager.getConsole("debug").output("You have no admin rights, please use only client side commands. (/help)");
            }
         }
         else
         {
            ConsolesManager.getConsole("debug").output("You are disconnected, use only client side commands.");
         }
         return true;
      }
      
      private function onConsoleOutputMessage(comsg:ConsoleOutputMessage) : Boolean
      {
         var match:* = null;
         var m:* = null;
         var transformText:* = null;
         var params:* = null;
         var className:* = null;
         var dataClass:* = null;
         var fctName:* = null;
         var data:* = null;
         if(comsg.consoleId != "debug")
         {
            return false;
         }
         var validClass:Dictionary = this.getValidClass();
         var t:String = comsg.text;
         var reg:RegExp = /@client\((\w*)\.(\d*)\.(\w*)\)/gm;
         var change:* = true;
         var changeCount:int = 0;
         while(change && changeCount++ < 100)
         {
            match = t.match(reg);
            change = match.length != 0;
            for each(m in match)
            {
               transformText = null;
               params = m.substring(8,m.length - 1).split(".");
               className = validClass[params[0].toLowerCase()];
               if(className != null)
               {
                  dataClass = getDefinitionByName(className);
                  fctName = this.getIdFunction(className);
                  if(fctName != null)
                  {
                     data = dataClass[fctName](parseInt(params[1]));
                     if(data != null)
                     {
                        if(data.hasOwnProperty(params[2]))
                        {
                           transformText = data[params[2]];
                        }
                        else
                        {
                           transformText = m.substr(0,m.length - 1) + ".bad field)";
                        }
                     }
                     else
                     {
                        transformText = m.substr(0,m.length - 1) + ".bad ID)";
                     }
                  }
                  else
                  {
                     transformText = m.substr(0,m.length - 1) + ".not compatible class)";
                  }
               }
               else
               {
                  transformText = m.substr(0,m.length - 1) + ".bad class)";
               }
               t = t.split(m).join(transformText);
            }
         }
         KernelEventsManager.getInstance().processCallback(HookList.ConsoleOutput,t,comsg.type);
         return true;
      }
      
      private function getValidClass() : Dictionary
      {
         var subXML:* = null;
         var varAndAccessors:* = null;
         var dico:Dictionary = new Dictionary();
         var xml:XML = DescribeTypeCache.typeDescription(GameDataList);
         for each(subXML in xml..constant)
         {
            varAndAccessors = this.getSimpleVariablesAndAccessors(String(subXML.@type));
            if(varAndAccessors.indexOf("id") != -1)
            {
               dico[String(subXML.@name).toLowerCase()] = String(subXML.@type);
            }
         }
         return dico;
      }
      
      private function getSimpleVariablesAndAccessors(clazz:String, addVectors:Boolean = false) : Array
      {
         var type:* = null;
         var currentXML:* = null;
         var result:Array = new Array();
         var xml:XML = DescribeTypeCache.typeDescription(getDefinitionByName(clazz));
         for each(currentXML in xml..variable)
         {
            type = String(currentXML.@type);
            if(type == "int" || type == "uint" || type == "Number" || type == "String")
            {
               result.push(String(currentXML.@name));
            }
            if(addVectors)
            {
               if(type.indexOf("Vector.<int>") != -1 || type.indexOf("Vector.<uint>") != -1 || type.indexOf("Vector.<Number>") != -1 || type.indexOf("Vector.<String>") != -1)
               {
                  if(type.split("Vector").length == 2)
                  {
                     result.push(String(currentXML.@name));
                  }
               }
            }
         }
         for each(currentXML in xml..accessor)
         {
            type = String(currentXML.@type);
            if(type == "int" || type == "uint" || type == "Number" || type == "String")
            {
               result.push(String(currentXML.@name));
            }
            if(addVectors)
            {
               if(type.indexOf("Vector.<int>") != -1 || type.indexOf("Vector.<uint>") != -1 || type.indexOf("Vector.<Number>") != -1 || type.indexOf("Vector.<String>") != -1)
               {
                  if(type.split("Vector").length == 2)
                  {
                     result.push(String(currentXML.@name));
                  }
               }
            }
         }
         return result;
      }
      
      private function getIdFunction(clazz:String) : String
      {
         var subXML:* = null;
         var parameterType:* = null;
         var xml:XML = DescribeTypeCache.typeDescription(getDefinitionByName(clazz));
         for each(subXML in xml..method)
         {
            if(subXML.@returnType == clazz && (XMLList(subXML.parameter).length() == 1 || XMLList(subXML.parameter).length() == 2))
            {
               parameterType = String(XMLList(subXML.parameter)[0].@type);
               if(parameterType == "int" || parameterType == "uint")
               {
                  if(String(subXML.@name).indexOf("ById") != -1)
                  {
                     return String(subXML.@name);
                  }
               }
            }
         }
         return null;
      }
      
      private function onQuitGameAction(qga:QuitGameAction) : Boolean
      {
         Dofus.getInstance().quit();
         return true;
      }
   }
}
