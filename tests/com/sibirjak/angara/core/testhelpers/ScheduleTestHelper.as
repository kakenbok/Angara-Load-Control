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
