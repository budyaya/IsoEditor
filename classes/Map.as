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
	import fl.controls.ComboBox;
	import fl.controls.CheckBox;
	import fl.data.DataProvider;

	public class Map extends MovieClip {

		var game:Object=new Object();
		var map:Object=new Object();
		var tileTable:Array;

		//------ Map ------------------------------------
		public function Map(_game:Object):void {
			game=_game;
			map=_game.map;
			buildMap();
			disposeMem();
		}
		//------ Build Map ------------------------------------
		function buildMap() {
			var table=new Array(map.mapHigh);
			tileTable=new Array(map.mapHigh);
			for (var k=0; k<map.mapHigh; k++) {
				table[k]=k;
				tileTable[k]=new Array(map.mapHeight);
				for (var j=0; j<map.mapHeight; ++j) {
					tileTable[k][j]=new Array(map.mapWidth);
					for (var i=0; i<map.mapWidth; ++i) {
						tileTable[k][j][i]=createTile(i,j,k);
					}
				}
			}
		}
		//------ Dispose Mem ------------------------------------
		function disposeMem() {
			delete(game.map.tileFrame);
			delete(game.map.addTileFrame);
			delete(game.map.objectInsideFrame);
			delete(game.map.objectOutsideFrame);
			delete(game.map.tileProperties);
		}
		//------ Calculate Depth ------------------------------------
		function calculateDepth(x:Number,y:Number,z:Number):Number {
			var _depth=29*x+31*y*5+11*z;
			return _depth;
		}

		//------ Create Tile ------------------------------------
		function createTile(i, j, k):Tile {
			var tile:Tile=new Tile(i,j,k,game.map.tileFrame[k][j][i],game.map.addTileFrame[k][j][i],game.map.objectInsideFrame[k][j][i], game.map.objectOutsideFrame[k][j][i],game.map.tileProperties[k][j][i],game.tileWidth,game.tileHeight,game.tileHigh,game.map.R,game.map.G,game.map.B);
			return tile;
		}
		//------ Create Empty Tile ------------------------------------
		public function createEmptyTile(i,j,k):Tile {
			if(k==0){
				var tile:Tile=new Tile(i,j,k,1,0,0,0,1,game.tileWidth+1,game.tileHeight+1,game.tileHigh,game.map.R,game.map.G,game.map.B);
			}else{
				tile=new Tile(i,j,k,0,0,0,0,1,game.tileWidth+1,game.tileHeight+1,game.tileHigh,game.map.R,game.map.G,game.map.B);
			}
			return tile;
		}
	}
}