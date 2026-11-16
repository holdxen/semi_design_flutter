import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String _status = '选择文件 / 上传进度 / 失败重试，事件写入此行。';
  final List<String> _events = [];

  // 受控 fileList。
  List<SemiUploadFile> _controlled = const [
    SemiUploadFile(uid: 'c1', name: 'controlled.png', size: 20480),
  ];

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

  static Widget _thumb(Color color) =>
      SizedBox(width: 96, height: 96, child: ColoredBox(color: color));

  Future<List<SemiUploadFile>> _pickBasic() async => [
    SemiUploadFile(
      name: 'photo-${DateTime.now().millisecondsSinceEpoch % 1000}.png',
      size: 120 * 1024,
      isImage: true,
      thumbnail: _thumb(const Color(0xFF7FB2FF)),
    ),
    SemiUploadFile(name: 'document.pdf', size: 8 * 1024),
  ];

  Future<List<SemiUploadFile>> _pickValidated() async => [
    SemiUploadFile(name: 'ok.png', size: 512 * 1024, isImage: true),
    SemiUploadFile(name: 'wrong.jpg', size: 100 * 1024, isImage: true),
    SemiUploadFile(name: 'huge.png', size: 4096 * 1024, isImage: true),
  ];

  Future<List<SemiUploadFile>> _pickRetry() async => [
    SemiUploadFile(name: 'ok.png', size: 1024, isImage: true),
    SemiUploadFile(name: 'fail.err', size: 1024),
  ];

  Future<List<SemiUploadFile>> _pickPicture() async => [
    SemiUploadFile(
      name: 'new-picture.png',
      size: 64 * 1024,
      isImage: true,
      thumbnail: _thumb(const Color(0xFFFFC38A)),
    ),
  ];

  /// 模拟请求：50ms 到 50%，120ms 成功；`*.err` 失败。
  void _request(SemiUploadRequestArgs args) {
    _push('request ${args.file.name}');
    Future<void>.delayed(const Duration(milliseconds: 60)).then((_) {
      if (args.file.name.endsWith('.err')) {
        args.onError('boom', '网络错误');
        return;
      }
      args.onProgress(50);
    });
    Future<void>.delayed(const Duration(milliseconds: 140)).then((_) {
      if (args.file.name.endsWith('.err')) {
        return;
      }
      args.onSuccess({'name': args.file.name});
    });
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      child,
      const SizedBox(height: 12),
    ],
  );

  static final List<SemiUploadFile> _pictureSeeds = [
    SemiUploadFile(
      uid: 'p1',
      name: 'seed-1.png',
      size: 32 * 1024,
      isImage: true,
      status: SemiUploadFileStatus.success,
      thumbnail: _thumb(const Color(0xFF9BE0C0)),
    ),
    SemiUploadFile(
      uid: 'p2',
      name: 'seed-2.png',
      size: 48 * 1024,
      isImage: true,
      status: SemiUploadFileStatus.success,
      thumbnail: _thumb(const Color(0xFFFFB4C0)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              child: SemiText(_status, key: const ValueKey('upload-status')),
            ),
          ),
          const SizedBox(height: 24),
          _section('基础列表', [
            _demo(
              '自定义触发（children）+ onPickFiles 返回文件；onRequest 模拟进度→成功；'
              '列表卡：预览/名称/尺寸/进度条/关闭；onChange 逐文件回调',
              SizedBox(
                width: 560,
                child: SemiUpload(
                  key: const ValueKey('upload-basic'),
                  action: '/api/upload',
                  onPickFiles: _pickBasic,
                  onRequest: _request,
                  onChange: (info) => _push(
                    'onChange ${info.currentFile?.name ?? info.fileList.length}',
                  ),
                  onProgress: (percent, file, list) =>
                      _push('onProgress ${file.name} $percent'),
                  onRemove: (file, list) => _push('onRemove ${file.name}'),
                  onClear: (list) => _push('onClear'),
                  children: const SemiButton('上传文件'),
                ),
              ),
            ),
            _demo(
              'accept: .png + maxSize: 1024KB + limit: 3 — 类型/尺寸/数量校验'
              '（wrong.jpg 触发 onAcceptInvalid；huge.png 尺寸非法入表但不请求）',
              SizedBox(
                width: 560,
                child: SemiUpload(
                  key: const ValueKey('upload-validated'),
                  accept: '.png',
                  maxSize: 1024,
                  limit: 3,
                  onPickFiles: _pickValidated,
                  onRequest: _request,
                  onAcceptInvalid: (files) => _push(
                    'onAcceptInvalid ${files.map((f) => f.name).join(',')}',
                  ),
                  onSizeError: (file, list) =>
                      _push('onSizeError ${file.name}'),
                  onExceed: (files) => _push('onExceed ${files.length}'),
                  children: const SemiButton('上传（校验）'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('拖拽区域', [
            _demo(
              'dragArea: true — 虚线区域 + 上传图标 + 主/副文案；hover 底色/边框变'
              'primary；点击仍可选择（OS 拖拽未移植，dragAreaStatus 可驱动提示）',
              SizedBox(
                width: 560,
                child: SemiUpload(
                  key: const ValueKey('upload-drag'),
                  dragArea: true,
                  dragMainText: '点击或拖拽文件到此处',
                  dragSubText: '支持 png / pdf，单个不超过 2MB',
                  onPickFiles: _pickBasic,
                  onRequest: _request,
                ),
              ),
            ),
            _demo(
              'dragAreaStatus: legal — 显示「松手开始上传」提示（由使用方驱动）',
              SizedBox(
                width: 560,
                child: SemiUpload(
                  key: const ValueKey('upload-drag-legal'),
                  dragArea: true,
                  dragAreaStatus: SemiUploadDragAreaStatus.legal,
                  onPickFiles: _pickBasic,
                  onRequest: _request,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('失败与重试', [
            _demo(
              'fail.err 请求失败 → 卡片失败底色 + 「网络错误」+ 重试；点击重试'
              '再次请求；onError/onRetry 回传',
              SizedBox(
                width: 560,
                child: SemiUpload(
                  key: const ValueKey('upload-retry'),
                  onPickFiles: _pickRetry,
                  onRequest: _request,
                  onError: (error, file, list) =>
                      _push('onError ${file.name} $error'),
                  onRetry: (file) => _push('onRetry ${file.name}'),
                  children: const SemiButton('上传（可失败）'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('图片墙', [
            _demo(
              'listType: picture + showPicInfo + showReplace — 96×96 卡片、hover '
              '出关闭/替换/预览、上传中圆形进度、底部序号条；add 卡虚线边框',
              SemiUpload(
                key: const ValueKey('upload-picture'),
                listType: SemiUploadListType.picture,
                showPicInfo: true,
                showReplace: true,
                defaultFileList: _pictureSeeds,
                onPickFiles: _pickPicture,
                onRequest: _request,
                onPreviewClick: (file) => _push('onPreview ${file.name}'),
                onRemove: (file, list) => _push('onRemove ${file.name}'),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('受控与自定义渲染', [
            _demo(
              'fileList 受控（onChange 回写 state；外部按钮清空）+ renderFileItem '
              '自定义条目',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SemiButton(
                        '外部清空',
                        onPressed: () => setState(() => _controlled = const []),
                      ),
                      const SizedBox(width: 8),
                      SemiButton(
                        '重置',
                        onPressed: () => setState(
                          () => _controlled = const [
                            SemiUploadFile(
                              uid: 'c1',
                              name: 'controlled.png',
                              size: 20480,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 560,
                    child: SemiUpload(
                      key: const ValueKey('upload-controlled'),
                      fileList: _controlled,
                      onChange: (info) {
                        _push('onChange ${info.fileList.length}');
                        setState(() => _controlled = info.fileList);
                      },
                      onPickFiles: _pickBasic,
                      onRequest: _request,
                      children: const SemiButton('上传（受控）'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 560,
                    child: SemiUpload(
                      key: const ValueKey('upload-custom-item'),
                      onPickFiles: _pickBasic,
                      onRequest: _request,
                      defaultFileList: const [
                        SemiUploadFile(
                          uid: 'i1',
                          name: 'custom.png',
                          size: 1024,
                        ),
                      ],
                      renderFileItem: (props) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SemiText(
                          '自定义条目 · ${props.file.name} · ${props.file.size} B',
                        ),
                      ),
                      children: const SemiButton('上传（自定义条目）'),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('禁用与根级校验', [
            _demo(
              'disabled: true + validateMessage — 触发/删除禁用，根级校验红字',
              SizedBox(
                width: 560,
                child: SemiUpload(
                  key: const ValueKey('upload-disabled'),
                  disabled: true,
                  validateMessage: '至少上传一个文件',
                  defaultFileList: const [
                    SemiUploadFile(uid: 'd1', name: 'locked.png', size: 1024),
                  ],
                  children: const SemiButton('上传（禁用）'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('RTL', [
            _demo(
              'Directionality.rtl — 列表内边距/关闭按钮/图片墙定位镜像',
              const SizedBox(
                width: 560,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SemiUpload(
                    key: ValueKey('upload-rtl'),
                    listType: SemiUploadListType.picture,
                    defaultFileList: [
                      SemiUploadFile(
                        uid: 'r1',
                        name: 'rtl.png',
                        size: 1024,
                        status: SemiUploadFileStatus.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
