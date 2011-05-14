package com.sibirjak.angara.resource {

	import com.sibirjak.angara.core.AbstractLoaderItem;
	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.core.LoaderItemType;
	import com.sibirjak.angara.core.sibirjak_loader;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import org.as3commons.collections.Map;
	import org.as3commons.collections.framework.IMap;



	/**
	 * Abstract implementation of the IResourceLoader interface.
	 * 
	 * @author jes 06.02.2009
	 */
	public class AbstractResourceLoader extends AbstractLoaderItem implements IResourceLoader {
		
		/**
		 * The request.
		 */
		protected var _request : URLRequest;

		/**
		 * Number of trials before loader will be marked as failed.
		 */
		private var _maxLoadingTrials : uint = 4;

		/**
		 * Number of loading trials already done.
		 */
		protected var _loadingTrials : uint = 0;

		/**
		 * Number of failed loading trials.
		 */
		protected var _failedLoadingTrials : uint = 0;

		/**
		 * Timeout to fail a loading trial.
		 */
		private var _timeout : uint = 1000;

		/**
		 * Http status.
		 */
		private var _httpStatus : int = -1;

		/**
		 * Bytes loaded.
		 */
		private var _bytesLoaded : uint = 0;

		/**
		 * Bytes total.
		 */
		private var _bytesTotal : uint = 0;

		/**
		 * The loaded content.
		 */
		private var _content : *;

		/**
		 * Loading error information.
		 */
		protected var _loadingError : LoadingError;

		/**
		 * Callback instance.
		 */
		private var _callback : ICallback;

		/**
		 * Map for dynamically added properties.
		 */
		private var _properties : IMap;

		/**
		 * Internal timeout timer.
		 */
		private var _timeoutTimer : Timer;

		/**
		 * Cache for the most recent progress to be evaluated within the timer event handlers.
		 */
		private var _lastProgress : Number;
		
		/**
		 * Constructor
		 * 
		 * @param request The request.
		 */
		public function AbstractResourceLoader(request : URLRequest) {
			_request = request;

			_type = LoaderItemType.LOADER;
			_status = LoaderItemStatus.WAITING;
			_numItems = 1;
		}
		
		/*
		 * IResourceLoader
		 */

		/**
		 * @inheritDoc
		 */
		public function get url() : String {
			return _request.url;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set maxLoadingTrials(trials : uint) : void {
			if (trials) _maxLoadingTrials = trials;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get maxLoadingTrials() : uint {
			return _maxLoadingTrials;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get failedLoadingTrials() : uint {
			return _failedLoadingTrials;
		}

		/**
		 * @inheritDoc
		 */
		public function set timeout(timeout : uint) : void {
			if (timeout > _timeout) _timeout = timeout;
		}

		public function set callbackFunction(callbackFunction : Function) : void {
			_callback = new Callback(this, callbackFunction);
		}

		/**
		 * @inheritDoc
		 */
		public function setProperty(name : String, value : *) : void {
			if (!_properties) _properties = new Map();
			_properties.add(name, value);
		}

		/**
		 * @inheritDoc
		 */
		public function getProperty(name : String) : * {
			if (!_properties) return undefined;
			return _properties.itemFor(name);
		}

		/**
		 * @inheritDoc
		 */
		public function load() : void {
			if (_status != LoaderItemStatus.WAITING) return;

			_loadingTrials++;
			startLoading();
			
			/*
			 * If a sandbox security error has been raised,
			 * the status will be FAILURE here.
			 * In this case we don't want the status to be set back to LOADING.
			 */
			if (_status == LoaderItemStatus.FAILURE) return;
			
			// start timeout watching
			
			_timeoutTimer = new Timer(_timeout);
			_timeoutTimer.addEventListener(TimerEvent.TIMER, timeoutTimerHandler);
			_timeoutTimer.start();
			
			// notify clients

			_status = LoaderItemStatus.LOADING;
			dispatchLoading();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop() : void {
			/* 
			 * Cannot stop a completed, paused or failed loader.
			 * This may become an issue with async callbacks where the loader
			 * is set to COMPLETE but still waiting for a callback return.
			 * In such a case by calling LoaderManager.stop() we would set
			 * the status back to LOADING what causes the ConnectionPool not
			 * to return a free connection and the Manager not to resume
			 * loading. 
			 */
			if (_status != LoaderItemStatus.LOADING) return;
			
			/*
			 * If the loader has already finished loading we cannot stop it
			 * any more and have to wait for its complete event.
			 */
			if (clear()) {
				removeTimeoutTimer();

				_progress = 0;
				_numItemsLoaded = 0;
				_numItemsFailed = 0;
				_status = LoaderItemStatus.WAITING;

				dispatchStop();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function pause() : void {
			// can only pause a waiting loader (loading not started yet)
			if (_status != LoaderItemStatus.WAITING) return;
			_status = LoaderItemStatus.PAUSED;
			dispatchPause();
		}

		/**
		 * @inheritDoc
		 */
		override public function resume() : void {
			// can only resume a paused loader
			if (_status != LoaderItemStatus.PAUSED) return;
			_status = LoaderItemStatus.WAITING;
			dispatchResume();
		}

		/**
		 * @inheritDoc
		 */
		public function get httpStatus() : int {
			return _httpStatus;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bytesLoaded() : uint {
			return _bytesLoaded;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bytesTotal() : uint {
			return _bytesTotal;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get content() : * {
			return _content;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loadingError() : LoadingError {
			return _loadingError;
		}

		/*
		 * Protected
		 */
		
		/**
		 * Template method to set up all internal loader references and start loading.
		 * 
		 * <p>An implementor should set up here all listeners to its particular
		 * internal loader and invoke its load method.</p>
		 */
		protected function startLoading() : void {
			// hook to be overridden
		}
		
		/**
		 * Template method to clean up all internal loader references.
		 * 
		 * <p>An implementor should clean up here all listeners to its particular
		 * internal loader and call its clear method.</p>
		 * 
		 * <p>After a reset() invokation the loader must not dispatch any further
		 * loading event.</p>
		 */
		protected function clear() : Boolean {
			return true;
			// hook to be overridden
		}

		/**
		 * A subclass must call notifyFailure in all cases the loading of the
		 * resource cannot be accomplished.
		 * 
		 * @param failureMessage The detailed failure description.
		 */
		protected final function notifyFailure(errorType : String, failureMessage : String, error : Error = null) : void {
			_failedLoadingTrials++;

			dispatchLoadingTrialFailure();
			
			trace ("notifyFailure: " + failureMessage);
			
			removeTimeoutTimer();
			
			// reset loader to not longer dispatch loading events.
			var reset : Boolean = clear();

			// try to load the resource again only in case of timeout.
			if (errorType == LoadingError.TIMEOUT) {
				
				if (_failedLoadingTrials < _maxLoadingTrials) {
					trace ("[AbstractResourceLoader] next try:" + (_loadingTrials + 1) + " out of " + _maxLoadingTrials + " for " + url);
					
					/*
					 * If reset fails (e.g. for security reasons) we do not start
					 * the loader again but mark it as failed.
					 */
					
					if (reset) {
						_status = LoaderItemStatus.WAITING;
						load();
						
						trace ("-------------------------------------------------------------------");
						return;
					}
				}
			}
			
			_numItemsFailed = 1;
			_progress = 1;
			_status = LoaderItemStatus.FAILURE;

			_loadingError = new LoadingError(errorType, this, failureMessage, error);
			dispatchFailure();
			trace ("-------------------------------------------------------------------");
		}

		/**
		 * A subclass must call notifyComplete in all cases the loading of the
		 * resource has been finished successfully.
		 * 
		 * <p>Executes the callback before the final COMPLETE event is dispatched.</p>
		 * 
		 * @param content The loaded content.
		 */
		protected function notifyComplete(content : *) : void {
			removeTimeoutTimer();
			
//			trace ("---complete " + url);
			if (!_content) _content = content;

			_numItemsLoaded = 1;
			_progress = 1;
			_status = LoaderItemStatus.COMPLETE;
			
			if (_callback) {
//				dispatchCallback();
				Callback(_callback).sibirjak_loader::call();
				if (Callback(_callback).sibirjak_loader::isAsync) return;
			}

			dispatchComplete();
		}

		/**
		 * A subclass may call notifyInit if the content is ready for display
		 * or any other use.
		 * 
		 * @param content The loaded content.
		 */
		protected function notifyInit(content : *) : void {
			_content = content;
			dispatchInit();
		}

		/**
		 * A subclass may call notifyProgress to inform the clients about
		 * a change in progess.
		 * 
		 * @param content The loaded content.
		 */
		protected final function notifyProgress(bytesTotal : uint = 0, bytesLoaded : uint = 0) : void {
//			trace ("---progress " + url + " " + progress);

			// don't dispatch event, if the progress did not change
			if (_bytesLoaded == bytesLoaded) return;

			if (bytesTotal) _progress = bytesLoaded / bytesTotal;

			_bytesLoaded = bytesLoaded;
			_bytesTotal = bytesTotal;
			
 			if (_progress == 1) {
				_lastProgress = 1;
				if (_timeoutTimer) {
					_timeoutTimer.delay = 200;
					
				} else {
					trace ("no timeout timer for " + this + " " + _progress);
				}
			}

			dispatchProgress();
		}
		
		/**
		 * A subclass may call notifyHttpStatus to store a http status code.
		 * 
		 * @param status The status code.
		 */
		protected final function notifyHttpStatus(status : int) : void {
			_httpStatus = status;
		}

		/*
		 * sibirjak_loader
		 */

		/**
		 * Framework internal method to detect, if a callback has been defined
		 * to this resource loader.
		 * 
		 * @return true, if a callback is defined.
		 */
		sibirjak_loader function hasCallback() : Boolean {
			return _callback != null;
		}

		/**
		 * Framework internal method to notify the resource loader about the
		 * completion of the callback.
		 * 
		 * <p>Will be invoked by the internal Callback instance.</p>
		 */
		sibirjak_loader function callbackFinished() : void {
			dispatchComplete();
		}

		/*
		 * Loader events
		 */

		/**
		 * Dispatches the ResourceLoaderEvent.LOADING event.
		 */
		protected function dispatchLoading() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.LOADING, this));
		}
		
		/**
		 * Dispatches the ResourceLoaderEvent.PROGRESS event.
		 */
		protected function dispatchProgress() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.PROGRESS, this));
		}
		
		/**
		 * Dispatches the ResourceLoaderEvent.PAUSE event.
		 */
		protected function dispatchPause() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.PAUSE, this));
		}

		/**
		 * Dispatches the ResourceLoaderEvent.RESUME event.
		 */
		protected function dispatchResume() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.RESUME, this));
		}

		/**
		 * Dispatches the ResourceLoaderEvent.STOP event.
		 */
		protected function dispatchStop() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.STOP, this));
		}

		/**
		 * Dispatches the ResourceLoaderEvent.INIT event.
		 */
		protected function dispatchInit() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.INIT, this));
		}

		/**
		 * Dispatches the ResourceLoaderEvent.COMPLETE event.
		 */
		protected function dispatchComplete() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.COMPLETE, this));
		}

		/**
		 * Dispatches the ResourceLoaderEvent.FAILURE event.
		 */
		protected function dispatchFailure() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.FAILURE, this));
		}
		
		/**
		 * Dispatches the ResourceLoaderEvent.TRIAL_FAILURE event.
		 */
		protected function dispatchLoadingTrialFailure() : void {
			dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.TRIAL_FAILURE, this));
		}
		
		/*
		 * Private
		 */

		/**
		 * Timer event handler
		 * 
		 * <p>Dispatches a failure event if the progess has not been changed since the
		 * last timer event.</p>
		 */
		private function timeoutTimerHandler(event : TimerEvent) : void {
			if (_progress == _lastProgress) {
				//trace ("[AbstractResourceLoader] timeout for " + _request.url + " _progress " + _progress + " _lastProgress " + _lastProgress + " time " + new Date().getTime());
				notifyFailure(LoadingError.TIMEOUT, "Timeout loading resource");
			}
			_lastProgress = _progress;
		}

		/**
		 * Removes the internal timer to free memory.
		 */
		private function removeTimeoutTimer() : void {
			if (_timeoutTimer) {
				_timeoutTimer.stop();
				_timeoutTimer.removeEventListener(TimerEvent.TIMER, timeoutTimerHandler);
				_timeoutTimer = null;
			}
			_lastProgress = 0;
		}
		
	}
}

