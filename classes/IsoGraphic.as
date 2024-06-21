//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com

package {
	
	import flash.display.MovieClip;
	import flash.ui.Mouse;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.geom.Rectangle;
	import flash.display.*;
	import fl.controls.Slider;
	import fl.controls.Label;
	import fl.events.SliderEvent;
	import fl.containers.ScrollPane;
	import fl.controls.Button;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.system.System;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import fl.controls.NumericStepper;
	import flash.geom.Matrix;
	import flash.system.Security;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import fl.controls.ButtonLabelPlacement;

	
	public class IsoGraphic extends MovieClip {
		var dataManager:DataManager;
		var game:Object;
		var map:Map;
		var worldTile:Array=new Array();
		var tileList:Array;
		var tileEditor:MovieClip= new MovieClip();
		var tileEditorTool:MovieClip= new MovieClip();
		var addTileEditorTool:MovieClip= null;
		var pictLdr:Loader;
		var pictLoad:Bitmap;
		var tileTarget=null;
		var tileListTarget=null;
		var firstPoint:Point=null;
		var tilePoint:Point;
		var scrollPane:ScrollPane;
		var mapText:TextField;
		public var offsetZ:Number;
		private var file:FileReference;
		var Memory:TextField = new TextField();
		var FPS:TextField = new TextField();
		var currentTime:int=0;
		var performanceTimer:Timer=new Timer(100,0);
	
		//----- Iso Graphic  -----------------------------------
		public function IsoGraphic(_dataManager:DataManager):void {
			newMap(_dataManager);
			tileTarget=null;
		}
		//----- New Map  -----------------------------------
		public function newMap(_dataManager:DataManager):void {
			initVar(_dataManager);
			initWorld();
			initEditor();
			initPerformance();
		}
		//----- Init Var -----------------------------------
		public function initVar(_dataManager:DataManager):void {
			dataManager=_dataManager;
			game=_dataManager.getGame();
			map=_dataManager.getMap();
			tilePoint =new Point(0,0);
		}
		//----- Init World -----------------------------------
		public function initWorld():void {
			scrollPane= new ScrollPane();
			initMap();
			centerMap();
		}
		//----- Init Map -----------------------------------
		public function initMap():void{
			initWorldTile();
			initScrollPane();			
			initOffset();
		}
		//----- Init World Tile -----------------------------------
		public function initWorldTile():void {
			worldTile=new Array(game.map.mapHeight);
			for (var j=0; j<game.map.mapHeight; j++) {
				worldTile[j]=new Array(game.map.mapWidth);
				for (var i=0; i<game.map.mapWidth; i++) {
					worldTile[j][i] = new MovieClip();
					var tile:MovieClip = worldTile[j][i];
					tile.x = i * game.tileWidth - j * game.tileHeight;
					tile.y = (i * game.tileWidth + j * game.tileHeight)/2;
					addTile(j,i,-1);
				}
			}
		}
		//----- Init Offset -----------------------------------
		public function initOffset():void {
			var graphicTileTable = dataManager.getGraphicTileTable();
			offsetZ = game.map.mapHigh*graphicTileTable[0][3];
		}
		//----- Init Scroll Pane -----------------------------------
		public function initScrollPane():void {
			addChild(scrollPane);
			scrollPane.source= map;
			scrollPane.setSize(520, 400);
			scrollPane.y+=20;
		}
		//----- Show World Tile Depth -----------------------------------
		public function showWorldTileDepth():void {
			for (var j=0; j<game.map.mapHeight; j++) {
				var depthTable = new Array();
				for (var i=0; i<game.map.mapWidth ; i++) {
					var tile:MovieClip = worldTile[j][i];
					depthTable.push(map.getChildIndex(tile));
				}
				if(depthTable.length>0){
					trace(depthTable);
				}
			}
		}
		//----- Display Tiles -----------------------------------
		public function displayTiles(_tileArray:Array, j , i) :void{
			var tile:MovieClip= worldTile[j][i];
			tile.mouseEnabled=true;
			copyTiles(tile, _tileArray);
		}
		//----- Add Tile -----------------------------------
		public function addTile(j:Number,i:Number,index:Number) :MovieClip{
			var tile:MovieClip= worldTile[j][i];
			swapTile(j,i);
			tile.transform.colorTransform = new ColorTransform(game.map.R,game.map.G,game.map.B,1,0,0,0,0);
			if(index == -1){
				map.addChild(tile);
			}else{
				map.addChildAt(tile,index);
			}
			return tile;
		}
		//----- Remove Tile -----------------------------------
		public function removeTile(j:Number,i:Number) :void{
			var tile:MovieClip= worldTile[j][i];
			if(map.contains(tile)){
				map.removeChild(tile);
			}
		}
		//----- Swap Tile -----------------------------------
		public function swapTile(j:Number,i:Number) :void{
			var tileArray:Array = new Array();
			for(var k=0; k<game.map.mapHigh; k++){
				tileArray.push(map.tileTable[k][j][i]);
			}
			displayTiles(tileArray,j,i);
			updateTileElevation(j,i);
		}
		//----- Update Elevation -----------------------------------
		public function updateTileElevation(j:Number,i:Number) :void{
			var tile:MovieClip= worldTile[j][i];
			tile.y = (i * game.tileWidth + j * game.tileHeight)/2- map.tileTable[0][j][i].elevation;
		}
		//----- Swap Depth -----------------------------------
		public function swapDepth(_tile:MovieClip,index:Number) :void{
			map.setChildIndex(_tile,index);
		}
		//----- Change Tile -----------------------------------
		public function changeTile(k:Number,j:Number,i:Number,frame:Number,frameSet:Number) :void{
			map.tileTable[k][j][i].frame=frame;
			map.tileTable[k][j][i].frameSet=frameSet;
			swapTile(j,i);
			if(map.tileTable[k][j][i].frame==99){
				map.tileTable[k][j][i].frame=0;
			}
		}
		//----- Change Tiles -----------------------------------
		public function changeTiles(k:Number,minJ:Number,minI:Number,maxJ:Number,maxI:Number,frame:Number,frameSet:Number, flip:Boolean) :void{
			for( var j=minJ; j<=maxJ;j++){
				for( var i=minI; i<=maxI;i++){
					if(tileEditor.tileLayer==0){
						map.tileTable[k][j][i].frame=frame;
						map.tileTable[k][j][i].frameSet=frameSet;
						map.tileTable[k][j][i].tileFlip=flip;
					}else if(tileEditor.tileLayer==1){
						map.tileTable[k][j][i].addFrame=frame;
						map.tileTable[k][j][i].addFrameSet=frameSet;
						map.tileTable[k][j][i].addTileFlip=flip;
					}else if(tileEditor.tileLayer==2){
						map.tileTable[k][j][i].objectInsideFrame=frame;
						map.tileTable[k][j][i].objectInsideFrameSet=frameSet;
						map.tileTable[k][j][i].objectInsideFlip=flip;
					}else if(tileEditor.tileLayer==3){
						map.tileTable[k][j][i].objectOutsideFrame=frame;
						map.tileTable[k][j][i].objectOutsideFrameSet=frameSet;
						map.tileTable[k][j][i].objectOutsideFlip=flip;
					}
					updateTileProperties(k,j,i);
					if(addTileEditorTool!=null && this.contains(addTileEditorTool)){
						showTileProperties(k,j,i);
					}
					swapTile(j,i);
				}
			}
		}
		//----- Update Properties -----------------------------------
		public function updateProperties(k:Number,minJ:Number,minI:Number,maxJ:Number,maxI:Number) :void{
			for( var j=minJ; j<=maxJ;j++){
				for( var i=minI; i<=maxI;i++){
					updateTileProperties(k,j,i);
					if(addTileEditorTool!=null && this.contains(addTileEditorTool)){
						showTileProperties(k,j,i);
						swapTile(j,i);
					}
				}
			}
		}
		//----- Update Tile Properties -----------------------------------
		public function updateTileProperties(k:Number,j:Number,i:Number) :void{
			var tile = map.tileTable[k][j][i];
			tile.cleanProperties();
			if(addTileEditorTool==null || !this.contains(addTileEditorTool)){
				tile.walkable=true;
				tile.elevation=0;
			}else{
				tile.walkable=addTileEditorTool.walkable.selected;
				if(addTileEditorTool.elevation.selected){
					tile.elevation=addTileEditorTool.elevationLevel.value;
				}
			}
			if(addTileEditorTool!=null && this.contains(addTileEditorTool) && addTileEditorTool.slopes.selected ){
				tile.slopes=addTileEditorTool.slopes.selected;
				tile.tileProperty=1;
				tile.slopesDirection = Math.pow(10,addTileEditorTool.slopesComboBox.selectedIndex);
			}
			if(addTileEditorTool!=null && this.contains(addTileEditorTool) && addTileEditorTool.ladder.selected){
				tile.ladder=addTileEditorTool.ladder.selected;
				tile.tileProperty=2;
				tile.ladderDirection = bools2String(addTileEditorTool.ladderDirection.DR.selected,addTileEditorTool.ladderDirection.DL.selected,addTileEditorTool.ladderDirection.UR.selected,addTileEditorTool.ladderDirection.UL.selected,false,false,addTileEditorTool.ladderDirection.BH.selected,addTileEditorTool.ladderDirection.BV.selected);
				//trace(tile.ladderDirection); 
			}
			if(addTileEditorTool!=null && this.contains(addTileEditorTool) && addTileEditorTool.slide.selected){
				tile.slide=addTileEditorTool.slide.selected;
				tile.tileProperty=3;
				tile.slideDirection =  Math.pow(10,addTileEditorTool.slideComboBox.selectedIndex);
				//trace(tile.slideDirection); 
			}
			if(addTileEditorTool!=null && this.contains(addTileEditorTool) && addTileEditorTool.bounce.selected){
				tile.bounce=addTileEditorTool.bounce.selected;
				tile.tileProperty=4;
				tile.bounceDirection = bools2String(addTileEditorTool.bounceDirection.DR.selected,addTileEditorTool.bounceDirection.DL.selected,addTileEditorTool.bounceDirection.UR.selected,addTileEditorTool.bounceDirection.UL.selected,addTileEditorTool.bounceDirection.High.selected,addTileEditorTool.bounceDirection.Deep.selected,false,false);
				//trace(tile.bounceDirection); 
			}
			if(addTileEditorTool!=null && this.contains(addTileEditorTool) && addTileEditorTool.teleport.selected){
				tile.teleport=addTileEditorTool.teleport.selected;
				tile.tileProperty=5;
				tile.teleportDestination = addTileEditorTool.teleportDestination.destX.value+addTileEditorTool.teleportDestination.destY.value*100+addTileEditorTool.teleportDestination.destZ.value*10000;
				//trace(tile.teleportDestination);
			}
		}
		//----- Dec 2 Bin -----------------------------------
		public function dec2bin(iNumber:Number):String  {
			//-- From http://www.kirupa.com
			var bin:String = "";
			var oNumber:Number = iNumber;
			while (iNumber>0) {
				if (iNumber%2) {
					bin = "1"+bin;
				} else {
					bin = "0"+bin;
				}
				iNumber = Math.floor(iNumber/2);
			}
			/*while (bin.length<8) {
				bin = "0"+bin;
			}*/
			return bin;
		} 
		//----- Bool 2 Char -----------------------------------
		public function bools2String(_DR:Boolean,_DL:Boolean,_UR:Boolean,_UL:Boolean,_High:Boolean,_Deep:Boolean,_BH:Boolean,_BV:Boolean):String  {
			var string:String = Number(_BV).toString()+Number(_BH).toString()+Number(_Deep).toString()+Number(_High).toString()+Number(_UL).toString()+Number(_UR).toString()+Number(_DL).toString()+Number(_DR).toString();
			string = Number(string).toString();
			return string;
		} 
		//----- Clean Tiles -----------------------------------
		public function cleanTiles() :void{
			for( var j=0; j<game.map.mapHeight;j++){
				for( var i=0; i<game.map.mapWidth;i++){
					for( var k=0; k<game.map.mapHigh;k++){
						map.tileTable[k][j][i].addFrame=0;
						map.tileTable[k][j][i].addFrameSet=0;
						map.tileTable[k][j][i].objectInsideFrame=0;
						map.tileTable[k][j][i].objectInsideFrameSet=0;
						map.tileTable[k][j][i].objectOutsideFrame=0;
						map.tileTable[k][j][i].objectOutsideFrameSet=0;
						map.tileTable[k][j][i].cleanProperties();
						if(k==0){
							map.tileTable[k][j][i].frame=1;
							map.tileTable[k][j][i].frameSet=0;
							swapTile(j,i);
						}else{
							map.tileTable[k][j][i].frame=99;
							swapTile(j,i);
							map.tileTable[k][j][i].frame=0;
							map.tileTable[k][j][i].frameSet=0;
						}
					}
				}
			}
		}
		//----- Flip Tiles Frames-----------------------------------
		public function flipTilesFrame() :void{
			for( var j=0; j<game.map.mapHeight;j++){
				for( var i=0; i<game.map.mapWidth;i++){
					for( var k=0; k<game.map.mapHigh;k++){
						var tile = map.tileTable[k][j][i];
						tile.tileFlip=!tile.tileFlip;
						tile.addTileFlip=!tile.addTileFlip;
						tile.objectInsideFlip=!tile.objectInsideFlip;
						tile.objectOutsideFlip=!tile.objectOutsideFlip;
					}
					swapTile(j,i);
				}
			}
		}
		//----- Flip Tiles Position Horizontal-----------------------------------
		public function flipTilesPositionH() :void{
			for( var j=0; j<game.map.mapHeight;j++){
				for( var i=0; i<game.map.mapWidth;i++){
					if(i<game.map.mapWidth/2-1){
						for( var k=0; k<game.map.mapHigh;k++){
							swapTiles(k,j,i,k,j,game.map.mapWidth-i-1);
						}
					}
					swapTile(j,i);
				}
			}
		}
		//----- Flip Tiles Position Vertical-----------------------------------
		public function flipTilesPositionV() :void{
			for( var j=0; j<game.map.mapHeight;j++){
				for( var i=0; i<game.map.mapWidth;i++){
					if(j<game.map.mapHeight/2-1){
						for( var k=0; k<game.map.mapHigh;k++){
							swapTiles(k,j,i,k,game.map.mapWidth-j-1,i);
						}
					}
					swapTile(j,i);
				}
			}
		}
		//----- Swap Tiles -----------------------------------
		public function swapTiles(k:Number,j:Number,i:Number,kk:Number,jj:Number, ii:Number):void{
			//-- Frame
			var tmp = map.tileTable[k][j][i].frame;
			map.tileTable[k][j][i].frame=map.tileTable[kk][jj][ii].frame;
			map.tileTable[kk][jj][ii].frame = tmp;
			//-- Add Frame
			tmp = map.tileTable[k][j][i].addFrame;
			map.tileTable[k][j][i].addFrame=map.tileTable[kk][jj][ii].addFrame;
			map.tileTable[kk][jj][ii].addFrame = tmp;
			//-- Object Inside Frame
			tmp = map.tileTable[k][j][i].objectInsideFrame;
			map.tileTable[k][j][i].objectInsideFrame=map.tileTable[kk][jj][ii].objectInsideFrame;
			map.tileTable[kk][jj][ii].objectInsideFrame = tmp;
			//-- Object Outside Frame
			tmp = map.tileTable[k][j][i].objectOutsideFrame;
			map.tileTable[k][j][i].objectOutsideFrame=map.tileTable[kk][jj][ii].objectOutsideFrame;
			map.tileTable[kk][jj][ii].objectOutsideFrame = tmp;
			//-- Frame Set
			tmp = map.tileTable[k][j][i].frameSet;
			map.tileTable[k][j][i].frameSet=map.tileTable[kk][jj][ii].frameSet;
			map.tileTable[kk][jj][ii].frameSet = tmp;
			//-- Add Frame Set
			tmp = map.tileTable[k][j][i].addFrameSet;
			map.tileTable[k][j][i].addFrameSet=map.tileTable[kk][jj][ii].addFrameSet;
			map.tileTable[kk][jj][ii].addFrameSet = tmp;
			//-- Object Frame Set
			tmp = map.tileTable[k][j][i].objectFrameSet;
			map.tileTable[k][j][i].objectFrameSet=map.tileTable[kk][jj][ii].objectFrameSet;
			map.tileTable[kk][jj][ii].objectFrameSet = tmp;
			//-- Tile Flip
			tmp = map.tileTable[k][j][i].tileFlip;
			map.tileTable[k][j][i].tileFlip=map.tileTable[kk][jj][ii].tileFlip;
			map.tileTable[kk][jj][ii].tileFlip = tmp;
			//-- Add Tile Flip
			tmp = map.tileTable[k][j][i].addTileFlip;
			map.tileTable[k][j][i].addTileFlip=map.tileTable[kk][jj][ii].addTileFlip;
			map.tileTable[kk][jj][ii].addTileFlip = tmp;
			//-- Object Inside Flip
			tmp = map.tileTable[k][j][i].objectInsideFlip;
			map.tileTable[k][j][i].objectInsideFlip=map.tileTable[kk][jj][ii].objectInsideFlip;
			map.tileTable[kk][jj][ii].objectInsideFlip = tmp;
			//-- Object Outside Flip
			tmp = map.tileTable[k][j][i].objectOutsideFlip;
			map.tileTable[k][j][i].objectOutsideFlip=map.tileTable[kk][jj][ii].objectOutsideFlip;
			map.tileTable[kk][jj][ii].objectOutsideFlip = tmp;
			//-- Tile Property
			tmp = map.tileTable[k][j][i].tileProperty;
			map.tileTable[k][j][i].tileProperty=map.tileTable[kk][jj][ii].tileProperty;
			map.tileTable[kk][jj][ii].tileProperty = tmp;
			//-- Tile Walkable
			tmp = map.tileTable[k][j][i].walkable;
			map.tileTable[k][j][i].walkable=map.tileTable[kk][jj][ii].walkable;
			map.tileTable[kk][jj][ii].walkable = tmp;
			//-- Tile Slopes
			tmp = map.tileTable[k][j][i].slopes;
			map.tileTable[k][j][i].slopes=map.tileTable[kk][jj][ii].slopes;
			map.tileTable[kk][jj][ii].slopes = tmp;
			//-- Tile Slopes Direction
			tmp = map.tileTable[k][j][i].slopesDirection;
			map.tileTable[k][j][i].slopesDirection=map.tileTable[kk][jj][ii].slopesDirection;
			map.tileTable[kk][jj][ii].slopesDirection = tmp;
			//-- Tile Ladder 
			tmp = map.tileTable[k][j][i].ladder;
			map.tileTable[k][j][i].ladder=map.tileTable[kk][jj][ii].ladder;
			map.tileTable[kk][jj][ii].ladder = tmp;
			//-- Tile Ladder Direction
			tmp = map.tileTable[k][j][i].ladderDirection;
			map.tileTable[k][j][i].ladderDirection=map.tileTable[kk][jj][ii].ladderDirection;
			map.tileTable[kk][jj][ii].ladderDirection = tmp;
			//-- Tile Slide 
			tmp = map.tileTable[k][j][i].slide;
			map.tileTable[k][j][i].slide=map.tileTable[kk][jj][ii].slide;
			map.tileTable[kk][jj][ii].slide = tmp;
			//-- Tile Slide Direction
			tmp = map.tileTable[k][j][i].slideDirection;
			map.tileTable[k][j][i].slideDirection=map.tileTable[kk][jj][ii].slideDirection;
			map.tileTable[kk][jj][ii].slideDirection = tmp;
			//-- Tile Bouce 
			tmp = map.tileTable[k][j][i].bounce;
			map.tileTable[k][j][i].bounce=map.tileTable[kk][jj][ii].bounce;
			map.tileTable[kk][jj][ii].bounce = tmp;
			//-- Tile Bounce Direction
			tmp = map.tileTable[k][j][i].bounceDirection;
			map.tileTable[k][j][i].bounceDirection=map.tileTable[kk][jj][ii].bounceDirection;
			map.tileTable[kk][jj][ii].bounceDirection = tmp;
			//-- Tile Teleport 
			tmp = map.tileTable[k][j][i].teleport;
			map.tileTable[k][j][i].teleport=map.tileTable[kk][jj][ii].teleport;
			map.tileTable[kk][jj][ii].teleport = tmp;
			//-- Tile Teleport Destination
			tmp = map.tileTable[k][j][i].teleportDestination;
			map.tileTable[k][j][i].teleportDestination=map.tileTable[kk][jj][ii].teleportDestination;
			map.tileTable[kk][jj][ii].teleportDestination = tmp;		
		}
		//----- Calculate Depth -----------------------------------
		public function calculateDepth(j:Number,i:Number) :Number{
			var depth:Number = i + j*game.map.mapWidth;
			return depth;
		}
		//----- Copy Tiles -----------------------------------
		public function copyTiles(_worldTile:MovieClip, _tileArray:Array):void {
			var graphicTileTable:Array = dataManager.getGraphicTileTable();
			var graphicAddTileTable:Array  = dataManager.getGraphicAddTileTable();
			var graphicObjectTable:Array  = dataManager.getGraphicObjectTable();
			var textureMaxHeight:Number = dataManager.getTextureMaxHeight();
			for each (var tile in _tileArray){
				if(tile.frame!=0 || tile.addFrame!=0 || tile.objectInsideFrame!=0 || tile.objectOutsideFrame!=0){
					var pictLoad=Bitmap(graphicTileTable[tile.frameSet][0].content);
					if(graphicAddTileTable.length>0){
						var pictLoadAdd=Bitmap(graphicAddTileTable[tile.addFrameSet][0].content);
					}
					if(graphicObjectTable.length>0){
						var pictLoadObjectInside=Bitmap(graphicObjectTable[tile.objectInsideFrameSet][0].content);
						var pictLoadObjectOutside=Bitmap(graphicObjectTable[tile.objectOutsideFrameSet][0].content);
					}
					if(tile.position.ztile==0){
						if(_worldTile.bitmapData == undefined){
							var myBitmapData:BitmapData = new BitmapData(graphicObjectTable[tile.objectInsideFrameSet][1],textureMaxHeight + (_tileArray.length-1)*game.tileHigh, true, 0);
						}else{
							myBitmapData = new BitmapData(graphicObjectTable[tile.objectInsideFrameSet][1],textureMaxHeight + (_tileArray.length-1)*game.tileHigh, true, 0);
							_worldTile.bm.bitmapData=myBitmapData;
						}
					}
					var x=(tile.frame-1)% graphicTileTable[tile.frameSet][3];
					var y=Math.floor((tile.frame-1)/(graphicTileTable[tile.frameSet][3]));
					var z=tile.position.ztile; 
					if(tile.tileFlip){
						var myFlipBitmapData:BitmapData = new BitmapData(graphicObjectTable[tile.objectInsideFrameSet][1],textureMaxHeight + (_tileArray.length-1)*game.tileHigh, true, 0);
						myFlipBitmapData.copyPixels(pictLoad.bitmapData, new Rectangle(x * graphicTileTable[tile.frameSet][1],y * graphicTileTable[tile.frameSet][2],graphicTileTable[tile.frameSet][1],graphicTileTable[tile.frameSet][2]), new Point(0, textureMaxHeight + (_tileArray.length-1)*game.tileHigh -z * game.tileHigh- graphicTileTable[tile.frameSet][2]),null,null,true);
						flipBitmapData(myFlipBitmapData);
						myBitmapData.draw(myFlipBitmapData);
					}else{
						myBitmapData.copyPixels(pictLoad.bitmapData, new Rectangle(x * graphicTileTable[tile.frameSet][1],y * graphicTileTable[tile.frameSet][2],graphicTileTable[tile.frameSet][1],graphicTileTable[tile.frameSet][2]), new Point(0, textureMaxHeight + (_tileArray.length-1)*game.tileHigh -z * game.tileHigh- graphicTileTable[tile.frameSet][2]),null,null,true);
					}
					if(graphicAddTileTable.length>0 && tile.addFrame!=0){
						var xAdd=(tile.addFrame-1)%graphicAddTileTable[tile.addFrameSet][3];
						var yAdd=Math.floor((tile.addFrame-1)/(graphicAddTileTable[tile.addFrameSet][3]));
						var zAdd=tile.position.ztile; 
						if(tile.addTileFlip){
							myFlipBitmapData = new BitmapData(graphicObjectTable[tile.objectInsideFrameSet][1],textureMaxHeight + (_tileArray.length-1)*game.tileHigh, true, 0);
							myFlipBitmapData.copyPixels(pictLoadAdd.bitmapData, new Rectangle(xAdd * graphicAddTileTable[tile.addFrameSet][1],yAdd * graphicAddTileTable[tile.addFrameSet][2],graphicAddTileTable[tile.addFrameSet][1],graphicAddTileTable[tile.addFrameSet][2]), new Point(0, textureMaxHeight + (_tileArray.length-1)*game.tileHigh -z * game.tileHigh- graphicAddTileTable[tile.addFrameSet][2]),null,null,true);
							flipBitmapData(myFlipBitmapData);
							myBitmapData.draw(myFlipBitmapData);
						}else{
							myBitmapData.copyPixels(pictLoadAdd.bitmapData, new Rectangle(xAdd * graphicAddTileTable[tile.addFrameSet][1],yAdd * graphicAddTileTable[tile.addFrameSet][2],graphicAddTileTable[tile.addFrameSet][1],graphicAddTileTable[tile.addFrameSet][2]), new Point(0, textureMaxHeight + (_tileArray.length-1)*game.tileHigh -zAdd * game.tileHigh - graphicAddTileTable[tile.addFrameSet][2]),null,null,true);	
						}
					}
					if(graphicObjectTable.length>0 && tile.objectInsideFrame!=0){
						var xObj=(tile.objectInsideFrame-1)%graphicObjectTable[tile.objectInsideFrameSet][3];
						var yObj=Math.floor((tile.objectInsideFrame-1)/(graphicObjectTable[tile.objectInsideFrameSet][3]));
						var zObj=tile.position.ztile;
						if(tile.objectInsideFlip){
							myFlipBitmapData = new BitmapData(graphicObjectTable[tile.objectInsideFrameSet][1],textureMaxHeight + (_tileArray.length-1)*game.tileHigh, true, 0);
							myFlipBitmapData.copyPixels(pictLoadObjectInside.bitmapData, new Rectangle(xObj * graphicObjectTable[tile.objectInsideFrameSet][1],yObj * graphicObjectTable[tile.objectInsideFrameSet][2],graphicObjectTable[tile.objectInsideFrameSet][1],graphicObjectTable[tile.objectInsideFrameSet][2]), new Point(0, textureMaxHeight + (_tileArray.length-1)*game.tileHigh -z * game.tileHigh- graphicObjectTable[tile.objectInsideFrameSet][2]),null,null,true);
							flipBitmapData(myFlipBitmapData);
							myBitmapData.draw(myFlipBitmapData);
						}else{
							myBitmapData.copyPixels(pictLoadObjectInside.bitmapData, new Rectangle(xObj * graphicObjectTable[tile.objectInsideFrameSet][1],yObj * graphicObjectTable[tile.objectInsideFrameSet][2],graphicObjectTable[tile.objectInsideFrameSet][1],graphicObjectTable[tile.objectInsideFrameSet][2]), new Point(0,textureMaxHeight + (_tileArray.length-1)*game.tileHigh -zObj * game.tileHigh - graphicObjectTable[tile.objectInsideFrameSet][2]),null,null,true);	
						}
					}
					if(graphicObjectTable.length>0 && tile.objectOutsideFrame!=0 && !tileEditorTool.inside.selected){
						xObj=(tile.objectOutsideFrame-1)%graphicObjectTable[tile.objectOutsideFrameSet][3];
						yObj=Math.floor((tile.objectOutsideFrame-1)/(graphicObjectTable[tile.objectOutsideFrameSet][3]));
						zObj=tile.position.ztile;
						if(tile.objectOutsideFlip){
							myFlipBitmapData = new BitmapData(graphicObjectTable[tile.objectInsideFrameSet][1],textureMaxHeight + (_tileArray.length-1)*game.tileHigh, true, 0);
							myFlipBitmapData.copyPixels(pictLoadObjectOutside.bitmapData, new Rectangle(xObj * graphicObjectTable[tile.objectOutsideFrameSet][1],yObj * graphicObjectTable[tile.objectOutsideFrameSet][2],graphicObjectTable[tile.objectOutsideFrameSet][1],graphicObjectTable[tile.objectOutsideFrameSet][2]), new Point(0, textureMaxHeight + (_tileArray.length-1)*game.tileHigh -z * game.tileHigh- graphicObjectTable[tile.objectOutsideFrameSet][2]),null,null,true);
							flipBitmapData(myFlipBitmapData);
							myBitmapData.draw(myFlipBitmapData);
						}else{
							myBitmapData.copyPixels(pictLoadObjectOutside.bitmapData, new Rectangle(xObj * graphicObjectTable[tile.objectOutsideFrameSet][1],yObj * graphicObjectTable[tile.objectOutsideFrameSet][2],graphicObjectTable[tile.objectOutsideFrameSet][1],graphicObjectTable[tile.objectOutsideFrameSet][2]), new Point(0,textureMaxHeight + (_tileArray.length-1)*game.tileHigh -zObj * game.tileHigh - graphicObjectTable[tile.objectOutsideFrameSet][2]),null,null,true);	
						}
					}
					colorBitmapData(myBitmapData, tile.R, tile.G, tile.B, 100);
				}
			}
			if(_worldTile.bitmapData == undefined){
				var bm:Bitmap = new Bitmap(myBitmapData);
				_worldTile.bitmapData= myBitmapData;
				_worldTile.bm = _worldTile.addChild(bm);
				
			}
		}
		//----- Color Bitmap Data -----------------------------------
		public function colorBitmapData(myBitmapData:BitmapData, R:Number,G:Number,B:Number,A:Number):void {
			var resultColorTransform:ColorTransform=new ColorTransform(R,G,B,A,0,0,0,0);
			myBitmapData.colorTransform(myBitmapData.rect, resultColorTransform);
		}
		//----- Flip BitmapData  -----------------------------------
		public function flipBitmapData(myBitmapData:BitmapData):void {
			var flipHorizontalMatrix:Matrix = new Matrix();
			flipHorizontalMatrix.scale(-1,1)
			flipHorizontalMatrix.translate(myBitmapData.width,0);
			var flippedBitmapData:BitmapData = new BitmapData(myBitmapData.width,myBitmapData.height,true,0)
			flippedBitmapData.draw(myBitmapData,flipHorizontalMatrix);
			myBitmapData.fillRect(myBitmapData.rect,0);
			myBitmapData.draw(flippedBitmapData);
		}
		//----- Center Map -----------------------------------
		public function centerMap():void {
			map.x=map.width/2-30*map.scaleX;			
			map.y=-offsetZ*map.scaleY;
		}
		//----- Blit Right -----------------------------------
		public function blitRight() :void{
			for (var j=0; j<game.map.mapHeight; j++) {
				var index:Number= (game.map.mapWidth+1)*j;
				addTile(j,game.map.mapWidth-1,-1);
			}
		}
		//----- Blit Left -----------------------------------
		public function blitLeft() :void{
			for (var j=0; j<game.map.mapHeight; j++) {
				removeTile(j,game.map.mapWidth-1);
			}
		}
		//----- Blit Down -----------------------------------
		public function blitDown() :void{
			for (var i:Number=0; i<game.map.mapWidth-1; i++) {
				var index:Number=(game.map.mapWidth*game.map.mapHeight)+i+1;
				addTile(game.map.mapHeight-1,i,-1);
			}			
		}
		//----- Blit Up -----------------------------------
		public function blitUp() :void{
			for (var i=0; i<game.map.mapWidth; i++) {
				removeTile(game.map.mapHeight-1,i);
			}
		}
		//----- Zoom In -----------------------------------
		public function zoomIn():void {
			if (game.map.mapWidth>2 && game.map.mapHeight>2) {
				blitLeft();
				blitUp();
				centerMap();
				scrollPane.update();
				game.map.mapHeight--;
				game.map.mapWidth--;
			}
		}
		//----- Zoom Out -----------------------------------
		public function zoomOut():void {
			if (game.map.mapWidth<=50 && game.map.mapHeight<=50) {
				if(game.map.mapWidth==map.tileTable[0].length && game.map.mapHeight==map.tileTable[0].length){
				extendMap();
				}
				game.map.mapHeight++;
				game.map.mapWidth++;
				blitDown();
				blitRight();
				centerMap();
				scrollPane.update();
			}
		}
		//----- Extend Map -----------------------------------
		public function extendMap():void {
			dataManager.extendMap();
			var tab:Array = worldTile;
			worldTile =new Array(game.map.mapHeight+1);
			for (var j=0; j<=game.map.mapHeight; j++) {
				worldTile[j]=new Array(game.map.mapWidth+1);
				for (var i=0; i<=game.map.mapWidth; i++) {
					if(j==game.map.mapHeight || i==game.map.mapWidth){
						worldTile[j][i] = new MovieClip();
						worldTile[j][i].x = i * game.tileWidth - j * game.tileHeight;
						worldTile[j][i].y = (i * game.tileWidth + j * game.tileHeight)/2;
						addTile(j,i,-1);
					}else{
						worldTile[j][i] = tab[j][i];
					}					
				}
			}
		}
		//----- Level Up Map -----------------------------------
		public function levelUpMap():void {
			dataManager.levelUpMap();
			tileEditorTool.tileLevel.maximum = game.map.mapHigh-1;
			for (var j=0; j<game.map.mapHeight; j++) {
				for (var i=0; i<game.map.mapWidth; i++) {
					swapTile(j,i);
				}
			}
		}
		//----- Level Down Map -----------------------------------
		public function levelDownMap():void {
			dataManager.levelDownMap();
			tileEditorTool.tileLevel.maximum = game.map.mapHigh-1;
			for (var j=0; j<game.map.mapHeight; j++) {
				for (var i=0; i<game.map.mapWidth; i++) {
					swapTile(j,i);
				}
			}
		}
		//----- Scale Map -----------------------------------
		public function scaleMap(scale:Number) {
			map.scaleX=scale;
			map.scaleY=scale;
		}
			
//################################################################################################
//######################################  Dynamic Tile  ##########################################
		//----- Color Tile -----------------------------------
		public function colorTile(tile,redM:Number,greenM:Number, blueM:Number,alphaM:Number,redO:Number,greenO:Number,blueO:Number) {
			if(tile!=null){
				cleanTile(tileTarget);
				var resultColorTransform:ColorTransform=new ColorTransform(redM,greenM,blueM,alphaM,redO,greenO,blueO,0);
				tile.transform.colorTransform=resultColorTransform;
				tileTarget=tile;
			}
		}
		//----- Color Tiles -----------------------------------
		public function colorTiles(firstTile,tile,redM:Number,greenM:Number, blueM:Number,alphaM:Number,redO:Number,greenO:Number,blueO:Number) {
			if(firstTile!=null && tile!=null){
				var min = minTile(firstTile,tile);
				var max = maxTile(firstTile,tile);
				var levelToEdit = tileEditorTool.tileLevel;
				if(firstTile!=null && tile!=null){
					cleanColorTile();
					for( var j=min.y; j<=max.y;j++){
						for( var i=min.x; i<=max.x;i++){
							var resultColorTransform:ColorTransform=new ColorTransform(redM,greenM,blueM,alphaM,redO,greenO,blueO,0);
							worldTile[j][i].transform.colorTransform=resultColorTransform;
						}
					}
				}
			}
		}
		//----- Color Tile List -----------------------------------
		public function colorTileList(tile,index,redM:Number,greenM:Number, blueM:Number,alphaM:Number,redO:Number,greenO:Number,blueO:Number) {
			if(tile!=null){
				var graphicTileTable:Array = getGraphicTileTable();
				if(tileEditor.tileFrame!=index*graphicTileTable[tileEditor.tileFrameSet][3] +1){
					var resultColorTransform:ColorTransform=new ColorTransform(redM,greenM,blueM,alphaM,redO,greenO,blueO,0);
					tile.transform.colorTransform=resultColorTransform;
					tileListTarget=tile;
				}
			}
		}
		//-----Clean Tile -----------------------------------
		public function cleanTile(_tile:MovieClip){
			if(_tile!=null){
				_tile.transform.colorTransform = new ColorTransform(game.map.R,game.map.G,game.map.B,1,0,0,0,0);
			}
		}
		//-----Clear Color Tile -----------------------------------
		public function cleanColorTile(){
			for (var i=0; i<game.map.mapWidth; i++) {
				for (var j=0; j<game.map.mapHeight; j++) {
					if(i<game.map.mapWidth && j<game.map.mapHeight && worldTile[j][i]!=null){
							worldTile[j][i].transform.colorTransform= new ColorTransform(game.map.R,game.map.G,game.map.B,1,0,0,0,0);
					}
				}
			}
			tileTarget=null;
		}
		//----- Screen To Iso -----------------------------------
		public function screenToIso(_tile):void {
			_tile.x = (_tile.position.x-_tile.position.y);
			_tile.y = (_tile.position.x+_tile.position.y)/2-_tile.position.z;
		}
		//----- Screen To Iso Point -----------------------------------
		public function screenToIsoPoint(_point:Point):Point {
			var point=new Point();
			point.x = (_point.x-_point.y);
			point.y = (_point.x+_point.y)/2;
			return point;
		}
		//----- Screen To Iso Point -----------------------------------
		public function isoToScreenPoint(_point:Point):Point {
			var point=new Point();
			point.x = _point.x/2 +_point.y;
			point.y = -_point.x/2+_point.y;
			return point;
		}
		//----- Get Tile At -----------------------------------
		public function getTileAt(_point:Point):Tile {
			var j:Number= Math.floor(_point.y/game.tileHeight);
			var i:Number=Math.floor( _point.x/game.tileWidth);
			while(i>worldTile[0].length-1 ||j>worldTile[0].length-1){
				i--;
				j--;
			}
			while(i<0 ||j<0){
				i++;
				j++;
			}
			for (var k:Number=map.tileTable.length-1; k>=0 ;k--){
				if(map.tileTable[k][j][i]!=null){
					return map.tileTable[k][j][i];
				}
			}
			return null;
		}
		//----- Get Movie Clip At -----------------------------------
		public function getMovieClipAt(_point:Point):MovieClip {
			var j:Number= Math.floor(_point.y/game.tileHeight);
			var i:Number=Math.floor( _point.x/game.tileWidth);
			while(i>worldTile[0].length-1 ||j>worldTile[0].length-1){
				i--;
				j--;
			}
			while(i<0 ||j<0){
				i++;
				j++;
			}
			if(i<game.map.mapWidth && j<game.map.mapHeight && worldTile[j][i]!=null){
				return worldTile[j][i];
			}
			return null;
		}
		//----- Get Map Tile At -----------------------------------
		public function getMapTileAt(_point:Point):Tile {
			var j:Number= Math.floor(_point.y/game.tileHeight);
			var i:Number=Math.floor( _point.x/game.tileWidth);
			while(i>worldTile[0].length-1 ||j>worldTile[0].length-1){
				i--;
				j--;
			}
			while(i<0 ||j<0){
				i++;
				j++;
			}
			if(worldTile[j][i]!=null){
				for (var k:Number=map.tileTable.length-1; k>=0 ;k--){
					if(map.tileTable[k][j][i].frame!=0){
						if(k==tileEditor.tileLevel){
							return map.tileTable[k][j][i];
						}else{
							return map.tileTable[tileEditor.tileLevel][j][i];
						}
					}
				}
			}
			return null;
		}
		//----- Get Intersection -----------------------------------
		public function getIntersection(a:TilePoint,c:TilePoint,b:TilePoint,d:TilePoint):TilePoint {
			//auteur keith-hair.net
			var m=new TilePoint  ;
			var a1:Number;
			var a2:Number;
			var b1:Number;
			var b2:Number;
			var c1:Number;
			var c2:Number;
			a1=c.y-a.y;
			b1=a.x-c.x;
			c1=c.x*a.y-a.x*c.y;
			a2=d.y-b.y;
			b2=b.x-d.x;
			c2=d.x*b.y-b.x*d.y;
			var denom:Number=a1*b2-a2*b1;
			if (denom!=0) {
				m.x=(b1*c2 - b2*c1)/denom;
				m.y=(a2*c1 - a1*c2)/denom;
			}
			return m;
		}
		//----- Color Clip -----------------------------------
		public function colorClip(_clip:MovieClip,redM:Number,greenM:Number, blueM:Number,alphaM:Number,redO:Number,greenO:Number,blueO:Number) {
			var resultColorTransform:ColorTransform=new ColorTransform(redM,greenM,blueM,alphaM,redO,greenO,blueO,0);
			if(_clip!=null && _clip.transform.colorTransform!=resultColorTransform){
				_clip.transform.colorTransform=resultColorTransform;
			}
		}
		//----- Clean Clip -----------------------------------
		public function cleanClip(_clip:MovieClip) {
			if(_clip!=null){
				_clip.transform.colorTransform=new ColorTransform(1,1,1,1,0,0,0,0);
			}
		}
//################################################################################################
//######################################  Editor  ################################################
	//----- Init Editor -----------------------------------
		public function initEditor():void {
			initTileEditorList();
			tileEditor.x=540;
			tileEditor.y=0;
			initTileEditorTool();
			addChild(tileEditor);
		}
		//----- Init Tile Editor Tool -----------------------------------
		public function initTileEditorTool():void {
			var graphicTileTable:Array = dataManager.getGraphicTileTable();
			var graphicAddTileTable:Array = dataManager.getGraphicAddTileTable();
			var graphicObjectTable:Array = dataManager.getGraphicObjectTable();
			tileEditorTool.inside = new CheckBox();
			tileEditorTool.inside.x=-280;
			tileEditorTool.inside.y=-248;
			tileEditorTool.inside.label="Inside";
			tileEditorTool.inside.labelPlacement = ButtonLabelPlacement.LEFT;
			tileEditorTool.inside.addEventListener(MouseEvent.CLICK, onTileEditorInsideClick);
			tileEditorTool.mapSize = new NumericStepper();
			tileEditorTool.mapSize.minimum = 2;
			tileEditorTool.mapSize.maximum = 50;
			tileEditorTool.mapSize.value = game.map.mapWidth;
			tileEditorTool.mapSize.x=tileEditorTool.inside.x+130;
			tileEditorTool.mapSize.y=-245;
			tileEditorTool.mapSize.width=40;
			tileEditorTool.mapSize.height-=5;
			tileEditorTool.mapSize.tabEnabled = false;
			tileEditorTool.mapSize.textField.editable = false;
			tileEditorTool.mapSizeText = new TextField();
			tileEditorTool.mapSizeText.x=tileEditorTool.mapSize.x-30;
			tileEditorTool.mapSizeText.y=tileEditorTool.mapSize.y-2;
			tileEditorTool.mapSizeText.text="Size";
			tileEditorTool.mapSizeText.selectable = false;
			tileEditorTool.mapSizeText.textColor = 0x000000;
			tileEditorTool.mapSize.addEventListener(SliderEvent.CHANGE, onTileEditorMapSizeChange);
			tileEditorTool.mapLevel = new NumericStepper();
			tileEditorTool.mapLevel.minimum = 2;
			tileEditorTool.mapLevel.maximum = 50;
			tileEditorTool.mapLevel.value = game.map.mapHigh;
			tileEditorTool.mapLevel.x=tileEditorTool.mapSize.x+80;
			tileEditorTool.mapLevel.y=tileEditorTool.mapSize.y;
			tileEditorTool.mapLevel.width=40;
			tileEditorTool.mapLevel.height-=5;
			tileEditorTool.mapLevel.tabEnabled = false;
			tileEditorTool.mapLevel.textField.editable = false;
			tileEditorTool.mapLevelText = new TextField();
			tileEditorTool.mapLevelText.x=tileEditorTool.mapLevel.x-35;
			tileEditorTool.mapLevelText.y=tileEditorTool.mapLevel.y-2;
			tileEditorTool.mapLevelText.text="Level";
			tileEditorTool.mapLevelText.selectable = false;
			tileEditorTool.mapLevelText.textColor = 0x000000;
			tileEditorTool.mapLevel.addEventListener(SliderEvent.CHANGE, onTileEditorMapLevelChange);
			tileEditorTool.tileLevel = new NumericStepper();
			tileEditorTool.tileLevel.maximum = game.map.mapHigh-1;
			tileEditorTool.tileLevel.value=0;
			tileEditorTool.tileLevel.x=20;
			tileEditorTool.tileLevel.width=40;
			tileEditorTool.tileLevel.height-=5;
			tileEditorTool.tileLevel.tabEnabled = false;
			tileEditorTool.tileLevel.textField.editable = false;
			tileEditorTool.tileLevelText = new TextField();
			tileEditorTool.tileLevelText.x-=10;
			tileEditorTool.tileLevelText.y=tileEditorTool.tileLevel.y-2;
			tileEditorTool.tileLevelText.text="Level";
			tileEditorTool.tileLevelText.selectable = false;
			tileEditorTool.tileLevelText.textColor = 0x000000;
			tileEditorTool.tileLevel.addEventListener(SliderEvent.CHANGE, onTileEditorLevelChange);
			tileEditorTool.tileFrameX = new Slider();
			tileEditorTool.tileFrameX.maximum = graphicTileTable[0][3];
			tileEditorTool.tileFrameX.width=graphicTileTable[0][1];
			tileEditorTool.tileFrameX.tabEnabled = false;
			tileEditorTool.tileFrameX.y+=25;
			tileEditorTool.tileFrameXText = new TextField();
			tileEditorTool.tileFrameXText.text="frame";
			tileEditorTool.tileFrameXText.selectable = false;
			tileEditorTool.tileFrameXText.textColor = 0x000000;
			tileEditorTool.tileFrameXText.y=tileEditorTool.tileFrameX.y+3;
			tileEditorTool.tileFrameXText.x+=12;
			tileEditorTool.tileFrameX.addEventListener(SliderEvent.THUMB_DRAG, onTileEditorFrameXChange);
			tileEditorTool.tileFrameX.addEventListener(SliderEvent.CHANGE, onTileEditorFrameXChange);
			tileEditorTool.tileFrameSet = new Slider();
			tileEditorTool.tileFrameSet.maximum = graphicTileTable.length-1;
			tileEditorTool.tileFrameSet.width=graphicTileTable[0][1];
			tileEditorTool.tileFrameSet.tabEnabled = false;
			tileEditorTool.tileFrameSet.y+=tileEditorTool.tileFrameX.y+25;
			tileEditorTool.tileFrameSetText = new TextField();
			tileEditorTool.tileFrameSetText.text="frameSet";
			tileEditorTool.tileFrameSetText.selectable = false;
			tileEditorTool.tileFrameSetText.textColor = 0x000000;
			tileEditorTool.tileFrameSetText.y=tileEditorTool.tileFrameSet.y+3;
			tileEditorTool.tileFrameSetText.x+=8;
			tileEditorTool.tileFrameSet.addEventListener(SliderEvent.THUMB_DRAG, onTileEditorFrameSetChange);
			tileEditorTool.tileFrameSet.addEventListener(SliderEvent.CHANGE, onTileEditorFrameSetChange);
			tileEditorTool.tileLayer = new Slider();
			tileEditorTool.tileLayer.maximum = 0;
			if(graphicAddTileTable.length>0){
				tileEditorTool.tileLayer.maximum += 1;
			}
			if(graphicObjectTable.length>0){
				tileEditorTool.tileLayer.maximum += 2;
			}
			tileEditorTool.tileLayer.width=graphicTileTable[0][1];
			tileEditorTool.tileLayer.tabEnabled = false;
			tileEditorTool.tileLayer.y+=tileEditorTool.tileFrameSet.y+25;
			tileEditorTool.tileLayerText = new TextField();
			tileEditorTool.tileLayerText.text="layer";
			tileEditorTool.tileLayerText.selectable = false;
			tileEditorTool.tileLayerText.textColor = 0x000000;
			tileEditorTool.tileLayerText.y=tileEditorTool.tileLayer.y+3;
			tileEditorTool.tileLayerText.x+=14;
			tileEditorTool.tileLayer.addEventListener(SliderEvent.THUMB_DRAG, onTileEditorLayerChange);
			tileEditorTool.tileLayer.addEventListener(SliderEvent.CHANGE, onTileEditorLayerChange);
			tileEditorTool.tileZoom = new Slider();
			tileEditorTool.tileZoom.maximum = 10;
			tileEditorTool.tileZoom.minimum = 5;
			tileEditorTool.tileZoom.snapInterval = 5;
			tileEditorTool.tileZoom.value= 10;
			tileEditorTool.tileZoom.width=graphicTileTable[0][1];
			tileEditorTool.tileZoom.tabEnabled = false;
			tileEditorTool.tileZoom.y+=tileEditorTool.tileLayer.y+25;
			tileEditorTool.tileZoomText = new TextField();
			tileEditorTool.tileZoomText.text="zoom";
			tileEditorTool.tileZoomText.selectable = false;
			tileEditorTool.tileZoomText.textColor = 0x000000;
			tileEditorTool.tileZoomText.y=tileEditorTool.tileZoom.y+3;
			tileEditorTool.tileZoomText.x+=12;
			tileEditorTool.tileZoom.addEventListener(SliderEvent.CHANGE, onTileEditorZoomChange);
			tileEditorTool.tileFlipFrame = new Slider();
			tileEditorTool.tileFlipFrame.maximum = 1;
			tileEditorTool.tileFlipFrame.minimum = 0;
			tileEditorTool.tileFlipFrame.value= 0;
			tileEditorTool.tileFlipFrame.width=graphicTileTable[0][1];
			tileEditorTool.tileFlipFrame.tabEnabled = false;
			tileEditorTool.tileFlipFrame.y+=tileEditorTool.tileZoom.y+25;
			tileEditorTool.tileFlipFrameText = new TextField();
			tileEditorTool.tileFlipFrameText.addEventListener(MouseEvent.CLICK,onTileEditorFlipFrameTextClick);
			tileEditorTool.tileFlipFrameText.addEventListener(MouseEvent.ROLL_OVER,onTileEditorFlipFrameTextRollOver);
			tileEditorTool.tileFlipFrameText.addEventListener(MouseEvent.ROLL_OUT,onTileEditorFlipFrameTextRollOut);
			tileEditorTool.tileFlipFrameText.text="flip frame";
			tileEditorTool.tileFlipFrameText.selectable = false;
			tileEditorTool.tileFlipFrameText.textColor = 0x000000;
			tileEditorTool.tileFlipFrameText.y=tileEditorTool.tileFlipFrame.y+7;
			tileEditorTool.tileFlipFrameText.x+=6;
			tileEditorTool.tileFlipFrame.addEventListener(SliderEvent.CHANGE, onTileEditorFlipFrameChange);
			tileEditorTool.tileFlipPositionHText = new TextField();
			tileEditorTool.tileFlipPositionHText.addEventListener(MouseEvent.CLICK,onTileEditorFlipPositionHTextClick);
			tileEditorTool.tileFlipPositionHText.addEventListener(MouseEvent.ROLL_OVER,onTileEditorFlipPositionHTextRollOver);
			tileEditorTool.tileFlipPositionHText.addEventListener(MouseEvent.ROLL_OUT,onTileEditorFlipPositionHTextRollOut);
			tileEditorTool.tileFlipPositionHText.text="flipH";
			tileEditorTool.tileFlipPositionHText.selectable = false;
			tileEditorTool.tileFlipPositionHText.textColor = 0x000000;
			tileEditorTool.tileFlipPositionHText.y=tileEditorTool.tileFlipFrameText.y+20;
			tileEditorTool.tileFlipPositionHText.x-=5;
			tileEditorTool.tileFlipPositionVText = new TextField();
			tileEditorTool.tileFlipPositionVText.addEventListener(MouseEvent.CLICK,onTileEditorFlipPositionVTextClick);
			tileEditorTool.tileFlipPositionVText.addEventListener(MouseEvent.ROLL_OVER,onTileEditorFlipPositionVTextRollOver);
			tileEditorTool.tileFlipPositionVText.addEventListener(MouseEvent.ROLL_OUT,onTileEditorFlipPositionVTextRollOut);
			tileEditorTool.tileFlipPositionVText.text="flipV";
			tileEditorTool.tileFlipPositionVText.selectable = false;
			tileEditorTool.tileFlipPositionVText.textColor = 0x000000;
			tileEditorTool.tileFlipPositionVText.y=tileEditorTool.tileFlipFrameText.y+20;
			tileEditorTool.tileFlipPositionVText.x+=40;
			tileEditorTool.buttonNew = new Button();
			tileEditorTool.buttonNew.label = "New";
			tileEditorTool.buttonNew.width = 80;
			tileEditorTool.buttonNew.y=175;
			tileEditorTool.buttonNew.x-=450;
			tileEditorTool.buttonNew.addEventListener(MouseEvent.CLICK, onButtonNewClick);
			tileEditorTool.buttonLoad = new Button();
			tileEditorTool.buttonLoad.label = "Load";
			tileEditorTool.buttonLoad.width =80;
			tileEditorTool.buttonLoad.y=175;
			tileEditorTool.buttonLoad.x=tileEditorTool.buttonNew.x+85;
			tileEditorTool.buttonLoad.addEventListener(MouseEvent.CLICK, onButtonLoadClick);
			tileEditorTool.buttonSave = new Button();
			tileEditorTool.buttonSave.label = "Save";
			tileEditorTool.buttonSave.width = 80;
			tileEditorTool.buttonSave.y=175;
			tileEditorTool.buttonSave.x=tileEditorTool.buttonLoad.x+85;
			tileEditorTool.buttonSave.addEventListener(MouseEvent.CLICK, onButtonSaveClick);
			tileEditorTool.buttonProperties = new Button();
			tileEditorTool.buttonProperties.label = "Properties";
			tileEditorTool.buttonProperties.width = 80;
			tileEditorTool.buttonProperties.y=175;
			tileEditorTool.buttonProperties.x=tileEditorTool.buttonSave.x+85;
			tileEditorTool.buttonProperties.addEventListener(MouseEvent.CLICK, onButtonPropertiesClick);
			tileEditorTool.addChild(tileEditorTool.inside);
			tileEditorTool.addChild(tileEditorTool.mapSizeText);
			tileEditorTool.addChild(tileEditorTool.mapLevelText);
			tileEditorTool.addChild(tileEditorTool.tileLevelText);
			tileEditorTool.addChild(tileEditorTool.tileFrameXText);
			tileEditorTool.addChild(tileEditorTool.tileFrameSetText);
			tileEditorTool.addChild(tileEditorTool.tileLayerText);
			tileEditorTool.addChild(tileEditorTool.tileZoomText);
			tileEditorTool.addChild(tileEditorTool.tileFlipFrameText);
			tileEditorTool.addChild(tileEditorTool.tileFlipPositionHText);
			tileEditorTool.addChild(tileEditorTool.tileFlipPositionVText);
			tileEditorTool.addChild(tileEditorTool.mapSize);
			tileEditorTool.addChild(tileEditorTool.mapLevel);
			tileEditorTool.addChild(tileEditorTool.tileLevel);
			tileEditorTool.addChild(tileEditorTool.tileFrameSet);
			tileEditorTool.addChild(tileEditorTool.tileFrameX);
			tileEditorTool.addChild(tileEditorTool.tileLayer);
			tileEditorTool.addChild(tileEditorTool.tileZoom);
			tileEditorTool.addChild(tileEditorTool.tileFlipFrame);
			tileEditorTool.addChild(tileEditorTool.buttonNew);
			tileEditorTool.addChild(tileEditorTool.buttonLoad);
			tileEditorTool.addChild(tileEditorTool.buttonSave);
			tileEditorTool.addChild(tileEditorTool.buttonProperties);
			tileEditorTool.x=540;
			tileEditorTool.y=tileEditor.y+tileEditor.height+10;
			addChild(tileEditorTool);
		}
		//----- On Tile Editor Inside Click -----------------------------------
		public function onTileEditorInsideClick(event:Event):void {
			for( var j=0; j<game.map.mapHeight;j++){
				for( var i=0; i<game.map.mapWidth;i++){
					swapTile(j,i);
				}
			}
		}
		//----- On Tile Editor Map Size Change -----------------------------------
		public function onTileEditorMapSizeChange(event:Event):void {
			if(event.target.value>game.map.mapWidth){
				zoomOut();
			}else{
				zoomIn();
			}
		}
		//----- On Tile Editor Map Level Change -----------------------------------
		public function onTileEditorMapLevelChange(event:Event):void {
			if(tileEditorTool.tileLevel.maximum+1 < tileEditorTool.mapLevel.value){
				levelUpMap();
			}else if (tileEditorTool.tileLevel.maximum+1 > tileEditorTool.mapLevel.value){
				levelDownMap();
			}
		}
		//----- On Tile Editor Level Change -----------------------------------
		public function onTileEditorLevelChange(event:Event):void {
			tileEditor.tileLevel = event.target.value;
		}
		//----- On Tile Editor Frame Set Change -----------------------------------
		public function onTileEditorFrameSetChange(event:SliderEvent):void {
			tileEditor.tileFrameSet = event.target.value;
			tileEditorTool.tileFrameX.value=0;
			tileEditor.tileFrameX=0;
			updateTileEditorList();
		}
		//----- On Tile Editor Frame X Change -----------------------------------
		public function onTileEditorFrameXChange(event:SliderEvent):void {
			tileEditor.tileFrameX = event.target.value;
			updateTileEditorList();
		}
		//----- On Tile Editor Layer Change -----------------------------------
		public function onTileEditorLayerChange(event:SliderEvent):void {
			tileEditor.tileLayer = event.target.value;
			if(tileEditor.tileLayer==0){//------------------------- tileFrame
				var graphicTileTable:Array = dataManager.getGraphicTileTable();
				tileEditorTool.tileFrameSet.maximum = graphicTileTable.length-1;
				tileEditorTool.tileFrameX.maximum = graphicTileTable[0][3];
			}else if(tileEditor.tileLayer==1){//------------------- addTileFrame
				var graphicAddTileTable:Array = dataManager.getGraphicAddTileTable();
				tileEditorTool.tileFrameSet.maximum = graphicAddTileTable.length-1;
				tileEditorTool.tileFrameX.maximum = graphicAddTileTable[0][3];
			}
			else{//------------------------------------------------ objectFrame Inside/Outside
				var graphicObjectTable:Array = dataManager.getGraphicObjectTable();
				tileEditorTool.tileFrameSet.maximum = graphicObjectTable.length-1;
				tileEditorTool.tileFrameX.maximum = graphicObjectTable[0][3];
			}
			tileEditorTool.tileFrameX.value=0;
			tileEditor.tileFrameX=0;
			tileEditorTool.tileFrameSet.value=0;
			tileEditor.tileFrameSet=0;
			updateTileEditorList();
		}
		//----- On Tile Editor Zoom Change -----------------------------------
		public function onTileEditorZoomChange(event:SliderEvent):void {
			if(event.target.value/10!=map.scaleX){
				scaleMap(event.target.value/10);
				centerMap();
				scrollPane.update();
			}		
		}
		//----- On Tile Editor Flip Frame Change -----------------------------------
		public function onTileEditorFlipFrameChange(event:SliderEvent):void {
			tileEditor.tileFlip = event.target.value;
			flipTileEditorFrame();
		}
		//----- Flip Tile Editor Frame -----------------------------------
		public function flipTileEditorFrame():void {
			for each( var tile in tileList[0]){
				if(tileEditor.tileFlip!=0 && tile.scaleX==1){
					tile.x+=tile.width;
					tile.scaleX*=-1;
					tileEditor.tileFlip=1;
				}else if (tileEditor.tileFlip==0 && tile.scaleX==-1){
					tile.x-=tile.width;
					tile.scaleX*=-1;
					tileEditor.tileFlip=0;
				}
			}
		}
		//----- On Tile Editor Flip Frame Text Click -----------------------------------
		public function onTileEditorFlipFrameTextClick(event:MouseEvent):void {
			flipTilesFrame();
		}
		//----- On Tile Editor Flip Text Roll Over -----------------------------------
		public function onTileEditorFlipFrameTextRollOver(event:MouseEvent):void {
			tileEditorTool.tileFlipFrameText.textColor=0xFF0000;
		}
		//----- On Tile Editor Flip Text Roll Out -----------------------------------
		public function onTileEditorFlipFrameTextRollOut(event:MouseEvent):void {
			tileEditorTool.tileFlipFrameText.textColor=0x000000;
		}
		//----- On Tile Editor Flip Position Horizontal Text Click -----------------------------------
		public function onTileEditorFlipPositionHTextClick(event:MouseEvent):void {
			flipTilesPositionH();
		}
		//----- On Tile Editor Flip Position Horizontal Text Roll Over -----------------------------------
		public function onTileEditorFlipPositionHTextRollOver(event:MouseEvent):void {
			tileEditorTool.tileFlipPositionHText.textColor=0xFF0000;
		}
		//----- On Tile Editor Flip Position Horizontal Text Roll Out -----------------------------------
		public function onTileEditorFlipPositionHTextRollOut(event:MouseEvent):void {
			tileEditorTool.tileFlipPositionHText.textColor=0x000000;
		}
		//----- On Tile Editor Flip Position Vertical Text Click -----------------------------------
		public function onTileEditorFlipPositionVTextClick(event:MouseEvent):void {
			flipTilesPositionV();
		}
		//----- On Tile Editor Flip Position Vertical Text Roll Over -----------------------------------
		public function onTileEditorFlipPositionVTextRollOver(event:MouseEvent):void {
			tileEditorTool.tileFlipPositionVText.textColor=0xFF0000;
		}
		//----- On Tile Editor Flip Position Vertical Text Roll Out -----------------------------------
		public function onTileEditorFlipPositionVTextRollOut(event:MouseEvent):void {
			tileEditorTool.tileFlipPositionVText.textColor=0x000000;
		}
		//----- On Button New Click  -----------------------------------
		public function onButtonNewClick(event:MouseEvent):void {
			cleanTiles();
		}
		//----- On Button Load Click  -----------------------------------
		public function onButtonLoadClick(event:MouseEvent):void {
			file= new FileReference();
			file.addEventListener(Event.SELECT, onSelectFile);
			var xmlFilter:FileFilter = new FileFilter("xml", "*.xml");
			file.browse([xmlFilter]);		
			if (addTileEditorTool!=null && this.contains(addTileEditorTool)){
					removeChild(addTileEditorTool);
					hideTilesProperties();
			}
		}
		//-----On Selected File --------------------------------
		public function onSelectFile(event:Event):void {
			var file:FileReference = FileReference(event.target);
			var fileType = file.type;
			var fileName = file.name;
			dataManager.loadNewXmlMap("xml/"+fileName);
			dataManager.addEventListener(DataManagerEvent.UPDATEMAP,onNewXmlMapLoadingSuccessfull);
		}
		//------ New Xml Map Loading Successfull ------------------------------------
		function onNewXmlMapLoadingSuccessfull(dataManagerEvent:DataManagerEvent):void {
			removeChild(scrollPane);
			initVar(dataManager);
			initWorld();
		}
		//----- On Button Save Click  -----------------------------------
		public function onButtonSaveClick(event:MouseEvent):void {
			if(mapText==null || !this.contains(mapText)){
				mapText = new TextField();
				mapText.text=dataManager.getXMLMap();
				System.setClipboard(mapText.text);
				mapText.appendText("\n\nThe map is automatically saved to the clipboard.");
				mapText.selectable = true;
				mapText.textColor = 0x000000;
				mapText.background = true;
				mapText.wordWrap = true;
				mapText.backgroundColor=0xFFFFFF;
				mapText.width=scrollPane.width-20;
				mapText.height=scrollPane.height-25;
				tileEditorTool.buttonSave.label = "Return";
				scrollPane.source = mapText;
				mapText.y=scrollPane.y+25;
				mapText.x=scrollPane.x;
				if (addTileEditorTool!= null && this.contains(addTileEditorTool)){
					removeChild(addTileEditorTool);
					hideTilesProperties();
				}
			}else{
				scrollPane.source = map;
				tileEditorTool.buttonSave.label = "Save";
				centerMap();
			}
		}
		//----- On Button Properties Click  -----------------------------------
		public function onButtonPropertiesClick(event:MouseEvent):void {
			if(tileEditorTool.buttonSave.label=="Save"){
				if(addTileEditorTool==null){
					initAddTileEditorTool();
					showTilesProperties();
				}else if (addTileEditorTool!= null && this.contains(addTileEditorTool)){
					removeChild(addTileEditorTool);
					hideTilesProperties();
				}else{
					addChild(addTileEditorTool);
					showTilesProperties();
				}
			}
		}
		//----- Show Tiles Properties  -----------------------------------
		public function showTilesProperties():void {
			for( var k=0; k<game.map.mapHigh;k++){
				for( var j=0; j<game.map.mapHeight;j++){
					for( var i=0; i<game.map.mapWidth;i++){
						showTileProperties(k,j,i);
						swapTile(j,i);
					}
				}
			}
		}
		//----- Show Tile Properties  -----------------------------------
		public function showTileProperties(k:Number,j:Number,i:Number):void {
			if(map.tileTable[k][j][i].tileProperty!=0){
				if(map.tileTable[k][j][i].tileProperty==1){//-------- Slopes
					map.tileTable[k][j][i].R=1;
					map.tileTable[k][j][i].G=1;
					map.tileTable[k][j][i].B=0;
				}else if(map.tileTable[k][j][i].tileProperty==2){//------- Ladder
					map.tileTable[k][j][i].R=1;
					map.tileTable[k][j][i].G=0.5;
					map.tileTable[k][j][i].B=0;
				}else if(map.tileTable[k][j][i].tileProperty==3){//------- Slide
					map.tileTable[k][j][i].R=0;
					map.tileTable[k][j][i].G=1;
					map.tileTable[k][j][i].B=0;
				}
				else if(map.tileTable[k][j][i].tileProperty==4){//------- Bounce
					map.tileTable[k][j][i].R=0;
					map.tileTable[k][j][i].G=0;
					map.tileTable[k][j][i].B=1;
				}
				else if(map.tileTable[k][j][i].tileProperty==5){//------- Teleport
					map.tileTable[k][j][i].R=1;
					map.tileTable[k][j][i].G=0;
					map.tileTable[k][j][i].B=1;
				}
			}else if(!map.tileTable[k][j][i].walkable){
				map.tileTable[k][j][i].R=1;
				map.tileTable[k][j][i].G=0;
				map.tileTable[k][j][i].B=0;
			}
		}
		//----- Hide Tiles Properties  -----------------------------------
		public function hideTilesProperties():void {
			for( var j=0; j<game.map.mapHeight;j++){
				for( var i=0; i<game.map.mapWidth;i++){
					for( var k=0; k<game.map.mapHigh;k++){
						map.tileTable[k][j][i].R=1;
						map.tileTable[k][j][i].G=1;
						map.tileTable[k][j][i].B=1;
					}
					swapTile(j,i);
				}
			}
		}
		//----- Init Tile Editor List -----------------------------------
		public function initTileEditorList():void {
			tileEditor.tileFrame=-1;
			tileEditor.tileLevel=0;
			tileEditor.tileFrameX=0;
			tileEditor.tileFrameSet=0;
			tileEditor.tileLayer=0;
			tileEditor.tileFlip=0;
			var graphicTileTable:Array = getGraphicTileTable();
			var pictLoad:Bitmap=Bitmap(graphicTileTable[0][0].content);
			tileList = new Array(2);
			tileList[0] = new Array();
			tileList[1] = new Array();
			for (var i:Number=0; i<graphicTileTable[0][4]; i++){
				var myBitmapData:BitmapData = new BitmapData(graphicTileTable[0][1],graphicTileTable[0][2], true, 0);
				var frame:Number= i*graphicTileTable[0][3] +1;
				var x=(frame-1)% graphicTileTable[0][3];
				var y=Math.floor((frame-1)/(graphicTileTable[0][3]));
				myBitmapData.copyPixels(pictLoad.bitmapData, new Rectangle(x * graphicTileTable[0][1],y * graphicTileTable[0][2],graphicTileTable[0][1],graphicTileTable[0][2]), new Point(0, 0),null,null,true);
				var bm:Bitmap = new Bitmap(myBitmapData);
				var tile:MovieClip = new MovieClip();
				tile.bitmapData= myBitmapData;
				tile.bm = tile.addChild(bm);
				tile.y=i*graphicTileTable[0][2];
				tileList[0][i]=tile;
				tileEditor.addChild(tile);
			}
		}
		//----- Update Tile Editor List -----------------------------------
		public function updateTileEditorList():void {
			cleanTileEditorList();
			var graphicTileTable:Array = getGraphicTileTable();
			var pictLoad:Bitmap=Bitmap(graphicTileTable[tileEditor.tileFrameSet][0].content);
			for (var i:Number=0; i<graphicTileTable[tileEditor.tileFrameSet][4]; i++){
				if(tileList[0][i].bitmapData!=undefined){
					var myBitmapData = new BitmapData(graphicTileTable[tileEditor.tileFrameSet][1],graphicTileTable[tileEditor.tileFrameSet][2], true, 0);
					tileList[0][i].bm.bitmapData = myBitmapData;
				}else{
					myBitmapData = new BitmapData(graphicTileTable[tileEditor.tileFrameSet][1],graphicTileTable[tileEditor.tileFrameSet][2], true, 0);
					var tile:MovieClip = new MovieClip();
					tile.bitmapData= myBitmapData;
					var bm:Bitmap = new Bitmap(myBitmapData);
					tile.addChild(bm);
					tileList[0][i]=tile;
					tileEditor.addChild(tile);
				}
				tileList[0][i].y=i*graphicTileTable[tileEditor.tileFrameSet][2];
				var frame:Number= i*graphicTileTable[tileEditor.tileFrameSet][3] + tileEditor.tileFrameX +1;
				var x=(frame-1)% graphicTileTable[tileEditor.tileFrameSet][3];
				var y=Math.floor((frame-1)/(graphicTileTable[tileEditor.tileFrameSet][3]));
				myBitmapData.copyPixels(pictLoad.bitmapData, new Rectangle(x * graphicTileTable[tileEditor.tileFrameSet][1],y * graphicTileTable[tileEditor.tileFrameSet][2],graphicTileTable[tileEditor.tileFrameSet][1],graphicTileTable[tileEditor.tileFrameSet][2]), new Point(0, 0),null,null,true);				
			}
		}
		//----- Clean Tile Editor List -----------------------------------
		public function cleanTileEditorList():void {
			for (var i:Number=0; i<tileList[0].length; i++){
				if(tileList[0][i].bitmapData!=undefined){
					var myBitmapData:BitmapData = tileList[0][i].bm.bitmapData;
					myBitmapData.fillRect(myBitmapData.rect, 0);
				}
			}
		}
		//----- Get GraphicTileTable -----------------------------------
		public function getGraphicTileTable():Array {
			if(tileEditor.tileLayer==0){
				var graphicTileTable:Array = dataManager.getGraphicTileTable();
			}else if(tileEditor.tileLayer==1){
				graphicTileTable = dataManager.getGraphicAddTileTable();
			}else{
				graphicTileTable = dataManager.getGraphicObjectTable();
			}
			return graphicTileTable;
		}
		//----- Get Tile List -----------------------------------
		public function getTileList():Array {
			return tileList;
		}
		//----- Get Tile Editor -----------------------------------
		public function getTileEditor():MovieClip {
			return tileEditor;
		}
		//----- Get Tile Editor -----------------------------------
		public function getTileEditorTool():MovieClip {
			return tileEditorTool;
		}
		//----- On Tile Editor Mouse Move -----------------------------------
		public function onTileEditorMouseMove(localY:Number):void {
			var index:Number= getTileEditorIndex(localY);
			cleanTile(tileListTarget);
			colorTileList(tileList[0][index],index,1,0,0,0.5,100,0,0);
		}
		//----- On Tile Editor Roll Out -----------------------------------
		public function onTileEditorRollOut():void {
			cleanTile(tileListTarget);
		}
		//----- On Tile Editor Mouse Up -----------------------------------
		public function onTileEditorMouseUp(localY:Number):void {
			var graphicTileTable:Array = getGraphicTileTable();
			var index:Number= getTileEditorIndex(localY);
			cleanTile(tileList[0][tileEditor.tileIndex]);
			if(tileEditor.tileFrame!=index*graphicTileTable[tileEditor.tileFrameSet][3] +1){
				tileEditor.tileFrame=index*graphicTileTable[tileEditor.tileFrameSet][3] +1;
				tileEditor.tileIndex=index;
				tileListTarget=null;
			}else{
				tileEditor.tileFrame=-1;
				tileListTarget=tileList[0][index];
			}
		}
		//----- On Get Tile Editor Index -----------------------------------
		public function getTileEditorIndex(localY:Number):Number {
			var graphicTileTable:Array = getGraphicTileTable();
			var tileY:Number=graphicTileTable[tileEditor.tileFrameSet][4];
			var index:Number= Math.floor((localY*tileY)/tileEditor.height);
			return index;
		}
		//----- Init Add Tile Editor Tool -----------------------------------
		public function initAddTileEditorTool():void {
			addTileEditorTool = new MovieClip();
			addTileEditorTool.walkable = new CheckBox();
			addTileEditorTool.walkable.label = "Walkable";
			addTileEditorTool.walkable.selected = true;
			addTileEditorTool.walkable.addEventListener(MouseEvent.CLICK, onAddTileEditorWalkableClick);
			addTileEditorTool.slopes = new CheckBox();
			addTileEditorTool.slopes.label = "Slopes";
			addTileEditorTool.slopes.y=addTileEditorTool.walkable.y+20;
			addTileEditorTool.slopes.addEventListener(MouseEvent.CLICK, onAddTileEditorSlopesClick);
			addTileEditorTool.ladder = new CheckBox();
			addTileEditorTool.ladder.label = "Ladder";
			addTileEditorTool.ladder.y=addTileEditorTool.slopes.y+20;
			addTileEditorTool.ladder.addEventListener(MouseEvent.CLICK, onAddTileEditorLadderClick);
			addTileEditorTool.slide = new CheckBox();
			addTileEditorTool.slide.label = "Slide";
			addTileEditorTool.slide.y=addTileEditorTool.ladder.y+20;
			addTileEditorTool.slide.addEventListener(MouseEvent.CLICK, onAddTileEditorSlideClick);
			addTileEditorTool.bounce = new CheckBox();
			addTileEditorTool.bounce.label = "Bounce";
			addTileEditorTool.bounce.y=addTileEditorTool.slide.y+20;
			addTileEditorTool.bounce.addEventListener(MouseEvent.CLICK, onAddTileEditorBounceClick);
			addTileEditorTool.teleport = new CheckBox();
			addTileEditorTool.teleport.label = "Teleport";
			addTileEditorTool.teleport.y=addTileEditorTool.bounce.y+20;
			addTileEditorTool.teleport.addEventListener(MouseEvent.CLICK, onAddTileEditorTeleportClick);
			addTileEditorTool.elevation = new CheckBox();
			addTileEditorTool.elevation.label = "Elevation";
			addTileEditorTool.elevation.y=addTileEditorTool.teleport.y+20;
			addTileEditorTool.elevation.addEventListener(MouseEvent.CLICK, onAddTileEditorElevationClick);
			addTileEditorTool.addChild(addTileEditorTool.walkable);
			addTileEditorTool.addChild(addTileEditorTool.slopes);
			addTileEditorTool.addChild(addTileEditorTool.ladder);
			addTileEditorTool.addChild(addTileEditorTool.slide);
			addTileEditorTool.addChild(addTileEditorTool.bounce);
			addTileEditorTool.addChild(addTileEditorTool.teleport);
			addTileEditorTool.addChild(addTileEditorTool.elevation);
			addTileEditorTool.x=tileEditor.x-addTileEditorTool.width;
			addTileEditorTool.y=scrollPane.y+scrollPane.height-180;
			addChild(addTileEditorTool);
		}
		//----- On Add Tile Editor Walkable Click -----------------------------------
		public function onAddTileEditorWalkableClick(event:Event):void {
			
		}
				//----- On Add Tile Editor Elevation Click -----------------------------------
		public function onAddTileEditorElevationClick(event:Event):void {
			if(!addTileEditorTool.elevation.selected ){
				addTileEditorTool.removeChild(addTileEditorTool.elevationLevel);
				if(!addTileEditorTool.ladder.selected &&!addTileEditorTool.slide.selected&& !addTileEditorTool.bounce.selected&& !addTileEditorTool.teleport.selected && !addTileEditorTool.slopes.selected){
					addTileEditorTool.x+=110;
				}
			}else{
				if(!addTileEditorTool.ladder.selected &&!addTileEditorTool.slide.selected&& !addTileEditorTool.bounce.selected&& !addTileEditorTool.teleport.selected && !addTileEditorTool.slopes.selected){
					addTileEditorTool.x-=110;
				}
				addTileEditorTool.elevationLevel = new NumericStepper();
				addTileEditorTool.elevationLevel.y=addTileEditorTool.elevation.y+2;
				addTileEditorTool.elevationLevel.x=85;
				addTileEditorTool.elevationLevel.width=40;
				addTileEditorTool.elevationLevel.height-=5;
				addTileEditorTool.elevationLevel.textField.editable = false;
				var graphicTileTable = dataManager.getGraphicTileTable();
				addTileEditorTool.elevationLevel.minimum = 0;
				addTileEditorTool.elevationLevel.maximum= game.tileHigh-1;
				addTileEditorTool.elevationLevel.value=0;
				addTileEditorTool.addChild(addTileEditorTool.elevationLevel);
			}
		}
		//----- On Add Tile Editor Slopes Click -----------------------------------
		public function onAddTileEditorSlopesClick(event:Event):void {
			if(!addTileEditorTool.slopes.selected ){
				addTileEditorTool.walkable.enabled=true;
				addTileEditorTool.walkable.selected = true;
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.removeChild(addTileEditorTool.slopesComboBox);
				if(!addTileEditorTool.elevation.selected){
					addTileEditorTool.x+=110;
				}
			}else{
				addTileEditorTool.walkable.enabled=false;
				if(!addTileEditorTool.ladder.selected &&!addTileEditorTool.slide.selected &&!addTileEditorTool.elevation.selected && !addTileEditorTool.bounce.selected&& !addTileEditorTool.teleport.selected){
					addTileEditorTool.x-=110;
				}else if (addTileEditorTool.targetClip!=null && addTileEditorTool.contains(addTileEditorTool.targetClip)) {
					addTileEditorTool.removeChild(addTileEditorTool.targetClip);
				}
				var dp:DataProvider = new DataProvider();
				addTileEditorTool.walkable.selected = false;
				addTileEditorTool.ladder.selected = false;
				addTileEditorTool.slide.selected = false;
				addTileEditorTool.bounce.selected = false;
				addTileEditorTool.teleport.selected = false;
				addTileEditorTool.slopesComboBox = new ComboBox();
				addTileEditorTool.targetClip = addTileEditorTool.slopesComboBox;
				addTileEditorTool.slopesComboBox.x=addTileEditorTool.slopes.x+addTileEditorTool.slopes.width-20;
				addTileEditorTool.slopesComboBox.y=addTileEditorTool.slopes.y;
				addTileEditorTool.slopesComboBox.width=85;
				addTileEditorTool.slopesComboBox.dataProvider = dp;
				dp.addItem( { label: "DownRight"});
				dp.addItem( { label: "DownLeft"});
				dp.addItem( { label: "UpRight"});
				dp.addItem( { label: "UpLeft"});
				addTileEditorTool.addChild(addTileEditorTool.slopesComboBox);
			}
		}
		//----- On Add Tile Editor Ladder Click -----------------------------------
		public function onAddTileEditorLadderClick(event:Event):void {
			if(!addTileEditorTool.ladder.selected ){
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.ladder.selected = false;
				addTileEditorTool.slide.selected = false;
				addTileEditorTool.teleport.selected = false;
				addTileEditorTool.removeChild(addTileEditorTool.ladderDirection);
				if(!addTileEditorTool.elevation.selected){
					addTileEditorTool.x+=110;
				}
			}else{
				addTileEditorTool.walkable.enabled=true;
				if(!addTileEditorTool.slopes.selected && !addTileEditorTool.bounce.selected &&!addTileEditorTool.elevation.selected&& !addTileEditorTool.teleport.selected && !addTileEditorTool.slide.selected){
					addTileEditorTool.x-=110;
				}else if (addTileEditorTool.targetClip!=null && addTileEditorTool.contains(addTileEditorTool.targetClip)) {
					addTileEditorTool.removeChild(addTileEditorTool.targetClip);
				}
				var dp:DataProvider = new DataProvider();
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.bounce.selected = false;
				addTileEditorTool.teleport.selected = false;
				addTileEditorTool.slide.selected = false;
				addTileEditorTool.ladderDirection = new MovieClip();
				addTileEditorTool.targetClip = addTileEditorTool.ladderDirection;
				addTileEditorTool.ladderDirection.y=addTileEditorTool.walkable.y;
				addTileEditorTool.ladderDirection.DR = new CheckBox();
				addTileEditorTool.ladderDirection.DR.label = "Down Right";
				addTileEditorTool.ladderDirection.DR.x=90;
				addTileEditorTool.ladderDirection.DR.y=0;
				addTileEditorTool.ladderDirection.DR.selected=true;
				addTileEditorTool.ladderDirection.DL = new CheckBox();
				addTileEditorTool.ladderDirection.DL.label = "Down Left";
				addTileEditorTool.ladderDirection.DL.x=90;
				addTileEditorTool.ladderDirection.DL.y=20;
				addTileEditorTool.ladderDirection.UR = new CheckBox();
				addTileEditorTool.ladderDirection.UR.label = "Up Right";
				addTileEditorTool.ladderDirection.UR.x=90;
				addTileEditorTool.ladderDirection.UR.y=40;
				addTileEditorTool.ladderDirection.UL = new CheckBox();
				addTileEditorTool.ladderDirection.UL.label = "Up Left";
				addTileEditorTool.ladderDirection.UL.x=90;
				addTileEditorTool.ladderDirection.UL.y=60;
				addTileEditorTool.ladderDirection.BH = new CheckBox();
				addTileEditorTool.ladderDirection.BH.label = "Bottom H";
				addTileEditorTool.ladderDirection.BH.x=90;
				addTileEditorTool.ladderDirection.BH.y=80;
				addTileEditorTool.ladderDirection.BV = new CheckBox();
				addTileEditorTool.ladderDirection.BV.label = "Bottom V";
				addTileEditorTool.ladderDirection.BV.x=90;
				addTileEditorTool.ladderDirection.BV.y=100;
				addTileEditorTool.ladderDirection.addChild(addTileEditorTool.ladderDirection.UR);
				addTileEditorTool.ladderDirection.addChild(addTileEditorTool.ladderDirection.UL);
				addTileEditorTool.ladderDirection.addChild(addTileEditorTool.ladderDirection.DR);
				addTileEditorTool.ladderDirection.addChild(addTileEditorTool.ladderDirection.DL);
				addTileEditorTool.ladderDirection.addChild(addTileEditorTool.ladderDirection.BH);
				addTileEditorTool.ladderDirection.addChild(addTileEditorTool.ladderDirection.BV);
				addTileEditorTool.addChild(addTileEditorTool.ladderDirection);
			}
		}
		//----- On Add Tile Editor Slide Click -----------------------------------
		public function onAddTileEditorSlideClick(event:Event):void {
			if(!addTileEditorTool.slide.selected ){
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.removeChild(addTileEditorTool.slideComboBox);
				if(!addTileEditorTool.elevation.selected){
					addTileEditorTool.x+=110;
				}
			}else{
				if(!addTileEditorTool.ladder.selected &&!addTileEditorTool.slopes.selected&&!addTileEditorTool.elevation.selected&& !addTileEditorTool.bounce.selected&& !addTileEditorTool.teleport.selected){
					addTileEditorTool.x-=110;
				}else if (addTileEditorTool.targetClip!=null && addTileEditorTool.contains(addTileEditorTool.targetClip)) {
					addTileEditorTool.removeChild(addTileEditorTool.targetClip);
				}
				var dp:DataProvider = new DataProvider();
				addTileEditorTool.walkable.enabled = true;
				addTileEditorTool.walkable.selected = true;
				addTileEditorTool.ladder.selected = false;
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.bounce.selected = false;
				addTileEditorTool.teleport.selected = false;
				addTileEditorTool.slideComboBox = new ComboBox();
				addTileEditorTool.targetClip = addTileEditorTool.slideComboBox;
				addTileEditorTool.slideComboBox.x=addTileEditorTool.slide.x+addTileEditorTool.slide.width-20;
				addTileEditorTool.slideComboBox.y=addTileEditorTool.slide.y;
				addTileEditorTool.slideComboBox.width=85;
				addTileEditorTool.slideComboBox.dataProvider = dp;
				dp.addItem( { label: "DownRight"});
				dp.addItem( { label: "DownLeft"});
				dp.addItem( { label: "UpRight"});
				dp.addItem( { label: "UpLeft"});
				dp.addItem( { label: "High"});
				addTileEditorTool.addChild(addTileEditorTool.slideComboBox);
			}
		}
		//----- On Add Tile Editor Bounce Click -----------------------------------
		public function onAddTileEditorBounceClick(event:Event):void {
			if(!addTileEditorTool.bounce.selected ){
				addTileEditorTool.walkable.enabled=true;
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.removeChild(addTileEditorTool.bounceDirection);
				if(!addTileEditorTool.elevation.selected){
					addTileEditorTool.x+=110;
				}
			}else{
				if(!addTileEditorTool.ladder.selected &&!addTileEditorTool.slopes.selected&&!addTileEditorTool.elevation.selected&& !addTileEditorTool.teleport.selected&& !addTileEditorTool.slide.selected){
					addTileEditorTool.x-=110;
				}else if (addTileEditorTool.targetClip!=null && addTileEditorTool.contains(addTileEditorTool.targetClip)) {
					addTileEditorTool.removeChild(addTileEditorTool.targetClip);
				}
				var dp:DataProvider = new DataProvider();
				addTileEditorTool.walkable.selected = true;
				addTileEditorTool.ladder.selected = false;
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.slide.selected = false;
				addTileEditorTool.teleport.selected = false;
				addTileEditorTool.bounceDirection = new MovieClip();
				addTileEditorTool.targetClip = addTileEditorTool.bounceDirection;
				addTileEditorTool.bounceDirection.y=addTileEditorTool.walkable.y;
				addTileEditorTool.bounceDirection.DR = new CheckBox();
				addTileEditorTool.bounceDirection.DR.label = "Down Right";
				addTileEditorTool.bounceDirection.DR.x=90;
				addTileEditorTool.bounceDirection.DR.y=0;
				addTileEditorTool.bounceDirection.DR.selected=true;
				addTileEditorTool.bounceDirection.DL = new CheckBox();
				addTileEditorTool.bounceDirection.DL.label = "Down Left";
				addTileEditorTool.bounceDirection.DL.x=90;
				addTileEditorTool.bounceDirection.DL.y=20;
				addTileEditorTool.bounceDirection.UR = new CheckBox();
				addTileEditorTool.bounceDirection.UR.label = "Up Right";
				addTileEditorTool.bounceDirection.UR.x=90;
				addTileEditorTool.bounceDirection.UR.y=40;
				addTileEditorTool.bounceDirection.UL = new CheckBox();
				addTileEditorTool.bounceDirection.UL.label = "Up Left";
				addTileEditorTool.bounceDirection.UL.x=90;
				addTileEditorTool.bounceDirection.UL.y=60;
				addTileEditorTool.bounceDirection.High = new CheckBox();
				addTileEditorTool.bounceDirection.High.label = "High";
				addTileEditorTool.bounceDirection.High.x=90;
				addTileEditorTool.bounceDirection.High.y=80;
				addTileEditorTool.bounceDirection.Deep = new CheckBox();
				addTileEditorTool.bounceDirection.Deep.label = "Deep";
				addTileEditorTool.bounceDirection.Deep.x=90;
				addTileEditorTool.bounceDirection.Deep.y=100;
				addTileEditorTool.bounceDirection.addChild(addTileEditorTool.bounceDirection.UR);
				addTileEditorTool.bounceDirection.addChild(addTileEditorTool.bounceDirection.UL);
				addTileEditorTool.bounceDirection.addChild(addTileEditorTool.bounceDirection.DR);
				addTileEditorTool.bounceDirection.addChild(addTileEditorTool.bounceDirection.DL);
				addTileEditorTool.bounceDirection.addChild(addTileEditorTool.bounceDirection.High);
				addTileEditorTool.bounceDirection.addChild(addTileEditorTool.bounceDirection.Deep);
				addTileEditorTool.addChild(addTileEditorTool.bounceDirection);
			}
		}
		//----- On Add Tile Editor Teleport Click -----------------------------------
		public function onAddTileEditorTeleportClick(event:Event):void {
			if(!addTileEditorTool.teleport.selected ){
				addTileEditorTool.walkable.enabled=true;
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.removeChild(addTileEditorTool.teleportDestination);
				if(!addTileEditorTool.elevation.selected){
					addTileEditorTool.x+=110;
				}
			}else{
				if(!addTileEditorTool.ladder.selected &&!addTileEditorTool.slopes.selected&&!addTileEditorTool.elevation.selected&& !addTileEditorTool.bounce.selected&& !addTileEditorTool.slide.selected){
					addTileEditorTool.x-=110;
				}else if (addTileEditorTool.targetClip!=null && addTileEditorTool.contains(addTileEditorTool.targetClip)) {
					addTileEditorTool.removeChild(addTileEditorTool.targetClip);
				}
				var dp:DataProvider = new DataProvider();
				addTileEditorTool.walkable.selected = true;
				addTileEditorTool.ladder.selected = false;
				addTileEditorTool.slopes.selected = false;
				addTileEditorTool.bounce.selected = false;
				addTileEditorTool.slide.selected = false;
				addTileEditorTool.teleportDestination = new MovieClip();
				addTileEditorTool.targetClip = addTileEditorTool.teleportDestination;
				addTileEditorTool.teleportDestination.y=addTileEditorTool.teleport.y;
				addTileEditorTool.teleportDestination.destX = new NumericStepper();
				addTileEditorTool.teleportDestination.destX.x= 70;
				addTileEditorTool.teleportDestination.destX.width=40;
				addTileEditorTool.teleportDestination.destX.height-=5;
				addTileEditorTool.teleportDestination.destX.maximum= game.map.mapWidth-1;
				addTileEditorTool.teleportDestination.destY = new NumericStepper();
				addTileEditorTool.teleportDestination.destY.x=addTileEditorTool.teleportDestination.destX.x+35;
				addTileEditorTool.teleportDestination.destY.width=40;
				addTileEditorTool.teleportDestination.destY.height-=5;
				addTileEditorTool.teleportDestination.destY.maximum= game.map.mapHeight-1;
				addTileEditorTool.teleportDestination.destZ = new NumericStepper();
				addTileEditorTool.teleportDestination.destZ.x=addTileEditorTool.teleportDestination.destY.x+35;
				addTileEditorTool.teleportDestination.destZ.width=40;
				addTileEditorTool.teleportDestination.destZ.height-=5;
				addTileEditorTool.teleportDestination.destZ.value=0;
				addTileEditorTool.teleportDestination.destZ.maximum= game.map.mapHigh-1;
				addTileEditorTool.teleportDestination.destTextX = new TextField();
				addTileEditorTool.teleportDestination.destTextX.text = "x";
				addTileEditorTool.teleportDestination.destTextX.x = 75;
				addTileEditorTool.teleportDestination.destTextX.y-=20;
				addTileEditorTool.teleportDestination.destTextY = new TextField();
				addTileEditorTool.teleportDestination.destTextY.text = "y";
				addTileEditorTool.teleportDestination.destTextY.x = 110;
				addTileEditorTool.teleportDestination.destTextY.y-=20;
				addTileEditorTool.teleportDestination.destTextZ = new TextField();
				addTileEditorTool.teleportDestination.destTextZ.text = "z";
				addTileEditorTool.teleportDestination.destTextZ.x = 145;
				addTileEditorTool.teleportDestination.destTextZ.y-=20;
				addTileEditorTool.teleportDestination.addChild(addTileEditorTool.teleportDestination.destX);
				addTileEditorTool.teleportDestination.addChild(addTileEditorTool.teleportDestination.destY);
				addTileEditorTool.teleportDestination.addChild(addTileEditorTool.teleportDestination.destZ);
				addTileEditorTool.teleportDestination.addChild(addTileEditorTool.teleportDestination.destTextX);
				addTileEditorTool.teleportDestination.addChild(addTileEditorTool.teleportDestination.destTextY);
				addTileEditorTool.teleportDestination.addChild(addTileEditorTool.teleportDestination.destTextZ);
				addTileEditorTool.addChild(addTileEditorTool.teleportDestination);
			}
		}
		//################################################################################################
		//######################################  Mouse Action  ##########################################
		//----- On Stage Mouse Click -----------------------------------
		public function onStageMouseMove(event:MouseEvent):void {
			if(tileEditorTool.buttonSave.label=="Save"){
				if(!event.buttonDown && tileEditor.hitTestPoint(event.stageX,event.stageY)){
					onTileEditorMouseMove(event.stageY-tileEditor.y);
				}else if( scrollPane.hitTestPoint(event.stageX,event.stageY) && !tileEditor.hitTestPoint(event.stageX,event.stageY) && event.stageX<500 && event.stageY<420){
					var point = new Point(event.stageX/map.scaleX-map.x-25+scrollPane.horizontalScrollPosition,event.stageY/map.scaleY-map.y-140-game.map.mapHigh*game.tileHigh+scrollPane.verticalScrollPosition);
					var tile:MovieClip=getMovieClipAt(isoToScreenPoint(point));
					if(event.buttonDown && firstPoint!=null){
						var firstTile:Tile=getMapTileAt(isoToScreenPoint(firstPoint));
						var secondTile:Tile=getMapTileAt(isoToScreenPoint(point));
						colorTiles(firstTile,secondTile,1,0,0,1,0,0,0);
					}else{
						
						colorTile(tile,1,0,0,1,0,0,0);
					}
				} else if(event.buttonDown && firstPoint!=null){
					if(map.width>scrollPane.width || map.height>scrollPane.height){
						if(event.stageX>scrollPane.x){
							scrollPane.horizontalScrollPosition+=5;
						}
						if(event.stageY>scrollPane.y){
							scrollPane.verticalScrollPosition+=5;
						}
						if(event.stageX<=5){
							scrollPane.horizontalScrollPosition-=5;
						}
						if(event.stageY<=5){
							scrollPane.verticalScrollPosition-=5;
						}
					}
				}
				if(!tileEditor.hitTestPoint(event.stageX,event.stageY)){
					onTileEditorRollOut();
				}
			}
		}
		//----- Remove Clip -----------------------------------
		public function removeClip(clip:MovieClip):void {
			if(this.contains(clip)){
				removeChild(clip);
			}
		}
		//----- On Stage Mouse Click -----------------------------------
		public function onStageMouseDown(event:MouseEvent):void {
			if(tileEditorTool.buttonSave.label=="Save"){
				if(scrollPane.hitTestPoint(event.stageX,event.stageY) && !tileEditor.hitTestPoint(event.stageX,event.stageY)  && event.stageX<500 && event.stageY<420 ){
					firstPoint = new Point(event.stageX/map.scaleX-map.x-25+scrollPane.horizontalScrollPosition,event.stageY/map.scaleY-map.y-140-game.map.mapHigh*game.tileHigh+scrollPane.verticalScrollPosition);
				}
			}
		}
		//----- On Stage Mouse Click -----------------------------------
		public function onStageMouseUp(event:MouseEvent):void {
			if(tileEditorTool.buttonSave.label=="Save"){
				if(scrollPane.hitTestPoint(event.stageX,event.stageY)&& !tileEditor.hitTestPoint(event.stageX,event.stageY) && tileEditor.tileFrame!=-1 && event.stageX<500 && event.stageY<420 ){
					var point = new Point(event.stageX/map.scaleX-map.x-25+scrollPane.horizontalScrollPosition,event.stageY/map.scaleY-map.y-140-game.map.mapHigh*game.tileHigh+scrollPane.verticalScrollPosition);
					var tile=getMapTileAt(isoToScreenPoint(point));
					if(tile!=null && firstPoint!=null){
						var firstTile:Tile=getMapTileAt(isoToScreenPoint(firstPoint));
						var min = minTile(firstTile,tile);
						var max = maxTile(firstTile,tile);
						if((tileEditor.tileFrame+tileEditor.tileFrameX!=tile.frame|| tileEditor.tileFrameSet!=tile.frameSet) && tileEditor.tileLayer==0 || (tileEditor.tileFrame+tileEditor.tileFrameX!=tile.addFrame || tileEditor.tileFrameSet!=tile.addFrameSet) && tileEditor.tileLayer==1 || (tileEditor.tileFrame+tileEditor.tileFrameX!=tile.objectInsideFrame || tileEditor.tileFrameSet!=tile.objectInsideFrameSet) && tileEditor.tileLayer==2 || (tileEditor.tileFrame+tileEditor.tileFrameX!=tile.objectOutsideFrame || tileEditor.tileFrameSet!=tile.objectOutsideFrameSet) && tileEditor.tileLayer==3 ){
							changeTiles(tileEditor.tileLevel,min.y,min.x,max.y,max.x,tileEditor.tileFrame+tileEditor.tileFrameX,tileEditor.tileFrameSet, tileEditor.tileFlip);				
						}else if(tile.frame!=1 && tileEditor.tileLevel==0 && tileEditor.tileLayer==0){
							changeTiles(tileEditor.tileLevel,min.y,min.x,max.y,max.x,1,0, false);				
						}else if(tile.frame!=1 && tileEditor.tileLevel>0 ||tileEditor.tileLayer!=0){
							changeTiles(tileEditor.tileLevel,min.y,min.x,max.y,max.x,0,0, false);				
						}
					} 
				}else if(scrollPane.hitTestPoint(event.stageX,event.stageY)&& !tileEditor.hitTestPoint(event.stageX,event.stageY) && tileEditor.tileFrame==-1 && addTileEditorTool!=null && this.contains(addTileEditorTool)  && event.stageX<500 && event.stageY<420 ){
					point = new Point(event.stageX/map.scaleX-map.x-25/map.scaleX+scrollPane.horizontalScrollPosition,event.stageY/map.scaleX-map.y-140-game.map.mapHigh*game.tileHigh+scrollPane.verticalScrollPosition);
					tile=getMapTileAt(isoToScreenPoint(point));
					if(tile!=null && firstPoint!=null){
						firstTile=getMapTileAt(isoToScreenPoint(firstPoint));
						min = minTile(firstTile,tile);
						max = maxTile(firstTile,tile);
						updateProperties(tileEditor.tileLevel,min.y,min.x,max.y,max.x);
					} 
				}
				else if(tileEditor.hitTestPoint(event.stageX,event.stageY)){// Not mouse down
					onTileEditorMouseUp(event.stageY-tileEditor.y);
				}
				cleanColorTile();
				firstPoint=null;
			}
		}
		//------ Min ------------------------------------
		function minTile(tile1:Tile, tile2:Tile) :Point{
			var min:Point=new Point();
			if(tile1.position.xtile<tile2.position.xtile){
				min.x=tile1.position.xtile;
			}
			else{
				min.x=tile2.position.xtile;
			}
			if(tile1.position.ytile<tile2.position.ytile){
				min.y=tile1.position.ytile;
			}
			else{
				min.y=tile2.position.ytile;
			}
			return min;
		}
		//------ Max ------------------------------------
		function maxTile(tile1:Tile, tile2:Tile) :Point{
			var max:Point=new Point();
			if(tile1.position.xtile<tile2.position.xtile){
				max.x=tile2.position.xtile;
			}
			else{
				max.x=tile1.position.xtile;
			}
			if(tile1.position.ytile<tile2.position.ytile){
				max.y=tile2.position.ytile;
			}
			else{
				max.y=tile1.position.ytile;
			}
			return max;
		}
		//----- On Stage Mouse Wheel Down -----------------------------------
		public function onStageMouseWheelDown():void {
			zoomIn();
		}
		//----- On Stage Mouse Wheel Up -----------------------------------
		public function onStageMouseWheelUp():void {
			zoomOut();
		}
		//------Init Performance  ------------------------------------
		public function initPerformance():void {
			FPS.text = "FPS";
			Memory.text = "mem";
			FPS.width=70;
			Memory.width=80;
			FPS.selectable = false;
			Memory.selectable = false;
			FPS.x=480;
			FPS.y=430;
			Memory.x = FPS.x+50;
			Memory.y = 430;
			addChild(FPS);
			addChild(Memory);
			initPerformanceListener();
		}
		//------Init Performance Listener---------------------------------
		public function initPerformanceListener():void{
			performanceTimer.addEventListener(TimerEvent.TIMER, onPerformanceTimer);
			performanceTimer.start();
		}
		//-- On Performance Timer ----------------------------------------------------
		public function onPerformanceTimer(event:TimerEvent):void {
			var fps:Number = 1/((getTimer()-currentTime)/1000);
			currentTime = getTimer();
			FPS.text = "FPS: "+Math.round(fps).toString();
			Memory.text = "Mem :"+(Math.round((System.totalMemory/1048576)*10)/10).toString()+" MB";
		}
		//################################################################################################
		//######################################  KeyBoard Action  ##########################################
		//----- On Key Left Down -----------------------------------
		public function onKeyLeftDown():void {
			scrollPane.horizontalScrollPosition-=5;
		}
		//----- On Key Right Down -----------------------------------
		public function onKeyRightDown():void {
			scrollPane.horizontalScrollPosition+=5;
		}
		//----- On Key Up Down -----------------------------------
		public function onKeyUpDown():void {
			scrollPane.verticalScrollPosition-=5;
		}
		//----- On Key Down Down -----------------------------------
		public function onKeyDownDown():void {
			scrollPane.verticalScrollPosition+=5;
		}
	}
}