

module net
{

    import Loader = Laya.Loader;
	import Browser = Laya.Browser;
	import Handler = Laya.Handler;

    export class NetPB
    {
		private ProtoBuf:any = Browser.window.protobuf;

        static pb;
        public nested:any;
        public c2sjson;

        constructor()
        {
            // todo
            this.ProtoBuf.load("res/protobuf/msg.proto", this.onAssetsLoaded);
        }

        private onAssetsLoaded(err:any, root:any):void
        {
            if (err) {
                throw err;
            }
            
            this.nested = root.nested;

            var c2sjson:any = root.nested.c2sjson;

            var message:any = c2sjson.create(
			{
				code: 123,
                str: "this is a test for protobuff"
			});
            var buffer:any = c2sjson.encode(message).finish();

            var message2:any = c2sjson.decode(buffer);
            console.debug("code=" + message2.code);
            console.debug("str=" + message2.str);

            console.debug("加载协议文件完毕!");
        }
    }
}
