package com.sibirjak.angara.resource.loaders {
	import com.sibirjak.angara.resource.AbstractResourceLoader;
	import com.sibirjak.angara.resource.IResourceLoaderContainer;
	import com.sibirjak.angara.resource.LoadingError;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;


	/**
	 * Adapter to the built-in Flash Loader class.
	 * 
	 * @author jes 04.02.2009
	 */
	public class LoaderDelegate extends AbstractResourceLoader implements ILoaderDelegate {
		
		/**
		 * The Flash Loader.
		 */
		private var _loader : Loader;

		/**
		 * The loader context of the Flash Loader load() method.
		 */
		private var _loaderContext : LoaderContext;

		/**
		 * The container the loaded content should be added to.
		 */
		private var _container : Sprite;
		
		/**
		 * Creates a new LoaderDelegate instance.
		 * 
		 * @param request The request.
		 */
		public function LoaderDelegate(request : URLRequest) {
			super(request);
			
			_loader = new Loader();
		}

		/*
		 * ILoaderDelegate
		 */

		/**
		 * @inheritDoc
		 */
		public function set loaderContext(loaderContext : LoaderContext) : void {
			_loaderContext = loaderContext;
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
			return "[SWFLoader] url:" + _request.url + " progress:" + _progress + " status:" + _status;
		}

		/*
		 * AbstractResourceLoader
		 */

		/**
		 * Tries to start the internal Flash Loader.
		 * 
		 * <p>If the loader cannot be started due to security reasons, this method will
		 * fail by invoking the notifyFailure method of the super class.</p>
		 */
		override protected function startLoading() : void {
			configureListeners();
			try {
				// a sandbox security exception can be raised here
				_loader.load(_request, _loaderContext);
			} catch (e : Error) {
				/*
				 * Loading remote items in local-with-filesystem realm or loading
				 * local items in the remote or local-with-network realm will be
				 * punished by an exception thrown here.
				 */
				deconfigureListeners();
				notifyFailure(LoadingError.LOADING_DENIED, "Security error. Loading resource not permitted!", e);
			}
		}
		
		/**
		 * Tries to reset the internal Flash Loader.
		 * 
		 * <p>If no connection is currently open, this method returns false.</p>
		 * 
		 * @return true, if an open connection has been closed. 
		 */
		override protected function clear() : Boolean {
			deconfigureListeners();
			try {
				_loader.close();
			} catch (e : Error) {
				/*
				 * If the item has not started loading yet or is already finished,
				 * we would get here an error when closing the loader connection.
				 */ 
				trace ("stop failed " + _loader + " " + e + " " + this + " -- total " + _loader.contentLoaderInfo.bytesTotal + " loaded " + _loader.contentLoaderInfo.bytesLoaded);
				return false;
			}
			return true;
		}

		/*
		 * Flash Loader events
		 */

		/**
		 * Starts listening to the Flash Loader notifications.
		 */
		private function configureListeners() : void {
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			_loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
		}

		/**
		 * Stops listening to the Flash Loader notifications.
		 */
		private function deconfigureListeners() : void {
			_loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			_loader.contentLoaderInfo.removeEventListener(Event.INIT, initHandler);
		}

		/**
		 * Handles the http status.
		 */
		private function statusHandler(event : HTTPStatusEvent) : void {
			trace ("[ImageLoader] onHttpStatusHandler " + event.status + " " + this);
			notifyHttpStatus(event.status);
		}

		/**
		 * Handles the progress event.
		 */
		private function progressHandler(event : ProgressEvent) : void {
//			trace ("[ImageLoader] onProgressHandler " + event.bytesLoaded + " of " + event.bytesTotal);
			notifyProgress(event.bytesTotal, event.bytesLoaded);
		}
		
		/**
		 * Handles the io error event.
		 */
		private function IOErrorHandler(event : IOErrorEvent) : void {
			trace ("[ImageLoader] errorHandler " + event.text + " " + this);

			deconfigureListeners();
			notifyFailure(LoadingError.FILE_NOT_FOUND, "File not found! " + event.text);
		}

		/**
		 * Handles the complete event.
		 * 
		 * <p>If the content cannot be accessed due to security reasons, this method will
		 * fail by invoking the notifyFailure method of the super class.</p>
		 */
		private function completeHandler(event : Event) : void {
//			trace ("[ImageLoader] completeHandler " + LoaderInfo(event.target).url);
			deconfigureListeners();

			try {
//				trace ("Complete " + url);
 				notifyComplete(LoaderInfo(event.target).content);
			} catch (e : Error) {

				/*
				 * When running in remote realm and loading resources of a different
				 * realm, where no policy file grant access to the content of resources,
				 * we cannot access the LoaderInfo content and an exception will be thrown: 
				 * 
				 * *** Security Sandbox-Verletzung ***
				 * SecurityDomain 'http://example.com/application.swf' hat versucht, auf
				 * inkompatiblen Kontext 'http://anotherexample.com/anotherapplication.swf'
				 * zuzugreifen
				 */
				
//				trace ("Security error when getting content " + info.url);

				notifyFailure(LoadingError.ACCESS_DENIED, "Security error. Accesssing resource content not permitted!", e);
			}
		}

		/**
		 * Handles the init event.
		 * 
		 * <p>If a container has been specified, the loaded content will be added to.</p>
		 * 
		 * <p>If the content cannot be accessed due to security reasons, this method will
		 * fail by invoking the notifyFailure method of the super class.</p>
		 */
		private function initHandler(event : Event) : void {
//			trace ("[ImageLoader] initHandler " + LoaderInfo(event.target).url);

			try {
//				trace ("Complete " + url);
				var content : DisplayObject = LoaderInfo(event.target).content;
 				if (_container) {
					if (_container is IResourceLoaderContainer) {
						IResourceLoaderContainer(_container).addLoadedContent(content);
					} else {
	 					_container.addChild(content);
					}
 				}
 				notifyInit(content);
			} catch (e : Error) {

				/*
				 * When running in remote realm and loading resources of a different
				 * realm, where no policy file grant access to the content of resources,
				 * we cannot access the LoaderInfo content and an exception will be thrown: 
				 * 
				 * *** Security Sandbox-Verletzung ***
				 * SecurityDomain 'http://example.com/application.swf' hat versucht, auf
				 * inkompatiblen Kontext 'http://anotherexample.com/anotherapplication.swf'
				 * zuzugreifen
				 */
				
//				trace ("Security error when getting content " + info.url);

				notifyFailure(LoadingError.ACCESS_DENIED, "Security error. Accesssing resource content not permitted!", e);
			}
		}
		
	}
}