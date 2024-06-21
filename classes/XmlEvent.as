//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com
package  
{
	import flash.events.Event;
	public class XmlEvent extends Event 
	{
		public static const SUCCESS:String = "success";
		
		public function XmlEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{ 
			super( type, bubbles, cancelable );
		} 
		
		public override function clone():Event 
		{ 
			return new XmlEvent( type, bubbles, cancelable );
		} 
		
		public override function toString():String 
		{ 
			return formatToString( "XmlEvent", "type", "bubbles", "cancelable", "eventPhase" ); 
		}
	}
}