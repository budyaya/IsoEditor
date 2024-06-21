//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com

package {
	
	import flash.events.Event;
	
	public class DataManagerEvent extends Event 
	{
		public static const SUCCESS:String = "Success";
		public static const UPDATECHAR:String = "Update char successfull";
		public static const UPDATEMAP:String = "Update map successfull";
		public static const LOADINGPROGRESS:String = "Loading Progress";
		public static const LOADINGCOMPLETED:String = "Loading Completed";
		public static const IOERROR:String = "Loading IoError";
		
		public function DataManagerEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{ 
			super( type, bubbles, cancelable );
		} 
		
		public override function clone():Event 
		{ 
			return new DataManagerEvent( type, bubbles, cancelable );
		} 
		
		public override function toString():String 
		{ 
			return formatToString( "DataManagerEvent", "type", "bubbles", "cancelable", "eventPhase" ); 
		}
	}
}