
//
// History:
//   Sep 21, 2012 tcolar Creation
//
using gfx

**
** LineShape
**
internal class LineShape : AaShape
{
  Point p1
  Point p2

  new make(Line line)
  {
    this.p1 = line.p1
    this.p2 = line.p2
  }

  override Void aaRender(Image302 img, DrawingEnv env, |Point| listener)
  {
    aaOn := env.antiAliasing

    dx := (p2.x - p1.x).abs
    dy := (p2.y - p1.y).abs
    //echo("$dx - $dy")
    (1 .. env.strokeSize).each
    {
      // thickness offset
      thickOff := it / 2; thickOff = it.isEven ? thickOff : -thickOff
      //thickOff := it
      np1 := dx>dy ? Point(p1.x, p1.y + thickOff) : Point(p1.x + thickOff, p1.y)
      np2 := dx>dy ? Point(p2.x, p2.y + thickOff) : Point(p2.x + thickOff, p2.y)

      //echo("($np1.x,$np1.y) - ($np2.x,$np2.y)")
      sx := np1.x < np2.x ? 1 : -1
      sy := np1.y < np2.y ? 1 : -1

      x := np1.x
      y := np1.y

      err := dx - dy

      while (true)
      {
        p := Point(x, y)

        if(aaOn)
          listener(p)
        else
          img.pix(p, env.strokeColor)

        if (x == np2.x && y == np2.y) {
          break // done
        }

        e2 := 2 * err
        if (e2 > -dy)
        {
          err -= dy; x += sx
        }
        if (e2 < dx)
        {
          err += dx; y += sy
        }
      }
    }
  }
}