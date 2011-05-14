package com.sibirjak.angara {
	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.loaders.TestLoader;
	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.ISequenceManager;
	import com.sibirjak.angara.sequence.SequenceManager;
	import com.sibirjak.angara.sequence.testhelpers.SequenceManagerMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceTestHelper;
	import flexunit.framework.TestCase;


	/**
	 * @author jes 11.02.2009
	 */
	public class LoaderManagerTest extends TestCase {

		private var _loaderManager : ILoaderManager;

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			LoaderManager.createInstance(5);
			_loaderManager = LoaderManager.getInstance();
		}

		override public function tearDown() : void {
			LoaderManager.destroyInstance();
			_loaderManager = null;
		}

		/**
		 * tests
		 */

		public function testTrue() : void {
			assertTrue(true);
		}

		/**
		 * test adding items
		 */

		public function testAddingItemLoadsItemImmediately() : void {
			var loader1 : TestLoader = new TestLoader(1);

			assertEquals(
				"Loader status is waiting",
				LoaderItemStatus.WAITING,
				loader1.status
			);
			
			_loaderManager.add(loader1);
			
			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				loader1.status
			);

		}

		public function testAddingItemTwice() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);

			_loaderManager.add(loader1);
			_loaderManager.add(loader2);
			_loaderManager.add(loader3);

			assertEquals(
				"Loader has 3 items",
				3,
				_loaderManager.numItemsLeft
			);

			_loaderManager.add(loader3);

			assertEquals(
				"Loader has 3 items",
				3,
				_loaderManager.numItemsLeft
			);

		}

		public function testAddingSequenceLoadsItemImmediately() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var sequence : ISequence = new SequenceMock();
			sequence.add(loader1);

			assertEquals(
				"Loader status is waiting",
				LoaderItemStatus.WAITING,
				loader1.status
			);
			
			_loaderManager.add(sequence);
			
			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				loader1.status
			);

		}

		public function testAddingItemToAScheduledSequenceLoadsItemImmediately() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var sequence : ISequence = new SequenceMock();
			_loaderManager.add(sequence);

			assertEquals(
				"Loader status is waiting",
				LoaderItemStatus.WAITING,
				loader1.status
			);
			
			sequence.add(loader1);
			
			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				loader1.status
			);

		}

		public function testAddingSequenceTwice() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);

			_loaderManager.add(loader1);

			var sequence : ISequence = new SequenceMock();
			sequence.add(loader2);
			sequence.add(loader3);
			_loaderManager.add(sequence);

			assertEquals(
				"Loader has 3 items total",
				3,
				_loaderManager.numItemsLeft
			);

			_loaderManager.add(sequence);

			assertEquals(
				"Loader has 3 items total",
				3,
				_loaderManager.numItemsLeft
			);

		}

		public function testAddingSequenceToAScheduledSequenceMangerLoadsItemImmediately() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var sequence : ISequence = new SequenceMock();
			sequence.add(loader1);

			var sequenceManager : ISequenceManager = new SequenceManager();
			sequenceManager.add(sequence);

			_loaderManager.add(sequence);

			assertEquals(
				"Loader status is waiting",
				LoaderItemStatus.WAITING,
				loader1.status
			);
			
			_loaderManager.add(sequenceManager);
			
			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				loader1.status
			);

		}

		public function testAddingSequenceManagerTwice() : void {
			var loader1 : TestLoader = new TestLoader(1);
			_loaderManager.add(loader1);

			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(2);
			var sequence3 : ISequence = SequenceTestHelper.createAndFillSequence(3);

			var sequenceManager : ISequenceManager = new SequenceManager();
			sequenceManager.add(sequence1);
			sequenceManager.add(sequence2);
			sequenceManager.add(sequence3);

			_loaderManager.add(sequenceManager);

			assertEquals(
				"Loader has 7 items",
				7,
				_loaderManager.numItemsLeft
			);

			_loaderManager.add(sequenceManager);

			assertEquals(
				"Loader has 7 items",
				7,
				_loaderManager.numItemsLeft
			);

			var sequence4 : ISequence = SequenceTestHelper.createAndFillSequence(3);

			_loaderManager.add(sequence4);

			assertEquals(
				"Loader has 10 items",
				10,
				_loaderManager.numItemsLeft
			);

			_loaderManager.add(new TestLoader(1));

			assertEquals(
				"Loader has 11 items",
				11,
				_loaderManager.numItemsLeft
			);

		}

		/**
		 * test removing items
		 */

		public function testRemovingWrongItem() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);

			_loaderManager.add(loader1);
			_loaderManager.add(loader2);
			_loaderManager.add(loader3);
			_loaderManager.add(loader4);

			assertEquals(
				"Loader has 4 items",
				4,
				_loaderManager.numItemsLeft
			);

			_loaderManager.remove(loader5);

			assertEquals(
				"Loader has 4 items",
				4,
				_loaderManager.numItemsLeft
			);

		}

		public function testRemovingWrongSequence() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);

			var sequence1 : ISequence = new SequenceMock();
			sequence1.add(loader1);
			sequence1.add(loader2);
			_loaderManager.add(sequence1);

			_loaderManager.add(loader3);

			var sequence2 : ISequence = new SequenceMock();
			sequence2.add(loader4);
			sequence2.add(loader5);

			assertEquals(
				"Loader has 3 items",
				3,
				_loaderManager.numItemsLeft
			);

			_loaderManager.remove(sequence2);

			assertEquals(
				"Loader has 3 items",
				3,
				_loaderManager.numItemsLeft
			);
		}

		public function testRemovingItemStopsItem() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);
			
			_loaderManager.add(loader1);
			_loaderManager.add(loader2);
			_loaderManager.add(loader3);
			_loaderManager.add(loader4);
			_loaderManager.add(loader5);
			
			assertEquals(
				"Loader has 5 items",
				5,
				_loaderManager.numItemsLeft
			);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				loader3.status
			);

			_loaderManager.remove(loader3);
		
			assertEquals(
				"Loader has 4 items",
				4,
				_loaderManager.numItemsLeft
			);

			assertEquals(
				"Loader is waiting",
				LoaderItemStatus.WAITING,
				loader3.status
			);
		
		}

		public function testRemovingSequenceStopsItems() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);
			
			var sequence : ISequence = new SequenceMock();
			sequence.add(loader2);
			sequence.add(loader3);
			sequence.add(loader5);

			_loaderManager.add(sequence);
			_loaderManager.add(loader1);
			_loaderManager.add(loader4);
			
			assertEquals(
				"Loader has 5 items",
				5,
				_loaderManager.numItemsLeft
			);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				loader3.status
			);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				loader5.status
			);

			_loaderManager.remove(sequence);
		
			assertEquals(
				"Loader has 2 items",
				2,
				_loaderManager.numItemsLeft
			);

			assertEquals(
				"Loader is waiting",
				LoaderItemStatus.WAITING,
				loader3.status
			);
		
			assertEquals(
				"Loader is waiting",
				LoaderItemStatus.WAITING,
				loader5.status
			);
		
		}

		public function testClearStopsAndRemovesItems() : void {
			var item1 : TestLoader = new TestLoader(1);
			_loaderManager.add(item1);

			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var item2 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0) as TestLoader;
			_loaderManager.add(sequence1);


			var sequenceManager : SequenceManagerMock = new SequenceManagerMock();
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var item3 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 0) as TestLoader;
			sequenceManager.add(sequence2);
			_loaderManager.add(sequenceManager);
			
			assertEquals("LoaderManager has 3 items", 3, _loaderManager.numItemsLeft);

			item1.notifyLoading();
			item2.notifyLoading();
			item3.notifyLoading();

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				item1.status
			);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				item2.status
			);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				item3.status
			);
			
			_loaderManager.clear();

			assertEquals("LoaderManager has 0 items", 0, _loaderManager.numItemsLeft);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.WAITING,
				item1.status
			);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.WAITING,
				item2.status
			);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.WAITING,
				item3.status
			);

		}

		/**
		 * testing cleanup
		 */

		public function testCleanupAfterCompletion() : void {
			
			LoaderManager.destroyInstance();
			LoaderManager.createInstance(10);
			_loaderManager = LoaderManager.getInstance();

			var item1 : TestLoader = new TestLoader(1);
			_loaderManager.add(item1);

			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(2);
			_loaderManager.add(sequence1);

			var item4 : TestLoader = new TestLoader(1);
			_loaderManager.add(item4);

			var item5 : TestLoader = new TestLoader(1);
			_loaderManager.add(item5);

			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(2);
			_loaderManager.add(sequence2);

			var item8 : TestLoader = new TestLoader(1);
			_loaderManager.add(item8);

			var item9 : TestLoader = new TestLoader(1);
			_loaderManager.add(item9);

			assertEquals(
				"Schedule contains 9 item after filling",
				9,
				_loaderManager.numItemsLeft
			);

			TestLoader(item4).notifyCompleteMock();

			TestLoader(item8).notifyCompleteMock();
			
			assertEquals(
				"Schedule contains 7 items after completing 2 items",
				7,
				_loaderManager.numItemsLeft
			);

			TestLoader(item1).notifyCompleteMock();

			TestLoader(item5).notifyCompleteMock();

			TestLoader(item9).notifyCompleteMock();

			assertEquals(
				"Schedule contains 4 items after completing 3 items",
				4,
				_loaderManager.numItemsLeft
			);

			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 1);

			TestLoader(item2).notifyCompleteMock();

			TestLoader(item3).notifyCompleteMock();

			assertEquals(
				"Loader has 2 items total",
				2,
				_loaderManager.numItemsLeft
			);

			var item6 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 0);
			var item7 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 1);

			TestLoader(item6).notifyCompleteMock();

			TestLoader(item7).notifyCompleteMock();

			assertEquals(
				"Schedule empty",
				0,
				_loaderManager.numItemsLeft
			);

		}

		public function testSequenceRemovedAfterCompletionOfAllSequenceItems() : void {

			LoaderManager.destroyInstance();
			LoaderManager.createInstance(10);
			_loaderManager = LoaderManager.getInstance();

			var item1 : TestLoader = new TestLoader(1);
			_loaderManager.add(item1);

			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(3);
			_loaderManager.add(sequence1);

			var item2 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			var item3 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 1);
			var item4 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 2);

			assertEquals(
				"Schedule contains 4 item after filling",
				4,
				_loaderManager.numItemsLeft
			);

			TestLoader(item2).notifyCompleteMock();

			assertEquals(
				"Loader has 3 items total",
				3,
				_loaderManager.numItemsLeft
			);

			TestLoader(item3).notifyCompleteMock();

			assertEquals(
				"Schedule contains still 2 items after completion of item3",
				2,
				_loaderManager.numItemsLeft
			);

			TestLoader(item4).notifyCompleteMock();

			assertEquals(
				"Schedule contains 1 item after completion of item3 (sequence1 removed)",
				1,
				_loaderManager.numItemsLeft
			);

		}


	}
	
}
