//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com
package 
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.net.*;
	
	public class HelpScreen extends MovieClip 
	{
		
		public function HelpScreen() {
			Mouse.show();
			returnButton.addEventListener( MouseEvent.CLICK, onClickReturn );
			angelstreet.addEventListener( MouseEvent.CLICK, onClickAngelStreet );
		}
		
		public function onClickReturn( event:MouseEvent ):void{
			dispatchEvent( new NavigationEvent( NavigationEvent.RETURN ) );
		}
		public function onClickAngelStreet( event:MouseEvent ):void {
			var url:String="http://angelstreetv2.blogspot.com/";
			var request:URLRequest=new URLRequest(url);
			try {
				navigateToURL(request, '_blank');// second argument is target
			} catch (e:Error) {
				trace("Error occurred!");
			}
		}
	}
}