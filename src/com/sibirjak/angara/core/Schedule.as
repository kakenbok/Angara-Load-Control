package com.sibirjak.angara.core {

	import com.sibirjak.angara.resource.AbstractResourceLoader;
	import flash.events.EventDispatcher;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.iterators.RecursiveFilterIterator2;



	/**
	 * The LoaderManager queue.
	 * 
	 * <p>Holds internally a PriorityMap reference.</p>
	 * 
	 * @author jes 12.02.2009
	 */
	public class Schedule extends EventDispatcher {
		
		/**
		 * The internal priority map.
		 */
		private var _priorityMap : PriorityMap;
		
		/**
		 * Create a new Schedule instance.
		 */
		public function Schedule() {
			_priorityMap = new PriorityMap();
		}
		
		/**
		 * Adds a new loader item to the schedule.
		 * 
		 * <p>The type can be either LoaderItemType.LOADER, LoaderItemType.SEQUENCE
		 * or LoaderItemType.SEQUENCE_MANAGER.</p>
		 * 
		 * @param loaderItem The item to add.
		 * @param priority The priority to load the item.
		 */
		public function add(loaderItem : ILoaderItem, priority : uint = 0) : void {
			
			// cannot add an already scheduled item twice.
			// items prior added to a sequence cannot be added again
			if (loaderItem.scheduled) return;
			
			configureListeners(loaderItem);
			
			_priorityMap.addLoaderItem(loaderItem, priority);
			AbstractLoaderItem(loaderItem).sibirjak_loader::setScheduled(true);
			
			dispatchEvent(new LoaderItemEvent(LoaderItemEvent.ADD, null, loaderItem, priority));
		}
		
		/**
		 * Removes a loader item from the queue.
		 * 
		 * @param loaderItem The item to remove.
		 */
		public function remove(loaderItem : ILoaderItem) : void {
			if (!_priorityMap.hasKey(loaderItem)) return;
			
			deconfigureListeners(loaderItem);

			_priorityMap.removeLoaderItem(loaderItem);
			AbstractLoaderItem(loaderItem).sibirjak_loader::setScheduled(false);

			dispatchEvent(new LoaderItemEvent(LoaderItemEvent.REMOVE, null, loaderItem));
		}
		
		/**
		 * Removes all items from the queue.
		 */
		public function clear() : void {
			var loaderItem : ILoaderItem;
			var iterator : IIterator = _priorityMap.iterator();
			while (iterator.hasNext()) {
				loaderItem = iterator.next();
				deconfigureListeners(loaderItem);
			}
			_priorityMap.clear();
		}
		
		/**
		 * Returns a list of resource loaders to be loaded at next.
		 * 
		 * <p>This method uses a recursive iterator to find all containers
		 * (sequence, sequence manager) and resource loaders of status
		 * LoaderItemStatus.WAITING. Each possible item will be filtered with
		 * an ItemTypeFilterIterator to finally get only resource loaders.</p>
		 * 
		 * <p>The length of the list may be lesser than the specified numItems
		 * value in 2 cases: When no more waiting resource loaders are scheduled
		 * and secondly if an item defines a callback. Then we have to wait for
		 * the callbacks finish to continue loading resources.</p>
		 * 
		 * <p>For a high performance all containers are supposed to remove
		 * their finished items (LoaderItemStatus.COMPLETE, LoaderItemStatus.FAILURE)
		 * immediately.</p>
		 * 
		 * @param loaderItem The number of resource loaders to load at next.
		 * @param return The list of resource loaders to load at next.
		 */
		public function getNextItems(numItems : uint) : Array {
			//var startTime : Number = new Date().getTime();

			var itemsToLoad : Array = new Array();
			
			if (!numItems) return itemsToLoad;
			
//			var filterIterator : IIterator = new ItemTypeFilterIterator( // filter for resource loaders
//				new StatusFilterIterator( // returns all items of the status WAITING
//					_priorityMap.iterator(),
//					LoaderItemStatus.WAITING
//				),
//				LoaderItemType.LOADER
//			);
			
			var filterIterator : IIterator = new RecursiveFilterIterator2(
				_priorityMap,
				function(item : ILoaderItem) : Boolean {
					return item.itemType == LoaderItemType.LOADER && item.status == LoaderItemStatus.WAITING;
				},
				function(item : ILoaderItem) : Boolean {
					return item.status == LoaderItemStatus.WAITING;
				}
			);

			/*
			 * Break, if the number of items to get is reached.
			 * Break, if an item defines a callback function.
			 */
			
			var item : AbstractResourceLoader;
			while (filterIterator.hasNext()) {
				item = filterIterator.next();
				itemsToLoad.push(item);
				if (item.sibirjak_loader::hasCallback()) break;
				if (numItems == itemsToLoad.length) break;
			}
			
			return itemsToLoad;
		}

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
		public function get numItemsLeft() : uint {
			var numItems : uint = 0;
			var iterator : IIterator = _priorityMap.iterator();
			var item : ILoaderItem;
			while (iterator.hasNext()) {
				item = iterator.next();
				numItems += (item.numItems - item.numItemsLoaded);
			}
			return numItems;
		}
		
		/*
		 * Item listeners
		 */
		
		/**
		 * Starts listening to resource loader notifications.
		 */
		private function configureListeners(loaderItem : ILoaderItem) : void {
			loaderItem.addEventListener(LoaderItemEvent.COMPLETE, itemCompleteHandler);
			loaderItem.addEventListener(LoaderItemEvent.FAILURE, itemCompleteHandler);
		}

		/**
		 * Stops listening to resource loader notifications.
		 */
		private function deconfigureListeners(loaderItem : ILoaderItem) : void {
			loaderItem.removeEventListener(LoaderItemEvent.COMPLETE, itemCompleteHandler);
			loaderItem.removeEventListener(LoaderItemEvent.FAILURE, itemCompleteHandler);
		}

		/**
		 * Info
		 */
		override public function toString() : String {
			return "[Schedule] items:" + _priorityMap.size;
		}

		/*
		 * Loader item listener
		 */

		/**
		 * Removes a loader item after a complete notification.
		 */
		private function itemCompleteHandler(event : LoaderItemEvent) : void {
			remove(event.loaderItem);
		}

	}
}

import com.sibirjak.angara.core.ILoaderItem;
import org.as3commons.collections.framework.IIterator;


/**
 * A filter iterator for loader item types.
 * 
 * <p>If set to LoaderItemType.LOADER it returns only resource loaders within
 * the enumeration loop.</p>
internal class ItemTypeFilterIterator extends AbstractFilterIterator {
	private var _itemType : String;
	public function ItemTypeFilterIterator(iterator : IIterator, itemType : String) {
		super(iterator);
		_itemType = itemType;
	}
	override public function accepts(item : *) : Boolean {
		return ILoaderItem(item).itemType == _itemType;
	}
}
 */

/**
 * A resursive filter iterator for loader item stati.
 * 
 * <p>If set to LoaderItemStatus.WAITING it returns all resource loaders, sequences
 * and sequence managers of that status. Loader items and all their subordinated items
 * are skipped if their status is not LoaderItemStatus.WAITING.</p>
internal class StatusFilterIterator extends AbstractRecursiveFilterIterator {
	private var _status : String;
	public function StatusFilterIterator(iterator : IIterator, status : String) {
		super(iterator);
		_status = status;
	}
	override public function accepts(item : *) : Boolean {
		return ILoaderItem(item).status == _status;
	}
}
 */
