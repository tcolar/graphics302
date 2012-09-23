//
// History:
//   Sep 19, 2012 tcolar Creation
//
using gfx

**
** Implementations provides import/export functionalities for a specific image format
**
mixin ImageFormat
{
  abstract Void save(OutStream out, Image302 img, Str:Str options := [:])
    
  abstract Image302 load(InStream in)  
  
  abstract Str contentType()
}