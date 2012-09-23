
//
// History:
//   Sep 19, 2012 tcolar Creation
//
using gfx

** Lighteight in memory image manipulation / drawing (Pure Fantom)
** With access to the in memory buffer and saving/loading functionalities
class Image302
{
  Size size
  // Data. Note: Color internally just uses a single int (argb), so fairly eficient
  Color[] pixels := [,]

  DrawingEnv env := DrawingEnv() 
  // Todo : antialiasing ??
  
  ** Creates an empty image
  ** See load() method to create from a file
  new make(Size size)
  {
    this.size = size
    // fill with transparent pixels
    pixels.fill(Color.makeArgb(0,0,0,0), size.w * size.h)
  }
  
  ** Change the current stroke color and thickness)
  ** Zero thickness means no stroke
  This stroke(Color color, Int thickness)
  {
    env.strokeColor = color
    env.strokeSize = thickness
    return this
  }
  
  ** Change the current fill color to be used when filling items
  This fill(Color color)
  {
    env.fillColor = color
    return this
  }
  
  ** tuen on / off antialiasing
  This aa(Bool val)
  {
    env.antiAliasing = val
    return this
  }
  
  ** Draw a pixel at x,y
  ** If color contains some alpha, blend it with the existing pixel color
  This pix(Point p, Color color)
  {
    if(p.x < 0 || p.y < 0 || p.x >= size.w || p.y >= size.h)
      return this// Out of bounds
    pixels[p.y * size.w + p.x] = blend(getPixel(p), color)
    return this
  }
  
  ** Draw a line with the current stroke
  This line(Point p1, Point p2)
  {
    LineShape(p1, p2).render(this, env)
    return this
  }
  
  ** Draw a rectangle with the current stroke.
  This rect(Rect r) 
  {
    // todo: antialias on the inside & outside edges
    fc := env.fillColor
    env.fillColor = env.strokeColor
    // 2 horiz bars
    filledRect(Rect(r.x, r.y, r.w, env.strokeSize))
    filledRect(Rect(r.x, r.y + r.h - env.strokeSize, r.w, env.strokeSize))
    // 2 ert bars
    filledRect(Rect(r.x, r.y + env.strokeSize, env.strokeSize, r.h - (env.strokeSize * 2)))
    filledRect(Rect(r.x + r.w - env.strokeSize, r.y + env.strokeSize, env.strokeSize, r.h - (env.strokeSize * 2)))
    env.fillColor = fc
    return this    
  }
  
  ** Draw a filled rectangle usng the fill color (no stroke used).
  This filledRect(Rect r)
  {
    // TODO: antialiasing on the outside edge ?
    (r.x ..< r.x + r.w).each |x|
    {
      (r.y ..< r.y + r.h).each |y|
      {
        pix(Point(x, y), env.fillColor)
      }
    }
    return this
  }

  ** Draw an oval with the current pen and brush.  The
  ** oval is fit within the rectangle specified by x, y, w, h.
  This oval(Rect r, Bool filled:=false) {throw Err("Not implemented")}

  ** A piece of oval ?
  This arc() {throw Err("Not implemented")} // part of an ellipse
  
  ** Draw a polygon ... link all the points together.
  This poly(Point[] points) 
  {
    Point? prev
    points[1 .. -1].each |point, index|
    {
      line(points[index], point)
    }
    line(points[-1], points[0])
    return this
  } 

  **
  ** Draw a the text string with the current brush and font.
  ** The x, y coordinate specifies the top left corner of
  ** the rectangular area where the text is to be drawn.
  **
  This text(Point p, Str s) 
  {
    // TODO : Render fonts ??
    // rendering ttf font is a huge pita ... maybe later
    // could render bmp fonts for now as a start
    throw Err("Not implemented")
  }
  
  Color? getPixel(Point p)
  {
    if(p.x < 0 || p.y < 0 || p.x >= size.w || p.y >= size.h)
      return null // Out of bounds
    return pixels[p.y * size.w + p.x]    
  }

  ** 
  ** Returns the unique colors used in this image
  ** CPU intensive as we scan the whole image to count colors
  ** If we hit max then we stop and return  
  Color[] colors(Int? max := null)
  {
    Color[] colors := [,]
    // scans the image to count colors
    pixels.eachWhile |color -> Int?|
    {
      if( ! colors.contains(color)) 
        colors.add(color)
      if(max != null && colors.size >= max)
        return 1 // continue
      return null
    }    
    return colors     
  }
  
  ** Save to a file
  Void save(File f, ImageFormat format, Str:Str options := [:])
  {
    out := f.out
    try
    {  
      format.save(out, this, options)
    }
    finally
    {
      out.close
    }          
  }
  
  static Image302 load(File f, ImageFormat format)
  {
    in := f.in
    try
    {  
      return format.load(in)
    }
    finally
    {
      in.close
    }          
  }
    
  ** fractional part of float
  internal Float floatPart(Float f) { f - f.floor }
  
  ** Alpha blending of 2 pixels
  ** Return the resulting (blended) pixel
  internal Color blend(Color curc, Color newc)
  {
    if(newc.a == 255 || curc.a == 0) 
      return newc
    if(newc.a == 0)
      return curc
    newa := newc.a / 255f  // alpha as a percentage (0 .. 1)
    a := curc.a == 255 ? 255 : (newc.a + curc.a * (1f - newa)).toInt
    r := (newc.r * newa + curc.r * (1f - newa)).toInt
    g := (newc.g * newa + curc.g * (1f - newa)).toInt
    b := (newc.b * newa + curc.b * (1f - newa)).toInt
    return Color.makeArgb(a.and(255), r.and(255), g.and(255), b.and(255))
  }
}