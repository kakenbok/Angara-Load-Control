package com.sibirjak.angara.core {

	import flexunit.framework.TestCase;

	import com.sibirjak.angara.core.testhelpers.CoreTestHelper;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.loaders.TestLoader;
	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.testhelpers.SequenceMock;


	/**
	 * @author jes 30.04.2009
	 */
	public class ConnectionPoolTest extends TestCase {

		private var _pool : ConnectionPool;

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			_pool = new ConnectionPool(5);
		}

		override public function tearDown() : void {
			_pool = null;
		}

		/**
		 * test initial state
		 */

		public function testInstantiated() : void {
			assertTrue("Schedule instantiated", _pool is ConnectionPool);
		}

		/**
		 * test items defining callback
		 */

		public function testNumFreeConnectionsReturnsZeroHavingCallbackItem() : void {
			
			assertEquals(
				"Pool has 5 free connections",
				5,
				_pool.numFreeConnections
			);
			
			var loader1 : IResourceLoader = CoreTestHelper.createResourceLoader();
			_pool.load([loader1]);
			
			assertEquals(
				"Pool has 4 free connections",
				4,
				_pool.numFreeConnections
			);

			var loader2 : IResourceLoader = CoreTestHelper.createResourceLoader();
			_pool.load([loader2]);

			assertEquals(
				"Pool has 3 free connections",
				3,
				_pool.numFreeConnections
			);

			var loader3 : IResourceLoader = CoreTestHelper.createResourceLoader();
			loader3.callbackFunction = new Function();
			_pool.load([loader3]);
			
			assertEquals(
				"Pool has 0 free connections since one of the connections defines a callback.",
				0,
				_pool.numFreeConnections
			);
			
			var loader4 : IResourceLoader = CoreTestHelper.createResourceLoader();
			_pool.load([loader4]);

			assertEquals(
				"Pool has 0 free connections since one of the connections defines a callback.",
				0,
				_pool.numFreeConnections
			);
			
			CoreTestHelper.setResourceLoaderCompleted(loader3);

			assertEquals(
				"Pool has 2 free connections",
				2,
				_pool.numFreeConnections
			);

			CoreTestHelper.setResourceLoaderCompleted(loader4);

			assertEquals(
				"Pool has 3 free connections",
				3,
				_pool.numFreeConnections
			);

		}

		/**
		 * test stop loading
		 */

		public function testStop() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);
			
			_pool.load([loader1, loader2, loader3, loader4, loader5]);
		
			assertEquals(
				"Pool has 0 free connections",
				0,
				_pool.numFreeConnections
			);
			
			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				loader3.status
			);

			_pool.clear();
		
			assertEquals(
				"Loader is waiting",
				LoaderItemStatus.WAITING,
				loader3.status
			);

			assertEquals(
				"Pool has 5 free connections",
				5,
				_pool.numFreeConnections
			);
		
		}

		public function testStopSingleLoader() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);
			
			_pool.load([loader1, loader2, loader3, loader4, loader5]);
		
			assertEquals(
				"Pool has 0 free connections",
				0,
				_pool.numFreeConnections
			);
			
			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				loader3.status
			);

			loader3.stop();
		
			assertEquals(
				"Loader is waiting",
				LoaderItemStatus.WAITING,
				loader3.status
			);

			assertEquals(
				"Pool has 1 free connection",
				1,
				_pool.numFreeConnections
			);
		
		}

		public function testStoppingSequenceStopsLoaders() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);
			
			var sequence : ISequence = new SequenceMock();
			sequence.add(loader2);
			sequence.add(loader3);
			sequence.add(loader5);

			_pool.load([loader1, loader2, loader3, loader4, loader5]);
		
			assertEquals(
				"Pool has 0 free connections",
				0,
				_pool.numFreeConnections
			);
			
			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				loader3.status
			);

			sequence.stop();
		
			assertEquals(
				"Loader is waiting",
				LoaderItemStatus.WAITING,
				loader3.status
			);

			assertEquals(
				"Pool has 3 free connections",
				3,
				_pool.numFreeConnections
			);
		
		}

		public function testRemovingItemFromSequence() : void {
			var loader1 : TestLoader = new TestLoader(1);
			var loader2 : TestLoader = new TestLoader(1);
			var loader3 : TestLoader = new TestLoader(1);
			var loader4 : TestLoader = new TestLoader(1);
			var loader5 : TestLoader = new TestLoader(1);
			
			var sequence : ISequence = new SequenceMock();
			sequence.add(loader2);
			sequence.add(loader3);
			sequence.add(loader5);

			_pool.load([loader1, loader2, loader3, loader4, loader5]);
		
			assertEquals(
				"Pool has 0 free connections",
				0,
				_pool.numFreeConnections
			);
			
			assertEquals(
				"Loader is loading",
				LoaderItemStatus.LOADING,
				loader3.status
			);

			sequence.remove(loader3);
		
			assertEquals(
				"Loader is waiting",
				LoaderItemStatus.WAITING,
				loader3.status
			);

			assertEquals(
				"Pool has 1 free connection",
				1,
				_pool.numFreeConnections
			);
		
		}

	}
}
