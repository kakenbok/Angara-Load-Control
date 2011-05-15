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
package com.sibirjak.angara.sequence {

	import flexunit.framework.TestCase;

	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.core.testhelpers.CoreTestHelper;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.loaders.TestLoader;
	import com.sibirjak.angara.sequence.testhelpers.PagedSequenceMock;
	import com.sibirjak.angara.sequence.testhelpers.PagedSequenceTestHelper;
	import com.sibirjak.angara.sequence.testhelpers.SequenceListener;


	/**
	 * @author jes 26.02.2009
	 */
	public class PagedSequenceTest extends TestCase {

		private var _sequence : ISequence;

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			_sequence = new PagedSequenceMock();
		}

		override public function tearDown() : void {
			_sequence = null;
		}

		/**
		 * test initial state
		 */

		public function testInstantiated() : void {
			assertTrue("Sequence instantiated", _sequence is Sequence);
		}
	
		public function testSequenceIsInitallyEmpty() : void {
			assertEquals("Sequence is initially empty", 0, _sequence.numItems);
			assertEquals("Sequence has no item loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has no progress", 0, _sequence.progress);
		}

		/**
		 * test adding of items
		 */

		public function testAddingOfLoaders() : void {
			PagedSequenceTestHelper.fillSequence(_sequence, 3);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has no item loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has no progress", 0, _sequence.progress);
		}

		public function testAddingSameLoaderTwiceWillBeIgnored() : void {

			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			
			_sequence.add(loader1);
			_sequence.add(loader1);

			assertEquals(
				"Sequence has stored only 1 resource loader",
				1,
				PagedSequenceTestHelper.getNumResourceLoaders(_sequence)
			);

			assertEquals("Sequence has 1 item", 1, _sequence.numItems);
			assertEquals("Sequence has 0 item loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has no progress", 0, _sequence.progress);

			CoreTestHelper.setResourceLoaderCompleted(loader1);

			assertEquals("Sequence has 1 item", 1, _sequence.numItems);
			assertEquals("Sequence has 1 item loaded", 1, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 1", 1, _sequence.progress);
		}

		public function testAddingSameLoaderToMultipleSequencesWillBeIgnored() : void {

			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			
			assertFalse(loader1.scheduled);

			_sequence.add(loader1);

			assertTrue(loader1.scheduled);
			
			assertEquals("Sequence has 1 item", 1, _sequence.numItems);
			assertEquals("Sequence has 0 item loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has no progress", 0, _sequence.progress);

			assertEquals(
				"Sequence has stored only 1 resource loader",
				1,
				PagedSequenceTestHelper.getNumResourceLoaders(_sequence)
			);

			var sequence2 : ISequence = new PagedSequenceMock();

			assertTrue(loader1.scheduled);

			sequence2.add(loader1);

			assertTrue(loader1.scheduled);

			assertEquals("Sequence2 has 0 items", 0, sequence2.numItems);
			assertEquals("Sequence2 has 0 item loaded", 0, sequence2.numItemsLoaded);
			assertEquals("Sequence2 has no progress", 0, sequence2.progress);

			assertEquals(
				"Sequence has stored 0 resource loaders",
				0,
				PagedSequenceTestHelper.getNumResourceLoaders(sequence2)
			);
		}

		public function testAddingLoadersToFinishedSequenceWillBeIgnored() : void {

			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			var loader2 : IResourceLoader = CoreTestHelper.createResourceLoader();
			
			_sequence.add(loader1);
			_sequence.add(loader2);

			assertEquals(
				"Sequence has stored 2 resource loaders",
				2,
				PagedSequenceTestHelper.getNumResourceLoaders(_sequence)
			);

			assertEquals("Sequence has 2 item", 2, _sequence.numItems);
			assertEquals("Sequence has 0 item loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has no progress", 0, _sequence.progress);

			CoreTestHelper.setResourceLoaderCompleted(loader1);
			CoreTestHelper.setResourceLoaderCompleted(loader2);

			assertEquals("Sequence has 2 items", 2, _sequence.numItems);
			assertEquals("Sequence has 2 items loaded", 2, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 1", 1, _sequence.progress);
			assertEquals("Sequence is complete", LoaderItemStatus.COMPLETE, _sequence.status);

			var loader3 : IResourceLoader = CoreTestHelper.createResourceLoader();
			_sequence.add(loader3);

			assertEquals("Sequence has 2 items", 2, _sequence.numItems);
			assertEquals("Sequence has 2 items loaded", 2, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 1", 1, _sequence.progress);
			assertEquals("Sequence is complete", LoaderItemStatus.COMPLETE, _sequence.status);
		}

		public function testAddingAndRemovingOfLoaderWithProgress() : void {
			PagedSequenceTestHelper.fillSequence(_sequence, 3);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals(
				"loader progress is .5",
				.5,
				loader1.progress
			);
			
			_sequence.add(loader1);

			assertEquals("Sequence has 4 items", 4, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is .125", .125, _sequence.progress);

			_sequence.remove(loader1);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);
		}

		public function testAddingAndRemovingOfCompletedLoader() : void {
			PagedSequenceTestHelper.fillSequence(_sequence, 3);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderCompleted(loader1);

			assertEquals(
				"loader progress is 1",
				1,
				loader1.progress
			);
			
			_sequence.add(loader1);

			assertEquals("Sequence has 4 items", 4, _sequence.numItems);
			assertEquals("Sequence has 1 item loaded", 1, _sequence.numItemsLoaded);
			assertEquals("Sequence has progress", .25, _sequence.progress);

			_sequence.remove(loader1);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);
		}

		public function testAddingAndRemovingOfFailedLoader() : void {
			PagedSequenceTestHelper.fillSequence(_sequence, 3);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			CoreTestHelper.setResourceLoaderFailed(loader1);

			CoreTestHelper.setResourceLoaderProgress(loader1, .5);

			assertEquals(
				"loader progress is .5",
				.5,
				loader1.progress
			);

			_sequence.add(loader1);

			assertEquals("Sequence has 4 items", 4, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has 1 item failed", 1, _sequence.numItemsFailed);
			assertEquals("Sequence has progress", .125, _sequence.progress);

			_sequence.remove(loader1);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has 0 items failed", 0, _sequence.numItemsFailed);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);

		}

		/**
		 * test clear
		 */
		public function testClear() : void {
			PagedSequenceTestHelper.fillSequence(_sequence, 3);
			var item2 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(_sequence, 0) as TestLoader;
			var item3 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(_sequence, 1) as TestLoader;
			var item4 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(_sequence, 2) as TestLoader;
			
			item2.notifyLoading();
			item2.notifyProgressMock(.4);

			item3.notifyLoading();
			item3.notifyCompleteMock();

			item4.notifyLoading();
			item4.notifyFailureMock();

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 1 item loaded", 1, _sequence.numItemsLoaded);
			assertEquals("Sequence has 1 item failed", 1, _sequence.numItemsFailed);
			assertEquals("Sequence progress is 2.4/3", 2.4/3, _sequence.progress);

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
			
			_sequence.clear();

			assertEquals("Sequence has 0 items", 0, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has 0 items failed", 0, _sequence.numItemsFailed);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.WAITING,
				item2.status
			);

			assertEquals(
				"Loader status is failure",
				LoaderItemStatus.COMPLETE,
				item3.status
			);

			assertEquals(
				"Loader status is loading",
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

			assertEquals("Sequence has 0 items", 0, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has 0 items failed", 0, _sequence.numItemsFailed);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);

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
				"Loader status is loading",
				LoaderItemStatus.FAILURE,
				item3.status
			);

			assertEquals(
				"Loader status is failure",
				LoaderItemStatus.COMPLETE,
				item4.status
			);

		}

		/**
		 * test stop pause resume
		 */

		public function testStopSequenceStopsAllSequenceItems() : void {
			var sequence1 : ISequence = PagedSequenceTestHelper.createAndFillSequence(3);
			var item2 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(sequence1, 0) as TestLoader;
			var item3 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(sequence1, 1) as TestLoader;
			var item4 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(sequence1, 2) as TestLoader;
			
			item2.notifyLoading();
			item3.notifyLoading();
			item4.notifyLoading();

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				item2.status
			);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				item3.status
			);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				item4.status
			);
			
			sequence1.stop();

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.WAITING,
				item2.status
			);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.WAITING,
				item3.status
			);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.WAITING,
				item4.status
			);

		}

		public function testPauseResume() : void {
			assertEquals("SequenceManagerStatus is WAITING", LoaderItemStatus.WAITING, _sequence.status);

			_sequence.pause();

			assertEquals("SequenceManagerStatus is WAITING", LoaderItemStatus.PAUSED, _sequence.status);

			_sequence.resume();

			assertEquals("SequenceManagerStatus is WAITING", LoaderItemStatus.WAITING, _sequence.status);
		}

		/**
		 * test sequence stop/resume events
		 */

		public function testSequenceFiresStopAndResumeEvents() : void {
			var listener : SequenceListener = new SequenceListener(_sequence);

			PagedSequenceTestHelper.fillSequence(_sequence, 3);

			assertFalse("Sequence did not fire STOPPED", listener.sequenceStoppedReceived);
			assertFalse("Sequence did not fire RESUME", listener.sequenceResumedReceived);

			_sequence.pause();

			assertTrue("Sequence has fired STOPPED", listener.sequenceStoppedReceived);
			assertFalse("Sequence did not fire RESUME", listener.sequenceResumedReceived);

			// prove that it sets back the receiving information
			assertFalse("Sequence did not fire STOPPED", listener.sequenceStoppedReceived);

			_sequence.resume();

			assertTrue("Sequence has fired RESUME", listener.sequenceResumedReceived);
			assertFalse("Sequence did not fire STOPPED", listener.sequenceStoppedReceived);
		}

		/**
		 * test sequence complete events
		 */

		public function testFailOrCompleteAllLoadersFiresComplete() : void {
			var listener : SequenceListener = new SequenceListener(_sequence);

			PagedSequenceTestHelper.fillSequence(_sequence, 3);
			PagedSequenceTestHelper.setResourceLoaderCompletedByIndex(_sequence, 0); // removes loader at 0
			PagedSequenceTestHelper.setResourceLoaderFailedByIndex(_sequence, 0); // removes loader at 0

			assertFalse("Sequence did not fire COMPLETE", listener.sequenceCompleteReceived);

			PagedSequenceTestHelper.setResourceLoaderCompletedByIndex(_sequence, 0); // removes loader at 0

			assertTrue("Sequence has fired COMPLETE", listener.sequenceCompleteReceived);
		}

		public function testCompleteAllLoadersClearsMonitor() : void {
			PagedSequenceTestHelper.fillSequence(_sequence, 3);
			var item2 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(_sequence, 0) as TestLoader;
			var item3 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(_sequence, 1) as TestLoader;
			var item4 : TestLoader = PagedSequenceTestHelper.getResourceLoaderAt(_sequence, 2) as TestLoader;

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 0 items loaded", 0, _sequence.numItemsLoaded);
			assertEquals("Sequence has 0 items failed", 0, _sequence.numItemsFailed);
			assertEquals("Sequence progress is 0", 0, _sequence.progress);

			item2.notifyLoading();
			item2.notifyCompleteMock();

			item3.notifyLoading();
			item3.notifyFailureMock();

			item4.notifyLoading();
			item4.notifyCompleteMock();

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 2 items loaded", 2, _sequence.numItemsLoaded);
			assertEquals("Sequence has 1 items failed", 1, _sequence.numItemsFailed);
			assertEquals("Sequence progress is 1", 1, _sequence.progress);
			
			assertNull("No loader exists anymore", PagedSequenceTestHelper.getResourceLoaderAt(_sequence, 0));

			item2.notifyLoading();
			item2.notifyProgressMock(.4);

			item3.notifyLoading();
			item3.notifyProgressMock(.4);

			item4.notifyLoading();
			item4.notifyProgressMock(.4);

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
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				item3.status
			);

			assertEquals(
				"Loader has progress of .4",
				.4,
				item3.progress
			);

			assertEquals(
				"Loader status is loading",
				LoaderItemStatus.LOADING,
				item4.status
			);

			assertEquals(
				"Loader has progress of .4",
				.4,
				item4.progress
			);

			assertEquals("Sequence has 3 items", 3, _sequence.numItems);
			assertEquals("Sequence has 2 items loaded", 2, _sequence.numItemsLoaded);
			assertEquals("Sequence has 1 items failed", 1, _sequence.numItemsFailed);
			assertEquals("Sequence progress is 1", 1, _sequence.progress);
			
		}

		public function testFailAllLoadersFiresComplete() : void {
			var listener : SequenceListener = new SequenceListener(_sequence);

			PagedSequenceTestHelper.fillSequence(_sequence, 3);
			PagedSequenceTestHelper.setResourceLoaderFailedByIndex(_sequence, 0); // removes loader at 0
			PagedSequenceTestHelper.setResourceLoaderFailedByIndex(_sequence, 0); // removes loader at 0

			assertFalse("Sequence did not fire COMPLETE", listener.sequenceCompleteReceived);

			PagedSequenceTestHelper.setResourceLoaderFailedByIndex(_sequence, 0); // removes loader at 0

			assertTrue("Sequence has fired COMPLETE", listener.sequenceCompleteReceived);
		}

		public function testCompleteAllLoadersFiresComplete() : void {
			var listener : SequenceListener = new SequenceListener(_sequence);

			PagedSequenceTestHelper.fillSequence(_sequence, 3);
			PagedSequenceTestHelper.setResourceLoaderCompletedByIndex(_sequence, 0);  // removes loader at 0
			PagedSequenceTestHelper.setResourceLoaderCompletedByIndex(_sequence, 0);  // removes loader at 0

			assertFalse("Sequence did not fire COMPLETE", listener.sequenceCompleteReceived);

			PagedSequenceTestHelper.setResourceLoaderCompletedByIndex(_sequence, 0);  // removes loader at 0

			assertTrue("Sequence has fired COMPLETE", listener.sequenceCompleteReceived);
		}

	}
}
