package com.sibirjak.angara.core {

	import org.as3commons.collections.SortedMap;
	import org.as3commons.collections.framework.IIterator;

	/**
	 * LoaderManager priority map.
	 * 
	 * <p>Takes a loader item and a priority and inserts the item at the
	 * position according to the priority. Multiple items for the same
	 * priority are added at the end of the sub list of items holding the
	 * same priority.</p>
	 * 
	 * @author jes 12.03.2009
	 */
	public class PriorityMap extends SortedMap {
		
		/**
		 * Internal order property to achieve multiple items at same priority.
		 */
		private var _order : uint = 0;
		
		/**
		 * Creates a new PriorityMap.
		 */
		public function PriorityMap() {
			super(new PriorityComparator());
		}
		
		/**
		 * Adds a loader item to the map at the specified priority.
		 * 
		 * <p>Multiple items for the same priority are added at the end of
		 * the sub list of items holding the same priority.</p>
		 * 
		 * @param loaderItem The loader item to add.
		 * @param priority Priority of that item.
		 */
		public function addLoaderItem(loaderItem : ILoaderItem, priority : uint) : void {
			if (hasKey(loaderItem)) removeKey(loaderItem);
			add(loaderItem, new PriorityNode(priority, _order++));
		}
		
		/**
		 * Removes a loader item from the map.
		 * 
		 * @param loaderItem The item to remove.
		 */
		public function removeLoaderItem(loaderItem : ILoaderItem) : void {
			removeKey(loaderItem);
		}
		
		/**
		 * Returns an iterator over all added loaderitems in the order of their
		 * priority. 
		 * 
		 * @param cursor Not supported. Enumerates always starting at the begin.
		 * @return The iterator.
		 */
		override public function iterator(cursor : * = undefined) : IIterator {
			return keyIterator();
		}

	}
}

import org.as3commons.collections.framework.IComparator;

/**
 * Internal prioritised map node.
 */
internal class PriorityNode {
	public var priority : uint;
	public var order : uint;
	public function PriorityNode(thePriority : uint, theOrder : uint) {
		order = theOrder;
		priority = thePriority;  
	}
	public function toString() : String {
		return "[PriorityNode] p:" + priority + " o:" + order;
	}
}

/**
 * Priority comparator. Compares priority before order.
 */
internal class PriorityComparator implements IComparator {
	public function compare(item1 : *, item2 : *) : int {
		var p1 : PriorityNode = item1;
		var p2 : PriorityNode = item2;
		if (p1.priority < p2.priority) return -1;
		else if (p1.priority > p2.priority) return 1;
		else {
			if (p1.order < p2.order) return -1;
			else if (p1.order > p2.order) return 1;
			else return 0;
		}
	}
}
