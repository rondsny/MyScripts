
module net {
    export class Protobuf {
        /**
         * 单例模式
        */
        private static _instance: Protobuf;
        public static getInstance(): Protobuf {
            if (!this._instance) {
                this._instance = new Protobuf();
            }
            return this._instance;
        }
        private constructor() { }

        /**
         * 获取protobuf文件中的消息类
         * @param protoUrl {string} protobuf文件地址
         * @param messageName {string} 消息类名
         * @param callback {Function} 回调函数
         * @param thisObj {any} this对象
         */
        public getMessage(protoUrl: string, messageName: string, callback: Function, thisObj: any = null): void {
            let pb = Laya.Browser.window.protobuf;
            if (!pb) {
                throw Error("your browser is not support protobufjs");
            }
            pb.load(protoUrl, (error, root) => {
                if (error) {
                    throw error;
                }
                let messageClass = root.lookup(messageName);
                callback && callback.apply(thisObj, [messageClass]);
            });
        }
        /**
            * 创建消息
            * @param messageClass {Message} 消息类
            * @param data {object} 消息字段集合
            */
        public create(messageClass, data: Object) {
            return messageClass.create(data);
        }
        /**
            * 消息验证
            * @param messageClass {Message} 消息类
            * @param message {Object} 验证消息
            */
        public verify(messageClass, message) {
            let errmsg = messageClass.verify(message);
            if (errmsg) {
                throw new Error(errmsg);
            }
        }
        /**
            * 序列化编码生成protobuf
            * @param messageClass {Meesage} 消息类
            * @param message {object} 消息
            */
        public encode(messageClass, message) {
            return messageClass.encode(message).finish();
        }
        /**
            * 反序列化解码生成对象
            * @param messageClass {Message} 消息类
            * @param buffer {} protobuf
            */
        public decode(messageClass, buffer) {
            return messageClass.decode(buffer);
        }
    }
}
