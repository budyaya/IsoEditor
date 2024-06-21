//--By AngelStreet--
//--http://angelstreetv2.free.fr
//--joachim_djibril@hotmail.com

package{

	public class DecorateurTile extends Tile {

		public function DecorateurTile(_tile:Tile) {
			super(_tile.position.xtile,_tile.position.ytile,_tile.position.ztile,_tile.frame,_tile.addFrame,_tile.addLadder,_tile.addSpeeding,_tile.tileWidth,_tile.tileHeight,_tile.tileHigh, _tile.R, _tile.G, _tile.B);
		}
	}
}