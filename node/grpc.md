@grpc/grpc-js

1.proto 生成 js/ts 使用

```sh
cd ../../protos
npm install -g grpc-tools
grpc_tools_node_protoc --js_out=import_style=commonjs,binary:../node/static_codegen/ --grpc_out=grpc_js:../node/static_codegen helloworld.proto
grpc_tools_node_protoc --js_out=import_style=commonjs,binary:../node/static_codegen/route_guide/ --grpc_out=grpc_js:../node/static_codegen/route_guide/ route_guide.proto
```

```sh
cd ../../protos
npm install -g grpc-tools
npm i grpc_tools_node_protoc_ts
grpc_tools_node_protoc --plugin=protoc-gen-ts=../node/node_modules/.bin/protoc-gen-ts --ts_out=grpc_js:../node/static_codegen/route_guide  clog.proto
```

2.使用参考 grpc.io 官方文档
