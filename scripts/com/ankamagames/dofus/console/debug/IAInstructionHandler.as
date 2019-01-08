package com.ankamagames.dofus.console.debug
{
   import com.ankamagames.atouin.managers.SelectionManager;
   import com.ankamagames.atouin.renderers.ZoneDARenderer;
   import com.ankamagames.atouin.types.Selection;
   import com.ankamagames.atouin.utils.DataMapProvider;
   import com.ankamagames.jerakine.console.ConsoleHandler;
   import com.ankamagames.jerakine.console.ConsoleInstructionHandler;
   import com.ankamagames.jerakine.map.IDataMapProvider;
   import com.ankamagames.jerakine.map.LosDetector;
   import com.ankamagames.jerakine.pathfinding.Pathfinding;
   import com.ankamagames.jerakine.types.Color;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.types.zones.Custom;
   import com.ankamagames.jerakine.types.zones.Lozenge;
   import com.ankamagames.jerakine.utils.display.Dofus1Line;
   import com.ankamagames.jerakine.utils.display.Dofus2Line;
   
   public class IAInstructionHandler implements ConsoleInstructionHandler
   {
       
      
      public function IAInstructionHandler()
      {
         super();
      }
      
      public function handle(console:ConsoleHandler, cmd:String, args:Array) : void
      {
         var s:* = null;
         var cell:* = 0;
         var cellPoint:* = null;
         var range:* = 0;
         var cellsSelection:* = null;
         var lozenge:* = null;
         var cells:* = null;
         var start:* = 0;
         var end:* = 0;
         var endPoint:* = null;
         var startPoint:* = null;
         var cellsPath:* = null;
         var cellsPathSelection:* = null;
         var fromCell:* = 0;
         var fromPoint:* = null;
         var toCell:* = 0;
         var toPoint:* = null;
         var cellsInLine:* = undefined;
         var i:int = 0;
         var map:IDataMapProvider = DataMapProvider.getInstance();
         switch(cmd)
         {
            case "debuglos":
               if(args.length != 2)
               {
                  s = SelectionManager.getInstance().getSelection("CellsFreeForLOS");
                  if(s)
                  {
                     s.remove();
                     console.output("Selection cleared");
                     break;
                  }
                  console.output("Arguments needed : cell and range");
                  break;
               }
               if(args.length == 2)
               {
                  cell = uint(uint(args[0]));
                  cellPoint = MapPoint.fromCellId(cell);
                  range = uint(uint(args[1]));
                  cellsSelection = new Selection();
                  lozenge = new Lozenge(0,range,map);
                  cells = lozenge.getCells(cell);
                  cellsSelection.renderer = new ZoneDARenderer();
                  cellsSelection.color = new Color(26112);
                  cellsSelection.zone = new Custom(LosDetector.getCell(map,cells,cellPoint));
                  SelectionManager.getInstance().addSelection(cellsSelection,"CellsFreeForLOS");
                  SelectionManager.getInstance().update("CellsFreeForLOS");
                  break;
               }
               break;
            case "calculatepath":
            case "tracepath":
               if(args.length != 2)
               {
                  s = SelectionManager.getInstance().getSelection("CellsForPath");
                  if(s)
                  {
                     s.remove();
                     console.output("Selection cleared");
                     break;
                  }
                  console.output("Arguments needed : start and end of the path");
                  break;
               }
               if(args.length == 2)
               {
                  start = uint(uint(args[0]));
                  end = uint(uint(args[1]));
                  endPoint = MapPoint.fromCellId(end);
                  if(map.height == 0 || map.width == 0 || !map.pointMov(endPoint.x,endPoint.y,true))
                  {
                     console.output("Problem with the map or the end.");
                     break;
                  }
                  startPoint = MapPoint.fromCellId(start);
                  cellsPath = Pathfinding.findPath(map,startPoint,endPoint).getCells();
                  if(cmd == "calculatepath")
                  {
                     console.output("Path: " + cellsPath.join(","));
                     break;
                  }
                  cellsPathSelection = new Selection();
                  cellsPathSelection.renderer = new ZoneDARenderer();
                  cellsPathSelection.color = new Color(26112);
                  cellsPathSelection.zone = new Custom(cellsPath);
                  SelectionManager.getInstance().addSelection(cellsPathSelection,"CellsForPath");
                  SelectionManager.getInstance().update("CellsForPath");
                  break;
               }
               break;
            case "debugcellsinline":
               if(args.length != 2)
               {
                  s = SelectionManager.getInstance().getSelection("CellsFreeForLOS");
                  if(s)
                  {
                     s.remove();
                     console.output("Selection cleared");
                     break;
                  }
                  console.output("Arguments needed : cell and cell");
                  break;
               }
               if(args.length == 2)
               {
                  fromCell = uint(uint(args[0]));
                  fromPoint = MapPoint.fromCellId(fromCell);
                  toCell = uint(uint(args[1]));
                  toPoint = MapPoint.fromCellId(toCell);
                  cellsInLine = !!Dofus1Line.useDofus2Line?Dofus2Line.getLine(fromPoint.cellId,toPoint.cellId):Dofus1Line.getLine(fromPoint.x,fromPoint.y,0,toPoint.x,toPoint.y,0);
                  cellsSelection = new Selection();
                  cells = new Vector.<uint>();
                  for(i = 0; i < cellsInLine.length; i++)
                  {
                     cells.push(MapPoint.fromCoords(cellsInLine[i].x,cellsInLine[i].y).cellId);
                  }
                  cellsSelection.renderer = new ZoneDARenderer();
                  cellsSelection.color = new Color(26112);
                  cellsSelection.zone = new Custom(cells);
                  SelectionManager.getInstance().addSelection(cellsSelection,"CellsFreeForLOS");
                  SelectionManager.getInstance().update("CellsFreeForLOS");
                  break;
               }
               break;
         }
      }
      
      public function getHelp(cmd:String) : String
      {
         switch(cmd)
         {
            case "debuglos":
               return "Display all cells which have LOS with the given cell. No argument will clear the selection if any.";
            case "calculatepath":
               return "List all cells of the path between two cellIds.";
            case "tracepath":
               return "Display all cells of the path between two cellIds. No argument will clear the selection if any.";
            case "debugcellsinline":
               return "Display all cells of line between two cellIds. No argument will clear the selection if any.";
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
