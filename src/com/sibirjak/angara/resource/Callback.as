package com.sibirjak.angara.resource {

	import com.sibirjak.angara.core.sibirjak_loader;

	import flash.events.EventDispatcher;

	/**
	 * @author jes 04.05.2009
	 */
	public class Callback extends EventDispatcher implements ICallback {
		
		/**
		 * The callback function to be invoked.
		 */
		private var _callbackFunction : Function;

		/**
		 * True if the callback needs to be confirmed.
		 */
		private var _isAsync : Boolean = false;

		/**
		 * Reference to the loader defining this callback.
		 */
		private var _loader : IResourceLoader;
		
		/**
		 * Creates a new callback.
		 *
		 * @param loader The loader defining this callback.
		 * @param callbackFunction The callback function to be invoked before the loader dispatch its COMPLETE event.
		 */
		public function Callback(loader : IResourceLoader, callbackFunction : Function) {
			_loader = loader;
			_callbackFunction = callbackFunction;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loader() : IResourceLoader {
			return _loader;
		}

		/**
		 * @inheritDoc
		 */
		public function setAsync() : void {
			_isAsync = true;
		}

		/**
		 * @inheritDoc
		 */
		public function notifyComplete() : void {
			if (!_isAsync) throw new Error(
				"This operation is only available to asnynchronous callbacks."
				+ " To switch to the asynchronous behaviour you need to call setAsync()"
				+ " within the callback event handler."
			);
			AbstractResourceLoader(_loader).sibirjak_loader::callbackFinished();
		}
		
		/**
		 * Framework internal method to determine, if a callback is asynchronous and
		 * needs to be confirmed by a client.
		 * 
		 * @return True, if is a an asynchronous callback.
		 */
		sibirjak_loader function get isAsync() : Boolean {
			return _isAsync;
		}

		/**
		 * Framework internal trigger of the callback.
		 */
		sibirjak_loader function call() : void {
			_callbackFunction(this);
		}
		
	}
}
