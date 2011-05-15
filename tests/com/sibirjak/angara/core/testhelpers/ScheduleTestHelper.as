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
package com.sibirjak.angara.core.testhelpers {

	import com.sibirjak.angara.core.Schedule;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.ISequenceManager;
	import com.sibirjak.angara.sequence.testhelpers.SequenceManagerMock;
	import com.sibirjak.angara.sequence.testhelpers.SequenceTestHelper;

	import org.as3commons.collections.ArrayList;
	import org.as3commons.collections.framework.IList;


	/**
	 * @author jes 16.02.2009
	 */
	public class ScheduleTestHelper {

		public static function scheduleResources(schedule : Schedule, numItems : uint) : IList {
			var list : IList = new ArrayList();
			for (var i : int = 0; i < numItems; i++) {
				var loader : IResourceLoader = CoreTestHelper.createResourceLoader();
				list.add(loader);
				schedule.add(loader);
			}
			return list;
		}

		public static function scheduleResource(schedule : Schedule) : IResourceLoader {
			var loader : IResourceLoader = CoreTestHelper.createResourceLoader();
			schedule.add(loader);
			return loader;
		}

		public static function fillAndScheduleSequence(schedule : Schedule, numItems : uint) : ISequence {
			var sequence : ISequence = SequenceTestHelper.createAndFillSequence(numItems);
			schedule.add(sequence);
			return sequence;
		}

		public static function fillAndScheduleSequenceManager(schedule : Schedule, numSequences : uint, numItems : uint) : ISequenceManager {
			var sequenceManager : ISequenceManager = new SequenceManagerMock();

			for (var i : int = 0; i < numSequences; i++) {
				var sequence : ISequence = SequenceTestHelper.createAndFillSequence(numItems);
				sequenceManager.add(sequence);
			}
			schedule.add(sequenceManager);
			return sequenceManager;
		}

	}
}
