//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com

package {

	import flash.utils.*;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class KeyManager {

		var keyCode:Number=0;
		var clickKeyCode:Number=0;//Previous key click
		var isoGraphic:IsoGraphic;

		//---- Key Manager------------------------------------------------
		public function KeyManager(_isoGraphic:IsoGraphic, _stage:Stage):void {
			initVar(_isoGraphic);
			initKeyListener(_stage);
		}
		//---- Init Var------------------------------------------------
		public function initVar(_isoGraphic:IsoGraphic):void {
			isoGraphic=_isoGraphic;
		}
		//------Init Key Listener ---------------------------------------------
		public function initKeyListener(_stage) {
			_stage.addEventListener(KeyboardEvent.KEY_DOWN,reportKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP,reportKeyUp);
		}
		//------Report Key Down ---------------------------------------------
		public function reportKeyDown(keyBoardEvent:KeyboardEvent):void {
			checkEventKeyDown(keyBoardEvent.keyCode);
		}
		//------Report Key Up ---------------------------------------------
		public function reportKeyUp(keyBoardEvent:KeyboardEvent):void {
			checkEventKeyUp(keyBoardEvent.keyCode);
			keyCode=0;
		}
		//---- Check Event Key Down ------------------------------------------------
		public function checkEventKeyDown(keyCode:Number):void {
			if (keyCode==Keyboard.LEFT || keyCode==81) {
				isoGraphic.onKeyLeftDown();
			} else if (keyCode==Keyboard.RIGHT || keyCode==68) {
				isoGraphic.onKeyRightDown();
			} else if (keyCode==Keyboard.UP || keyCode==90) {
				isoGraphic.onKeyUpDown();
			} else if (keyCode==Keyboard.DOWN || keyCode==83) {
				isoGraphic.onKeyDownDown();
			} else if (keyCode==Keyboard.ENTER) {
				trace("ENTER");
			} else if (keyCode==Keyboard.SPACE) {
				trace("SPACE");
			}
		}
		//---- Check Event Key Up ------------------------------------------------
		public function checkEventKeyUp(keyCode:Number) {

		}
	}
}