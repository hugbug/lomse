//---------------------------------------------------------------------------------------
//  This file is part of the Lomse library.
//  Copyright (c) 2010-2011 Lomse project
//
//  Lomse is free software; you can redistribute it and/or modify it under the
//  terms of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Lomse is distributed in the hope that it will be useful, but WITHOUT ANY
//  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with Lomse; if not, see <http://www.gnu.org/licenses/>.
//
//  For any comment, suggestion or feature request, please contact the manager of
//  the project at cecilios@users.sourceforge.net
//
//---------------------------------------------------------------------------------------

#include "lomse_image.h"

#include "lomse_image_reader.h"

#include <iostream>
#include <sstream>
#include <stdexcept>
#include <cstring>
#include <cstdlib>
using namespace std;

namespace lomse
{

//=======================================================================================
// Image implementation
//=======================================================================================
Image::Image(unsigned char* imgbuf, VSize bmpSize, EPixelFormat format, USize imgSize)
    : m_bmap(NULL)
    , m_error("")
{
    //AWARE: ownership of imgbuf is transferred to this Image object

    load(imgbuf, bmpSize, format, imgSize);
}

//---------------------------------------------------------------------------------------
Image::Image()
    : m_error("")
{
    //Build default img: grey square 24x24 px

    m_bmpSize = VSize(24, 24);
    //TODO: get display reolution from lomse initialization. Here it is assumed 96 ppi
    m_imgSize = USize(24.0 * 2540.0f / 96.0f, 24.0 * 2540.0f / 96.0f);
    m_format = k_pix_format_rgba32;

    //allocate a buffer for the bitmap
    int bmpsize = 24 * 24 * 4;   //24px width, 24px height, 4bytes per pixel (RGBA)
    if ((m_bmap = (unsigned char*)malloc(bmpsize)) == NULL)
        throw std::runtime_error("[Image constructor]: not enough memory for image buffer");

    unsigned char no_image = 0x77;
    memset(m_bmap, no_image, bmpsize);
}

//---------------------------------------------------------------------------------------
Image::~Image()
{
    if (m_bmap)
        free(m_bmap);
}

//---------------------------------------------------------------------------------------
void Image::set_error_msg(const string& msg)
{
    m_error = msg;
}

//---------------------------------------------------------------------------------------
void Image::load(unsigned char* imgbuf, VSize bmpSize, EPixelFormat format,
                    USize imgSize)
{
    m_bmpSize = bmpSize;
    m_imgSize = imgSize;
    m_format = format;
    m_error = "";

    if (m_bmap) free(m_bmap);
    m_bmap = imgbuf;
}

//---------------------------------------------------------------------------------------
int Image::get_bits_per_pixel()
{
    switch(m_format)
    {
        case k_pix_format_undefined:    return 0;    // By default. No conversions are applied
    //    case k_pix_format_bw = 1,         // 1 bit per color B/W
        case k_pix_format_gray8:    return 8;    // Simple 256 level grayscale
        case k_pix_format_gray16:   return 16;   // Simple 65535 level grayscale
        case k_pix_format_rgb555:   return 15;   // 15 bit rgb. Depends on the byte ordering!
        case k_pix_format_rgb565:   return 16;   // 16 bit rgb. Depends on the byte ordering!
        case k_pix_format_rgbAAA:   return 30;   // 30 bit rgb. Depends on the byte ordering!
        case k_pix_format_rgbBBA:   return 32;   // 32 bit rgb. Depends on the byte ordering!
        case k_pix_format_bgrAAA:   return 30;   // 30 bit bgr. Depends on the byte ordering!
        case k_pix_format_bgrABB:   return 32;   // 32 bit bgr. Depends on the byte ordering!
        case k_pix_format_rgb24:    return 24;   // R-G-B, one byte per color component
        case k_pix_format_bgr24:    return 24;   // B-G-R, native win32 BMP format.
        case k_pix_format_rgba32:   return 32;   // R-G-B-A, one byte per color component
        case k_pix_format_argb32:   return 32;   // A-R-G-B, native MAC format
        case k_pix_format_abgr32:   return 32;   // A-B-G-R, one byte per color component
        case k_pix_format_bgra32:   return 32;   // B-G-R-A, native win32 BMP format
        case k_pix_format_rgb48:    return 48;   // R-G-B, 16 bits per color component
        case k_pix_format_bgr48:    return 48;   // B-G-R, native win32 BMP format.
        case k_pix_format_rgba64:   return 64;   // R-G-B-A, 16 bits byte per color component
        case k_pix_format_argb64:   return 64;   // A-R-G-B, native MAC format
        case k_pix_format_abgr64:   return 64;   // A-B-G-R, one byte per color component
        case k_pix_format_bgra64:   return 64;   // B-G-R-A, native win32 BMP format
    }
    return 0;       //compiler happy
}

//---------------------------------------------------------------------------------------
bool Image::has_alpha()
{
    switch(m_format)
    {
        case k_pix_format_undefined:    // By default. No conversions are applied
//        case k_pix_format_gray8:        // Simple 256 level grayscale
        case k_pix_format_gray16:       // Simple 65535 level grayscale
        case k_pix_format_rgb555:       // 15 bit rgb. Depends on the byte ordering!
        case k_pix_format_rgb565:       // 16 bit rgb. Depends on the byte ordering!
        case k_pix_format_rgbAAA:       // 30 bit rgb. Depends on the byte ordering!
        case k_pix_format_rgbBBA:       // 32 bit rgb. Depends on the byte ordering!
        case k_pix_format_bgrAAA:       // 30 bit bgr. Depends on the byte ordering!
        case k_pix_format_bgrABB:       // 32 bit bgr. Depends on the byte ordering!
        case k_pix_format_rgb24:        // R-G-B, one byte per color component
        case k_pix_format_bgr24:        // B-G-R, native win32 BMP format.
        case k_pix_format_rgb48:        // R-G-B, 16 bits per color component
        case k_pix_format_bgr48:        // B-G-R, native win32 BMP format.
            return false;

        case k_pix_format_rgba32:       // R-G-B-A, one byte per color component
        case k_pix_format_argb32:       // A-R-G-B, native MAC format
        case k_pix_format_abgr32:       // A-B-G-R, one byte per color component
        case k_pix_format_bgra32:       // B-G-R-A, native win32 BMP format
        case k_pix_format_rgba64:       // R-G-B-A, 16 bits byte per color component
        case k_pix_format_argb64:       // A-R-G-B, native MAC format
        case k_pix_format_abgr64:       // A-B-G-R, one byte per color component
        case k_pix_format_bgra64:       // B-G-R-A, native win32 BMP format
            return true;
        default:
        {
            stringstream s;
            s << "[Image::has_alpha] unsupported pixel format " << m_format;
            throw std::runtime_error(s.str());
        }
    }
    return false;       //compiler happy
}


}   //namespace lomse
