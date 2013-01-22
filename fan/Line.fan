// History:
//  Jan 21 13 tcolar Creation
//

using gfx

**
** Line
**
const class Line
{
  const Int x1
  const Int x2
  const Int y1
  const Int y2
  const Point p1
  const Point p2

  new make(Int x1, Int y1, Int x2, Int y2)
  {
    this.x1 = x1
    this.x2 = x2
    this.y1 = y1
    this.y2 = y2
    p1 = Point(x1, y1)
    p2 = Point(x2, y2)
  }

  new makePt(Point p1, Point p2)
  {
    this.p1 = p1
    this.p2 = p2
    x1 = p1.x
    x2 = p2.x
    y1 = p1.y
    y2 = p2.y
  }
}