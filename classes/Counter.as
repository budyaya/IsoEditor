//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com
//Thanks to Avoider Game Tutorial, by Michael James Williams
//http://gamedev.michaeljameswilliams.com
package
{
	import flash.display.MovieClip;
	public class Counter extends MovieClip
	{
		public var currentValue:Number;
		
		public function Counter()
		{
			reset();
		}
		
		public function addToValue( amountToAdd:Number ):void
		{
			currentValue = currentValue + amountToAdd;
			updateDisplay();
		}
		
		public function setValue( amount:Number ):void
		{
			currentValue = amount;
			updateDisplay();
		}
		
		public function reset():void
		{
			currentValue = 0;
			updateDisplay();
		}
		
		public function updateDisplay():void
		{
			
		}
		
		public function updateError(errorText:String):void
		{
			
		}
	}
}