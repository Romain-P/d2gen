package com.ankamagames.dofus.modules.utils.pathfinding.world
{
   import com.ankamagames.jerakine.utils.misc.DictionaryUtils;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class WorldGraph
   {
       
      
      private var _vertices:Dictionary;
      
      private var _edges:Dictionary;
      
      private var _outgoingEdges:Dictionary;
      
      public function WorldGraph(data:ByteArray)
      {
         var from:* = null;
         var to:* = null;
         var edge:* = null;
         var transitionCount:int = 0;
         var j:int = 0;
         this._vertices = new Dictionary();
         this._edges = new Dictionary();
         this._outgoingEdges = new Dictionary();
         super();
         var edgeCount:int = data.readInt();
         for(var i:int = 0; i < edgeCount; i++)
         {
            from = this.addVertex(data.readDouble(),data.readInt());
            to = this.addVertex(data.readDouble(),data.readInt());
            edge = this.addEdge(from,to);
            transitionCount = data.readInt();
            for(j = 0; j < transitionCount; j++)
            {
               edge.addTransition(data.readByte(),data.readByte(),data.readInt(),data.readUTFBytes(data.readInt()),data.readDouble(),data.readInt(),data.readDouble());
            }
         }
      }
      
      private static function getInternalEdgeId(from:Vertex, to:Vertex) : String
      {
         return from.UID + "|" + to.UID;
      }
      
      public function countVertices() : int
      {
         return DictionaryUtils.getLength(this._vertices);
      }
      
      public function getVertices() : Vector.<Vertex>
      {
         return this._vertices.values();
      }
      
      public function getEdges() : Dictionary
      {
         return this._edges;
      }
      
      public function countEdges() : int
      {
         return DictionaryUtils.getLength(this._edges);
      }
      
      public function countTransitions() : int
      {
         var edge:* = null;
         var count:int = 0;
         for each(edge in this._edges)
         {
            count = count + edge.countTransitions();
         }
         return count;
      }
      
      public function countTransitionWithValidDirections() : int
      {
         var edge:* = null;
         var count:int = 0;
         for each(edge in this._edges)
         {
            count = count + edge.countTransitionWithValidDirections();
         }
         return count;
      }
      
      public function addVertex(mapId:Number, zone:int) : Vertex
      {
         var vertex:Vertex = this._vertices[Vertex.getVertexUID(mapId,zone)];
         if(vertex == null)
         {
            vertex = new Vertex(mapId,zone);
            this._vertices[vertex.UID] = vertex;
         }
         return vertex;
      }
      
      public function getVertex(mapId:Number, mapRpZone:int) : Vertex
      {
         return this._vertices[Vertex.getVertexUID(mapId,mapRpZone)];
      }
      
      public function getVertexFromUID(vertexUID:String) : Vertex
      {
         return this._vertices[vertexUID];
      }
      
      public function getOutgoingEdgesFromVertex(from:Vertex) : Vector.<Edge#156>
      {
         return this._outgoingEdges[from.UID];
      }
      
      public function getOutgoingEdgesFromMap(mapId:Number, zone:int) : Vector.<Edge#156>
      {
         var v:Vertex = this.getVertex(mapId,zone);
         if(v == null)
         {
            return null;
         }
         return this.getOutgoingEdgesFromVertex(v);
      }
      
      public function hasEdge(from:Vertex, to:Vertex) : Boolean
      {
         return this.getEdge(from,to) != null;
      }
      
      public function getEdge(from:Vertex, to:Vertex) : Edge#156
      {
         return this._edges[getInternalEdgeId(from,to)];
      }
      
      public function addEdge(from:Vertex, to:Vertex) : Edge#156
      {
         var edge:Edge = this.getEdge(from,to);
         if(edge != null)
         {
            return edge;
         }
         if(!this.doesVertexExist(from) || !this.doesVertexExist(to))
         {
            return null;
         }
         edge = new Edge#156(from,to);
         var internalId:String = getInternalEdgeId(from,to);
         this._edges[internalId] = edge;
         var outgoing:Vector.<Edge> = this._outgoingEdges[from.UID];
         if(outgoing == null)
         {
            outgoing = new Vector.<Edge#156>();
            this._outgoingEdges[from.UID] = outgoing;
         }
         outgoing.push(edge);
         return edge;
      }
      
      public function doesVertexExist(v:Vertex) : Boolean
      {
         return v.UID in this._vertices;
      }
      
      public function getMapIdFromVertexUid(vertexUid:String) : Number
      {
         var vertex:Vertex = this._vertices[vertexUid];
         return vertex == null?0:Number(vertex.mapId);
      }
      
      public function getVertexUid(mapId:Number, mapRpZone:int) : String
      {
         var vertex:Vertex = this.getVertex(mapId,mapRpZone);
         return vertex == null?null:vertex.UID;
      }
   }
}
