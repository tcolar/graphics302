
//
// History:
//   Sep 20, 2012 tcolar Creation
//
using gfx
using fwt

**
** Main
**
class Main
{
  Void main()
  {
    file := File(`/tmp/test.bmp`)
    img := Image302(Size(300,300))
    Color lblue := Color.makeArgb(100,0,0,255)
    Color lred := Color.makeArgb(100,255,0,0) 
    Color opurple := Color.makeArgb(200,255,0,255) 
    img.fill(Color.makeArgb(255,25,25,25)).filledRect(Rect(0,0,299,299))
    //img.stroke(Color.blue, 5).rect(Rect(2,2,295,295))
    img.aa(true)
    img.stroke(Color.green, 10).line(Point(200,90), Point(10,50))
    img.stroke(lblue, 30).line(Point(10,10), Point(100,200))
    img.aa(false)
    img.stroke(Color.green, 10).line(Point(200,190), Point(10,150))
    //img.stroke(lred, 3).poly([Point(50,50), Point(249, 50), Point(149, 200)]) // triangle
    //img.stroke(Color.white, 5).poly([Point(149,79), Point(199, 129), Point(149, 179), Point(99, 129)]) // diamond
    //img.fill(opurple).filledRect(Rect(30,150,150, 130))
    Bool alpha := false
    img.save(file, BmpFormat(), ["withAlpha" : alpha ? "true" : ""])
    w := Window {
      it.size = Size(500,500)
      i := Image(file)
      Label{image = i},
    } 
    w.open
  }
}