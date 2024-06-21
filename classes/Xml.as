//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Xml extends MovieClip {

		public var contenu:XML;

		public function Xml(_chemin:String) {
		loadXml(_chemin);
		}

		public function loadXml(_chemin) {
			var loader:URLLoader = new URLLoader ();
			loader.addEventListener(Event.COMPLETE, finDuChargement);
			loader.addEventListener(IOErrorEvent.IO_ERROR, indiquerErreur);
			loader.load( new URLRequest(_chemin) );
		}
		
		function finDuChargement( event:Event ) {
			contenu=new XML(event.target.data);
			dispatchEvent( new XmlEvent( XmlEvent.SUCCESS ) );
		}

		function indiquerErreur( event:Event ) {
			loadXml("xml/map.xml");
		}
	}
}