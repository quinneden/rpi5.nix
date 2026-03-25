{ pkgs, ... }:

{
  console.earlySetup = true;
  console.font = pkgs.terminus_font + "/share/consolefonts/ter-u16n.psf.gz";
  console.colors = [
    "000000"
    "06989A"
    "3465A4"
    "34E2E2"
    "4E9A06"
    "555753"
    "739FCF"
    "75507B"
    "8AE234"
    "AD7FA8"
    "C4A000"
    "CC0000"
    "D3D7CF"
    "EEEEEC"
    "EF2929"
    "FCE94F"
  ];
}
