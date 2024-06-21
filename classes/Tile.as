//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com

package{
	
	import flash.display.MovieClip;
	import flash.ui.Mouse;
	import flash.events.Event;
	import flash.geom.ColorTransform;

	public class Tile extends MovieClip {

		public var tileName:String;
		public var frame:Number;
		public var addFrame:Number;
		public var objectInsideFrame:Number;
		public var objectOutsideFrame:Number;
		public var frameSet:Number=0;
		public var addFrameSet:Number=0;
		public var objectInsideFrameSet:Number=0;
		public var objectOutsideFrameSet:Number=0;
		public var flip:Boolean=false;
		public var tileFlip:Boolean=false;
		public var addTileFlip:Boolean=false;
		public var objectInsideFlip:Boolean=false;
		public var objectOutsideFlip:Boolean=false;
		public var tileProperty:Number=0;
		
		
		public var walkable:Boolean=true;
		public var elevation:Number=0;
		public var slopes:Boolean=true;
		public var slopesDirection:String;
		public var ladder:Boolean=true;
		public var ladderDirection:String;
		public var slide:Boolean=true;
		public var slideDirection:String;
		public var bounce:Boolean=true;
		public var bounceDirection:String;
		public var teleport:Boolean=true;
		public var teleportDestination:String;
		
		public var depth:Number;
		public var tileWidth:Number=30;
		public var tileHeight:Number=30;
		public var tileHigh:Number=0;
		public var xMovable:Boolean=false;
		public var yMovable:Boolean=false;
		public var zMovable:Boolean=false;
		public var position:TilePoint=new TilePoint();
		public var center:TilePoint=new TilePoint();
		public var cornerUL:TilePoint=new TilePoint();
		public var cornerUR:TilePoint=new TilePoint();
		public var cornerDL:TilePoint=new TilePoint();
		public var cornerDR:TilePoint=new TilePoint();
		public var position2:TilePoint=new TilePoint();
		public var addLadder:String="";
		public var addSpeeding:Number=0;
		public var xSpeedingSpeed:Number=2;
		public var ySpeedingSpeed:Number=2;
		public var zSpeedingSpeed:Number=10;
		public var addK:String="";
		public var xKSpeed:Number=8;
		public var yKSpeed:Number=8;
		public var zKSpeed:Number=8;
		var gameTileWidth:Number=30;
		var gameTileHeight:Number=30;
		var gameTileHigh:Number=10;
		public var R:Number;
		public var G:Number;
		public var B:Number;
		
		
		public function Tile(i:Number,j:Number,k:Number,_frame:Number,_addFrame:Number,_objectInsideFrame:Number, _objectOutsideFrame:Number,_tileProperties:Number,_gameTileWidth:Number,_gameTileHeight:Number,_gameTileHigh:Number, _R:Number, _G:Number, _B:Number):void {
			initVar(i,j,k,_frame,_addFrame,_objectInsideFrame, _objectOutsideFrame,_tileProperties,_gameTileWidth,_gameTileHeight,_gameTileHigh, _R, _G, _B);
			getTilePoint(i,j,k);
			calculateDepth();
		}
		//----- init Var -----------------------------------
		private function initVar(i:Number,j:Number,k:Number,_frame:Number,_addFrame:Number,_objectInsideFrame:Number, _objectOutsideFrame:Number,_tileProperties:Number,_gameTileWidth:Number,_gameTileHeight:Number,_gameTileHigh:Number, _R:Number, _G:Number, _B:Number):void {
			tileName="t_"+k+"_"+j+"_"+i;
			getFrame(_frame,_addFrame,_objectInsideFrame, _objectOutsideFrame, k);
			getProperties(_tileProperties);
			gameTileWidth=_gameTileWidth;
			gameTileHeight=_gameTileHeight;
			gameTileHigh=_gameTileHigh;
			tileWidth=_gameTileWidth;
			tileHeight=_gameTileHeight;
			tileHigh=_gameTileHigh;
			R=_R;
			G=_G;
			B=_B;
		}
		//----- Screen To Tile -----------------------------------
		public function screenToTile(point:TilePoint):void {
			point.xtile=Math.floor(point.x/gameTileWidth);
			point.ytile=Math.floor(point.y/gameTileHeight);
			point.ztile=Math.floor(point.z/gameTileHigh);
		}
		//----- Tile To Screen -----------------------------------
		public function tileToScreen(point:TilePoint):void {
			point.x=point.xtile*gameTileWidth;
			point.y=point.ytile*gameTileHeight;
			point.z=point.ztile*gameTileHigh;
		}
		//----- Update Corner -----------------------------------
		public function updateCorner(point:TilePoint):void {
			var downY=point.y+tileHeight-1;
			var upY=point.y;
			var leftX=point.x;
			var rightX=point.x+tileWidth-1;
			center.x=point.x+tileWidth/2-1;
			center.y=point.y+tileHeight/2-1;
			center.z=position.z;
			position2.x=position.x;
			position2.y=position.y;
			position2.z=position.z+tileHigh;
			cornerUL.x=leftX;
			cornerUL.y=upY;
			cornerUL.z=position.z;
			cornerDL.x=leftX;
			cornerDL.y=downY;
			cornerDL.z=position.z;
			cornerUR.x=rightX;
			cornerUR.y=upY;
			cornerUR.z=position.z;
			cornerDR.x=rightX;
			cornerDR.y=downY;
			cornerDR.z=position.z;
			screenToTile(center);
			screenToTile(position);
			screenToTile(cornerUL);
			screenToTile(cornerDL);
			screenToTile(cornerUR);
			screenToTile(cornerDR);
			screenToTile(position2);
		}
		//----- Get Frame -----------------------------------
		public function getFrame(_frame:Number,_addFrame:Number,_objectInsideFrame:Number,_objectOutsideFrame:Number,k:Number):void {
			//-------------- Flip --------------------------------
			if (_frame<0) {
				tileFlip=true;
				_frame*=-1;
			}
			if (_addFrame<0) {
				addTileFlip=true;
				_frame*=-1;
			}
			if (_objectInsideFrame<0) {
				objectInsideFlip=true;
				_frame*=-1;
			}
			if (_objectOutsideFrame<0) {
				objectOutsideFlip=true;
				_frame*=-1;
			}
			//----------- Frame Set ------------------------------
			if (_frame>=100) {
				frameSet=Math.floor(_frame/100);
				_frame=_frame%100;
			}
			if (_addFrame>=100) {
				addFrameSet=Math.floor(_addFrame/100);
				_addFrame=_addFrame%100;
			}
			if (_objectInsideFrame>=100) {
				objectInsideFrameSet=Math.floor(_objectInsideFrame/100);
				_objectInsideFrame=_objectInsideFrame%100;
			}
			if (_objectOutsideFrame>=100) {
				objectOutsideFrameSet=Math.floor(_objectOutsideFrame/100);
				_objectOutsideFrame=_objectOutsideFrame%100;
			}
			//----------- Frame ------------------------------
			frame=_frame;
			addFrame=_addFrame;
			objectInsideFrame=_objectInsideFrame;
			objectOutsideFrame=_objectOutsideFrame;
		}
		//----- Get Properties -----------------------------------
		public function getProperties(_properties:Number):void {
			var str:String = _properties.toString();
			walkable = bin2Bool(str.charAt(str.length-1));//-------------  Walkable
			elevation= Number(str.charAt(str.length-2));
			tileProperty = Number(str.charAt(str.length-3));
			if(tileProperty==1){//---------------------------  Slopes
				walkable=false;
				slopes=true;
				slopesDirection=str.substr(0,str.length-3);
			}else if(tileProperty==2){//---------------------  Ladder
				ladder=true;
				ladderDirection=str.substr(0,str.length-3);
			}else if(tileProperty==3){//---------------------  Slide
				slide = true;
				slideDirection=str.substr(0,str.length-3);
			}else if(tileProperty==4){//---------------------  Bounce
				bounce=true;
				bounceDirection=str.substr(0,str.length-3);
			}else if(tileProperty==5){//---------------------  Teleport
				teleport = true;
				teleportDestination=str.substr(0,str.length-3);
			}
		}
		//----- Bin to Bool-----------------------------------
		public function bin2Bool(bin:String):Boolean {
			if(bin=="1"){
				return true;
			}
			return false;
		}
		//----- Get Tile Point -----------------------------------
		public function getTilePoint(i:Number,j:Number,k:Number) {
			position.xtile=i;
			position.ytile=j;
			position.ztile=k;
			tileToScreen(position);
			updateCorner(position);
		}
		//----- Calculate Depth -----------------------------------
		function calculateDepth():void {
			var r:Number = sum(position.xtile + position.ytile) + position.ytile + 1;
         	depth =r*15+position.ztile;
		}
		//----- Sum -----------------------------------
		function sum(n:Number) : Number {
            return (n * (n + 1) / 2);
   		}
		//----- Clean Properties -----------------------------------
		function cleanProperties():void {
			tileProperty=0;
			walkable=true;
			elevation=0;
			slopes=false;
			slopesDirection="";
			ladder=false;
			ladderDirection="";
			slide=false;
			slideDirection="";
			bounce=false;
			bounceDirection="";
			teleport=false;
			teleportDestination="";
		}
		//----- ToString -----------------------------------
		public  function ToString() : void {
           trace(this, tileName, ",frame: "+ frame, ",xtile: "+position.xtile, ",ytile: "+position.ytile, ",ztile: "+position.ztile, ",walkable: "+walkable);
   		}
	}
}