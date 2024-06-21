//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com

package{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;

	public class DataManager extends MovieClip {

		var xmlMap:Xml;
		var xmlChar:Xml;
		var xmlTexture:Xml;
		var loader:Loader;
		var textureToLoad:Array;
		var addTextureToLoad:Array;
		var objectTextureToLoad:Array;
		var graphicTileTable:Array=new Array();
		var graphicAddTileTable:Array=new Array();
		var graphicObjectTable:Array=new Array();
		var textureMaxHeight:Number=0;
		var game:Object=new Object();
		public var map:Map;
		var pictLdr:Loader;
		var mapPath:String;
		var ioError:String

		public function DataManager( _mapPath:String):void {
			mapPath="xml/"+_mapPath;
			loadXmlTexture("xml/texture.xml");
		}
		//------ On Progress Made ------------------------------------
		public function onProgressMade( progressEvent:ProgressEvent ):void {
			dispatchEvent( new DataManagerEvent(DataManagerEvent.LOADINGPROGRESS));
		}
		//------ On Io Error ------------------------------------
		public function onIoError( event:IOErrorEvent ):void {
			ioError=  event.toString();
			dispatchEvent( new DataManagerEvent(DataManagerEvent.IOERROR));
		}
		//------ Load Xml Texture ------------------------------------
		function loadXmlTexture(_path:String) {
			xmlTexture=new Xml(_path);
			xmlTexture.addEventListener(XmlEvent.SUCCESS,xmlTextureLoadingSuccessfull);
		}
		//------ Xml Map Loading Successfull  ------------------------------------
		function xmlTextureLoadingSuccessfull(xmlEvent:XmlEvent):void {
			initTileTextureLoader();
			loadGraphicTile();
			xmlTexture.removeEventListener(XmlEvent.SUCCESS,xmlTextureLoadingSuccessfull);
		}
		//------ Init Texture Loader ------------------------------------
		function initTileTextureLoader() {
			textureToLoad=new Array();
			addTextureToLoad=new Array();
			objectTextureToLoad=new Array();
			for each  (var  png:XML  in xmlTexture.contenu.tileSet.png)  {
				textureToLoad.push([png, png.@tileWidth, png.@tileHeight, png.@tileX, png.@tileY , png.@tileSetName]);
				if(png.@tileHeight>textureMaxHeight){
					textureMaxHeight = png.@tileHeight;
				}
			}
			for each  (png in xmlTexture.contenu.addTileSet.png)  {
				addTextureToLoad.push([png, png.@tileWidth, png.@tileHeight, png.@tileX, png.@tileY, png.@tileSetName]);
				if(png.@tileHeight>textureMaxHeight){
					textureMaxHeight = png.@tileHeight;
				}
			}
			for each  (png in xmlTexture.contenu.objectSet.png)  {
				objectTextureToLoad.push([png, png.@tileWidth, png.@tileHeight, png.@tileX, png.@tileY, png.@tileSetName]);
				if(png.@tileHeight>textureMaxHeight){
					textureMaxHeight = png.@tileHeight;
				}
			}
		}
		//------ Load Graphic Tile ------------------------------------
		function loadGraphicTile() {
			pictLdr = new Loader();
			var pictURL:String=textureToLoad[0][0];
			var pictURLReq:URLRequest=new URLRequest(pictURL);
			pictLdr.load(pictURLReq);
			pictLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, graphicTileLoadingSuccessfull);
			pictLdr.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgressMade );
			pictLdr.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIoError );
		}
		//------ Load Graphic Add Tile ------------------------------------
		function loadGraphicAddTile() {
			if(addTextureToLoad.length>0){
				pictLdr = new Loader();
				var pictURL:String=addTextureToLoad[0][0];
				var pictURLReq:URLRequest=new URLRequest(pictURL);
				pictLdr.load(pictURLReq);
				pictLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, graphicAddTileLoadingSuccessfull);
				pictLdr.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgressMade );
				pictLdr.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIoError );
			}else{
				loadGraphicObject();
			}
		}
		//------ Load Graphic Object ------------------------------------
		function loadGraphicObject() {
			if(objectTextureToLoad.length>0){
				pictLdr = new Loader();
				var pictURL:String=objectTextureToLoad[0][0];
				var pictURLReq:URLRequest=new URLRequest(pictURL);
				pictLdr.load(pictURLReq);
				pictLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, graphicObjectLoadingSuccessfull);
				pictLdr.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgressMade );
				pictLdr.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIoError );
			}else{
				loadXmlMap(mapPath);
			}
		}
		//------ Graphic Tile Loading Successfull ------------------------------------
		function graphicTileLoadingSuccessfull(event:Event):void {
			dispatchEvent( new DataManagerEvent(DataManagerEvent.LOADINGCOMPLETED));
			var tileSet:Object=event.target;
			graphicTileTable.push([tileSet,textureToLoad[0][1] ,textureToLoad[0][2],textureToLoad[0][3],textureToLoad[0][4],textureToLoad[0][5]]);
			textureToLoad.shift();
			if(textureToLoad.length==0){
				pictLdr.contentLoaderInfo.removeEventListener(Event.COMPLETE, graphicTileLoadingSuccessfull);
				pictLdr.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onProgressMade );
				pictLdr.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onIoError );
				loadGraphicAddTile();
			}else{
				loadGraphicTile();
			}
		}
		//------ Graphic Add Tile Loading Successfull ------------------------------------
		function graphicAddTileLoadingSuccessfull(event:Event):void {
			dispatchEvent( new DataManagerEvent(DataManagerEvent.LOADINGCOMPLETED));
			var tileSet:Object=event.target;
			graphicAddTileTable.push([tileSet,addTextureToLoad[0][1] ,addTextureToLoad[0][2],addTextureToLoad[0][3],addTextureToLoad[0][4],addTextureToLoad[0][5]]);
			addTextureToLoad.shift();
			if(addTextureToLoad.length==0){
				pictLdr.contentLoaderInfo.removeEventListener(Event.COMPLETE, graphicAddTileLoadingSuccessfull);
				pictLdr.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onProgressMade );
				pictLdr.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onIoError );
				loadGraphicObject();
			}else{
				loadGraphicAddTile();
			}
		}
		//------ Graphic Object Tile Loading Successfull ------------------------------------
		function graphicObjectLoadingSuccessfull(event:Event):void {
			dispatchEvent( new DataManagerEvent(DataManagerEvent.LOADINGCOMPLETED));
			var tileSet:Object=event.target;
			graphicObjectTable.push([tileSet,objectTextureToLoad[0][1] ,objectTextureToLoad[0][2],objectTextureToLoad[0][3],objectTextureToLoad[0][4],objectTextureToLoad[0][5]]);
			objectTextureToLoad.shift();
			if(objectTextureToLoad.length==0){
				pictLdr.contentLoaderInfo.removeEventListener(Event.COMPLETE, graphicObjectLoadingSuccessfull);
				pictLdr.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onProgressMade );
				pictLdr.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onIoError );
				loadXmlMap(mapPath);
			}else{
				loadGraphicObject();
			}
		}
		//------ Load Xml Map ------------------------------------
		function loadXmlMap(_path:String) {
			xmlMap=new Xml(_path);
			xmlMap.addEventListener(XmlEvent.SUCCESS,xmlMapLoadingSuccessfull);
		}
		//------ Load New Xml Map ------------------------------------
		public function loadNewXmlMap(_path:String) {
			xmlMap=new Xml(_path);
			xmlMap.addEventListener(XmlEvent.SUCCESS,xmlNewMapLoadingSuccessfull);
		}
		//------ Xml Map Loading Successfull  ------------------------------------
		function xmlMapLoadingSuccessfull(xmlEvent:XmlEvent):void {
			initMap(xmlMap.contenu);
		}
		//------ Xml New Map Loading Successfull  ------------------------------------
		function xmlNewMapLoadingSuccessfull(xmlEvent:XmlEvent):void {
			initMap(xmlMap.contenu);
		}
		//------ Load Xml  ------------------------------------
		public function loadXml(_xml:XML) {
			initMap(_xml);
		}
		//------ Init Map ------------------------------------
		function initMap(_xml:XML) {
			game.tileWidth=Math.abs(_xml.game.@tileWidth);
			game.tileHeight=Math.abs(_xml.game.@tileHeight);
			game.tileHigh=Math.abs(_xml.game.@tileHigh);
			game.tileMode=_xml.game.@tileMode;
			game.visibility=new Object();
			game.visibility.X=Math.abs(_xml.game.@visibilityX);
			game.visibility.Y=Math.abs(_xml.game.@visibilityY);
			game.visibility.Z=Math.abs(_xml.game.@visibilityZ);
			game.map =new Object();
			game.map.mapHigh=Math.abs(_xml.map.@mapHigh);
			game.map.mapHeight=Math.abs(_xml.map.@mapHeight);
			game.map.mapWidth=Math.abs(_xml.map.@mapWidth);
			game.map.mapColor=_xml.map.@mapColor;
			game.map.R=_xml.map.@R;
			game.map.G=_xml.map.@G;
			game.map.B=_xml.map.@B;
			game.map.tileFrame=stringToTabXml(_xml.map.@tileFrame.split(","));
			game.map.addTileFrame=stringToTabXml(_xml.map.@addTileFrame.split(","));
			game.map.objectInsideFrame=stringToTabXml(_xml.map.@objectInsideFrame.split(","));
			game.map.objectOutsideFrame=stringToTabXml(_xml.map.@objectOutsideFrame.split(","));
			game.map.tileProperties=stringToTabXml(_xml.map.@tileProperties.split(","));
			map=new Map(game);
			dispatchEvent( new DataManagerEvent(DataManagerEvent.UPDATEMAP));
		}
		//------ Init Tab ------------------------------------
		function initTab(_frame:Number) {
			var tab:Array=new Array(game.map.mapHigh);
			for (var k=0; k<game.map.mapHigh; k++) {
				tab[k]=new Array(game.map.mapHeight);
				for (var j=0; j<game.map.mapHeight; ++j) {
					tab[k][j]=new Array(game.map.mapWidth);
					for (var i=0; i<game.map.mapWidth; ++i) {
						if (k==0) {
							tab[k][j][i]=2;
						} else {
							tab[k][j][i]=1;
						}
					}
				}
			}
			return tab;
		}
		//------ String To Tab Xml ------------------------------------
		function stringToTabXml(_tab:Array):Array {
			var tab:Array=new Array(game.map.mapHigh);
			tab[0]=new Array(game.map.mapHeight);
			tab[0][0]=new Array(game.map.mapWidth);
			var tmp:Number=0;
			var i=0;var j=0; var k=0;
			while(tmp<_tab.length){
				var string:Array = _tab[tmp].split("*");
				if(string.length==1){
					tab[k][j][i]=string[0];							
					i++;
					if(i>=game.map.mapWidth){
						i=0;
						j++;
						tab[k][j]=new Array(game.map.mapWidth);
						if(j>=game.map.mapHeight){
							j=0;
							k++;
							tab[k]=new Array(game.map.mapWidth);
							tab[k][0]=new Array(game.map.mapWidth);
						}
					}
				}else{
					for (var l:Number=0; l<Number(string[0]);l++){
						tab[k][j][i]=string[1];
						i++;
						if(i>=game.map.mapWidth){
							i=0;
							j++;
							tab[k][j]=new Array(game.map.mapWidth);
							if(j>=game.map.mapHeight){
								j=0;
								k++;
								tab[k]=new Array(game.map.mapWidth);
								tab[k][0]=new Array(game.map.mapWidth);
							}
						}							
					}
				}
				tmp++;
			}
			//trace(tab);
			return tab;
		}
		//------ Tab To String Xml ------------------------------------
		function tabToStringXml(_tab:Array):String {
			var string:String = "";
			var frame:Number=-1;
			var cpt:Number=1;
			for (var k=0; k<game.map.mapHigh; k++) {
				for (var j=0; j<game.map.mapHeight; ++j) {
					for (var i=0; i<game.map.mapWidth; ++i) {
						if(frame!=-1){
							if(frame == _tab[k][j][i]){
								cpt++;
							}else{
								if(cpt>1){
									string+=cpt+"*"+frame;
									cpt=1;
								}else{
									string+=frame;
								}
								if(k!=game.map.mapHigh && j!=game.map.mapHeight && i!=game.map.mapWidth){
									string+=",";
								}
							}
						}
						frame=_tab[k][j][i];
					}							
				}
			}
			if(cpt>1){
				string+=cpt+"*"+frame;
			}
			return string;
		}
		//------ String To Bool ------------------------------------
		function stringToBool(data:String):Boolean {
			if (data=="true") {
				return true;
			} else if (data=="false") {
				return false;
			}
			return false;
		}
				//----- Extend map -----------------------------------
		public function extendMap():void {
			var tab:Array=new Array(game.map.mapHigh);
			for (var k=0; k<game.map.mapHigh; k++) {
				tab[k]= new Array(game.map.mapHeight+1);
				for (var j=0; j<=game.map.mapHeight; ++j) {
					tab[k][j] = new Array(game.map.mapWidth+1);
					for (var i=0; i<=game.map.mapWidth; ++i) {
						if(j==game.map.mapHeight || i==game.map.mapWidth){
							tab[k][j][i]=map.createEmptyTile(i,j,k);
						}else{
							tab[k][j][i]=map.tileTable[k][j][i];
						}
					}
				}
			}
			map.tileTable=tab;
		}
		//----- Level Up map -----------------------------------
		public function levelUpMap():void {
			game.map.mapHigh+=1;
			var tab:Array=new Array(game.map.mapHigh);
			for (var k=0; k<game.map.mapHigh; k++) {
				tab[k]= new Array(game.map.mapHeight);
				for (var j=0; j<game.map.mapHeight; ++j) {
					tab[k][j] = new Array(game.map.mapWidth);
					for (var i=0; i<game.map.mapWidth; ++i) {
						if(k==game.map.mapHigh-1){
							tab[k][j][i]=map.createEmptyTile(i,j,k);
						}else{
							tab[k][j][i]=map.tileTable[k][j][i];
						}
					}
				}
			}
			map.tileTable=tab;
		}
		//----- Level Down map -----------------------------------
		public function levelDownMap():void {
			game.map.mapHigh-=1;
			var tab:Array=new Array(game.map.mapHigh);
			for (var k=0; k<game.map.mapHigh; k++) {
				tab[k]= new Array(game.map.mapHeight);
				for (var j=0; j<game.map.mapHeight; ++j) {
					tab[k][j] = new Array(game.map.mapWidth);
					for (var i=0; i<game.map.mapWidth; ++i) {
						if(k<game.map.mapHigh){
							tab[k][j][i]=map.tileTable[k][j][i];
						}
					}
				}
			}
			map.tileTable=tab;
		}
		//************************************************************************
		//**************************** Get / Set *********************************
		//-- Get Game ---------------------------------------------
		public function getGame():Object{
			return game;
		}
		//-- Get Map ---------------------------------------------
		public function getMap():Map{
			return map;
		}
		//-- Get XML Map ---------------------------------------------
		public function getXMLMap():XML{
			var xml:XML = xmlMap.contenu;
			xml=updateMapText(xml);
			return xml;
		}
		//-- Get Map ---------------------------------------------
		public function updateMapText(xml:XML):XML{
			var tabFrame:Array=new Array(game.map.mapHigh);
			var tabAddFrame:Array=new Array(game.map.mapHigh);
			var tabObjectInsideFrame:Array=new Array(game.map.mapHigh);
			var tabObjectOutsideFrame:Array=new Array(game.map.mapHigh);
			var tabProperties:Array=new Array(game.map.mapHigh);
			for (var k=0; k<game.map.mapHigh; k++) {
				tabFrame[k]= new Array(game.map.mapHeight);
				tabAddFrame[k]= new Array(game.map.mapHeight);
				tabObjectInsideFrame[k]= new Array(game.map.mapHeight);
				tabObjectOutsideFrame[k]= new Array(game.map.mapHeight);
				tabProperties[k]= new Array(game.map.mapHeight);
				for (var j=0; j<game.map.mapHeight; ++j) {
					tabFrame[k][j] = new Array(game.map.mapWidth);
					tabAddFrame[k][j] = new Array(game.map.mapWidth);
					tabObjectInsideFrame[k][j] = new Array(game.map.mapWidth);
					tabObjectOutsideFrame[k][j]= new Array(game.map.mapHeight);
					tabProperties[k][j] = new Array(game.map.mapWidth);
					for (var i=0; i<game.map.mapWidth; ++i) {
						tabFrame[k][j][i]=map.tileTable[k][j][i].frame+100*map.tileTable[k][j][i].frameSet;
						if(map.tileTable[k][j][i].tileFlip){
							tabFrame[k][j][i]*=-1;
						}
						tabAddFrame[k][j][i]=map.tileTable[k][j][i].addFrame+100*map.tileTable[k][j][i].addFrameSet;
						if(map.tileTable[k][j][i].addTileFlip){
							tabAddFrame[k][j][i]*=-1;
						}
						tabObjectInsideFrame[k][j][i]=map.tileTable[k][j][i].objectInsideFrame+100*map.tileTable[k][j][i].objectInsideFrameSet;
						if(map.tileTable[k][j][i].objectInsideFlip){
							tabObjectInsideFrame[k][j][i]*=-1;
						}
						tabObjectOutsideFrame[k][j][i]=map.tileTable[k][j][i].objectOutsideFrame+100*map.tileTable[k][j][i].objectOutsideFrameSet;
						if(map.tileTable[k][j][i].objectOutsideFlip){
							tabObjectOutsideFrame[k][j][i]*=-1;
						}tabProperties[k][j][i]=Number(map.tileTable[k][j][i].walkable);
						if(map.tileTable[k][j][i].elevation>0){
							tabProperties[k][j][i]+=10*Number(map.tileTable[k][j][i].elevation);
						}
						if(map.tileTable[k][j][i].slopes){
							tabProperties[k][j][i]+=100*map.tileTable[k][j][i].tileProperty;
							tabProperties[k][j][i]+=Number(map.tileTable[k][j][i].slopesDirection)*1000;
						}else if (map.tileTable[k][j][i].ladder){
							tabProperties[k][j][i]+=100*map.tileTable[k][j][i].tileProperty;
							tabProperties[k][j][i]+=Number(map.tileTable[k][j][i].ladderDirection)*1000;
						}else if (map.tileTable[k][j][i].slide){
							tabProperties[k][j][i]+=100*map.tileTable[k][j][i].tileProperty;
							tabProperties[k][j][i]+=Number(map.tileTable[k][j][i].slideDirection)*1000;
						}else if (map.tileTable[k][j][i].bounce){
							tabProperties[k][j][i]+=100*map.tileTable[k][j][i].tileProperty;
							tabProperties[k][j][i]+=Number(map.tileTable[k][j][i].bounceDirection)*1000;
						}else if (map.tileTable[k][j][i].teleport){
							tabProperties[k][j][i]+=100*map.tileTable[k][j][i].tileProperty;
							tabProperties[k][j][i]+=Number(map.tileTable[k][j][i].teleportDestination)*1000;
						}
					}
				}
			}
			var xmlMapFrameText:String = tabToStringXml(tabFrame);
			var xmlMapAddFrameText:String = tabToStringXml(tabAddFrame);
			var xmlMapObjectInsideFrameText:String = tabToStringXml(tabObjectInsideFrame);
			var xmlMapObjectOutsideFrameText:String = tabToStringXml(tabObjectOutsideFrame);
			var xmlMapPropertiesFrameText:String = tabToStringXml(tabProperties);
			xml.map.@tileFrame=xmlMapFrameText;
			xml.map.@addTileFrame=xmlMapAddFrameText;
			xml.map.@objectInsideFrame=xmlMapObjectInsideFrameText;
			xml.map.@objectOutsideFrame=xmlMapObjectOutsideFrameText;
			xml.map.@tileProperties=xmlMapPropertiesFrameText;
			xml.map.@mapWidth=game.map.mapWidth;
			xml.map.@mapHeight=game.map.mapHeight;
			xml.map.@mapHigh=game.map.mapHigh;
			return xml;
		}
		//-- Get tileSet ---------------------------------------------
		public function getTileSet(tileSetName:String):Number{
			for (var i=0; i<graphicTileTable.length;i++){
				if(graphicTileTable[i][graphicTileTable[0].length-1]==tileSetName){
					return i;
				}
			}
			return 0;
		}
		//-- Get Graphic Tile Table ---------------------------------------------
		public function getGraphicTileTable():Array{
			return graphicTileTable;
		}
		//-- Get Graphic Add Tile Table ---------------------------------------------
		public function getGraphicAddTileTable():Array{
			return graphicAddTileTable;
		}
		//-- Get Graphic Object Tile Table ---------------------------------------------
		public function getGraphicObjectTable():Array{
			return graphicObjectTable;
		}
		//-- Get Texture Max height ---------------------------------------------
		public function getTextureMaxHeight():Number{
			return textureMaxHeight;
		}
		//-- Get Pict Loader ---------------------------------------------
		public function getPictLdr():Loader{
			return pictLdr;
		}
		//-- Get IoError  ---------------------------------------------
		public function getIoError():String{
			return ioError;
		}
		//-- Get IoError  ---------------------------------------------
		public function getTotalPict():Number{
			if(xmlTexture.contenu!=null){
				return xmlTexture.contenu.*.children().length();
			}
			return 0;
		}
	}
}