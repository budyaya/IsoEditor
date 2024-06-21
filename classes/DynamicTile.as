//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com

package{
	
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.BitmapData;
	import flash.display.Bitmap;

	public class DynamicTile extends DecorateurTile {

		public var id:Number;
		public var charsetName:String;
		public var bitmapData:BitmapData=null;
		public var bitmap:Bitmap=null;
		public var informationClip:InformationClip;
		
		public var oldFrame:Number=0;
		public var dirx:Number=0;
		public var diry:Number=0;
		public var dirz:Number=0;
		public var speed:Number=4;
		public var xSpeed:Number=speed;
		public var ySpeed:Number=speed;
		public var zSpeed:Number=speed/2;
		public var xJumpSpeed:Number=0;
		public var yJumpSpeed:Number=0;
		public var zJumpSpeed:Number=0;
		public var jumpStart:Number=-10;
		public var slideStart:Number=-10;
		public var longJump:Number=-4;
		public var friction:Number=2;
		public var zFriction:Number=0;
		public var gravity:Number=2;
		public var collision:Number=0;
		public var range:Number=5;
		public var rangeTiles:Array=null;
		public var strength:Number=10;
		public var weight:Number=10;
		public var stamina:Number=30;
		public var currentStamina:Number=30;
		public var acceleration:Number=1;
		public var breath:Number=1;
		public var targetTile=null;
		
		public var path:Path=null;
		public var destination:Object=null;
		
		public var canAttack=true;
		public var canMove:Boolean=true;
		public var canSit=true;
		public var canPull=true;
		public var canPush=true;
		public var canThrow=true;
		public var canHold=true;
		public var canCarry:Boolean=true;
		public var canClimb:Boolean=false;
		public var canRun:Boolean=true;
		public var canFly:Boolean=true;
		public var canBeGrab:Boolean=true;
		public var canBePush:Boolean=true;
		public var canTeleport:Boolean=true;
		public var canSlowTime:Boolean=true;
		
		public var isPushed:Number=0;
		public var isConnected:Boolean=true;
		public var isAttacking:Boolean=false;
		public var isDefending:Boolean=false;
		public var isJumping:Boolean=false;
		public var isDoubleJumping:Boolean=false;
		public var isFalling:Boolean=false;
		public var isSliding:Boolean=false;
		public var isOnSlope:Boolean=false;
		public var isOnLadder:Boolean=false;
		public var isOnSpeed:Boolean=false;
		public var isMoving:Boolean=false;
		public var isSitting:Boolean=false;
		public var isGrab:Boolean=false;
		public var isClimbing:Boolean=false;
		public var isRunning:Boolean=false;
		public var isSlow:Boolean=false;
		public var isSlowedBy:Char=null;
		public var isSlowingTime:Boolean=false;
		public var isFlying:Boolean=false;
		public var isSelectable:Boolean=true;
		public var isPulling:DynamicTile=null;
		public var isPushedBy:DynamicTile=null;
		public var isPushing:DynamicTile=null;
		public var isThrowing:DynamicTile=null;
		public var isHolding:DynamicTile=null;
		public var isCarrying:DynamicTile=null;
		public var isCarryiedBy:DynamicTile=null;
		public var isSelected:Boolean =false;
		
		public var targetAI:DynamicTile=null;
		public var childrenAI:DynamicTile=null;
		public var wanderAI:Boolean=false;
		public var wanderTheta:Number=0;
		public var evadeAI:Boolean=false;
		public var pusruitAI:Boolean=false;
		public var seekAI:Boolean=false;

		public function DynamicTile(_tile:Tile,_positionx:Number,_positiony:Number,_positionz:Number, _tileWidth:Number, _tileHeight:Number,_tileHigh:Number, _id:Number,_charsetName:String,  _targetTile) {
			super(_tile);
			decorVar(_positionx,_positiony,_positionz,_tileWidth, _tileHeight,_tileHigh, _id,_charsetName, _targetTile);
			initInformationClip();
		}
		//----- Decor Var -----------------------------------
		private function decorVar(_positionx:Number,_positiony:Number,_positionz:Number,_tileWidth:Number, _tileHeight:Number,_tileHigh:Number, _id:Number,_charsetName:String,   _targetTile) {
			tileName="dynamicTile";
			id=_id;
			charsetName=_charsetName;
			walkable=false;
			xMovable=true;
			yMovable=true;
			zMovable=true;
			tileWidth=_tileWidth;
			tileHeight=_tileHeight;
			tileHigh=_tileHigh;
			position.x=_positionx;
			position.y=_positiony;
			position.z=_positionz;
			targetTile=_targetTile;
			updateCorner(position);
			
		}
		//----- Init Information Clip -----------------------------------
		public function initInformationClip():void {
			informationClip = new InformationClip(this);
			addChild(informationClip);
		}
		//----- Get Player XMl -----------------------------------
		public function getPlayerXml():String {
			var xml:String="<updatetile>";
			xml+="<char";
			xml+=" id='"+id+"'";
			xml+=" charsetName='"+charsetName+"'";
			xml+=" x='"+position.x+"'";
			xml+=" y='"+position.y+"'";
			xml+=" z='"+position.z+"'";
			xml+=" dirx='"+dirx+"'";
			xml+=" diry='"+diry+"'";
			xml+=" dirz='"+dirz+"'";
			xml+=" width='"+tileWidth+"'";
			xml+=" height='"+tileHeight+"'";
			xml+=" high='"+tileHigh+"'";
			xml+=" xJumpSpeed='"+xJumpSpeed+"'";
			xml+=" yJumpSpeed='"+yJumpSpeed+"'";
			xml+=" zJumpSpeed='"+zJumpSpeed+"'";
			xml+=" frame='"+frame+"'";
			xml+=" texture='"+frame+"'";
			xml+=" xSpeed='"+xSpeed+"'";
			xml+=" ySpeed='"+ySpeed+"'";
			xml+=" zSpeed='"+zSpeed+"'";
			xml+=" friction='"+friction+"'";
			xml+=" gravity='"+gravity+"'";
			xml+=" jumpStart='"+jumpStart+"'";
			xml+=" slideStart='"+slideStart+"'";	
			xml+=" currentStamina='"+currentStamina+"'";	
			xml+=" isAttacking='"+isAttacking+"'";
			xml+=" isSliding='"+isSliding+"'";
			xml+=" isGrab='"+isGrab+"'";
			xml+=" isPulling='"+isPulling+"'";
			xml+=" isHolding='"+isHolding+"'";
			xml+=" isPushing='"+isPushing+"'";
			xml+=" isOnSlope='"+isOnSlope+"'";
			xml+=" isThrowing='"+isThrowing+"'";
			xml+=" isCarrying='"+isCarrying+"'";
			xml+=" isSlowingTime='"+isSlowingTime+"'";
			xml+=" isJumping='"+isJumping+"'";
			xml+=" isFalling='"+isFalling+"'";
			xml+=" isOnladder='"+isOnLadder+"'";
			xml+=" isPushed='"+isPushed+"'";
			xml+="/>";
			xml+="</updatetile>";
		return xml;
		}
	}
}