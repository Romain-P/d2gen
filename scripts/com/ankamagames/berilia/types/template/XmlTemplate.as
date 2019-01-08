package com.ankamagames.berilia.types.template
{
   import com.ankamagames.berilia.enums.XmlAttributesEnum;
   import com.ankamagames.berilia.enums.XmlTagsEnum;
   import com.ankamagames.jerakine.eval.Evaluator;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import flash.utils.getQualifiedClassName;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   
   public class XmlTemplate
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(XmlTemplate));
      
      private static var _instanceIdInc:int = 0;
       
      
      private var _aTemplateParams:Array;
      
      private var _sXml:String;
      
      private var _xDoc:XMLDocument;
      
      private var _aVariablesStack:Array;
      
      private var _filename:String;
      
      private var _utilsVar:Array;
      
      private var _instanceId:int;
      
      private var _uniqueIdInc:int = 0;
      
      public function XmlTemplate(sXml:String = null, sFilename:String = null)
      {
         this._aVariablesStack = new Array();
         super();
         this._filename = sFilename;
         if(sXml != null)
         {
            this.xml = sXml;
         }
      }
      
      public function get xml() : String
      {
         return this._sXml;
      }
      
      public function set xml(sXml:String) : void
      {
         this._sXml = sXml;
         this.parseTemplate();
      }
      
      public function get filename() : String
      {
         return this._filename;
      }
      
      public function set filename(s:String) : void
      {
         this._filename = s;
      }
      
      public function get templateParams() : Array
      {
         return this._aTemplateParams;
      }
      
      public function get variablesStack() : Array
      {
         return this._aVariablesStack;
      }
      
      public function makeTemplate(aVar:Array) : XMLNode
      {
         var key:* = null;
         var aVariables:* = null;
         var variable:* = null;
         var step:int = 0;
         var evaluator:Evaluator = new Evaluator();
         var newXml:String = this._xDoc.toString();
         var localVar:* = [];
         this.initializeIds();
         for(key in this._aTemplateParams)
         {
            localVar[key] = this._aTemplateParams[key];
         }
         for(key in aVar)
         {
            if(!this._aTemplateParams[key])
            {
               _log.error("Template " + this._filename + ", param " + key + " is not defined");
               delete aVar[key];
            }
            else
            {
               localVar[key] = aVar[key];
            }
         }
         newXml = this.replaceParam(newXml,localVar,"#");
         aVariables = new Array();
         for(key in this._utilsVar)
         {
            aVariables[this._utilsVar[key].name] = this._utilsVar[key];
         }
         for(step = 0; step < this._aVariablesStack.length; step++)
         {
            variable = this._aVariablesStack[step].clone();
            variable.value = evaluator.eval(this.replaceParam(this.replaceParam(variable.value,localVar,"#"),aVariables,"$"));
            aVariables[variable.name] = variable;
         }
         newXml = this.replaceParam(newXml,aVariables,"$");
         var newDoc:XMLDocument = new XMLDocument();
         newDoc.parseXML(newXml);
         return newDoc;
      }
      
      private function initializeIds() : void
      {
         this._instanceId = _instanceIdInc++;
         this._utilsVar = [new TemplateVar("TEMPLATE_INSTANCE_ID",this._filename.replace(".xml","") + "" + this._instanceId),new TemplateVar("UNIQUE_ID",this.getUniqueId)];
      }
      
      private function parseTemplate() : void
      {
         this._xDoc = new XMLDocument();
         this._aTemplateParams = new Array();
         this._xDoc.ignoreWhite = true;
         this._xDoc.parseXML(this._sXml);
         if(this._xDoc.firstChild.nodeName + ".xml" != this._filename)
         {
            _log.error("Wrong root node name in " + this._filename + ", found " + this._xDoc.firstChild.nodeName + ", waiting for " + this._filename.replace(".xml",""));
            return;
         }
         this.matchDynamicsParts(this._xDoc.firstChild);
      }
      
      private function matchDynamicsParts(node:XMLNode) : void
      {
         var currNode:* = null;
         var variable:* = null;
         var param:* = null;
         var n:* = null;
         for(var i:int = 0; i < node.childNodes.length; i++)
         {
            currNode = node.childNodes[i];
            if(currNode.nodeName == XmlTagsEnum.TAG_VAR)
            {
               if(currNode.attributes[XmlAttributesEnum.ATTRIBUTE_NAME])
               {
                  variable = new TemplateVar(currNode.attributes[XmlAttributesEnum.ATTRIBUTE_NAME]);
                  variable.value = currNode.firstChild.toString().replace(/&apos;/g,"\'");
                  this._aVariablesStack.push(variable);
                  currNode.removeNode();
                  i--;
                  continue;
               }
               _log.warn("Template " + this._filename + ", " + currNode.nodeName + " must have [" + XmlAttributesEnum.ATTRIBUTE_NAME + "] attribute");
            }
            if(currNode.nodeName == XmlTagsEnum.TAG_PARAM)
            {
               if(currNode.attributes[XmlAttributesEnum.ATTRIBUTE_NAME])
               {
                  param = new TemplateParam(currNode.attributes[XmlAttributesEnum.ATTRIBUTE_NAME]);
                  this._aTemplateParams[param.name] = param;
                  param.defaultValue = "";
                  if(currNode.hasChildNodes())
                  {
                     for each(n in currNode.childNodes)
                     {
                        param.defaultValue = param.defaultValue + n.toString();
                     }
                  }
                  currNode.removeNode();
                  i--;
               }
               else
               {
                  _log.warn("Template " + this._filename + ", " + currNode.nodeName + " must have [" + XmlAttributesEnum.ATTRIBUTE_NAME + "] attribute");
               }
               continue;
            }
         }
      }
      
      private function replaceParam(txt:String, aVars:Array, prefix:String, recur:uint = 1) : String
      {
         var key:* = null;
         var value:* = undefined;
         var i:int = 0;
         if(!txt)
         {
            return txt;
         }
         var sortedParam:Array = new Array();
         if(aVars["name"])
         {
            if(!aVars["name"].value && aVars["isInstance"])
            {
               aVars["isInstance"].value = true;
            }
            else if(aVars["isInstance"])
            {
               aVars["isInstance"].value = false;
            }
         }
         for(key in aVars)
         {
            sortedParam.push(key);
         }
         sortedParam.sort(Array.DESCENDING);
         for(i = 0; i < sortedParam.length; )
         {
            key = sortedParam[i];
            value = aVars[key];
            if(aVars[key] != null)
            {
               value = aVars[key].value;
               if(value is Function)
               {
                  value = value();
               }
               if(!value && aVars[key] is TemplateParam)
               {
                  value = aVars[key].defaultValue;
               }
               if(value == null)
               {
                  _log.warn("Template " + this._filename + ", no value for " + prefix + key);
               }
               else
               {
                  txt = txt.split(prefix + key).join(value);
                  if(value == "false")
                  {
                     txt = txt.split(prefix + "!" + key).join("true");
                  }
                  if(value == "true")
                  {
                     txt = txt.split(prefix + "!" + key).join("false");
                  }
               }
            }
            i++;
         }
         return txt;
      }
      
      private function getUniqueId() : String
      {
         return this._filename + "_" + this._instanceId + "_" + this._uniqueIdInc++;
      }
   }
}
