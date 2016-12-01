#!/bin/bash

ImagePath=$1

cp "$ImagePath"/default_journal_ipad_L*.png ../Assets/images.xcassets/DefaultBrandLogo-Landscape.imageset
cp "$ImagePath"/default_journal_ipad_P*.png ../Assets/images.xcassets/DefaultBrandLogo-Portrait.imageset
cp "$ImagePath"/default_journal_ipad_P*.png ../Assets/images.xcassets/DefaultBrandLogo-Phone.imageset

cp "$ImagePath"/default_cover_ipad*.png ../Assets/images.xcassets/DefaultCoverImage-iPad.imageset
cp "$ImagePath"/default_cover_iphone*.png ../Assets/images.xcassets/DefaultcoverImage-iPhone.imageset

cp "$ImagePath"/society_branding_graphic_ipad*.png ../Assets/images.xcassets/DefaultSocietyLogo-Landscape.imageset
cp "$ImagePath"/society_branding_graphic_portrait_ipad*.png ../Assets/images.xcassets/DefaultSocietyLogo-Portrait.imageset
cp "$ImagePath"/society_branding_iPhone*.png ../Assets/images.xcassets/DefaultSocietyLogo-Phone.imageset
