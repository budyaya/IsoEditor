//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com
package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.Security;

	public class DocumentClass extends MovieClip {
		public var menuScreen:MenuScreen;
		public var playScreen:Editeur;
		public var helpScreen:HelpScreen;
		public var loadingProgress:LoadingProgress;

		public function DocumentClass() {
			Security.allowInsecureDomain("*");
			loadingProgress = new LoadingProgress();
			loadingProgress.x=300;
			loadingProgress.y=200;
			addChild( loadingProgress );
			loaderInfo.addEventListener( Event.COMPLETE, onCompletelyDownloaded );
			loaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgressMade );
		}
		//------ On Completely Downloaded ------------------------------------
		public function onCompletelyDownloaded( event:Event ):void {
			gotoAndStop(3);
			removeChild(loadingProgress);
			showMenuScreen();
		}
		//------ On Progress Made ------------------------------------
		public function onProgressMade( progressEvent:ProgressEvent ):void {
			loadingProgress.setValue( Math.floor( 100 * loaderInfo.bytesLoaded / loaderInfo.bytesTotal ) );
		}
		//------ Show Menu Screen ------------------------------------
		public function showMenuScreen():void {
			menuScreen = new MenuScreen();
			menuScreen.addEventListener( NavigationEvent.START, onRequestStart );
			menuScreen.addEventListener( NavigationEvent.HELP, onRequestHelp );
			menuScreen.x=100;
			menuScreen.y=25;
			addChild( menuScreen );
		}
		//------ On Request Return Start ------------------------------------
		public function onRequestStart( navigationEvent:NavigationEvent ):void {
			playScreen = new Editeur();
			playScreen.x=0;
			playScreen.y=0;
			addChild(playScreen);
			removeChild(menuScreen);
			menuScreen=null;
		}
		//------ On Request Help ------------------------------------
		public function onRequestHelp( navigationEvent:NavigationEvent ):void {
			helpScreen = new HelpScreen();
			helpScreen.x=100;
			helpScreen.y=25;
			helpScreen.addEventListener( NavigationEvent.RETURN, onRequestReturn );
			addChild(helpScreen);
			removeChild(menuScreen);
			menuScreen=null;
		}
		//------ On Request Return ------------------------------------
		 function onRequestReturn( navigationEvent:NavigationEvent ):void {
			if(helpScreen!=null){
				removeChild(helpScreen);
				helpScreen=null;
			}
			showMenuScreen();
		}	
	}
}