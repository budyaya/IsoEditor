//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com
package {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.ColorTransform;

	public class MouseManager {
		var isoGraphic:IsoGraphic;
		var tileTarget:Tile=null;
		var tileTargetTable:Array=new Array();
		var firstTile:Tile=null;
		var secondTile:Tile=null;
		
		public function MouseManager(_isoGraphic:IsoGraphic, _stage:Stage):void {
			initVar(_isoGraphic);
			initMouseListener(_stage);
		}
		//------Init Var-------------------------------------
		public function initVar(_isoGraphic:IsoGraphic):void {
			isoGraphic=_isoGraphic;
		}
		//------Init listener-------------------------------------
		public function initMouseListener(_stage:Stage):void {
			initStageListener(_stage);
		}
		
		//**********************************************************************
		//------Init Stage Listener---------------------------------------------
		public function initStageListener(_stage:Stage):void {
			_stage.doubleClickEnabled=true;
			_stage.addEventListener(MouseEvent.CLICK,onStageClick);
			_stage.addEventListener(MouseEvent.DOUBLE_CLICK,onStageDoubleClick);
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL,onStageWheel);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			
		}
		//------Click Handler ---------------------------------------------
		public function onStageClick(event:MouseEvent):void {
		}
		//------Double Click Handler ---------------------------------------------
		public function onStageDoubleClick(event:MouseEvent):void {
			
		}
		//------Mouse Down Handler ---------------------------------------------
		public function onStageMouseDown(event:MouseEvent):void {
			isoGraphic.onStageMouseDown(event);
		}
		//------Mouse Up Handler ---------------------------------------------
		public function onStageMouseUp(event:MouseEvent):void {
			isoGraphic.onStageMouseUp(event);
		}
		//------Mouse Move Handler ---------------------------------------------
		public function onStageMouseMove(event:MouseEvent):void {
			isoGraphic.onStageMouseMove(event);
		}
		//------Wheel Handler ---------------------------------------------
		public function onStageWheel(event:MouseEvent):void {
			if (event.delta>0) {
				isoGraphic.onStageMouseWheelDown();
			} else {
				isoGraphic.onStageMouseWheelUp();
			}
		}		
	}
}