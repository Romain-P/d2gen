package com.ankamagames.berilia.uiRender
{
   import com.ankamagames.berilia.enums.XmlAttributesEnum;
   import com.ankamagames.berilia.enums.XmlTagsEnum;
   import com.ankamagames.berilia.managers.TemplateManager;
   import com.ankamagames.berilia.types.event.PreProcessEndEvent;
   import com.ankamagames.berilia.types.event.TemplateLoadedEvent;
   import com.ankamagames.berilia.types.template.TemplateParam;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.managers.LangManager;
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   
   public class XmlPreProcessor extends EventDispatcher
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(XmlPreProcessor));
       
      
      private var _xDoc:XMLDocument;
      
      private var _bMustBeRendered:Boolean = true;
      
      private var _aImportFile:Array;
      
      public function XmlPreProcessor(xDoc:XMLDocument)
      {
         super();
         this._xDoc = xDoc;
      }
      
      public function get importedFiles() : int
      {
         return this._aImportFile.length;
      }
      
      public function processTemplate() : void
      {
         this._aImportFile = new Array();
         TemplateManager.getInstance().addEventListener(TemplateLoadedEvent.EVENT_TEMPLATE_LOADED,this.onTemplateLoaded);
         this.matchImport(this._xDoc.firstChild);
         if(!this._aImportFile.length)
         {
            dispatchEvent(new PreProcessEndEvent(this));
            TemplateManager.getInstance().removeEventListener(TemplateLoadedEvent.EVENT_TEMPLATE_LOADED,this.onTemplateLoaded);
            return;
         }
         for(var i:int = 0; i < this._aImportFile.length; )
         {
            TemplateManager.getInstance().register(this._aImportFile[i]);
            i++;
         }
      }
      
      private function matchImport(node:XMLNode) : void
      {
         var currNode:* = null;
         if(node == null)
         {
            return;
         }
         for(var i:int = 0; i < node.childNodes.length; )
         {
            currNode = node.childNodes[i];
            if(currNode.nodeName == XmlTagsEnum.TAG_IMPORT)
            {
               if(currNode.attributes[XmlAttributesEnum.ATTRIBUTE_URL] == null)
               {
                  _log.warn("Attribute \'" + XmlAttributesEnum.ATTRIBUTE_URL + "\' is missing in " + XmlTagsEnum.TAG_IMPORT + " tag.");
               }
               else
               {
                  this._aImportFile.push(LangManager.getInstance().replaceKey(currNode.attributes[XmlAttributesEnum.ATTRIBUTE_URL]));
               }
               currNode.removeNode();
               i--;
            }
            else if(currNode != null)
            {
               this.matchImport(currNode);
            }
            i++;
         }
      }
      
      private function replaceTemplateCall(node:XMLNode, depthRecursion:int = 0) : Boolean
      {
         var currNode:* = null;
         var currVarNode:* = null;
         var templateNode:* = null;
         var insertedNode:* = null;
         var j:int = 0;
         var s:* = null;
         var n:int = 0;
         var aTmp:* = null;
         var sFileName:* = null;
         var aTemplateVar:* = null;
         var replace:Boolean = false;
         var content:* = null;
         var varNode:* = null;
         var bRes:Boolean = false;
         if(depthRecursion > 128)
         {
            _log.error("replaceTemplateCall : Recursion depth is too high :" + depthRecursion);
            return bRes;
         }
         for(var i:int = 0; i < node.childNodes.length; )
         {
            currNode = node.childNodes[i];
            replace = false;
            for(j = 0; j < this._aImportFile.length; )
            {
               aTmp = this._aImportFile[j].split("/");
               sFileName = aTmp[aTmp.length - 1];
               if(sFileName.toUpperCase() == (currNode.nodeName + ".xml").toUpperCase())
               {
                  aTemplateVar = new Array();
                  for(s in currNode.attributes)
                  {
                     aTemplateVar[s] = new TemplateParam(s,currNode.attributes[s]);
                  }
                  for(n = 0; n < currNode.childNodes.length; n++)
                  {
                     currVarNode = currNode.childNodes[n];
                     content = "";
                     for each(varNode in currVarNode.childNodes)
                     {
                        content = content + varNode;
                     }
                     aTemplateVar[currVarNode.nodeName] = new TemplateParam(currVarNode.nodeName,content);
                  }
                  templateNode = TemplateManager.getInstance().getTemplate(sFileName).makeTemplate(aTemplateVar);
                  for(n = 0; n < templateNode.firstChild.childNodes.length; n++)
                  {
                     insertedNode = templateNode.firstChild.childNodes[n].cloneNode(true);
                     currNode.parentNode.insertBefore(insertedNode,currNode);
                  }
                  currNode.removeNode();
                  currNode = node.childNodes[i];
                  bRes = replace = true;
               }
               j++;
            }
            bRes = this.replaceTemplateCall(currNode,depthRecursion + 1) || bRes;
            i++;
         }
         return bRes;
      }
      
      private function onTemplateLoaded(e:TemplateLoadedEvent) : void
      {
         if(TemplateManager.getInstance().areLoaded(this._aImportFile) && this._bMustBeRendered)
         {
            this._bMustBeRendered = this.replaceTemplateCall(this._xDoc.firstChild);
            if(this._bMustBeRendered)
            {
               this.processTemplate();
            }
            else
            {
               dispatchEvent(new PreProcessEndEvent(this));
               TemplateManager.getInstance().removeEventListener(TemplateLoadedEvent.EVENT_TEMPLATE_LOADED,this.onTemplateLoaded);
            }
         }
      }
   }
}
