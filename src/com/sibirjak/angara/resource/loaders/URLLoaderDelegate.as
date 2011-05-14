package com.sibirjak.angara.resource.loaders {
	import com.sibirjak.angara.resource.AbstractResourceLoader;
	import com.sibirjak.angara.resource.LoadingError;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;


	/**
	 * Adapter to the built-in Flash URLLoader class.
	 * 
	 * @author jes 04.02.2009
	 */
	public class URLLoaderDelegate extends AbstractResourceLoader implements IURLLoaderDelegate {
		
		/**
		 * The Flash URLLoader.
		 */
		protected var _urlLoader : URLLoader;

		/**
		 * The data format of the Flash URLLoader content.
		 */
		protected var _dataFormat : String;
		
		/**
		 * Creates a new URLLoaderDelegate instance.
		 * 
		 * @param request The request.
		 */
		public function URLLoaderDelegate(request : URLRequest) {
			super(request);

			_urlLoader = new URLLoader(); // default format is URLLoaderDataFormat.TEXT
		}

		/*
		 * IURLLoaderDelegate
		 */
		
		/**
		 * @inheritDoc
		 */
		public function get dataFormat() : String {
			return _urlLoader.dataFormat;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set dataFormat(format : String) : void {
			_urlLoader.dataFormat = format;
		}

		/**
		 * Info
		 */
		override public function toString() : String {
			return "[DataLoader] url:" + _request.url + " progress:" + _progress + " status:" + _status;
		}

		/*
		 * AbstractResourceLoader
		 */

		/**
		 * Tries to start the internal Flash URLLoader.
		 * 
		 * <p>If the loader cannot be started due to security reasons, this method will
		 * fail by invoking the notifyFailure method of the super class.</p>
		 */
		override protected function startLoading() : void {
			configureListeners();
            try {
				_urlLoader.load(_request);
            } catch (e : Error) {
//				trace ("Security error " + e);
				deconfigureListeners();
				notifyFailure(LoadingError.LOADING_DENIED, "Security error. Loading resource not permitted!", e);
			}
		}
		
		/**
		 * Tries to reset the internal Flash URLLoader.
		 * 
		 * <p>If no connection is currently open, this method returns false.</p>
		 * 
		 * @return true, if an open connection has been closed. 
		 */
		override protected function clear() : Boolean {
			deconfigureListeners();
			try {
				_urlLoader.close();
			} catch (e : Error) {
				/*
				 * If the item has not started loading yet or is already finished,
				 * we would get here an error when closing the loader connection.
				 * 
				 * Also, if loading is not allowed by security restrictions the first try
				 * to load the resource won't be successful and we have no open stream
				 * that can be reset.
				 */ 
				trace ("stop failed " + _urlLoader + " " + e + " " + this + " -- total " + _urlLoader.bytesTotal + " loaded " + _urlLoader.bytesLoaded);
				return false;
			}
			return true;
		}

		/*
		 * Flash URLLoader events
		 */

		/**
		 * Starts listening to the Flash URLLoader notifications.
		 */
		private function configureListeners() : void {
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_urlLoader.addEventListener(Event.COMPLETE, completeHandler);
		}

		/**
		 * Stops listening to the Flash URLLoader notifications.
		 */
		private function deconfigureListeners() : void {
			_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		    _urlLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			_urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
		}

		/**
		 * Handles the http status.
		 */
		private function statusHandler(event : HTTPStatusEvent) : void {
//			trace ("Status " + event.status);
			notifyHttpStatus(event.status);
		}

		/**
		 * Handles the progress event.
		 */
		private function progressHandler(event : ProgressEvent) : void {
//			trace ("onProgressHandler " + event.bytesLoaded + " of " + event.bytesTotal);
			notifyProgress(event.bytesTotal, event.bytesLoaded);
		}

		/**
		 * Handles the security error event.
		 */
		private function securityErrorHandler(event : SecurityErrorEvent) : void {
			//trace ("security " + event.text);
			deconfigureListeners();
			notifyFailure(LoadingError.LOADING_DENIED, "Security error. Loading resource not permitted! " + event.text);
		}

		/**
		 * Handles the io error event.
		 */
		private function IOErrorHandler(event : IOErrorEvent) : void {
//			trace ("IO error " + event.text);
//			trace ("security " + event.text);
			deconfigureListeners();
			notifyFailure(LoadingError.FILE_NOT_FOUND, "File not found! " + event.text);
		}

		/**
		 * Handles the complete event.
		 */
		private function completeHandler(event : Event) : void {
//			trace ("[DataLoader] completeHandler url:" + _request.url + " progress:" + _progress + " status:" + _status + " scheduled:" + _isScheduled);
			deconfigureListeners();
			notifyComplete(URLLoader(event.target).data);
		}

	}
}
