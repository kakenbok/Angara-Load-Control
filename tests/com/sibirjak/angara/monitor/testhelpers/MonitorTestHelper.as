package com.sibirjak.angara.monitor.testhelpers {

	import com.sibirjak.angara.core.testhelpers.CoreTestHelper;
	import com.sibirjak.angara.monitor.IMonitor;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.testhelpers.SequenceTestHelper;
	import org.as3commons.collections.ArrayList;
	import org.as3commons.collections.framework.IOrderedList;


	/**
	 * @author jes 16.02.2009
	 */
	public class MonitorTestHelper {

		/**
		 * loader related
		 */
		
		public static function createAndAddResourceLoaders(monitor : IMonitor, numItems : uint) : IOrderedList {
			var list : IOrderedList = new ArrayList();
			for (var i : int = 0; i < numItems; i++) {
				var loader : IResourceLoader = CoreTestHelper.createResourceLoader();
				list.add(loader);
				monitor.add(loader);
			}
			return list;
		}

		public static function createAndAddResourceLoader(monitor : IMonitor, weight : uint = 0) : IResourceLoader {
			var loader : IResourceLoader = CoreTestHelper.createResourceLoader();
			monitor.add(loader, weight);
			return loader;
		}

		public static function createFillAndAddSequence(monitor : IMonitor, numItems : uint, weight : uint = 0) : ISequence {
			var sequence : ISequence = SequenceTestHelper.createAndFillSequence(numItems);
			monitor.add(sequence, weight);
			return sequence;
		}

	}
}
