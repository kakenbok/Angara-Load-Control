package com.sibirjak.angara.core {

	import com.sibirjak.angara.resource.AbstractResourceLoader;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.ResourceLoaderEvent;

	import org.as3commons.collections.LinkedSet;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.IOrderedSet;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * Manages all open loader connections.
	 * 
	 * @author jes 10.02.2009
	 */
	public class ConnectionPool extends EventDispatcher {
		
		/**
		 * The number of simultaneous http connections.
		 */
		private var _numMaxConnections : uint;

		/**
		 * The list of currently loading resource loaders.
		 */
		private var _connections : IOrderedSet;

		/**
		 * Creates a new ConnectionPool instance.
		 * 
		 * @param numConnections The number of simultaneous http connections.
		 */
		public function ConnectionPool(maxConnections : uint) {
			_numMaxConnections = maxConnections;
			_connections = new LinkedSet();
		}

		/**
		 * Starts loading for each of the specified list of resource loaders.
		 * 
		 * @param itemsToLoad List of loaders to start loading.
		 */
		public function load(itemsToLoad : Array) : void {
			var loader : IResourceLoader;
			for (var i : Number = 0; i < itemsToLoad.length; i++) {
				loader = itemsToLoad[i];
				_connections.add(loader);
				configureListeners(loader);
				loader.load();
			}
		}
		
		/**
		 * Returns the number of free connections.
		 * 
		 * <p>This method is called by the LoaderManager. The pool will subsequently
		 * be filled by the number of resource loaders returned by this method.</p>
		 * 
		 * <p>The method will return zero if at least 1 resource loader defines a
		 * callback function. In such a case we have to wait for the callbacks
		 * finish before we continue loading other resources.</p>
		 * 
		 * @return The number of connections left to be opened subsequentially.
		 */
		public function get numFreeConnections() : uint {
			var iterator : IIterator = _connections.iterator();
			var loader : IResourceLoader;
			while (iterator.hasNext()) {
				loader = iterator.next();
				if (AbstractResourceLoader(loader).sibirjak_loader::hasCallback()) return 0;
			}

			return _numMaxConnections - _connections.size;
		}
		
		/**
		 * Closes all open connections.
		 * 
		 * <p>The method calls the stop() property of each containing resource loader.
		 * The loader is then supposed to dispatch a stop notification, which will
		 * remove it from the connection pool.</p>
		 */
		public function clear() : void {
			trace ("stop connections:" + this);
			var loader : IResourceLoader;
			var iterator : IIterator = _connections.iterator();
			while (iterator.hasNext()) {
				loader = iterator.next();
				deconfigureListeners(loader);
				loader.stop();
			}
			_connections.clear();
			trace ("/stop connections:" + this);

			dispatchRemove();
		}
		
		/*
		 * Item listeners
		 */
		
		/**
		 * Starts listening to resource loader notifications.
		 */
		private function configureListeners(loader : IResourceLoader) : void {
			// priority 1 enables the queue to be the first
			// receiver of resource events
			loader.addEventListener(ResourceLoaderEvent.COMPLETE, resourceFinishedHandler);
			loader.addEventListener(ResourceLoaderEvent.FAILURE, resourceFinishedHandler);
			loader.addEventListener(ResourceLoaderEvent.STOP, resourceFinishedHandler);
		}

		/**
		 * Stops listening to resource loader notifications.
		 */
		private function deconfigureListeners(loader : IResourceLoader) : void {
			loader.removeEventListener(ResourceLoaderEvent.COMPLETE, resourceFinishedHandler);
			loader.removeEventListener(ResourceLoaderEvent.FAILURE, resourceFinishedHandler);
			loader.removeEventListener(ResourceLoaderEvent.STOP, resourceFinishedHandler);
		}

		/**
		 * Removes a loader after it has been finished or stopped
		 * and dispatches a pool remove event.
		 */
		private function resourceFinishedHandler(event : ResourceLoaderEvent) : void {
			//trace ("[ConnectionPool] " + event.type + " " + event.target);
			removeResourceLoader(event.resourceLoader);
			dispatchRemove();
		}
		
		/*
		 * Private
		 */

		/**
		 * Dispatches the LoaderItemEvent.REMOVE event.
		 */
		protected function dispatchRemove() : void {
//			trace ("DISPATCH REMOVED");
			dispatchEvent(new Event(Event.REMOVED));
		}
		
		/**
		 * Remvoes a loader from the pool.
		 */
		private function removeResourceLoader(loader : IResourceLoader) : void {
			deconfigureListeners(loader);
			_connections.remove(loader);
		}
		
		/**
		 * Info
		 */
		override public function toString() : String {
			return "[ConnectionPool] numItems:" + _connections.size;
		}
	}
}
