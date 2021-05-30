<hr>
<img align="left" width="50" height="50" src="https://schnapple.com/wp-content/uploads/2021/05/m1_small.jpg">
I'm trying to fund an M1 Mac to keep old games running on new Macs. If you'd like to help you can contribute here: https://ko-fi.com/schnapple
<hr>

#  Virtual Boy Emulator for iOS using Google Cardboard VR

This is a Virtual Boy Emulator for use with the iPhone and a Google Cardboard compliant headset and MFi controller to recreate the 3D experience of playing old Virtual Boy games.

It is based off of [Provenance](https://provenance-emu.com/) and [Mednafen](https://mednafen.github.io/), specifically a Mednafen-based subset of Provenance, combined with the [Google Cardboard VR SDK for iOS](https://developers.google.com/vr/ios/).

![vbwl](https://raw.githubusercontent.com/tomkidd/VirtualBoyVR-iOS/master/vbwl.jpg)

An MFi controller such as the SteelSeries Nimbus is required to play the games. A Google Cardboard VR headset or similar phone-based headset is required, preferrably one that can strap onto your head as your hands will be occupied. You must provide your own ROM images and cover art, they are not provided. You must place them in folders called "roms" and "covers" with filenames matching what's [provided](https://github.com/tomkidd/VirtualBoyVR-iOS/blob/master/VirtualBoyVR-iOS/HomeViewController.swift#L56) in the source code. They must be added as folder references, not just groups in Xcode. When done correctly they will appear in blue. 

![folders](https://raw.githubusercontent.com/tomkidd/VirtualBoyVR-iOS/master/folders.png)

The Virtual Boy font is by [RunnerPack on PlanetVB](https://www.planetvb.com/modules/newbb/viewtopic.php?topic_id=3812&viewmode=flat&order=ASC&type=&mode=0&start=20)

You can read a lengthy blog article on how I did all this [here](http://schnapple.com/virtual-boy-emulator-for-ios-using-google-cardboard-vr/).

Have fun. For any questions I can be reached at tomkidd@gmail.com
