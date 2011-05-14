package {

	import com.sibirjak.angara.LoaderManagerTest;
	import com.sibirjak.angara.core.ConnectionPoolTest;
	import com.sibirjak.angara.core.PriorityMapTest;
	import com.sibirjak.angara.core.ScheduleTest;
	import com.sibirjak.angara.monitor.MonitorTest;
	import com.sibirjak.angara.resource.loaders.LoaderDelegateTest;
	import com.sibirjak.angara.resource.loaders.TestLoaderTest;
	import com.sibirjak.angara.resource.loaders.URLLoaderDelegateTest;
	import com.sibirjak.angara.sequence.PagedSequenceTest;
	import com.sibirjak.angara.sequence.SequenceManagerTest;
	import com.sibirjak.angara.sequence.SequenceTest;
	import com.sibirjak.angara.utils.ImageAssetLoaderTest;
	import flexunit.framework.TestSuite;


	/**
	 * @author jes 11.02.2009
	 */
	public class AllTests extends TestSuite {

		public function AllTests() {
			
			addTestSuite(URLLoaderDelegateTest);
			addTestSuite(ImageAssetLoaderTest);
			addTestSuite(TestLoaderTest);
			addTestSuite(LoaderDelegateTest);

			addTestSuite(MonitorTest);
			addTestSuite(SequenceTest);
			addTestSuite(SequenceManagerTest);
			addTestSuite(PagedSequenceTest);

			addTestSuite(ScheduleTest);
			addTestSuite(ConnectionPoolTest);
			addTestSuite(PriorityMapTest);

			addTestSuite(LoaderManagerTest);

		}

	}
}
