package com.sibirjak.angara.resource {
	import flash.display.Sprite;

	/**
	 * Declares the possibility of a loader to automatically add the
	 * loaded content to a given display class object.
	 * 
	 * @author jes 13.05.2009
	 */
	public interface IDisplayAssetLoader {

		/**
		 * Specifies the display container the loaded content should be added to.
		 * 
		 * @param container The container the content will be added to.
		 */
		function set container(container : Sprite) : void;

		/**
		 * Returns the previously defined container.
		 * 
		 * @return container The container the content will be added to.
		 */
		function get container() : Sprite;
		
	}
}
