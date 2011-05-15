/*******************************************************************************
* The MIT License
* 
* Copyright (c) 2011 Jens Struwe.
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
******************************************************************************/
package com.sibirjak.angara {

	import com.sibirjak.angara.core.ConnectionPool;
	import com.sibirjak.angara.core.ILoaderItem;
	import com.sibirjak.angara.core.LoaderItemEvent;
	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.core.Schedule;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author jes 10.02.2009
	 */
	public class LoaderManager extends EventDispatcher implements ILoaderManager {

		/*
		 * Singleton
		 */
		
		/**
		 * The internal sole LoaderManager instance.
		 */
		private static var _instance : ILoaderManager;

		/**
		 * Creates a new LoaderManager instance.
		 * 
		 * <p>Has to be called at start of the application.</p>
		 */
		public static function createInstance(numConnections : uint = 1) : ILoaderManager {
			if (_instance) {
				throw new Error("LoaderManager already exists and cannot be created twice.");
			}
			_instance = new LoaderManager(numConnections);
			return _instance;
		}

		/**
		 * Returns a prior created LoaderManager instance.
		 */
		public static function getInstance() : ILoaderManager {
			if (!_instance) {
				throw new Error("You need to first create a LoaderManager instance.");
			}
			return _instance;
		}

		/**
		 * Sets the static instance to null.
		 */
		public static function destroyInstance() : void {
			_instance = null;
		}

		/*
		 * Instance context
		 */

		/**
		 * Reference to the connection pool which holds all open loader connections.
		 */
		private var _pool : ConnectionPool;

		/**
		 * Reference to the schedule (queue).
		 */
		private var _schedule : Schedule;

		/**
		 * Status of the LoaderManager.
		 */
		private var _status : String = LoaderItemStatus.WAITING;

		/**
		 * Creates a new LoaderManager instance.
		 * 
		 * @param numConnections The number of simultaneous http connections.
		 */
		public function LoaderManager(numConnections : uint = 1) {
			_schedule = new Schedule();
			_schedule.addEventListener(LoaderItemEvent.ADD, scheduleAddHandler);
			_schedule.addEventListener(LoaderItemEvent.REMOVE, scheduleRemoveHandler);

			_pool = new ConnectionPool(numConnections);
			_pool.addEventListener(Event.REMOVED, connectionAvailableHandler);
		}
		
		/*
		 * ILoaderManager
		 */
		/**
		 * @inheritDoc
		 */
		public function add(loaderItem : ILoaderItem, priority : uint = 0) : void {
			_schedule.add(loaderItem, priority);

			loadNext();
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(loaderItem : ILoaderItem) : void {
			_schedule.remove(loaderItem);

			loaderItem.stop();
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear() : void {
			_schedule.clear();
			_pool.clear();
			dispatchEvent(new LoaderItemEvent(LoaderItemEvent.CLEAR, null));
		}
		
		/**
		 * @inheritDoc
		 */
		public function stop() : void {
			_pool.clear();
		}

		/**
		 * @inheritDoc
		 */
		public function pause() : void {
			if (_status == LoaderItemStatus.PAUSED) return;
			_status = LoaderItemStatus.PAUSED;
		}
		
		/**
		 * @inheritDoc
		 */
		public function resume() : void {
			if (_status == LoaderItemStatus.WAITING) return;
			_status = LoaderItemStatus.WAITING;
			loadNext();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get status() : String {
			return _status;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get numItemsLeft() : uint {
			return _schedule.numItemsLeft;
		}
		
		/**
		 * Info
		 */
		override public function toString() : String {
			return "[LoaderManager] itemsLeft:" + numItemsLeft + " status:" + _status;
		}

		/*
		 * Listeners
		 */

		/**
		 * Tries to advance the LoaderManager after an item has been loaded.
		 */
		private function connectionAvailableHandler(event : Event) : void {
			loadNext();
		}

		/**
		 * Tries to advance the LoaderManager after an item has been resumed. 
		 */
		private function itemResumeHandler(event : LoaderItemEvent) : void {
			loadNext();
		}

		/**
		 * Starts listening to an item's resume notification.
		 */
		private function scheduleAddHandler(event : LoaderItemEvent) : void {
			event.affectedLoaderItem.addEventListener(LoaderItemEvent.ADD, itemResumeHandler);
			event.affectedLoaderItem.addEventListener(LoaderItemEvent.RESUME, itemResumeHandler);
			
			dispatchEvent(new LoaderItemEvent(LoaderItemEvent.ADD, null, event.affectedLoaderItem, event.priority));
		}
		
		/**
		 * Stops listening to an item's resume notification.
		 */
		private function scheduleRemoveHandler(event : LoaderItemEvent) : void {
			event.affectedLoaderItem.removeEventListener(LoaderItemEvent.ADD, itemResumeHandler);
			event.affectedLoaderItem.removeEventListener(LoaderItemEvent.RESUME, itemResumeHandler);

			dispatchEvent(new LoaderItemEvent(LoaderItemEvent.REMOVE, null, event.affectedLoaderItem));
		}

		/*
		 * Private
		 */

		/**
		 * Reads the number of free connections from the pool and passes the
		 * next items to load back.
		 */
		private function loadNext() : void {
			if (_status == LoaderItemStatus.PAUSED) return;
			
			var numFreeConnections : uint = _pool.numFreeConnections;
			if (numFreeConnections) {
				var itemsToLoad : Array = _schedule.getNextItems(numFreeConnections);
				_pool.load(itemsToLoad);
			}
		}

	}
}
