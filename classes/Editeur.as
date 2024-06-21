//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com

package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.display.Loader;
	import flash.display.LoaderInfo;

	public class Editeur extends EditeurScreen {
		
		var dataManager:DataManager;
		var isoGraphic:IsoGraphic;
		var mouseManager:MouseManager;
		var keyManager:KeyManager;		
		var loadingProgress:LoadingProgress;
		var cpt:int=0;

		public function Editeur():void {
			dataManager = new DataManager("map.xml");
			dataManager.addEventListener(DataManagerEvent.UPDATEMAP, onDataManagerLoadingSuccessfull );
			dataManager.addEventListener(DataManagerEvent.LOADINGPROGRESS, onDataManagerLoadingProgress );
			dataManager.addEventListener(DataManagerEvent.LOADINGCOMPLETED, onDataManagerLoadingCompleted );
			dataManager.addEventListener(DataManagerEvent.IOERROR, onDataManagerIoError );
			loadingProgress = new LoadingProgress();
			loadingProgress.x=300;
			loadingProgress.y=200;
			loadingProgress.updateError(cpt + " / " + dataManager.getTotalPict());
			addChild( loadingProgress );
		}
		//-- On DataManager Loading Progress ------------------------------------------
		public function onDataManagerLoadingProgress(dataManagerEvent:DataManagerEvent):void{
			var pictLdr:Loader = dataManager.getPictLdr();
			loadingProgress.setValue(  Math.floor( 100 * pictLdr.contentLoaderInfo.bytesLoaded / pictLdr.contentLoaderInfo.bytesTotal ) );
		}
		//-- On DataManager Loading Completed ------------------------------------------
		public function onDataManagerLoadingCompleted(dataManagerEvent:DataManagerEvent):void{
			cpt++;
			loadingProgress.updateError(cpt + " / " + dataManager.getTotalPict());
			
		}
		//-- On DataManager IoError ------------------------------------------
		public function onDataManagerIoError(dataManagerEvent:DataManagerEvent):void{
			var ioError:String = dataManager.getIoError();
			loadingProgress.updateError("IoError: " + ioError);
		}
		//-- On DataManager Loading Successfull ------------------------------------------
		public function onDataManagerLoadingSuccessfull(dataManagerEvent:DataManagerEvent):void{
			removeChild( loadingProgress );
			isoGraphic = new IsoGraphic(dataManager);
			addChild(isoGraphic);
			initListener();
			dataManager.removeEventListener(DataManagerEvent.UPDATEMAP, onDataManagerLoadingSuccessfull );
		}
		//-- Init Listener ------------------------------------------
		public function initListener():void {
			mouseManager=new MouseManager(isoGraphic,stage);
			keyManager=new KeyManager(isoGraphic,stage);
		}		
		//-- Load Map ------------------------------------------
		public function loadMap():void{
			removeChild(isoGraphic);
			dataManager = new DataManager("map.xml");
			dataManager.addEventListener(DataManagerEvent.UPDATEMAP, onDataManagerLoadingSuccessfull );
		}
	}
}