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

	import com.sibirjak.angara.core.testhelpers.CoreTestHelper;
	import com.sibirjak.angara.core.testhelpers.ScheduleTestHelper;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.loaders.TestLoader;
	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.ISequenceManager;
	import com.sibirjak.angara.sequence.testhelpers.SequenceManagerMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceManagerTestHelper;
	import com.sibirjak.angara.sequence.testhelpers.SequenceMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceTestHelper;
	import com.sibirjak.utils.ArrayUtils;


	/**
	 * @author jes 16.02.2009
	 */

	public class ScheduleTest extends TestCase {
		
		private var _schedule : Schedule;

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			_schedule = new Schedule();
		}

		override public function tearDown() : void {
			_schedule = null;
		}

		/**
		 * test initial state
		 */

		public function testInstantiated() : void {
			assertTrue("Schedule instantiated", _schedule is Schedule);
		}
	
		public function testScheduleIsInitallyEmpty() : void {
			assertEquals("Schedule is initially empty", 0, _schedule.numItemsLeft);
		}

		public function testGetNextItemsReturnsInitiallyAnEmptyArray() : void {
			var nextItems : Array = _schedule.getNextItems(1);

			assertEquals("Schedule return no items", 0, nextItems.length);
		}

		/**
		 * test adding items
		 */

		public function testAddResourceLoaders() : void {
			
			ScheduleTestHelper.scheduleResource(_schedule);
			assertEquals("Schedule contains 1 item after adding 1", 1, _schedule.numItemsLeft);

			ScheduleTestHelper.scheduleResource(_schedule);
			assertEquals("Schedule contains 2 items after adding 2", 2, _schedule.numItemsLeft);

		}

		public function testAddSequences() : void {
			
			ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);
			assertEquals("Schedule contains 1 item after adding 1", 1, _schedule.numItemsLeft);

			ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);
			assertEquals("Schedule contains 2 items after adding 2", 2, _schedule.numItemsLeft);

		}

		public function testAddSequenceManagers() : void {
			
			ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 2, 2);
			assertEquals("Schedule contains 4 item after adding 1 manager of 4 items", 4, _schedule.numItemsLeft);

			ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 2, 2);
			assertEquals("Schedule contains 8 items after adding a second manager of 4 items", 8, _schedule.numItemsLeft);

		}

		public function testAddMixedItems() : void {
			
			ScheduleTestHelper.scheduleResource(_schedule);
			assertEquals("Schedule contains 1 item after adding 1", 1, _schedule.numItemsLeft);

			ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			assertEquals("Schedule contains 3 items after adding 3", 3, _schedule.numItemsLeft);

			ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 3, 2);
			assertEquals("Schedule contains 9 items after adding 9", 9, _schedule.numItemsLeft);

			ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			assertEquals("Schedule contains 11 items after adding 11", 11, _schedule.numItemsLeft);

		}

		public function testAddingItemSetsMarksItemAsScheduled() : void {
			
			var loaderItem : ILoaderItem = CoreTestHelper.createResourceLoader();
			assertEquals("Item status is RESOURCE_WAITING", LoaderItemStatus.WAITING, loaderItem.status);
			assertFalse("Item not yet scheduled", loaderItem.scheduled);
			_schedule.add(loaderItem);
			assertEquals("Item status is RESOURCE_WAITING", LoaderItemStatus.WAITING, loaderItem.status);
			assertTrue("Item scheduled", loaderItem.scheduled);

			loaderItem = new SequenceMock();
			assertEquals("Item status is WAITING", LoaderItemStatus.WAITING, loaderItem.status);
			assertFalse("Item not yet scheduled", loaderItem.scheduled);
			_schedule.add(loaderItem);
			assertEquals("Item status is WAITING", LoaderItemStatus.WAITING, loaderItem.status);
			assertTrue("Item scheduled", loaderItem.scheduled);

			loaderItem = new SequenceManagerMock();
			assertEquals("Item status is WAITING", LoaderItemStatus.WAITING, loaderItem.status);
			assertFalse("Item not yet scheduled", loaderItem.scheduled);
			_schedule.add(loaderItem);
			assertEquals("Item status is WAITING", LoaderItemStatus.WAITING, loaderItem.status);
			assertTrue("Item scheduled", loaderItem.scheduled);

		}

		public function _testAddItemsToAScheduledSequence() : void {

			var sequence : ISequence = new SequenceMock();
			_schedule.add(sequence);

			assertEquals(
				"Schedule contains 0 items after adding 1 empty sequence.",
				0,
				_schedule.numItemsLeft
			);
			
			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"No item retrieved when empty sequence added",
				0,
				nextItems.length
			);

			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence.add(loader1);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"After adding 1 item to a already scheduled sequence we get 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			var loader2 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence.add(loader2);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"After adding 2 items to a already scheduled sequence we get 2 items to load",
				2,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader2,
				nextItems[1]
			);

		}

		public function _testAddSequencesToAScheduledSequenceManager() : void {

			var sequenceManager : ISequenceManager = new SequenceManagerMock();
			_schedule.add(sequenceManager);

			assertEquals(
				"Schedule contains 0 item after adding 1 empty sequence manager",
				0,
				_schedule.numItemsLeft
			);
			
			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"No item retrieved when empty sequence added",
				0,
				nextItems.length
			);

			var sequence1 : ISequence = new SequenceMock();
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence1.add(loader1);

			sequenceManager.add(sequence1);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"After adding 1 item to a already scheduled sequence we get 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			var sequence2 : ISequence = new SequenceMock();
			var loader2 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence2.add(loader2);

			sequenceManager.add(sequence2);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"After adding 2 items to a already scheduled sequence we get 2 items to load",
				2,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader2,
				nextItems[1]
			);

		}

		public function _testAddingResourceLoadersTwiceWillBeIgnored() : void {

			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();

			_schedule.add(loader1);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"After adding 1 sequence we get 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			_schedule.add(loader1);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Adding the same sequence again will be ignored",
				1,
				_schedule.numItemsLeft
			);

			assertEquals(
				"Adding the same sequence again will be ignored",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"Adding the same sequence again will be ignored",
				loader1,
				nextItems[0]
			);
			
		}

		public function _testAddingSequencesTwiceWillBeIgnored() : void {

			var sequence : ISequence = new SequenceMock();
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence.add(loader1);

			_schedule.add(sequence);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"After adding 1 sequence we get 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			_schedule.add(sequence);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Adding the same sequence again will be ignored",
				1,
				_schedule.numItemsLeft
			);

			assertEquals(
				"Adding the same sequence again will be ignored",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"Adding the same sequence again will be ignored",
				loader1,
				nextItems[0]
			);
			
		}

		public function _testAddingSequenceManagersTwiceWillBeIgnored() : void {

			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();

			var sequence : ISequence = new SequenceMock();
			sequence.add(loader1);

			var sequenceManager : ISequenceManager = new SequenceManagerMock();
			sequenceManager.add(sequence);

			_schedule.add(sequenceManager);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"After adding 1 sequence we get 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			_schedule.add(sequenceManager);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Adding the same sequence again will be ignored",
				1,
				_schedule.numItemsLeft
			);

			assertEquals(
				"Adding the same sequence again will be ignored",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"Adding the same sequence again will be ignored",
				loader1,
				nextItems[0]
			);
			
		}

		public function _testAddingLoadersAlreadyAddedToASequenceWillBeIgnored() : void {

			var sequence : ISequence = new SequenceMock();
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence.add(loader1);

			_schedule.add(sequence);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"After adding 1 sequence we get 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader1,
				nextItems[0]
			);

			_schedule.add(loader1);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Adding the item directly will be ignored",
				1,
				_schedule.numItemsLeft
			);

			assertEquals(
				"Adding the item directly will be ignored",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"Adding the item directly will be ignored",
				loader1,
				nextItems[0]
			);
			
		}

		public function _testAddingSequencesAlreadyAddedToASequenceManagerWillBeIgnored() : void {
			var loader : IResourceLoader = CoreTestHelper.createResourceLoader();

			var sequence : ISequence = new SequenceMock();
			sequence.add(loader);
			
			var sequenceManager : ISequenceManager = new SequenceManagerMock();
			sequenceManager.add(sequence);

			_schedule.add(sequenceManager);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"After adding 1 sequence we get 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"The item to load is our added sequence item",
				loader,
				nextItems[0]
			);

			_schedule.add(sequence);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Adding the item directly will be ignored",
				1,
				_schedule.numItemsLeft
			);

			assertEquals(
				"Adding the item directly will be ignored",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"Adding the item directly will be ignored",
				loader,
				nextItems[0]
			);
			
		}

		/**
		 * test number of items returned
		 */

		public function testGettingOneItemReturnsOneItem() : void {
			ScheduleTestHelper.scheduleResource(_schedule);
			
			var nextItems : Array = _schedule.getNextItems(1);
			assertEquals(
				"One item returned when one item requested",
				1,
				nextItems.length
			);
		}

		public function testGettingNumberOfItemsReturnsThatNumberOfItems() : void {

			// add 5 items
			ScheduleTestHelper.scheduleResources(_schedule, 5);
			
			var nextItems : Array = _schedule.getNextItems(3);
			assertEquals(
				"3 items returned when 3 items requested",
				3,
				nextItems.length
			);

			nextItems = _schedule.getNextItems(5);
			assertEquals(
				"5 items returned when 5 items requested",
				5,
				nextItems.length
			);
		}

		public function testGettingNumberOfItemsReturnsNotMoreThanAvailableItems() : void {
			// add 5 items
			ScheduleTestHelper.scheduleResources(_schedule, 5);
			
			var nextItems : Array = _schedule.getNextItems(6);
			assertEquals(
				"5 items returned when 6 items requested",
				5,
				nextItems.length
			);

			nextItems = _schedule.getNextItems(15);
			assertEquals(
				"5 items returned when 15 items requested",
				5,
				nextItems.length
			);
		}

		public function testGettingZeroItemsReturnsZeroItems() : void {
			// add 5 items
			ScheduleTestHelper.scheduleResources(_schedule, 5);
			
			var nextItems : Array = _schedule.getNextItems(0);
			assertEquals(
				"0 items returned when 0 items requested",
				0,
				nextItems.length
			);

		}

		/**
		 * test getting next items
		 */

		public function testGettingAddedLoaderItems() : void {
			
			var loaderItem : ILoaderItem = ScheduleTestHelper.scheduleResource(_schedule);
			
			var nextItems : Array = _schedule.getNextItems(1);
			assertStrictlyEquals(
				"Item retrieved is the first item added",
				loaderItem,
				nextItems[0]
			);
			
			// as the status has not changed we should get the
			// same item again
			nextItems = _schedule.getNextItems(1);
			assertStrictlyEquals(
				"Item retrieved is the first item added",
				loaderItem,
				nextItems[0]
			);

		}

		public function _testGettingAddedSequenceLoaders() : void {
			
			// creating a sequence of 5 loaders
			var sequence : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 5);
			
			assertEquals("Schedule contains 5 item after adding 1 sequence", 5, _schedule.numItemsLeft);

			var nextItems : Array = _schedule.getNextItems(1);
			assertStrictlyEquals(
				"Item retrieved is the first item added to the sequence",
				SequenceTestHelper.getResourceLoaderAt(sequence, 0),
				nextItems[0]
			);

			nextItems = _schedule.getNextItems(100);
			assertStrictlyEquals(
				"Item retrieved is the 3rd item added to the sequence",
				SequenceTestHelper.getResourceLoaderAt(sequence, 2),
				nextItems[2]
			);

		}

		public function _testGettingAddedSequenceManagerLoaders() : void {
			
			// creating a sequence of 5 loaders
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(5);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(5);
			var sequenceManager : ISequenceManager = new SequenceManagerMock();
			sequenceManager.add(sequence1);
			sequenceManager.add(sequence2);
			
			_schedule.add(sequenceManager);
			
			assertEquals("Schedule contains 10 items after adding 1 sequence manager", 10, _schedule.numItemsLeft);

			var nextItems : Array = _schedule.getNextItems(1);
			assertStrictlyEquals(
				"Item retrieved is the first item added to the sequence1",
				SequenceTestHelper.getResourceLoaderAt(sequence1, 0),
				nextItems[0]
			);

			nextItems = _schedule.getNextItems(100);
			assertStrictlyEquals(
				"Item retrieved is the 3rd item added to the sequence1",
				SequenceTestHelper.getResourceLoaderAt(sequence1, 2),
				nextItems[2]
			);

			assertStrictlyEquals(
				"Item retrieved is the 1rd item added to the sequence2",
				SequenceTestHelper.getResourceLoaderAt(sequence2, 0),
				nextItems[5]
			);

			assertStrictlyEquals(
				"Item retrieved is the 3rd item added to the sequence2",
				SequenceTestHelper.getResourceLoaderAt(sequence2, 2),
				nextItems[7]
			);

		}

		public function _testGettingAddedMixedItems() : void {
			
			var item1 : ILoaderItem = ScheduleTestHelper.scheduleResource(_schedule);
			var sequence : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 5);
			var sequenceManager : ISequenceManager = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 2, 2);
			var item7 : ILoaderItem = ScheduleTestHelper.scheduleResource(_schedule);

			assertEquals("Schedule contains 11 items after adding 2 items, 1 sequence and 1 sequencemanager", 11, _schedule.numItemsLeft);

			var nextItems : Array = _schedule.getNextItems(100);
			assertStrictlyEquals(
				"Item retrieved is the first item added to the sequence",
				item1,
				nextItems[0]
			);

			assertStrictlyEquals(
				"3rd item retrieved is the 2nd item added to the sequence",
				SequenceTestHelper.getResourceLoaderAt(sequence, 1),
				nextItems[2]
			);

			sequence = SequenceManagerTestHelper.getSequenceAt(sequenceManager, 0);
			assertStrictlyEquals(
				"Item retrieved is the first item of the first sequence manager sequence",
				SequenceTestHelper.getResourceLoaderAt(sequence, 0),
				nextItems[6]
			);

			sequence = SequenceManagerTestHelper.getSequenceAt(sequenceManager, 1);
			assertStrictlyEquals(
				"Item retrieved is the 2nd item of the 2nd sequence manager sequence",
				SequenceTestHelper.getResourceLoaderAt(sequence, 1),
				nextItems[9]
			);

			assertStrictlyEquals(
				"Item retrieved is the last added item",
				item7,
				nextItems[10]
			);

		}

		/**
		 * test respecting the items status when getting next items
		 */

		public function _testGettingNextItemsIgnoresNotWaitingResourceLoaders() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var nextItems : Array = _schedule.getNextItems(1);
			assertStrictlyEquals(
				"Item retrieved is the first schedule item",
				item1,
				nextItems[0]
			);
			
			TestLoader(item1).setStatus(LoaderItemStatus.FAILURE);

			nextItems = _schedule.getNextItems(1);
			assertEquals(
				"No item retrieved when item is set to FAILURE",
				0,
				nextItems.length
			);

			TestLoader(item1).setStatus(LoaderItemStatus.WAITING);

			nextItems = _schedule.getNextItems(1);
			assertStrictlyEquals(
				"Item retrieved is again the first schedule item",
				item1,
				nextItems[0]
			);

			var item2 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			TestLoader(item1).setStatus(LoaderItemStatus.COMPLETE);

			nextItems = _schedule.getNextItems(1);
			assertStrictlyEquals(
				"Item retrieved is the second schedule item",
				item2,
				nextItems[0]
			);

			TestLoader(item2).setStatus(LoaderItemStatus.PAUSED);
			nextItems = _schedule.getNextItems(1);
			assertEquals(
				"No item retrieved when item is set to FAILURE",
				0,
				nextItems.length
			);

		}

		public function _testGettingNextItemsIgnoresNotWaitingSequences() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			var sequence : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);
			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence, 0);
			var item3 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"2 items and a sequence of 1 item added returns 3 items to load",
				3,
				nextItems.length
			);
			
			assertStrictlyEquals(
				"Second item to load is the first sequence item",
				item2,
				nextItems[1]
			);

			sequence.pause();

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting the sequence to STOPPED returns then 2 items to load",
				2,
				nextItems.length
			);

			assertStrictlyEquals(
				"Second item to load is the second single item",
				item3,
				nextItems[1]
			);

			sequence.resume();

			nextItems = _schedule.getNextItems(100);
			assertEquals(
				"Again 3 items to load returned",
				3,
				nextItems.length
			);

			assertStrictlyEquals(
				"Second item to load is the first sequence item",
				item2,
				nextItems[1]
			);

			TestLoader(item1).setStatus(LoaderItemStatus.COMPLETE);
			TestLoader(item3).setStatus(LoaderItemStatus.COMPLETE);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting single items to COMPLETE returns then 1 item to load",
				1,
				nextItems.length
			);

			assertStrictlyEquals(
				"First item to load is the first sequence item",
				item2,
				nextItems[0]
			);
		}

		public function _testGettingNextItemsIgnoresNotWaitingSequenceManagers() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);
			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence, 0);

			var sequenceManager : ISequenceManager = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 1, 1);
			sequence = SequenceManagerTestHelper.getSequenceAt(sequenceManager, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence, 0);

			var item4 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"2 items, a sequence of 1 item and a sequence manager of 1 item added returns 4 items to load",
				4,
				nextItems.length
			);
			
			assertStrictlyEquals(
				"Third item to load is the first sequence manager item",
				item3,
				nextItems[2]
			);

			sequenceManager.pause();

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting the sequence to STOPPED returns then 3 items to load",
				3,
				nextItems.length
			);

			assertStrictlyEquals(
				"Third item to load is the second single item",
				item4,
				nextItems[2]
			);

			sequenceManager.resume();

			nextItems = _schedule.getNextItems(100);
			assertEquals(
				"Again 4 items to load returned",
				4,
				nextItems.length
			);

			assertStrictlyEquals(
				"Third item to load is the first sequence manager item",
				item3,
				nextItems[2]
			);

			TestLoader(item1).setStatus(LoaderItemStatus.COMPLETE);
			TestLoader(item4).setStatus(LoaderItemStatus.COMPLETE);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting 2 single items to COMPLETE returns then 2 items to load",
				2,
				nextItems.length
			);

			assertStrictlyEquals(
				"First item to load is the first sequence manager item",
				item2,
				nextItems[0]
			);

			assertStrictlyEquals(
				"Second item to load is the first sequence item",
				item3,
				nextItems[1]
			);

		}

		public function _testGettingNextItemsIgnoresNotWaitingSequenceResourceLoaders() : void {
			
			ScheduleTestHelper.scheduleResource(_schedule);
			var sequence : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);
			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence, 0);
			var item3 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			TestLoader(item2).setStatus(LoaderItemStatus.COMPLETE);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"Setting the first sequence item to COMPLETE returns then 2 items to load",
				2,
				nextItems.length
			);

			assertStrictlyEquals(
				"Second item to load is the second single item",
				item3,
				nextItems[1]
			);
		}

		public function _testGettingNextItemsIgnoresNotWaitingSequenceManagerSequences() : void {
			
			ScheduleTestHelper.scheduleResource(_schedule);

			ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);

			var sequenceManager : ISequenceManager = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 1, 1);
			var sequence : ISequence = SequenceManagerTestHelper.getSequenceAt(sequenceManager, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence, 0);

			var item4 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"Schedule contains 4 items to load",
				4,
				nextItems.length
			);

			assertStrictlyEquals(
				"Third item to load is the manager sequence loader",
				item3,
				nextItems[2]
			);

			SequenceMock(sequence).setStatus(LoaderItemStatus.COMPLETE);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting the first manager sequence to COMPLETE returns then 3 items to load",
				3,
				nextItems.length
			);

			assertStrictlyEquals(
				"Third item to load is the second single item",
				item4,
				nextItems[2]
			);
		}

		public function _testGettingNextItemsIgnoresNotWaitingSequenceManagerResourceLoaders() : void {
			
			ScheduleTestHelper.scheduleResource(_schedule);

			ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);

			var sequenceManager : ISequenceManager = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 1, 1);
			var sequence : ISequence = SequenceManagerTestHelper.getSequenceAt(sequenceManager, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence, 0);

			var item4 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"Schedule contains 4 items to load",
				4,
				nextItems.length
			);

			assertStrictlyEquals(
				"Third item to load is the manager sequence loader",
				item3,
				nextItems[2]
			);

			TestLoader(item3).setStatus(LoaderItemStatus.COMPLETE);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting the first manager sequence to COMPLETE returns then 3 items to load",
				3,
				nextItems.length
			);

			assertStrictlyEquals(
				"Third item to load is the second single item",
				item4,
				nextItems[2]
			);
		}

		/**
		 * test pause item / sequence
		 */
		public function _testGettingNextItemsIgnoresPausedItems() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence1 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 1);

			var item4 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			var item5 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence2 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			var item6 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 0);
			var item7 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 1);

			var item8 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			var item9 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequenceManager : ISequenceManager = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 1, 1);
			var sequence3 : ISequence = SequenceManagerTestHelper.getSequenceAt(sequenceManager, 0);
			var item10 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence3, 0);

			assertEquals(
				"Schedule contains 10 items after filling",
				10,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5, item6, item7, item8, item9, item10]
				)
			);
			
			item1.pause();
			item2.pause();
			item3.pause();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item4, item5, item6, item7, item8, item9, item10]
				)
			);

			item4.pause();
			item5.pause();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item6, item7, item8, item9, item10]
				)
			);

			item6.pause();
			item7.pause();
			item8.pause();
			item9.pause();
			item10.pause();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[]
				)
			);

			item1.resume();
			item2.resume();
			item3.resume();
			item4.resume();
			item5.resume();
			
			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5]
				)
			);
			
			item6.resume();
			item7.resume();
			item8.resume();
			item9.resume();
			item10.resume();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5, item6, item7, item8, item9, item10]
				)
			);

			// sequence
			
			sequence1.pause();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item4, item5, item6, item7, item8, item9, item10]
				)
			);

			sequence2.pause();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item4, item5, item8, item9, item10]
				)
			);

			sequence3.pause();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item4, item5, item8, item9]
				)
			);

			sequence1.resume();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5, item8, item9]
				)
			);

			sequence2.resume();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5, item6, item7, item8, item9]
				)
			);

			sequence3.resume();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5, item6, item7, item8, item9, item10]
				)
			);

			// sequence manager

			sequenceManager.pause();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5, item6, item7, item8, item9]
				)
			);

			sequenceManager.resume();

			nextItems = _schedule.getNextItems(100);

			assertTrue(
				"Schedule returns the right items " + nextItems,
				ArrayUtils.arraysEqual(
					nextItems,
					[item1, item2, item3, item4, item5, item6, item7, item8, item9, item10]
				)
			);

		}

		public function _testGettingNextItemsWithMultipleItems() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence1 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 1);

			var item4 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			var item5 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence2 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			var item6 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 0);
			var item7 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 1);

			var item8 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			var item9 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"5 items and a two sequences of each 2 items added returns 9 items to load",
				9,
				nextItems.length
			);
			
			assertTrue(
				"Items of sequence1 in loading list",
				nextItems.indexOf(item2) > -1
			);

			assertTrue(
				"Items of sequence1 in loading list",
				nextItems.indexOf(item3) > -1
			);

			// stop seq 1
			sequence1.pause();

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting sequence to STOPPED returns 7 items to load",
				7,
				nextItems.length
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item2) > -1
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item3) > -1
			);

			// reschedule seq 1
			sequence1.resume();

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule sequence again returns 9 items to load",
				9,
				nextItems.length
			);

			assertTrue(
				"Items of sequence1 in loading list",
				nextItems.indexOf(item2) > -1
			);

			assertTrue(
				"Items of sequence1 in loading list",
				nextItems.indexOf(item3) > -1
			);

			// stop seq 2
			sequence2.pause();

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting sequence to STOPPED returns 7 items to load",
				7,
				nextItems.length
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item6) > -1
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item7) > -1
			);

			// stop all single items 
			item1.stop();
			item4.stop();
			item5.stop();
			item8.stop();
			item9.stop();

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Setting all 5 single itmes to STOPPED returns still 7 items to load",
				7,
				nextItems.length
			);

			assertTrue(
				"Items of sequence1 still in loading list",
				nextItems.indexOf(item2) > -1
			);

			assertTrue(
				"Items of sequence1 still in loading list",
				nextItems.indexOf(item3) > -1
			);
		}

		/**
		 * test items defining callback
		 */

		public function _testGettingNextItemsBreaksOnCallbackItems() : void {
			
			// creating a sequence of 5 loaders
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			ScheduleTestHelper.scheduleResource(_schedule);
			var item3 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			item3.callbackFunction = new Function();
			ScheduleTestHelper.scheduleResource(_schedule);
			ScheduleTestHelper.scheduleResource(_schedule);
			

			assertEquals(
				"Schedule contains 5 items after adding 5",
				5,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"3 items retrieved",
				3,
				nextItems.length
			);

			assertStrictlyEquals(
				"Item retrieved is the first item added to the sequence",
				item1,
				nextItems[0]
			);

			nextItems = _schedule.getNextItems(100);
			assertStrictlyEquals(
				"Item retrieved is the 3rd item added to the sequence",
				item3,
				nextItems[2]
			);

		}

		public function _testGettingNextItemsBreaksOnCallbackItemsWithinASequence() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence1 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 1);
			item3.callbackFunction = new Function();

			ScheduleTestHelper.scheduleResource(_schedule);
			ScheduleTestHelper.scheduleResource(_schedule);

			assertEquals(
				"Schedule contains 5 items after adding 5",
				5,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"3 items retrieved",
				3,
				nextItems.length
			);

			assertStrictlyEquals(
				"Item retrieved is the first item added to the sequence",
				item1,
				nextItems[0]
			);

			nextItems = _schedule.getNextItems(100);
			assertStrictlyEquals(
				"Item retrieved is the 3rd item added to the sequence",
				item3,
				nextItems[2]
			);

		}

		/**
		 * test removing of items
		 */

		public function testRemoveSingleItem() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			assertEquals(
				"Schedule contains 1 item after adding 1",
				1,
				_schedule.numItemsLeft
			);
			
			assertTrue("Item scheduled", item1.scheduled);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"1 item retrieved after adding 1",
				1,
				nextItems.length
			);
			
			_schedule.remove(item1);

			assertEquals(
				"Schedule empty after removing of the only added item",
				0,
				_schedule.numItemsLeft
			);

			assertFalse("Item not scheduled any longer", item1.scheduled);

		}

		public function _testRemoveSequenceItem() : void {
			
			var sequence : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 5);

			assertEquals(
				"Schedule contains 5 items after adding a sequence",
				5,
				_schedule.numItemsLeft
			);
			
			assertTrue("Item scheduled", sequence.scheduled);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"5 item retrieved after adding 1 sequence of 5 items",
				5,
				nextItems.length
			);
			
			_schedule.remove(sequence);

			assertEquals(
				"Schedule empty after removing of the only added sequence",
				0,
				_schedule.numItemsLeft
			);

			assertFalse("Item not scheduled any longer", sequence.scheduled);

		}

		public function _testRemoveSequenceManagerItem() : void {
			
			var sequenceManager : ISequenceManager = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 2, 2);

			assertEquals(
				"Schedule contains 4 item after adding a sequence of 4 items",
				4,
				_schedule.numItemsLeft
			);
			
			assertTrue("Item scheduled", sequenceManager.scheduled);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"4 item retrieved after adding 1 sequence manager of 2 sequences with 2 itmes",
				4,
				nextItems.length
			);
			
			_schedule.remove(sequenceManager);

			assertEquals(
				"Schedule empty after removing of the only added sequence",
				0,
				_schedule.numItemsLeft
			);

			assertFalse("Item not scheduled any longer", sequenceManager.scheduled);

		}

		public function testRemoveNotExistingItem() : void {

			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			_schedule.remove(new TestLoader(1));

			assertEquals(
				"Schedule still contains 1 item after removing a wrong one",
				1,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertStrictlyEquals(
				"The left item will be the added one",
				item1,
				nextItems[0]
			);

		}

		public function _testRemoveMixedItems() : void {
			
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence1 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 1);

			var item4 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			var item5 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			var sequence2 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 2);
			var item6 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 0);
			var item7 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 1);

			var item8 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);
			var item9 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			assertTrue("Item scheduled", item1.scheduled);
			assertTrue("Item scheduled", sequence1.scheduled);
			assertTrue("Item scheduled", item2.scheduled);
			assertTrue("Item scheduled", item3.scheduled);
			assertTrue("Item scheduled", item4.scheduled);
			assertTrue("Item scheduled", item5.scheduled);
			assertTrue("Item scheduled", sequence2.scheduled);
			assertTrue("Item scheduled", item6.scheduled);
			assertTrue("Item scheduled", item7.scheduled);
			assertTrue("Item scheduled", item8.scheduled);
			assertTrue("Item scheduled", item9.scheduled);

			assertEquals(
				"Schedule contains 9 item after filling",
				9,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"5 items and a two sequences of each 2 items added returns 9 items to load",
				9,
				nextItems.length
			);
			
			// remove sequence
			_schedule.remove(sequence2);
			
			assertTrue("Item scheduled", item1.scheduled);
			assertTrue("Item scheduled", sequence1.scheduled);
			assertTrue("Item scheduled", item2.scheduled);
			assertTrue("Item scheduled", item3.scheduled);
			assertTrue("Item scheduled", item4.scheduled);
			assertTrue("Item scheduled", item5.scheduled);
			assertFalse("Item not scheduled any longer", sequence2.scheduled);
			assertTrue("Item scheduled", item6.scheduled);
			assertTrue("Item scheduled", item7.scheduled);
			assertTrue("Item scheduled", item8.scheduled);
			assertTrue("Item scheduled", item9.scheduled);

			assertEquals(
				"Schedule contains 7 item after removing sequence",
				7,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Removing a sequence of 2 items returns 7 items to load",
				7,
				nextItems.length
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item6) > -1
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item7) > -1
			);
			
			// remove 2 items
			_schedule.remove(item4);
			_schedule.remove(item8);

			assertTrue("Item scheduled", item1.scheduled);
			assertTrue("Item scheduled", sequence1.scheduled);
			assertTrue("Item scheduled", item2.scheduled);
			assertTrue("Item scheduled", item3.scheduled);
			assertFalse("Item not scheduled any longer", item4.scheduled);
			assertTrue("Item scheduled", item5.scheduled);
			assertFalse("Item not scheduled any longer", sequence2.scheduled);
			assertTrue("Item scheduled", item6.scheduled);
			assertTrue("Item scheduled", item7.scheduled);
			assertFalse("Item not scheduled any longer", item8.scheduled);
			assertTrue("Item scheduled", item9.scheduled);

			assertEquals(
				"Schedule contains 5 item after removing 2 items",
				5,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Removing 2 single items returns 5 items to load",
				5,
				nextItems.length
			);

			// remove sequence
			_schedule.remove(sequence1);

			assertTrue("Item scheduled", item1.scheduled);
			assertFalse("Item not scheduled any longer", sequence1.scheduled);
			assertTrue("Item scheduled", item2.scheduled);
			assertTrue("Item scheduled", item3.scheduled);
			assertFalse("Item not scheduled any longer", item4.scheduled);
			assertTrue("Item scheduled", item5.scheduled);
			assertFalse("Item not scheduled any longer", sequence2.scheduled);
			assertTrue("Item scheduled", item6.scheduled);
			assertTrue("Item scheduled", item7.scheduled);
			assertFalse("Item not scheduled any longer", item8.scheduled);
			assertTrue("Item scheduled", item9.scheduled);

			assertEquals(
				"Schedule contains 3 item after removing a sequence of 2 items",
				3,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Removing a sequence of 2 items returns 3 items to load",
				3,
				nextItems.length
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item2) > -1
			);

			assertFalse(
				"Items of stopped sequence not in loading list",
				nextItems.indexOf(item3) > -1
			);

			assertTrue(
				"Item1 still in loading list",
				nextItems.indexOf(item1) > -1
			);

			assertTrue(
				"Item5 still in loading list",
				nextItems.indexOf(item5) > -1
			);

			assertTrue(
				"Item9 still in loading list",
				nextItems.indexOf(item9) > -1
			);

			// remove last 3 items
			_schedule.remove(item1);
			_schedule.remove(item5);
			_schedule.remove(item9);

			assertFalse("Item not scheduled any longer", item1.scheduled);
			assertFalse("Item not scheduled any longer", sequence1.scheduled);
			assertTrue("Item scheduled", item2.scheduled);
			assertTrue("Item scheduled", item3.scheduled);
			assertFalse("Item not scheduled any longer", item4.scheduled);
			assertFalse("Item not scheduled any longer", item5.scheduled);
			assertFalse("Item not scheduled any longer", sequence2.scheduled);
			assertTrue("Item scheduled", item6.scheduled);
			assertTrue("Item scheduled", item7.scheduled);
			assertFalse("Item not scheduled any longer", item8.scheduled);
			assertFalse("Item not scheduled any longer", item9.scheduled);

			assertEquals(
				"Schedule empty after removing of the last items",
				0,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Removing last 3 items empties the schedule",
				0,
				nextItems.length
			);

		}
		
		/**
		 * Test removal of items after complete events
		 */
		
		public function testEventResourceLoaderCompleteRemovesLoader() : void {
			var item1 : IResourceLoader = ScheduleTestHelper.scheduleResource(_schedule);

			assertEquals(
				"Schedule has 1 item after adding 1",
				1,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"Schedule returns 1 item",
				1,
				nextItems.length
			);

			TestLoader(item1).notifyCompleteMock();

			assertEquals(
				"Schedule empty after completion of the added item",
				0,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule return 0 items",
				0,
				nextItems.length
			);

		}

		public function _testEventSequenceCompleteRemovesSequence() : void {

			// sequence dispatchs complete

			var sequence1 : ISequence = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);
			
			assertEquals(
				"Schedule has 1 item after adding 1",
				1,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"Schedule returns 1 item",
				1,
				nextItems.length
			);

			SequenceMock(sequence1).dispatchCompleteMock();

			assertEquals(
				"Schedule empty after completion of the added item",
				0,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule return 0 items",
				0,
				nextItems.length
			);

			// item dispatchs complete
			
			sequence1 = ScheduleTestHelper.fillAndScheduleSequence(_schedule, 1);
			var item1 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			
			assertEquals(
				"Schedule has 1 item after adding 1",
				1,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule returns 1 item",
				1,
				nextItems.length
			);

			TestLoader(item1).notifyCompleteMock();

			assertEquals(
				"Schedule empty after completion of the added item",
				0,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule return 0 items",
				0,
				nextItems.length
			);

		}

		public function _testEventSequenceManagerCompleteRemovesSequenceManager() : void {

			// sequence manager dispatchs complete

			var sequenceManager1 : ISequenceManager = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 1, 1);

			assertEquals(
				"Schedule has 1 item after adding 1",
				1,
				_schedule.numItemsLeft
			);

			var nextItems : Array = _schedule.getNextItems(100);

			assertEquals(
				"Schedule returns 1 item",
				1,
				nextItems.length
			);

			SequenceManagerMock(sequenceManager1).dispatchCompleteMock();

			assertEquals(
				"Schedule empty after completion of the added item",
				0,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule return 0 items",
				0,
				nextItems.length
			);
			
			// sequence dispatchs complete

			sequenceManager1 = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 1, 1);
			var sequence1 : ISequence = SequenceManagerTestHelper.getSequenceAt(sequenceManager1, 0);
			
			assertEquals(
				"Schedule has 1 item after adding 1",
				1,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule returns 1 item",
				1,
				nextItems.length
			);

			SequenceMock(sequence1).dispatchCompleteMock();

			assertEquals(
				"Schedule empty after completion of the added item",
				0,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule return 0 items",
				0,
				nextItems.length
			);

			// item dispatchs complete
			
			sequenceManager1 = ScheduleTestHelper.fillAndScheduleSequenceManager(_schedule, 1, 1);
			sequence1 = SequenceManagerTestHelper.getSequenceAt(sequenceManager1, 0);
			var item1 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			
			assertEquals(
				"Schedule has 1 item after adding 1",
				1,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule returns 1 item",
				1,
				nextItems.length
			);

			TestLoader(item1).notifyCompleteMock();

			assertEquals(
				"Schedule empty after completion of the added item",
				0,
				_schedule.numItemsLeft
			);

			nextItems = _schedule.getNextItems(100);

			assertEquals(
				"Schedule return 0 items",
				0,
				nextItems.length
			);

		}

	}
}
