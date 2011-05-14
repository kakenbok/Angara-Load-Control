package com.sibirjak.angara.utils {
	import com.sibirjak.angara.resource.IDisplayAssetLoader;
	import com.sibirjak.angara.resource.IResourceLoaderContainer;
	import com.sibirjak.angara.resource.loaders.URLLoaderDelegate;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;


	/**
	 * The ImageAssetLoader loads display assets via an URLLoaderDelegate, which
	 * is pretty much faster than using the LoaderDelegate.
	 * 
	 * <p>After the URLLoaderDelegate has been completed, a new Flash Loader instance
	 * is initialised with the loaded binary data (ByteArray).</p>
	 * 
	 * <p>Its possible to specify a container the loaded content gets added
	 * automatically after it is ready to display.</p>
	 * 
	 * @author jes 04.02.2009
	 */
	public class ImageAssetLoader extends URLLoaderDelegate implements IDisplayAssetLoader {
		
		/**
		 * The container the loaded content should be added to.
		 */
		private var _container : Sprite;

		/**
		 * Creates a new LoaderDelegate instance.
		 * 
		 * @param request The request.
		 */
		public function ImageAssetLoader(request : URLRequest) {
			super(request);
			
			dataFormat = URLLoaderDataFormat.BINARY;
		}

		/*
		 * IDisplayAssetLoader
		 */
		
		/**
		 * @inheritDoc
		 */
		public function set container(container : Sprite) : void {
			_container = container;
		}

		/**
		 * @inheritDoc
		 */
		public function get container() : Sprite {
			return _container;
		}

		/**
		 * Info
		 */
		override public function toString() : String {
			return "[ImageLoader] url:" + _request.url + " progress:" + _progress + " status:" + _status;
		}

		/*
		 * AbstractResourceLoader
		 */

		/**
		 * @inheritDoc
		 */
		override protected function notifyComplete(content : *) : void {
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
			loader.loadBytes(content);
		}
		
		/*
		 * Private
		 */

		/**
		 * Handles the init event.
		 * 
		 * <p>If a container has been specified, the loaded content will be added to.</p>
		 */
		private function initHandler(event : Event) : void {
			var loaderInfo : LoaderInfo = event.target as LoaderInfo;
			loaderInfo.removeEventListener(Event.INIT, initHandler);

			if (_container) {
				if (_container is IResourceLoaderContainer) {
					IResourceLoaderContainer(_container).addLoadedContent(loaderInfo.content);
				} else {
 					_container.addChild(loaderInfo.content);
				}
			}
 
			super.notifyComplete(loaderInfo.content);
		}

		
	}
}
