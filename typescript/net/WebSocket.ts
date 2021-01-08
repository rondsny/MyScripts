module net {
    import Browser = Laya.Browser;
    import Event = Laya.Event;
    import Socket = Laya.Socket;
    import Byte = Laya.Byte;

    export class WebSocket{

        private static _instance:WebSocket;
        private ws:Laya.Socket;
        private byte:Laya.Byte;


        public static getInstance(){
            if(!this._instance){
                this._instance = new WebSocket();
            }
            return this._instance;
        }
        constructor(){
            //发送二进制格式的数据
            this.byte = new Laya.Byte();
            this.byte.endian = Laya.Byte.LITTLE_ENDIAN;//小端

            this.ws = new Laya.Socket();
            this.ws.endian = Laya.Byte.LITTLE_ENDIAN;//小端

            this.ws.on(Laya.Event.MESSAGE, this, this.onMessage);
            this.ws.on(Laya.Event.OPEN, this, this.onOpen);
            this.ws.on(Laya.Event.CLOSE, this, this.onClose);
            this.ws.on(Laya.Event.ERROR, this, this.onError);
        }
        onMessage(message){
            console.log("WebSocket onMessage", message);
        }
        onOpen(event){
            console.log("WebSocket onOpen", event);
        }
        onClose(event){
            console.log("WebSocket onClose", event);
        }
        onError(error){
            console.log("WebSocket onError", error);
        }
        connect(host, port){
            if(!port){
                // ws://localhost:8989”
                this.ws.connectByUrl(host);
            }else{
                this.ws.connect(host, port);
            }
            return this;
        }
        close(){
            this.ws.close();
        }
        destroy(){
            this.ws.offAll();
            this.ws.cleanSocket();
            this.ws = null;
        }
        send(data){
            this.ws.send(data);
            return this;
        }
    }

}
