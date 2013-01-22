//
// History:
//   Sep 21, 2012 tcolar Creation
//
using gfx

**
** Shape that supports anti aliasing
** Render will compute a list of intesting points to look at whne doing anti aliasing
** ie: Known edge pixels or at the minimum all modified pixels
**
mixin AaShape : Shape
{
  final override Void render(Image302 img, DrawingEnv env)
  {
    // the listener calculates and keeps only edge point along with their direct neighbors

    /*Int:Int points := [:] // location : count of painted neibors
    listener := |Point p|
    {
      (-1 .. 1).each | xstep |
      {
        (-1 .. 1).each | ystep |
        {
          x := p.x + xstep
          y := p.y + ystep
          if(x>=0 && y>=0 && x<img.size.w && y<img.size.h)
          {
            loc := y * img.size.w + x
            val := points[loc] ?: 0
            // 9 = painted point. +1 for other neighbor points
            val += (xstep==0 && ystep == 0) ? 9 : 1
            if (val >= 17)
            {
              // completely surounded point, so no neigbor could need aa, so removing from mem
              points.remove(loc)
              // paint it first
              img.pix(p, img.env.strokeColor)
            }
            else
            {
              points[loc] = val
            }
          }
        }
      }
    }*/

    //temp
    listener := |Point p| {img.pix(p, img.env.strokeColor)}

    aaRender(img, env, listener)

    // TODO: we are left with "edge" points and neigbbor points with an intensity indicator
    // we could use that to do some bluring (average))
    // or maybe better woud be to detect the "jaggies" in there and do something like the Wu antialiasing


    /*
    // Now we should be lef with a list of points that have neighbors but not completely surrounded
      points.each |count, location| {
      c := img.env.strokeColor
      Int? newa
      if(count <= 8)
      { // neighboor point
        newa = (((count / 8f))* c.a ).toInt
      }
      else
      { // actual point that has neighbors
        v := count - 8
        newa = (c.a * 0.7f).toInt //( (1f - (v / 10f))* c.a ).toInt
      }
      aaColor := Color.makeArgb(newa, c.r, c.g, c.b)
      y := location / img.size.w
      x := location % img.size.w
      img.pix(Point(x, y), aaColor)
    }*/
  }

  ** Renders the shape
  ** If img.env.antiAliasing is enbaled then for each modified point, a callback to pixelListener(point) MUST be made
  abstract Void aaRender(Image302 img, DrawingEnv env, |Point| pixelListener)
}