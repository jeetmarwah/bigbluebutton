package org.bigbluebutton.clientcheck.service
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;

	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;

	import org.bigbluebutton.clientcheck.model.ISystemConfiguration;

	public class PingService implements IPingService
	{
		private var _urlLoader:URLLoader;
		private var _urlRequest:URLRequest;

		private static var NUM_OF_TESTS:Number=5;
		private static var UNDEFINED:String="Undefined";
		private static var HTTP:String="http://";

		[Inject]
		public var systemConfiguration:ISystemConfiguration;

		public function init():void
		{
			_urlRequest=new URLRequest(HTTP + systemConfiguration.serverName);
			_urlLoader=new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, urlLoaderLoadCompleteHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderIoErrorHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderSecurityErrorHandler);
			_urlLoader.load(_urlRequest);

			systemConfiguration.pingTest.startTime=getTimer();
		}

		protected function urlLoaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			systemConfiguration.pingTest.testResult=UNDEFINED;
			systemConfiguration.pingTest.testSuccessfull=false;
		}

		protected function urlLoaderIoErrorHandler(event:IOErrorEvent):void
		{
			systemConfiguration.pingTest.testResult=UNDEFINED;
			systemConfiguration.pingTest.testSuccessfull=false;
		}

		protected function urlLoaderLoadCompleteHandler(event:Event):void
		{
			systemConfiguration.pingTest.endTime=getTimer();

			var totalTime:Number=(systemConfiguration.pingTest.endTime - systemConfiguration.pingTest.startTime);

			systemConfiguration.pingTest.testResultArray.push(totalTime);

			if (systemConfiguration.pingTest.testResultArray.length >= NUM_OF_TESTS)
			{
				calculateResults();
			}
			else
			{
				init();
			}
		}

		private function calculateResults():void
		{
			var totalResult:Number=0;

			for (var i:int=0; i < systemConfiguration.pingTest.testResultArray.length; i++)
			{
				totalResult+=systemConfiguration.pingTest.testResultArray[i];
			}

			var formatter:NumberFormatter=new NumberFormatter();
			formatter.precision=3;
			formatter.rounding=NumberBaseRoundType.NEAREST;

			var result:String=formatter.format(totalResult / systemConfiguration.pingTest.testResultArray.length);

			systemConfiguration.pingTest.testResult=result + " ms";
			systemConfiguration.pingTest.testSuccessfull=true;
		}
	}
}
