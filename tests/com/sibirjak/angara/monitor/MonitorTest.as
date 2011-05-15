package com.sibirjak.angara.monitor {

	import flexunit.framework.TestCase;

	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.core.testhelpers.CoreTestHelper;
	import com.sibirjak.angara.monitor.testhelpers.MonitorListener;
	import com.sibirjak.angara.monitor.testhelpers.MonitorTestHelper;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.loaders.TestLoader;
	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.testhelpers.SequenceMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceTestHelper;

	import org.as3commons.collections.framework.IOrderedList;



	/**
	 * @author jes 17.02.2009
	 */
	public class MonitorTest extends TestCase {

		private var _monitor : IMonitor;

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			_monitor = new Monitor();
		}

		override public function tearDown() : void {
			_monitor = null;
		}

		/**
		 * test initial state
		 */

		public function testInstantiated() : void {
			assertTrue("Monitor instantiated", _monitor is IMonitor);
		}
	
		public function testMonitorIsInitallyEmpty() : void {
			assertEquals("Monitor is initially empty", 0, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		/**
		 * test adding of items
		 */

		public function testAddingOfLoaders() : void {
			MonitorTestHelper.createAndAddResourceLoaders(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		public function testAddingSameLoaderTwiceWillBeIgnored() : void {

			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			
			_monitor.add(loader1);
			_monitor.add(loader1);

			assertEquals("Monitor has 1 item", 1, _monitor.numItems);
			assertEquals("Monitor has 0 item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			CoreTestHelper.setResourceLoaderCompleted(loader1);

			assertEquals("Monitor has 1 item", 1, _monitor.numItems);
			assertEquals("Monitor has 1 item loaded", 1, _monitor.numItemsLoaded);
			assertEquals("Monitor progress is 1", 1, _monitor.progress);
		}

		public function testAddingOfMixedItems() : void {
			_monitor.add(CoreTestHelper.createResourceLoader());
			_monitor.add(SequenceTestHelper.createAndFillSequence(1));
			_monitor.add(CoreTestHelper.createResourceLoader());
			_monitor.add(SequenceTestHelper.createAndFillSequence(1));

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		public function testAddingSameSequenceTwiceWillBeIgnored() : void {

			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(3);
			
			_monitor.add(sequence1);
			_monitor.add(sequence1);

			assertEquals("Sequence has 3 items", 3, sequence1.numItems);
			assertEquals("Sequence has 0 item loaded", 0, sequence1.numItemsLoaded);
			assertEquals("Sequence has no progress", 0, sequence1.progress);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has 0 item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			// setting all loaders to complete should set the sequence to complete
			var loader : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			CoreTestHelper.setResourceLoaderCompleted(loader); // removes loader at 0

			assertEquals("Sequence has still 3 items", 3, sequence1.numItems);
			assertEquals("Sequence has 1 item loaded", 1, sequence1.numItemsLoaded);
			assertEquals("Sequence progress is 1/3", 1/3, sequence1.progress);

			assertEquals("Monitor has still 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has 1 item loaded", 1, _monitor.numItemsLoaded);
			assertEquals("Monitor progress is 1/3", 1/3, _monitor.progress);

			loader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			CoreTestHelper.setResourceLoaderCompleted(loader); // removes loader at 0

			assertEquals("Sequence has still 3 items", 3, sequence1.numItems);
			assertEquals("Sequence has 2 items loaded", 2, sequence1.numItemsLoaded);
			assertEquals("Sequence progress is 2/3", 2/3, sequence1.progress);

			assertEquals("Monitor has still 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has 2 items loaded", 2, _monitor.numItemsLoaded);
			assertEquals("Monitor progress is 2/3", 2/3, _monitor.progress);


			loader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			CoreTestHelper.setResourceLoaderCompleted(loader); // removes loader at 0

			assertEquals("Sequence has still 3 items", 3, sequence1.numItems);
			assertEquals("Sequence has 3 items loaded", 3, sequence1.numItemsLoaded);
			assertEquals("Sequence progress is 1", 1, sequence1.progress);

			assertEquals("Monitor has still 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has 3 items loaded", 3, _monitor.numItemsLoaded);
			assertEquals("Monitor progress is 1", 1, _monitor.progress);
		}

		public function testAddingAndRemovingOfLoaderWithProgress() : void {
			MonitorTestHelper.createAndAddResourceLoaders(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals(
				"loader progress is .5",
				.5,
				loader1.progress
			);
			
			_monitor.add(loader1);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has progress", .125, _monitor.progress);

			_monitor.remove(loader1);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		public function testAddingAndRemovingOfCompletedLoader() : void {
			MonitorTestHelper.createAndAddResourceLoaders(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderCompleted(loader1);

			assertEquals(
				"loader progress is 1",
				1,
				loader1.progress
			);
			
			_monitor.add(loader1);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has 1 item loaded", 1, _monitor.numItemsLoaded);
			assertEquals("Monitor has progress", .25, _monitor.progress);

			_monitor.remove(loader1);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		public function testAddingAndRemovingOfFailedLoader() : void {
			MonitorTestHelper.createAndAddResourceLoaders(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderFailed(loader1);

			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals(
				"loader progress is .5",
				.5,
				loader1.progress
			);

			_monitor.add(loader1);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has 0 items loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has 1 item failed", 1, _monitor.numItemsFailed);
			assertEquals("Monitor has progress", .125, _monitor.progress);

			_monitor.remove(loader1);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no item failed", 0, _monitor.numItemsFailed);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		public function testAddingAndRemovingOfSequenceWithProgress() : void {
			MonitorTestHelper.createAndAddResourceLoaders(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var sequence : ISequence = SequenceTestHelper.createAndFillSequence(3);
			SequenceTestHelper.setSequenceProgress(sequence, .6);

			assertEquals(
				"sequence progress is .6",
				.6,
				sequence.progress
			);
			
			_monitor.add(sequence);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has progress", .3, _monitor.progress);
			
			_monitor.remove(sequence);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		public function testAddingAndRemovingOfCompletedSequence() : void {
			MonitorTestHelper.createAndAddResourceLoaders(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var sequence : ISequence = SequenceTestHelper.createAndFillSequence(3);
			SequenceTestHelper.setSequenceComplete(sequence);

			assertEquals(
				"sequence progress is 1",
				1,
				sequence.progress
			);

			_monitor.add(sequence);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has 3 items loaded", 3, _monitor.numItemsLoaded);
			assertEquals("Monitor has progress", .5, _monitor.progress);
			
			_monitor.remove(sequence);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		public function testAddingAndRemovingOfSequenceWithFailedLoaders() : void {
			MonitorTestHelper.createAndAddResourceLoaders(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var sequence : ISequence = SequenceTestHelper.createAndFillSequence(3);

			assertEquals(
				"sequence progress is 0",
				0,
				sequence.progress
			);

			CoreTestHelper.setResourceLoaderProgress(
				SequenceTestHelper.getResourceLoaderAt(sequence, 0),
				.7
			);

			CoreTestHelper.setResourceLoaderProgress(
				SequenceTestHelper.getResourceLoaderAt(sequence, 1),
				.7
			);

			SequenceTestHelper.setResourceLoaderFailedByIndex(sequence, 2); // sets progress to 1

			assertEquals(
				"sequence progress is .8",
				2.4/3,
				sequence.progress
			);

			_monitor.add(sequence);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has 0 items loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has 1 item failed", 1, _monitor.numItemsFailed);
			assertEquals("Monitor has progress", 2.4/6, _monitor.progress);
			
			_monitor.remove(sequence);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has 0 items failed", 0, _monitor.numItemsFailed);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
		}

		/**
		 * test clear
		 */
		public function testClearRemovesItems() : void {
			var item2 : TestLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor) as TestLoader;
			var item3 : TestLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor) as TestLoader;
			var item4 : TestLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor) as TestLoader;

			item2.notifyLoading();
			item2.notifyProgressMock(.4);

			item3.notifyLoading();
			item3.notifyCompleteMock();

			item4.notifyLoading();
			item4.notifyFailureMock();

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has 1 item loaded", 1, _monitor.numItemsLoaded);
			assertEquals("Monitor has 1 item failed", 1, _monitor.numItemsFailed);
			assertEquals("Monitor progress is 2.4/3", 2.4/3, _monitor.progress);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				item2.status
			);

			assertEquals(
				"Loader has progress of .4",
				.4,
				item2.progress
			);

			assertEquals(
				"Loader status is complete",
				LoaderItemStatus.COMPLETE,
				item3.status
			);

			assertEquals(
				"Loader status is failure",
				LoaderItemStatus.FAILURE,
				item4.status
			);
			
			_monitor.clear();

			assertEquals("Monitor has 0 items", 0, _monitor.numItems);
			assertEquals("Monitor has 0 items loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has 0 items failed", 0, _monitor.numItemsFailed);
			assertEquals("Monitor progress is 0", 0, _monitor.progress);

			assertEquals(
				"Loader status is still loading",
				LoaderItemStatus.LOADING,
				item2.status
			);

			assertEquals(
				"Loader status is still complete",
				LoaderItemStatus.COMPLETE,
				item3.status
			);

			assertEquals(
				"Loader status is still failure",
				LoaderItemStatus.FAILURE,
				item4.status
			);

			// test if updating resources does not affect the sequence 
			
			item2.notifyLoading();
			item2.notifyProgressMock(.8);

			item3.notifyLoading();
			item3.notifyFailureMock();

			item4.notifyLoading();
			item4.notifyCompleteMock();

			assertEquals("Monitor has 0 items", 0, _monitor.numItems);
			assertEquals("Monitor has 0 items loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has 0 items failed", 0, _monitor.numItemsFailed);
			assertEquals("Monitor progress is 0", 0, _monitor.progress);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				item2.status
			);

			assertEquals(
				"Loader has progress of .8",
				.8,
				item2.progress
			);

			assertEquals(
				"Loader status is failure",
				LoaderItemStatus.FAILURE,
				item3.status
			);

			assertEquals(
				"Loader status is complete",
				LoaderItemStatus.COMPLETE,
				item4.status
			);

		}

		/**
		 * test item progress handling
		 */

		public function testProgressOfLoaders() : void {
			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 0, .5);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .1",
				.1,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 1, .5);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .2",
				.2,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 0, 1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 1, 1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 2, 1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 3, 1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 4, 1);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1",
				1,
				_monitor.progress
			);
		}

		public function testProgressOfMixedItems() : void {

			var loader1 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor);
			var loader2 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor);
			MonitorTestHelper.createAndAddResourceLoader(_monitor);
			var sequence1 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 11, 1);

			assertEquals("Monitor has 14 items", 14, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals("Monitor has 14 items", 14, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .125",
				.125,
				_monitor.progress
			);

			SequenceTestHelper.setSequenceProgress(sequence1, .5);

			assertEquals(
				"Sequence progress is .5",
				.5,
				sequence1.progress
			);

			assertEquals("Monitor has 14 items", 14, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .25",
				.25,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader2, 1);

			assertEquals("Monitor has 14 items", 14, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .5",
				.5,
				_monitor.progress
			);

		}

		public function testWeightedProgressOfLoaders() : void {
			
			var loader1 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor, 2);
			var loader2 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor, 1);
			var loader3 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor, 1);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .25",
				.25,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader2, .5);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .375",
				.375,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader3, 1);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .625",
				.625,
				_monitor.progress
			);

		}

		public function testWeightedProgressOfMixedItems() : void {

			var loader1 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor, 2);
			var loader2 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor, 1);
			MonitorTestHelper.createAndAddResourceLoader(_monitor, 1);
			var sequence1 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 6);

			assertEquals("Monitor has 9 items", 9, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals("Monitor has 9 items", 9, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .1",
				.1,
				_monitor.progress
			);

			SequenceTestHelper.setSequenceProgress(sequence1, .5);

			assertEquals("Monitor has 9 items", 9, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .4",
				.4,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader2, 1);

			assertEquals("Monitor has 9 items", 9, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .5",
				.5,
				_monitor.progress
			);

			SequenceTestHelper.setSequenceProgress(sequence1, 1);

			assertEquals("Monitor has 9 items", 9, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .8",
				.8,
				_monitor.progress
			);

		}

		public function testRaisingProgressOfASequenceItem() : void {
			
			var sequence1 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 4);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var loader1 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .125",
				.125,
				_monitor.progress
			);

		}

		public function testRaisingProgressOfAnItemInAWeightedSequence() : void {
			
			var sequence1 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 4, 1);
			MonitorTestHelper.createAndAddResourceLoader(_monitor);
			MonitorTestHelper.createAndAddResourceLoader(_monitor);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var loader1Sequence1 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			CoreTestHelper.setResourceLoaderProgress(loader1Sequence1, .5);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/24",
				1/24,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader1Sequence1, 1);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/12",
				1/12,
				_monitor.progress
			);

			var loader1 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor, 6);

			assertEquals("Monitor has 7 items", 7, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is (1/4/9)",
				1/4/9,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader1, 1);

			assertEquals("Monitor has 7 items", 7, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is (1/4/9 + 6/9)",
				1/4/9 + 6/9,
				_monitor.progress
			);

		}

		public function testRaisingProgressOfAnItemInAWeightedSequence2() : void {
			
			var sequence1 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 4, 2);
			MonitorTestHelper.createAndAddResourceLoader(_monitor);
			MonitorTestHelper.createAndAddResourceLoader(_monitor);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			var loader1Sequence1 : IResourceLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0);
			CoreTestHelper.setResourceLoaderProgress(loader1Sequence1, .5);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/8 * 2/4",
				1/8 * 2/4,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader1Sequence1, 1);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 2/8 * 2/4",
				1/4 * 2/4,
				_monitor.progress
			);

			var loader1 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor, 6);

			assertEquals("Monitor has 7 items", 7, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/4 * 2/10",
				1/4 * 2/10,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader1, 1);

			assertEquals("Monitor has 7 items", 7, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/4 * 2/10 + 6/10",
				1/4 * 2/10 + 6/10,
				_monitor.progress
			);

		}

		public function testAddingItemsToASequenceRaisesNumItems() : void {
			
			var sequence1 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			sequence1.add(CoreTestHelper.createResourceLoader());
			sequence1.add(CoreTestHelper.createResourceLoader());

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

		}

		public function testAddingItemsToASequenceCalculatesProgressRight() : void {
			
			var sequence1 : ISequence = new SequenceMock();
			
			_monitor.add(sequence1);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			var loader2 : IResourceLoader = CoreTestHelper.createResourceLoader();
			var loader3 : IResourceLoader = CoreTestHelper.createResourceLoader();
			
			sequence1.add(loader1);
			sequence1.add(loader2);
			
			assertEquals("Sequence has 2 items", 2, sequence1.numItems);
			assertEquals("Sequence has no item loaded", 0, sequence1.numItemsLoaded);
			assertEquals(
				"Sequence progress is 0",
				0,
				sequence1.progress
			);

			assertEquals("Monitor has 2 items", 2, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 0",
				0,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader1, 1);

			assertEquals("Monitor has 2 items", 2, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/2",
				1/2,
				_monitor.progress
			);
			
			sequence1.add(loader3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/3",
				1/3,
				_monitor.progress
			);

			var sequence2 : ISequence = new SequenceMock();
			_monitor.add(sequence2, 2);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/5",
				1/5,
				_monitor.progress
			);

			var loader4 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence2.add(loader4, 2);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/5",
				1/5,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader4, 1);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertTrue(
				"Monitor progress is 3/5",
				Math.abs(3/5 - _monitor.progress) < .00000000001
			);

		}

		public function testAddingAndRemovingProgressedItemsToASequenceCalculatesProgressRight() : void {
			
			var sequence1 : ISequence = new SequenceMock();
			
			_monitor.add(sequence1);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals(
				"loader progress is .5",
				.5,
				loader1.progress
			);
			
			var loader2 : IResourceLoader = CoreTestHelper.createResourceLoader();
			
			sequence1.add(loader1);
			sequence1.add(loader2);
			
			assertEquals("Monitor has 2 items", 2, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .25",
				.25,
				_monitor.progress
			);
			
			var loader3 : IResourceLoader = CoreTestHelper.createResourceLoader();
			sequence1.add(loader3);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .5/3",
				.5/3,
				_monitor.progress
			);

			var sequence2 : ISequence = new SequenceMock();
			_monitor.add(sequence2, 2);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .5/5",
				.5/5,
				_monitor.progress
			);

			var loader4 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderProgress(loader4, 1);

			assertEquals(
				"loader progress is .5",
				.5,
				loader1.progress
			);

			sequence2.add(loader4, 2);

			assertEquals("Monitor has 4 items", 4, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1/2",
				1/2,
				_monitor.progress
			);

			sequence2.remove(loader4);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertTrue(
				"Monitor progress is .5/5",
				Math.abs(.5/5 - _monitor.progress) < .00000000001
			);

			_monitor.remove(sequence2);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertTrue(
				"Monitor progress is .5/3",
				Math.abs(.5/3 - _monitor.progress) < .00000000001
			);

			sequence1.remove(loader3);

			assertEquals("Monitor has 2 items", 2, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertTrue(
				"Monitor progress is .25",
				Math.abs(.25 - _monitor.progress) < .00000000001
			);
			
			sequence1.remove(loader1);
			sequence1.remove(loader2);

			assertEquals("Monitor has 0 items", 0, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 0",
				0,
				_monitor.progress
			);

		}

		public function testProgressOfGrowingMonitor() : void {

			assertEquals("Monitor is initially empty", 0, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			var loader1 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor);

			assertEquals("Monitor has 1 item", 1, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			CoreTestHelper.setResourceLoaderProgress(loader1, 1);

			assertEquals("Monitor has 1 item", 1, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1",
				1,
				_monitor.progress
			);

			var loader2 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor);

			assertEquals("Monitor has 2 items", 2, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .5",
				.5,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderProgress(loader2, .5);
			var loader3 : IResourceLoader = MonitorTestHelper.createAndAddResourceLoader(_monitor);
			CoreTestHelper.setResourceLoaderProgress(loader3, .5);

			assertEquals("Monitor has 3 items", 3, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .667",
				2/3,
				_monitor.progress
			);

			var sequence1 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 3);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .333",
				1/3,
				_monitor.progress
			);

			SequenceTestHelper.setSequenceProgress(sequence1, 1/3);

			assertEquals("Monitor has 6 items", 6, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .5",
				.5,
				_monitor.progress
			);

			MonitorTestHelper.createFillAndAddSequence(_monitor, 3, 1);

			assertEquals("Monitor has 9 items", 9, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 3/7",
				3/7,
				_monitor.progress
			);

			var sequence3 : ISequence = MonitorTestHelper.createFillAndAddSequence(_monitor, 3, 2);

			assertEquals("Monitor has 12 items", 12, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 3/9 = .333",
				1/3,
				_monitor.progress
			);
			
			SequenceTestHelper.setSequenceProgress(sequence3, 1);

			assertEquals("Monitor has 12 items", 12, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 5/9",
				5/9,
				_monitor.progress
			);

		}

		/**
		 * test item complete handling
		 */

		public function testProgressAlways_1_whenAllItemsComplete() : void {
			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 0, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 1, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 2, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 3, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 4, .1);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .1",
				.1,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 0);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 1);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 2);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 3);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 4);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has 5 item loaded", 5, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1",
				1,
				_monitor.progress
			);
			
			var loader1 : IResourceLoader = loaders.itemAt(0) as IResourceLoader;
			assertEquals(
				"Item1 progress is 1",
				1,
				loader1.progress
			);
			
			var loader4 : IResourceLoader = loaders.itemAt(0) as IResourceLoader;
			assertEquals(
				"Item4 progress is 1",
				1,
				loader4.progress
			);

		}

		public function testCompletionOfLoadersRaisesProgress() : void {
			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);
			
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 0);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has 1 loaded", 1, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .2",
				.2,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 1);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has 2 loaded", 2, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .4",
				.4,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 2);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 3);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 4);
			
			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has 5 loaded", 5, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is 1",
				1,
				_monitor.progress
			);
			
		}
		
		/**
		 * test resource failure
		 */

		public function testNumItemsFailed() : void {
			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has no progress", 0, _monitor.progress);

			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 0, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 1, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 2, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 3, .1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 4, .1);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has no item loaded", 0, _monitor.numItemsLoaded);
			assertEquals(
				"Monitor progress is .1",
				.1,
				_monitor.progress
			);

			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 0);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 1);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 2);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 3);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 4);

			assertEquals("Monitor has 5 items", 5, _monitor.numItems);
			assertEquals("Monitor has 5 item loaded", 0, _monitor.numItemsLoaded);
			assertEquals("Monitor has 5 item loaded", 5, _monitor.numItemsFailed);
			assertEquals("Monitor progress is now 1", 1,	_monitor.progress);
			
			var loader1 : IResourceLoader = loaders.itemAt(0) as IResourceLoader;
			assertEquals(
				"Item1 progress is now 1",
				1,
				loader1.progress
			);
			
			var loader4 : IResourceLoader = loaders.itemAt(0) as IResourceLoader;
			assertEquals(
				"Item4 progress is now 1",
				1,
				loader4.progress
			);

		}

		/**
		 * test complete_event dispatching
		 */

		public function testCompleteEventFiredWhenAllItemsLoaded() : void {
			
			var listener : MonitorListener = new MonitorListener(_monitor);

			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 0);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 1);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 2);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 3);

			assertFalse("Monitor did not fire COMPLETE", listener.monitorCompleteReceived);
			// prove that it sets back the receiving information
			assertFalse("Monitor event notification removed ", listener.monitorCompleteReceived);

			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 4);

			assertTrue("Monitor has fired COMPLETE", listener.monitorCompleteReceived);

		}

		public function testCompleteEventFiredWhenAllItemsFail() : void {
			
			var listener : MonitorListener = new MonitorListener(_monitor);

			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 0);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 1);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 2);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 3);

			assertFalse("Monitor did not fire COMPLETE", listener.monitorCompleteReceived);
			// prove that it sets back the receiving information
			assertFalse("Monitor event notification removed ", listener.monitorCompleteReceived);

			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 4);

			assertTrue("Monitor has fired COMPLETE", listener.monitorCompleteReceived);

		}

		public function testCompleteEventFiredWhenAllItemsFailOrComplete() : void {
			
			var listener : MonitorListener = new MonitorListener(_monitor);

			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 0);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 1);
			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 2);

			assertFalse("Monitor did not fire COMPLETE", listener.monitorCompleteReceived);
			// prove that it sets back the receiving information
			assertFalse("Monitor event notification removed ", listener.monitorCompleteReceived);

			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 3);
			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 4);

			assertTrue("Monitor has fired COMPLETE", listener.monitorCompleteReceived);

		}

		public function testCompleteEventNotFiredEvenIfEachItemProgressIs_1() : void {
			
			var listener : MonitorListener = new MonitorListener(_monitor);

			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 0, 1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 1, 1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 2, 1);
			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 3, 1);

			assertFalse("Monitor did not fire COMPLETE", listener.monitorCompleteReceived);

			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 4, 1);

			assertFalse("Monitor did not fire COMPLETE", listener.monitorCompleteReceived);

		}

		/**
		 * test progress_event dispatching
		 */

		public function testProgressEventFiredForItemProgressOrCompletionOrFailure() : void {
			
			var loaders : IOrderedList = MonitorTestHelper.createAndAddResourceLoaders(_monitor, 5);

			var listener : MonitorListener = new MonitorListener(_monitor);

			assertFalse("No progress event notification saved", listener.monitorProgressReceived);

			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 0, 1);

			assertTrue("Monitor has fired PROGRESS 1", listener.monitorProgressReceived);
			// prove that it sets back the receiving information
			assertFalse("Progress event notification removed", listener.monitorProgressReceived);

			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 1);

			assertTrue("Monitor has fired PROGRESS 2", listener.monitorProgressReceived);

			CoreTestHelper.setResourceLoaderProgressByIndex(loaders, 2, 1);

			assertTrue("Monitor has fired PROGRESS 3", listener.monitorProgressReceived);

			CoreTestHelper.setResourceLoaderCompletedByIndex(loaders, 3);

			assertTrue("Monitor has fired PROGRESS 4", listener.monitorProgressReceived);

			CoreTestHelper.setResourceLoaderFailedByIndex(loaders, 4);

			assertTrue("Monitor has fired PROGRESS 5", listener.monitorProgressReceived);
		}

	}
}


