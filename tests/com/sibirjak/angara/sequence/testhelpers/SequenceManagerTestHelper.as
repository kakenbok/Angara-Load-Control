package com.sibirjak.angara.sequence.testhelpers {

	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.ISequenceManager;

	import org.as3commons.collections.framework.IIterator;


	/**
	 * @author jes 14.05.2009
	 */
	public class SequenceManagerTestHelper {

		public static function toArray(sequenceManager : ISequenceManager) : Array {
			var iterator : IIterator = sequenceManager.iterator();
			var sequences : Array = new Array();
			while (iterator.hasNext()) {
				sequences.push(iterator.next());
			}
			return sequences;
		}

		public static function getSequenceAt(sequenceManager : ISequenceManager, index : uint) : ISequence {
			var iterator : IIterator = sequenceManager.iterator();
			var i : uint = 0;
			while (iterator.hasNext()) {
				var sequence : ISequence = iterator.next() as ISequence;
				if (i == index) return sequence;
				i++;
			}
			return null;
		}

	}
}
