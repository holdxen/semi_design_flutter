// 1:1 port of vs/editor/browser/gpu/rectangleRenderer.wgsl.ts
//
// `export const enum` -> class static const. The WGSL template literal keeps
// its `${...}` interpolations as Dart string interpolation with the same
// numeric binding ids.

/// 1:1: `export const enum RectangleRendererBindingId`
class RectangleRendererBindingId {
  static const int Shapes = 0;
  static const int LayoutInfoUniform = 1;
  static const int ScrollOffset = 2;
}

/// 1:1: `export const rectangleRendererWgsl`
const String rectangleRendererWgsl = '''
struct Vertex {
	@location(0) position: vec2f,
};

struct LayoutInfo {
	canvasDims: vec2f,
	viewportOffset: vec2f,
	viewportDims: vec2f,
}

struct ScrollOffset {
	offset: vec2f,
}

struct Shape {
	position: vec2f,
	size: vec2f,
	color: vec4f,
};

struct VSOutput {
	@builtin(position) position: vec4f,
	@location(1)       color:    vec4f,
};

// Uniforms
@group(0) @binding(${RectangleRendererBindingId.LayoutInfoUniform}) var<uniform>       layoutInfo:      LayoutInfo;

// Storage buffers
@group(0) @binding(${RectangleRendererBindingId.Shapes})            var<storage, read> shapes:          array<Shape>;
@group(0) @binding(${RectangleRendererBindingId.ScrollOffset})      var<uniform>       scrollOffset:    ScrollOffset;

@vertex fn vs(
	vert: Vertex,
	@builtin(instance_index) instanceIndex: u32,
	@builtin(vertex_index) vertexIndex : u32
) -> VSOutput {
	let shape = shapes[instanceIndex];

	var vsOut: VSOutput;
	vsOut.position = vec4f(
		(
			// Top left corner
			vec2f(-1,  1) +
			// Convert pixel position to clipspace
			vec2f( 2, -2) / layoutInfo.canvasDims *
			// Shape position and size
			(layoutInfo.viewportOffset - scrollOffset.offset + shape.position + vert.position * shape.size)
		),
		0.0,
		1.0
	);
	vsOut.color = shape.color;
	return vsOut;
}

@fragment fn fs(vsOut: VSOutput) -> @location(0) vec4f {
	return vsOut.color;
}
''';
