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
	import com.sibirjak.angara.resource.loaders.TestLoader;
	import com.sibirjak.angara.sequence.testhelpers.SequenceManagerListener;
	import com.sibirjak.angara.sequence.testhelpers.SequenceManagerMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceManagerTestHelper;
	import com.sibirjak.angara.sequence.testhelpers.SequenceMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceTestHelper;
	import com.sibirjak.utils.ArrayUtils;


	/**
	 * @author jes 14.05.2009
	 */
	public class SequenceManagerTest extends TestCase {
		
		private var _sequenceManager : SequenceManagerMock;

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			_sequenceManager = new SequenceManagerMock();
		}

		override public function tearDown() : void {
			_sequenceManager = null;
		}

		/**
		 * test initial state
		 */

		public function testInstantiated() : void {
			assertTrue("Sequence instantiated", _sequenceManager is ISequenceManager);
		}
	
		public function testSequenceIsInitallyEmpty() : void {
			assertEquals("Sequence is initially empty", 0, _sequenceManager.numItems);
		}

		/**
		 * test adding of sequences
		 */

		public function testAddingOfSequences() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence3 : ISequence = SequenceTestHelper.createAndFillSequence(1);

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence3);

			assertEquals("SequenceManager has 3 items", 3, _sequenceManager.numItems);
			
			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence1, sequence2, sequence3],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);
			
		}

		public function testAddingSequenceTwiceWillBeIgnored() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence1);

			assertEquals("SequenceManager has 2 items", 2, _sequenceManager.numItems);
			
			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence1, sequence2],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);
			
		}

		public function testAddingSequenceToMultipleManagersNotPossible() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);

			_sequenceManager.add(sequence1);

			var sequenceManager2 : ISequenceManager = new SequenceManager();

			sequenceManager2.add(sequence2);

			assertEquals("SequenceManager has 1 item", 1, sequenceManager2.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence2],
					SequenceManagerTestHelper.toArray(sequenceManager2)
				)
			);

			sequenceManager2.add(sequence1);

			assertEquals("SequenceManager2 has 1 item", 1, sequenceManager2.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence2],
					SequenceManagerTestHelper.toArray(sequenceManager2)
				)
			);

			_sequenceManager.remove(sequence1);

			sequenceManager2.add(sequence1);

			assertEquals("SequenceManager2 has 2 items", 2, sequenceManager2.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence2, sequence1],
					SequenceManagerTestHelper.toArray(sequenceManager2)
				)
			);

		}

		public function testAddingSequenceToCompletedManagersNotPossible() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);

			_sequenceManager.add(sequence1);

			assertEquals("SequenceManager has 1 item", 1, _sequenceManager.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence1],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);
			
			_sequenceManager.setStatus(LoaderItemStatus.COMPLETE);

			_sequenceManager.add(sequence2);

			assertEquals("SequenceManager has 1 item", 1, _sequenceManager.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence1],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

			_sequenceManager.setStatus(LoaderItemStatus.WAITING);

			_sequenceManager.add(sequence2);

			assertEquals("SequenceManager2 has 2 items", 2, _sequenceManager.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence1, sequence2],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

		}

		/**
		 * test removing of sequences
		 */

		public function testRemovingOfSequences() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence3 : ISequence = SequenceTestHelper.createAndFillSequence(1);

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence3);

			_sequenceManager.remove(sequence2);

			assertEquals("SequenceManager has 2 items", 2, _sequenceManager.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence1, sequence3],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

			_sequenceManager.remove(sequence1);

			assertEquals("SequenceManager has 1 item", 1, _sequenceManager.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence3],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

			_sequenceManager.remove(sequence3);

			assertEquals("SequenceManager empty", 0, _sequenceManager.numItems);

			assertTrue(
				"SequenceManager empty",
				ArrayUtils.arraysEqual(
					[],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

		}

		public function testRemovingWrongSequenceWillBeIgnored() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var sequence3 : ISequence = SequenceTestHelper.createAndFillSequence(1);

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);

			_sequenceManager.remove(sequence3);

			assertEquals("SequenceManager has 2 items", 2, _sequenceManager.numItems);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence1, sequence2],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

		}

		/**
		 * test clear
		 */

		public function testClearStopsAndRemovesItems() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(3);
			var item2 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0) as TestLoader;
			var item3 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 1) as TestLoader;
			var item4 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 2) as TestLoader;
			_sequenceManager.add(sequence1);
			
			assertEquals("SequenceManager has 3 items", 3, _sequenceManager.numItems);
			assertEquals("SequenceManager has 0 items loaded", 0, _sequenceManager.numItemsLoaded);
			assertEquals("SequenceManager has 0 items failed", 0, _sequenceManager.numItemsFailed);
			assertEquals("SequenceManager progress is 0", 0, _sequenceManager.progress);

			item2.notifyLoading();
			item2.notifyProgressMock(.4);

			item3.notifyLoading();
			item3.notifyCompleteMock();

			item4.notifyLoading();
			item4.notifyFailureMock();

			assertEquals("Sequence has 3 items", 3, sequence1.numItems);
			assertEquals("Sequence has 1 item loaded", 1, sequence1.numItemsLoaded);
			assertEquals("Sequence has 1 item failed", 1, sequence1.numItemsFailed);
			assertEquals("Sequence progress is 2.4/3", 2.4/3, sequence1.progress);

			assertEquals("SequenceManager has 3 items", 3, _sequenceManager.numItems);
			assertEquals("SequenceManager has 1 item loaded", 1, _sequenceManager.numItemsLoaded);
			assertEquals("SequenceManager has 1 item failed", 1, _sequenceManager.numItemsFailed);
			assertEquals("SequenceManager progress is 2.4/3", 2.4/3, _sequenceManager.progress);

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
			
			_sequenceManager.clear();

			assertEquals("SequenceManager has 0 items", 0, _sequenceManager.numItems);
			assertEquals("SequenceManager has 0 items loaded", 0, _sequenceManager.numItemsLoaded);
			assertEquals("SequenceManager has 0 items failed", 0, _sequenceManager.numItemsFailed);
			assertEquals("SequenceManager progress is 0", 0, _sequenceManager.progress);

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

			assertEquals("SequenceManager has 0 items", 0, _sequenceManager.numItems);
			assertEquals("SequenceManager has 0 items loaded", 0, _sequenceManager.numItemsLoaded);
			assertEquals("SequenceManager has 0 items failed", 0, _sequenceManager.numItemsFailed);
			assertEquals("SequenceManager progress is 0", 0, _sequenceManager.progress);

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
		 * test stop
		 */

		public function testStopSequenceManagerStopsAllSequences() : void {
			var sequence1 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var item1 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence1, 0) as TestLoader;
			item1.notifyLoading();

			var sequence2 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var item2 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence2, 0) as TestLoader;
			item2.notifyLoading();

			var sequence3 : ISequence = SequenceTestHelper.createAndFillSequence(1);
			var item3 : TestLoader = SequenceTestHelper.getResourceLoaderAt(sequence3, 0) as TestLoader;
			item3.notifyLoading();

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence3);

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				item1.status
			);
			
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

			_sequenceManager.stop();

			assertEquals(
				"Loader is loading",
				LoaderItemStatus.WAITING,
				item1.status
			);

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

		}

		public function testPauseResume() : void {
			var sequence1 : ISequence = new Sequence();
			
			_sequenceManager.add(sequence1);
			assertEquals("SequenceManagerStatus is WAITING", LoaderItemStatus.WAITING, _sequenceManager.status);

			_sequenceManager.pause();

			assertEquals("SequenceManagerStatus is PAUSED", LoaderItemStatus.PAUSED, _sequenceManager.status);

			_sequenceManager.resume();

			assertEquals("SequenceManagerStatus is WAITING", LoaderItemStatus.WAITING, _sequenceManager.status);
		}

		/**
		 * test changing sequence order
		 */

		public function testMovingSequenceToTheBegin() : void {
			var sequence1 : ISequence = new Sequence();
			var sequence2 : ISequence = new Sequence();
			var sequence3 : ISequence = new Sequence();
			var sequence4 : ISequence = new Sequence();

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence3);
			_sequenceManager.add(sequence4);

			_sequenceManager.loadBeforeOthers(sequence3);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence3, sequence1, sequence2, sequence4],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

			_sequenceManager.loadBeforeOthers(sequence2);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence2, sequence3, sequence1, sequence4],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

			_sequenceManager.loadBeforeOthers(sequence4);

			assertTrue(
				"Sequences in the same order as added",
				ArrayUtils.arraysEqual(
					[sequence4, sequence2, sequence3, sequence1],
					SequenceManagerTestHelper.toArray(_sequenceManager)
				)
			);

		}

		/**
		 * test event dispatching
		 */

		public function testSequenceFiresStopAndResumeEvents() : void {
			var listener : SequenceManagerListener = new SequenceManagerListener(_sequenceManager);

			var sequence1 : ISequence = new Sequence();
			var sequence2 : ISequence = new Sequence();
			var sequence3 : ISequence = new Sequence();

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence3);

			assertFalse("SequenceManager did not fire STOPPED", listener.sequenceManagerStoppedReceived);
			assertFalse("SequenceManager did not fire RESUME", listener.sequenceManagerResumedReceived);

			_sequenceManager.pause();

			assertTrue("SequenceManager has fired STOPPED", listener.sequenceManagerStoppedReceived);
			assertFalse("SequenceManager did not fire RESUME", listener.sequenceManagerResumedReceived);

			// prove that it sets back the receiving information
			assertFalse("SequenceManager did not fire STOPPED", listener.sequenceManagerStoppedReceived);

			_sequenceManager.resume();

			assertTrue("SequenceManager has fired RESUME", listener.sequenceManagerResumedReceived);
			assertFalse("SequenceManager did not fire STOPPED", listener.sequenceManagerStoppedReceived);
		}

		public function testCompleteAllSequencesFiresComplete() : void {
			var listener : SequenceManagerListener = new SequenceManagerListener(_sequenceManager);

			var sequence1 : SequenceMock = new SequenceMock();
			var sequence2 : SequenceMock = new SequenceMock();
			var sequence3 : SequenceMock = new SequenceMock();

			_sequenceManager.add(sequence1);
			_sequenceManager.add(sequence2);
			_sequenceManager.add(sequence3);

			sequence1.dispatchCompleteMock();
			sequence2.dispatchCompleteMock();

			assertFalse("SequenceManager did not fire COMPLETE", listener.sequenceManagerCompleteReceived);

			sequence3.dispatchCompleteMock();

			assertTrue("SequenceManager has fired COMPLETE", listener.sequenceManagerCompleteReceived);
		}

	}
}
