//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com
package  
{
	import flash.events.Event;
	public class NavigationEvent extends Event 
	{
		public static const RESTART:String = "restart";
		public static const START:String = "start";
		public static const NEWMAP:String = "new map";
		public static const SAVEMAP:String = "save map";
		public static const HELP:String = "help";
		public static const RETURN:String = "return";
		
		public function NavigationEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{ 
			super( type, bubbles, cancelable );
			
		} 
		
		public override function clone():Event 
		{ 
			return new NavigationEvent( type, bubbles, cancelable );
		} 
		
		public override function toString():String 
		{ 
			return formatToString( "NavigationEvent", "type", "bubbles", "cancelable", "eventPhase" ); 
		}
	}
}