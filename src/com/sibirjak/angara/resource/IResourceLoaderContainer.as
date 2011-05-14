package com.sibirjak.angara.resource {
	import flash.display.DisplayObject;

	/**
	 * The IResourceLoaderContainer declares an arbitrary display class to be
	 * a target of the loaded content of an IDisplayAssetLoader.
	 * 
	 * <p>You may develop a more complex display class. When implementing this
	 * interface and assigning the display class to an IDisplayAssetLoader instance,
	 * the addLoadedContent() will be called after the resource is ready to display.
	 * Within the addLoadedContent() method you can perform your custom addChild()
	 * operation.</p>
	 * 
	 * @author jes 13.05.2009
	 * @see IDisplayAssetLoader
	 */
	public interface IResourceLoaderContainer {
		
		/**
		 * Method that is called if the resource of the according IDisplayAssetLoader
		 * is ready to be displayed.
		 * 
		 * @param content The content to be displayed.
		 */
		function addLoadedContent(content : DisplayObject) : void;
		
	}
}
