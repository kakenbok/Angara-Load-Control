package com.sibirjak.angara.core {
	import flash.events.Event;
	
	/**
	 * Loader item event definition.
	 * 
	 * @author jes 14.05.2009
	 */
	public class LoaderItemEvent extends Event {

		/**
		 * An item has been added to the loader manager queue (Schedule)
		 * or to a sequence.
		 * 
		 * <p>The loader manager will start listening to events of the scheduled
		 * item (Schedule) or continue loading (Sequence and SequenceManager)</p>
		 * 
		 * <p>Dispatched by Schedule, Sequence and SequenceManager.</p>
		 */
		public static const ADD : String = "item_added";
		
		/**
		 * An item has been removed from the to the loader manager queue (Schedule)
		 * or from the connection pool.
		 * 
		 * <p>The loader manager will stop listening to events of the scheduled item
		 * after the Schedule dispatchs this event.</p>
		 * 
		 * <p>The loader manager will find the next items to load after the ConnectionPool
		 * dispatchs this event.</p>
		 * 
		 * <p>Dispatched by Schedule and ConnectionPool.</p>
		 */
		public static const REMOVE : String = "item_removed";

		/**
		 * Progress of an item has changed.
		 * 
		 * <p>Dispatched by all loader items.</p>
		 */
		public static const PROGRESS : String = "item_progress";

		/**
		 * Item is complete.
		 * 
		 * <p>Dispatched by all loader items.</p>
		 */
		public static const COMPLETE : String = "item_complete";

		/**
		 * Loading resource has been failed.
		 * 
		 * <p>Dispatched only by resource loaders.</p>
		 */
		public static const FAILURE : String = "item_failure";

		/**
		 * Item container has been cleared.
		 * 
		 * <p>Dispatched by LoaderManager, Sequence and SequenceManager.</p>
		 */
		public static const CLEAR : String = "item_clear";

		/**
		 * Item has been stopped.
		 * 
		 * <p>Dispatched by all loader items.</p>
		 */
		public static const STOP : String = "item_stop";

		/**
		 * Item has been paused.
		 * 
		 * <p>Dispatched by all loader items.</p>
		 */
		public static const PAUSE : String = "item_pause";

		/**
		 * Item has been resumed.
		 * 
		 * <p>Dispatched by all loader items.</p>
		 */
		public static const RESUME : String = "item_resume";
		
		/**
		 * Reference to the event dispatching loader item.
		 */
		protected var _loaderItem : ILoaderItem;

		/**
		 * Reference to a child oader item, which has been added or removed.
		 */
		protected var _affectedLoaderItem : ILoaderItem;

		/**
		 * Loader item priority.
		 * 
		 * <p>Item priority when added to the LoaderManager.</p>
		 */
		protected var _priority : uint;

		/**
		 * Creates a new LoaderItemEvent.
		 * 
		 * @param type Type of the event.
		 * @param loaderItem Reference to the affected loader item.
		 * @param affectedLoaderItem The affected (added or removed) child loader item.
		 */
		public function LoaderItemEvent(type : String, loaderItem : ILoaderItem, affectedLoaderItem : ILoaderItem = null, priority : uint = 0) {
			super(type);
			
			_loaderItem = loaderItem;
			_affectedLoaderItem = affectedLoaderItem;
			_priority = priority;
		}

		/**
		 * Returns the event dispatching loader item.
		 * 
		 * @return The event dispatching loader item.
		 */
		public function get loaderItem() : ILoaderItem {
			return _loaderItem;
		}
		
		/**
		 * Returns the affected child loader item, which has been added or removed.
		 * 
		 * @return The affected child loader item.
		 */
		public function get affectedLoaderItem() : ILoaderItem {
			return _affectedLoaderItem;
		}
		
		/**
		 * Returns the priority the item is added with to the LoaderManager.
		 * 
		 * <p>This property is only set in the ADD event of the LoaderManager.</p>
		 * 
		 * @return The loader item priority.
		 */
		public function get priority() : uint {
			return _priority;
		}
	}
}
