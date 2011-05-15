package com.sibirjak.angara.resource.loaders {

	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.resource.AbstractResourceLoader;
	import com.sibirjak.angara.resource.IDisplayAssetLoader;
	import com.sibirjak.angara.resource.IResourceLoaderContainer;
	import com.sibirjak.angara.resource.LoadingError;

	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;


	/**
	 * The TestLoader helps you visualising the loading behaviour of the application.
	 * 
	 * <p>Each TestLoader object is respresented by an internal NumberRect instance,
	 * which will be colourised depending on the items state.</p>
	 * 
	 * <p>There are various properties to set up a custom TestLoader.</p>
	 * 
	 * @author jes 04.05.2009
	 */
	public class TestLoader extends AbstractResourceLoader implements IDisplayAssetLoader {
		
		/**
		 * Event name for a click on the internal NumberRect.
		 */
		public static const EVENT_CLICK : String = "resource_loder_content_click";

		/**
		 * A loader of this type will always succeed.
		 */
		public static const TYPE_DEFAULT : String = "default";

		/**
		 * A loader of this type will fail returning a 404 status code.
		 * 
		 * <p>This simulates the Flash IOError.</p>
		 */
		public static const TYPE_404 : String = "404";

		/**
		 * A loader of this type will fail immediately after the load() method has been called.
		 * 
		 * <p>This simulates the Flash Security error when loading from a not permitted realm.</p>
		 */
		public static const TYPE_LOADING_PROHIBITED : String = "loading_prohibited";

		/**
		 * A loader of this type will fail with the first trial to access the loaded content.
		 * 
		 * <p>This simulates the Flash Security error when accessing content as data, which is not
		 * allowed by distributors permission.</p>
		 */
		public static const TYPE_ACCESS_PROHIBITED : String = "access_prohibited";
		
		/**
		 * A loader of this type will fail due to a missing progess over a specific time period.
		 */
		public static const TYPE_TIMEOUT : String = "timeout";
		
		/**
		 * The number value of the TestLoader, displayed within the NumberRect.
		 */
		private var _number : uint;

		/**
		 * The TestLoader type.
		 */
		private var _testLoaderType : String = TYPE_DEFAULT;

		/**
		 * The width of the NumberRect.
		 */
		private var _width : uint;

		/**
		 * The height of the NumberRect.
		 */
		private var _height : uint;
		
		/**
		 * The duration of loading in ms.
		 */
		private var _loadingDuration : uint;

		/**
		 * The steps of loading.
		 */
		private var _loadingSteps : uint;

		/**
		 * Internal timer to advance the loading progress.
		 */
		private var _timer : Timer;

		/**
		 * The container the loaded content should be added to.
		 */
		private var _container : Sprite;

		/**
		 * The loader visualisation object.
		 */
		private var _numberRect : NumberRect;
		
		/**
		 * A timer to simulate different loading durations due to network latencies.
		 */
		private var _startTimer : Timer;

		/**
		 * Creates a new TestLoader.
		 * 
		 * @param number The value of the TestLoader instance.
		 * @param width The width of the visualisating NumberRect.
		 * @param height The height of the visualisating NumberRect.
		 * @param loadingDuration The duration of loading.
		 * @param loadingDuration The steps of loading.
		 */
		public function TestLoader(
			number : uint, width : uint = 21, height : uint = 8,
			loadingDuration : uint = 25, loadingSteps : uint = 1
		) {
			super(new URLRequest(number.toString()));

			_number = number;
			_width = width;
			_height = height;
			_loadingDuration = loadingDuration ? loadingDuration : 25;
			_loadingSteps = loadingSteps ? loadingSteps : 1;
			
			var delay : Number = _loadingDuration / _loadingSteps;

			_timer = new Timer(delay, _loadingSteps);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);

			_numberRect = new NumberRect(this, _number, _width, _height);
			
			var startDelay : uint = Math.floor(Math.random() * _loadingDuration);
			_startTimer = new Timer(startDelay, 1);
			_startTimer.addEventListener(TimerEvent.TIMER, startTimerAfterDelay);
		}
		
		/*
		 * IDisplayAssetLoader
		 */
		
		/**
		 * @inheritDoc
		 */
		public function set container(container : Sprite) : void {
			_container = container;
			if (_container is IResourceLoaderContainer) {
				IResourceLoaderContainer(_container).addLoadedContent(_numberRect);
			} else {
				_container.addChild(_numberRect);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get container() : Sprite {
			return _container;
		}

		/**
		 * @inheritDoc
		 */
		override protected function startLoading() : void {
			if (_testLoaderType == TYPE_LOADING_PROHIBITED) {
				notifyFailure(LoadingError.LOADING_DENIED, "Security error. Loading resource not permitted!");
				return;
			}
			
			_startTimer.start();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function clear() : Boolean {
			resetTimer();

			return true;
		}

		/*
		 * TestLoader properties
		 */

		/**
		 * Specifies a test loader type.
		 * 
		 * <p>Default: A succeeding loader.</p>
		 */
		public function set loaderType(type : String) : void {
			_testLoaderType = type;
		}

		/*
		 * ResourceLoader status manipulation
		 */

		/**
		 * Manipulates the loader's status.
		 * 
		 * <p>Usage in unit tests.</p>
		 * 
		 * @param status The status to set.
		 */
		public function setStatus(status : String) : void {
			_status = status;
		}

		/**
		 * Applies and dispatches a progress change.
		 * 
		 * <p>Usage in unit tests.</p>
		 * 
		 * @param progress The new progress.
		 */
		public function notifyProgressMock(progress : Number) : void {
			_progress = progress;
			dispatchProgress();
		}
		
		/**
		 * Completes the loader immediately.
		 * 
		 * <p>Usage in unit tests.</p>
		 */
		public function notifyCompleteMock() : void {
			_status = LoaderItemStatus.COMPLETE;
			_numItemsLoaded = 1;
			_progress = 1;
			dispatchComplete();
		}

		/**
		 * Fails the loader immediately.
		 * 
		 * <p>Usage in unit tests.</p>
		 */
		public function notifyFailureMock() : void {
			_status = LoaderItemStatus.FAILURE;
			_numItemsFailed = 1;
			_progress = 1;

			_loadingError = new LoadingError(LoadingError.ACCESS_DENIED, this);
			dispatchFailure();
		}
		
		/**
		 * Sets and dispatchs the status LoaderItemStatus.LOADING.
		 * 
		 * <p>Usage in unit tests.</p>
		 */
		public function notifyLoading() : void {
			_status = LoaderItemStatus.LOADING;
			dispatchLoading();
		}

		/**
		 * Info
		 */
		override public function toString() : String {
			return "[TestLoader] url:" + _request.url + " status: " + _status + " content:" + content;
		}
		
		/*
		 * Private
		 */

		/**
		 * Recalcurates status and progress with each timer event.
		 */
		private function timerHandler(event : TimerEvent) : void {
			if (_testLoaderType == TYPE_TIMEOUT) {
				return;
			}
			
			var count : int = _timer.currentCount;
			
			if (_testLoaderType == TYPE_404) {
				notifyHttpStatus(404);
				
				resetTimer();

				notifyFailure(LoadingError.FILE_NOT_FOUND, "File not found! " + _number);
				return;
			}

			notifyProgress(_loadingSteps * 100, count * 100);

			if (count == _loadingSteps) {
				_timer.stop();
				_timer.reset();

				notifyHttpStatus(200);

				resetTimer();

				if (_testLoaderType == TYPE_ACCESS_PROHIBITED) {
					notifyFailure(LoadingError.ACCESS_DENIED, "Security error. Accessing resource not permitted!" + _number);
				} else {
//					trace (this + " Resource complete");
					notifyComplete(_numberRect);
				}
				return;
			}
			
		}

		/**
		 * Resets both timers.
		 */
		private function resetTimer() : void {
			_startTimer.stop();
			_startTimer.reset();

			_timer.stop();
			_timer.reset();
		}

		/**
		 * Starts the loading timer after a delay.
		 */
		private function startTimerAfterDelay(event : TimerEvent) : void {
			_timer.start();
		}
	}
}

import com.sibirjak.angara.core.LoaderItemStatus;
import com.sibirjak.angara.resource.ResourceLoaderEvent;
import com.sibirjak.angara.resource.loaders.TestLoader;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;


/**
 * The TestLoader instanace visualisation.
 */
internal class NumberRect extends Sprite {
	private var _testLoader : TestLoader;
	
	private var _number : uint;

	private var _tf : TextField;
	private var _clickArea : Sprite;
	
	private var _width : uint;
	private var _height : uint;
	
	public function NumberRect(testLoader : TestLoader, number : uint, width : uint, height : uint) {
		_testLoader = testLoader;
		
		_testLoader.addEventListener(ResourceLoaderEvent.LOADING, loaderEventHandler);
		_testLoader.addEventListener(ResourceLoaderEvent.STOP, loaderEventHandler);
		_testLoader.addEventListener(ResourceLoaderEvent.PAUSE, loaderEventHandler);
		_testLoader.addEventListener(ResourceLoaderEvent.RESUME, loaderEventHandler);
		_testLoader.addEventListener(ResourceLoaderEvent.PROGRESS, loaderEventHandler);
		_testLoader.addEventListener(ResourceLoaderEvent.INIT, loaderEventHandler);
		_testLoader.addEventListener(ResourceLoaderEvent.COMPLETE, loaderEventHandler);
		_testLoader.addEventListener(ResourceLoaderEvent.FAILURE, loaderEventHandler);
		

		_number = number;
		_width = width;
		_height = height;

		createChildren();

		addEventListener(MouseEvent.CLICK, clickHandler);

		draw();
		
	}
	
	private function clickHandler(event : MouseEvent) : void {
		dispatchEvent(new ResourceLoaderEvent(TestLoader.EVENT_CLICK, _testLoader));
	}

	private function loaderEventHandler(event : ResourceLoaderEvent) : void {
		draw();
		
		if (event.type == ResourceLoaderEvent.COMPLETE
			|| event.type == ResourceLoaderEvent.FAILURE
		) {
			_testLoader.removeEventListener(ResourceLoaderEvent.LOADING, loaderEventHandler);
			_testLoader.removeEventListener(ResourceLoaderEvent.STOP, loaderEventHandler);
			_testLoader.removeEventListener(ResourceLoaderEvent.PROGRESS, loaderEventHandler);
			_testLoader.removeEventListener(ResourceLoaderEvent.INIT, loaderEventHandler);
			_testLoader.removeEventListener(ResourceLoaderEvent.COMPLETE, loaderEventHandler);
			_testLoader.removeEventListener(ResourceLoaderEvent.FAILURE, loaderEventHandler);

			_testLoader.removeEventListener("resource_pause", loaderEventHandler);
			_testLoader.removeEventListener("resource_resume", loaderEventHandler);
			_testLoader = null;
		}
	}

	private function createChildren() : void {
		var textFormat : TextFormat = new TextFormat();
		textFormat.font = "Arial";
		textFormat.size = 7;

		_tf = new TextField();
		_tf.textColor = 0xFFFFFF;
		_tf.autoSize = TextFieldAutoSize.LEFT;
		_tf.wordWrap = false;
		_tf.selectable = false;
		_tf.defaultTextFormat = textFormat;
		
		_tf.text = _number.toString();
		_tf.x = 0;
		_tf.y = -1;
		
		addChild(_tf);
		
		_clickArea = new Sprite();
		_clickArea.graphics.beginFill(0x000000, 0);
		_clickArea.graphics.drawRect(1, 1, _width, _height);
		_clickArea.buttonMode = true;
		_clickArea.useHandCursor = true;
		
		addChild(_clickArea);

	}

	public function draw() : void {
		graphics.clear();
		
		var color : Number;
		
		switch (_testLoader.status) {
			case LoaderItemStatus.WAITING:
				color = 0x99FF99;
				break;
			case LoaderItemStatus.LOADING:
				color = 0x00CC00;
				break;
			case LoaderItemStatus.PAUSED:
				color = 0xCCCCCC;
				break;
			case LoaderItemStatus.COMPLETE:
				color = 0x0000FF;
				break;
			case LoaderItemStatus.FAILURE:
				color = 0xFF0000;
				break;
		}

		graphics.beginFill(color);
		graphics.drawRect(1, 1, _width, _height);
	}
	
}