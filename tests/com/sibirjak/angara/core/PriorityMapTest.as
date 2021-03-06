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

	import flexunit.framework.TestCase;

	import com.sibirjak.angara.resource.loaders.LoaderDelegate;
	import com.sibirjak.utils.ArrayUtils;

	import flash.net.URLRequest;



	/**
	 * @author jes 16.02.2009
	 */
	public class PriorityMapTest extends TestCase {

		private var _map : PriorityMap;
		
		private var item1 : ILoaderItem = new LoaderDelegate(new URLRequest("no_url1"));
		private var item2 : ILoaderItem = new LoaderDelegate(new URLRequest("no_url2"));
		private var item3 : ILoaderItem = new LoaderDelegate(new URLRequest("no_url3"));
		private var item4 : ILoaderItem = new LoaderDelegate(new URLRequest("no_url4"));
		private var item5 : ILoaderItem = new LoaderDelegate(new URLRequest("no_url5"));
		private var item6 : ILoaderItem = new LoaderDelegate(new URLRequest("no_url6"));
		private var item7 : ILoaderItem = new LoaderDelegate(new URLRequest("no_url7"));

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			_map = new PriorityMap();
		}

		override public function tearDown() : void {
			_map = null;
		}

		/**
		 * test initial state
		 */

		public function testInstantiated() : void {
			assertTrue("Map instantiated", _map is PriorityMap);
		}
	
		/**
		 * test adding items
		 */

		public function testAddItems() : void {
			
			_map.addLoaderItem(item1, 0);
			assertEquals("Map contains 1 item after adding 1", 1, _map.size);

			_map.addLoaderItem(item2, 1);
			assertEquals("Map contains 2 items after adding 2", 2, _map.size);
			
			assertTrue(
				"Map contains the items added " + _map.keysToArray(),
				ArrayUtils.arraysEqual(
					[item1, item2],
					_map.keysToArray()
				)
			);

		}

		public function testAddItemsWithSamePriorityKeepsInsertionOrder() : void {
			_map.addLoaderItem(item1, 0);
			_map.addLoaderItem(item2, 0);
			_map.addLoaderItem(item3, 0);
			_map.addLoaderItem(item4, 0);
			_map.addLoaderItem(item5, 0);
			
			assertTrue(
				"Map contains the items added",
				ArrayUtils.arraysEqual(
					[item1, item2, item3, item4, item5],
					_map.keysToArray()
				)
			);
		}

		public function testAddItemsWithSamePriorityKeepsInsertionOrder2() : void {
			_map.addLoaderItem(item1, 2);
			_map.addLoaderItem(item2, 2);
			_map.addLoaderItem(item3, 2);
			_map.addLoaderItem(item4, 1);
			_map.addLoaderItem(item5, 1);
			_map.addLoaderItem(item6, 0);
			_map.addLoaderItem(item7, 0);
			
			assertTrue(
				"Map contains the items added",
				ArrayUtils.arraysEqual(
					[item6, item7, item4, item5, item1, item2, item3],
					_map.keysToArray()
				)
			);
		}

		public function testAddItemsTwiceUpdatesAndRepriorizedItem() : void {
			_map.addLoaderItem(item1, 2);
			_map.addLoaderItem(item2, 2);
			_map.addLoaderItem(item3, 2);

			_map.addLoaderItem(item2, 1);
			
			assertTrue(
				"Map contains the items added " + _map.keysToArray(),
				ArrayUtils.arraysEqual(
					[item2, item1, item3],
					_map.keysToArray()
				)
			);
		}

		/**
		 * test removing items
		 */

		public function testRemovingOfItems() : void {
			
			_map.addLoaderItem(item1, 0);
			_map.addLoaderItem(item2, 1);
			_map.addLoaderItem(item3, 2);
			
			assertTrue(
				"Map contains the items added",
				ArrayUtils.arraysEqual(
					[item1, item2, item3],
					_map.keysToArray()
				)
			);

			assertEquals("Map contains 3 items after adding 3", 3, _map.size);

			_map.removeLoaderItem(item2);
			assertEquals("Map contains 2 items after removing #2 ", 2, _map.size);

			assertTrue(
				"Map contains the items added",
				ArrayUtils.arraysEqual(
					[item1, item3],
					_map.keysToArray()
				)
			);

			_map.removeLoaderItem(item1);
			assertEquals("Map contains 2 items after removing #1 ", 1, _map.size);

			assertTrue(
				"Map contains the items added",
				ArrayUtils.arraysEqual(
					[item3],
					_map.keysToArray()
				)
			);

			_map.removeLoaderItem(item3);
			assertEquals("Map empty after removing the #3 ", 0, _map.size);

			assertTrue(
				"Map contains no items",
				ArrayUtils.arraysEqual(
					[],
					_map.keysToArray()
				)
			);

		}

		public function testRemovingAndReaddingPossible() : void {
			_map.addLoaderItem(item1, 2);
			_map.addLoaderItem(item2, 2);
			_map.addLoaderItem(item3, 2);

			_map.removeLoaderItem(item2);
			_map.addLoaderItem(item2, 1);
			
			assertTrue(
				"Map contains the items added",
				ArrayUtils.arraysEqual(
					[item2, item1, item3],
					_map.keysToArray()
				)
			);
		}

	}
}
