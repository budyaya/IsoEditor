//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com
package
{
	import flash.text.TextField;
	public class LoadingProgress extends Counter
	{
		public function LoadingProgress()
		{
			super();
		}
		
		override public function updateDisplay():void
		{
			super.updateDisplay();
			percentDisplay.text = currentValue.toString();
		}
		override public function updateError(errorText:String):void
		{
			super.updateError(errorText);
			errorDisplay.text = errorText;
		}
	}
}