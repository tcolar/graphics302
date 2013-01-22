
//
// History:
//   Sep 19, 2012 tcolar Creation
//
using gfx

**
** BmpFormat
** Save and load images in Bitmap format
** While it's a "dated" format it's easy to use and widely supported
**
class BmpFormat  : ImageFormat
{
  override Str contentType() {"image/bmp"}

  ** If opts["withAlpha"] == "true" then the image will be saved in 32 bits mode (only mode that supports alpha)
  ** Otherwise it will automatically save in the most compact format possible (with palette if < 256 colors)
  ** No compression is used but this could be saved into a ZipStream for pretty effective compression
  override Void save(OutStream out, Image302 img, Str:Str options := [:])
  {
    // BMP uses little Endian
    out.endian = Endian.little

    Bool withAlpha := options["withAlpha"]?.equals("true") ?: false

    // 1) Determining palette need and size

    Color[] colors := [,]
    Int paletteSize := 0 // size of palette in bytes (0, 8, 16, 64 or 1024) - 0 means no palette used.
    imgSize := img.size
    if( ! withAlpha)
    {
      colors = img.colors(256)
      // If we have more than 255 colors, won't use a palette (not worth it)
      // each palette entry(RGBQUAD) is 4 bytes (Blue, Green, Red, 0);
      if(colors.size > 255) {colors.clear}
        else if(colors.size <=2) {paletteSize = 8}
        else if(colors.size <= 4) {paletteSize = 16}
        else if(colors.size <= 16) {paletteSize = 64}
        else if(colors.size <= 256) {paletteSize = 1024}
      }
    fileSize := FILE_HEADER_SIZE + BITMAP_HEADER_SIZE
    fileSize += paletteSize
    //echo("palette size: $paletteSize")

    // 2) Determining total file size

    Int bitsPerPix := 0 // NOTE -> in BITS NOT BYTES
    if(paletteSize == 0) {bitsPerPix = 32} // 32 bits per pixel : RGBA
      else if(paletteSize == 8) {bitsPerPix = 1} // 1 bit per pixel
      else if(paletteSize == 64) {bitsPerPix = 4} // 4 bits per pixel
      else if(paletteSize == 1024) {bitsPerPix = 8} // 8 bits per pixels
      // row size need to be multiple of 4, according to BMP spec
    rowSize := imgSize.w * bitsPerPix / 8 // in bytes
    if(rowSize < 4)
      rowSize = 4
    while(rowSize % 4 != 0)
      rowSize++
    dataSize := rowSize * imgSize.h
    fileSize += dataSize

    // 3) Saving data
    dataOffset := FILE_HEADER_SIZE + BITMAP_HEADER_SIZE + paletteSize

    writeHeader(out, fileSize, dataOffset, bitsPerPix, imgSize)

    palette := writePalette(out, paletteSize, colors)

    writePixels(out, img, palette, bitsPerPix, withAlpha)
  }

  override Image302 load(InStream in)
  {
    return Image302(Size(200, 200))
    // TODO: load in the data
  }

  ** Bitmap header
  internal Void writeHeader(OutStream out, Int fileSize, Int dataOffset, Int bitsPerPix, Size imgSize)
  {
    out.write(0x42) // B (bitmap signature)
    out.write(0x4D) // M (bitmap signature)
    out.writeI4(fileSize) //file size
    out.writeI4(0) // Empty 4 bytes (according to spec)
    out.writeI4(dataOffset) // bitmap data offest (after palette)
    out.writeI4(40) // header size : (std = 40)
    out.writeI4(imgSize.w)// image width
    out.writeI4(imgSize.h)// image height
    out.writeI2(1)// nb of planes (1=default)
    out.writeI2(bitsPerPix) // pixel size (bit count)
    out.writeI4(0) //compression (0 = none)
    out.writeI4(0) // size of image (leave at 0 for auto)
    out.writeI8(0) //pixelPerMeter stuff (not needed)
    out.writeI4(0) // biclrused (0 = use bit count)
    out.writeI4(0) // important colors (0=all)
  }

  ** Write the actual palette
  ** (RGBSQUAD):  Blue/Green/Red/0
  internal [Color:Int]? writePalette(OutStream out, Int paletteSize, Color[] colors)
  {
    if(paletteSize == 0)
      return null
    Color:Int palette := [:]
    colors.each |color|
    {
      index := palette[color]
      if(index == null)
      {
        index = palette.size
        palette[color] = index
      }
      // WARNING: not the usual RGB but instead BGR0 !
      out.write(color.b)
      out.write(color.g)
      out.write(color.r)
      out.write(0)
    }
    // pad the rest of the palette with zeroes
    (colors.size ..< paletteSize / 4).each {out.writeI4(0);}

    return palette
  }

  internal Void writePixels(OutStream out, Image302 img, [Color:Int]? palette, Int bitsPerPix, Bool withAlpha)
  {
    size := img.size
    Int cpt := 0;
    Int bitCount := 0
    Int byte := 0
    // Note: BMP stores the lines bottom up
    (size.h .. 1).each |y| {
      (1 .. size.w).each |x| {
        pixel := img.getPixel(Point(x - 1, y - 1))
        if(bitsPerPix == 32)
        {
          // No palette, direclty write RGBA color data
          out.write(pixel.b)
          out.write(pixel.g)
          out.write(pixel.r)
          out.write(withAlpha ? pixel.a : 255); cpt++
        }
        else
        {
          // use palette
          index := palette[pixel]
          byte = byte.shiftl(bitsPerPix) + index
          bitCount += bitsPerPix
          if(bitCount >= 8)
          {
            // write complete byte
            out.write(byte); cpt++
            bitCount = 0; byte = 0
          }
        }
      }
      // write any leftover uncomplete byte
      if(bitCount!=0)
      {
        out.write(byte.shiftl(8 - bitCount)); cpt++
        bitCount = 0; byte = 0
      }
      // padd the lines to be multiple of 4 bytes as defined by spec
      while(cpt % 4 != 0)
      {
        out.write(0); cpt++
      }
    }
  }

  internal static const Int FILE_HEADER_SIZE := 14
  internal static const Int BITMAP_HEADER_SIZE := 40
}