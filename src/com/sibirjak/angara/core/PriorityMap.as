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
