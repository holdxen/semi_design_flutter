// 1:1 translation of monaco-lsp-client/src/index.ts
// Source:
//   import { MonacoLspClient, MonacoLspClientOptions } from './adapters/LspClient';
//   import { WebSocketTransport } from '@hediet/json-rpc-websocket';
//   import { createTransportToWorker, createTransportToIFrame } from '@hediet/json-rpc-browser';
//   export { MonacoLspClient, WebSocketTransport, createTransportToWorker, createTransportToIFrame };
//   export type { MonacoLspClientOptions };
//
// The three transport symbols come from unported external packages
// (@hediet/json-rpc-websocket / -browser). Per the established carrier
// convention they are re-exported as opaque function slots, preserving the
// exact public surface. The LSP client itself is a real re-export.
export 'adapters/LspClient.dart'
    show MonacoLspClient, MonacoLspClientOptions;

/// 1:1 carrier of `@hediet/json-rpc-websocket`'s `WebSocketTransport`.
/// Injected by consumers; no behavior is invented here.
Object? Function(Object? socket)? WebSocketTransport;

/// 1:1 carrier of `@hediet/json-rpc-browser`'s `createTransportToWorker`.
Object? Function(Object? worker)? createTransportToWorker;

/// 1:1 carrier of `@hediet/json-rpc-browser`'s `createTransportToIFrame`.
Object? Function(Object? iframe)? createTransportToIFrame;
