package com.sibirjak.angara {

	import com.sibirjak.angara.core.ILoaderItem;

	import flash.events.IEventDispatcher;

	/**
	 * The LoaderManager interface.
	 * 
	 * The LoaderManager is basically a prioritised queue.
	 * 
	 * @author jes 10.02.2009
	 */
	public interface ILoaderManager extends IEventDispatcher {
		
		/**
		 * Adds a new loader item to the queue.
		 * 
		 * <p>The type can be either LoaderItemType.LOADER, LoaderItemType.SEQUENCE
		 * or LoaderItemType.SEQUENCE_MANAGER.</p>
		 * 
		 * <p>It is possible to specify a priority at which time the item should be
		 * loaded. Lesser priority value means sooner loading.</p>
		 * 
		 * @param loaderItem The item to add.
		 * @param priority The priority to load the item.
		 */
		function add(loaderItem : ILoaderItem, priority : uint = 0) : void;

		/**
		 * Removes a loader item from the queue.
		 * 
		 * <p>The type can be either LoaderItemType.LOADER, LoaderItemType.SEQUENCE
		 * or LoaderItemType.SEQUENCE_MANAGER.</p>
		 * 
		 * @param loaderItem The item to remove.
		 */
		function remove(loaderItem : ILoaderItem) : void;

		/**
		 * Stops all loaders and removes all loader item references from the queue.
		 */
		function clear() : void;

		/**
		 * Stops all active net connections.
		 * 
		 * <p>In order to stop the loader manager loading and pause you need to call
		 * pause() + stop().</p>
		 */
		function stop() : void;
		
		/**
		 * Pauses the LoaderManager.
		 * 
		 * <p>Active connections won't be closed. Use pause() + stop() to close
		 * all connections
		 * and stop the loader manager.</p>
		 */
		function pause() : void;
		
		/**
		 * Resumes the prior paused LoaderManager.
		 */
		function resume() : void;

		/**
		 * The current loader manager status.
		 * 
		 * <p>The initial status is LoaderItemStatus.WAITING. Its possible to
		 * pause the loader manager, which will set the status to LoaderItemStatus.PAUSED.</p>
		 * 
		 * @return The current loading status.
		 */
		function get status() : String;

		/**
		 * Returns the number of resources left to load.
		 * 
		 * <p>Adding 2 loader, finishing 1 loader will then return 1.</p>
		 * 
		 * <p>The value will be calculated at runtime with a worst complexity O(n)
		 * where n is the number of resource loaders added directly or to a container.</p>
		 * 
		 * @return The number of resources left to load.
		 */
		function get numItemsLeft() : uint;

	}
}
