
//
// History:
//   Sep 19, 2012  tcolar  Creation
//
using build

**
** Build: graphics302
**
class Build : BuildPod
{
  new make()
  {
    podName = "graphics302"
    summary = "Fantom image manipulation utilities. In memory image drawing (pure fantom). Loading/saving images."
    depends = ["sys 1.0", "gfx 1.0", "fwt 1.0"]
    srcDirs = [`fan/`, `test/`, `fan/formats/`, `fan/aa/`, `fan/shapes/`]
  }
}
