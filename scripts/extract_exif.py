#!/usr/bin/env python3
"""
HEIC EXIF and GPS Data Extractor
Extracts EXIF metadata and GPS location data from HEIC files
"""

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
    from PIL.ExifTags import TAGS, GPSTAGS
    from pillow_heif import register_heif_opener

    # Register HEIF opener with PIL
    register_heif_opener()
except ImportError as e:
    print(f"Error: Required library not found - {e}")
    print("Please install required packages:")
    print("pip install Pillow pillow-heif")
    sys.exit(1)


def dms_to_decimal(dms, direction):
    """Convert degrees, minutes, seconds to decimal degrees"""
    try:
        # Handle case where dms might not be a sequence of 3 values
        if not isinstance(dms, (list, tuple)) or len(dms) != 3:
            return None
        
        degrees, minutes, seconds = dms
        decimal = float(degrees) + float(minutes)/60 + float(seconds)/3600
        if direction in ['S', 'W']:
            decimal = -decimal
        return decimal
    except (ValueError, TypeError, AttributeError):
        return None


def extract_gps_data(exif_dict):
    """Extract GPS coordinates from EXIF data"""
    gps_data = {}

    # Look for GPSInfo in the EXIF data
    if 'GPSInfo' not in exif_dict:
        return None

    gps_info = exif_dict['GPSInfo']
    
    # Check if gps_info is a dictionary-like object with items() method
    if not hasattr(gps_info, 'items'):
        return None

    try:
        # Convert GPS tag IDs to names
        for gps_tag_id, gps_value in gps_info.items():
            gps_tag = GPSTAGS.get(gps_tag_id, gps_tag_id)
            gps_data[gps_tag] = gps_value
    except (AttributeError, TypeError) as e:
        print(f"Error processing GPS info: {e}")
        return None

    if not gps_data:
        return None

    # Extract latitude
    lat = None
    if 'GPSLatitude' in gps_data and 'GPSLatitudeRef' in gps_data:
        lat = dms_to_decimal(gps_data['GPSLatitude'], gps_data['GPSLatitudeRef'])

    # Extract longitude
    lon = None
    if 'GPSLongitude' in gps_data and 'GPSLongitudeRef' in gps_data:
        lon = dms_to_decimal(gps_data['GPSLongitude'], gps_data['GPSLongitudeRef'])

    # Extract altitude
    alt = None
    if 'GPSAltitude' in gps_data:
        try:
            alt = float(gps_data['GPSAltitude'])
            if 'GPSAltitudeRef' in gps_data and gps_data['GPSAltitudeRef'] == 1:
                alt = -alt  # Below sea level
        except (ValueError, TypeError):
            alt = None

    return {
        'latitude': lat,
        'longitude': lon,
        'altitude': alt,
        'raw_gps_data': gps_data
    }


def extract_exif_data(image_path):
    """Extract all EXIF data from image"""
    try:
        with Image.open(image_path) as img:
            # Use getexif() method (modern PIL/Pillow method)
            exif_data = img.getexif()

            if not exif_data:
                return None, None

            # Convert EXIF data to readable format
            readable_exif = {}
            for tag_id, value in exif_data.items():
                tag = TAGS.get(tag_id, tag_id)
                readable_exif[tag] = value

            # Handle GPS data specially
            gps_info = None
            if 'GPSInfo' in readable_exif:
                gps_info = extract_gps_data(readable_exif)

            return readable_exif, gps_info

    except Exception as e:
        print(f"Error reading image: {e}")
        return None, None


def format_exposure_time(exposure):
    """Format exposure time as a fraction if it's very short"""
    if isinstance(exposure, float) and exposure < 1:
        # Convert to fraction (e.g., 0.008333 -> 1/120)
        reciprocal = int(1 / exposure)
        return f"1/{reciprocal}"
    return str(exposure)


def format_focal_length(focal_length):
    """Format focal length with units"""
    if isinstance(focal_length, (int, float)):
        return f"{focal_length}mm"
    return str(focal_length)


def format_f_number(f_number):
    """Format f-number"""
    if isinstance(f_number, (int, float)):
        return f"f/{f_number}"
    return str(f_number)


def main():
    parser = argparse.ArgumentParser(description='Extract EXIF and GPS data from HEIC files')
    parser.add_argument('filename', help='Path to the HEIC file')
    parser.add_argument('--gps-only', action='store_true', help='Show only GPS data')
    parser.add_argument('--maps-url', action='store_true', help='Generate Google Maps URL')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show all EXIF tags')

    args = parser.parse_args()

    # Check if file exists
    file_path = Path(args.filename)
    if not file_path.exists():
        print(f"Error: File '{args.filename}' not found")
        sys.exit(1)

    print(f"Extracting EXIF data from: {args.filename}")
    print("-" * 50)

    # Extract EXIF and GPS data
    exif_data, gps_info = extract_exif_data(file_path)

    if exif_data is None:
        print("No EXIF data found in the image")
        sys.exit(1)

    # Display GPS information
    if gps_info and (gps_info['latitude'] is not None and gps_info['longitude'] is not None):
        print("GPS LOCATION DATA:")
        print(f"  Latitude:  {gps_info['latitude']:.6f}")
        print(f"  Longitude: {gps_info['longitude']:.6f}")
        if gps_info['altitude'] is not None:
            print(f"  Altitude:  {gps_info['altitude']:.1f} meters")

        if args.maps_url:
            maps_url = f"https://www.google.com/maps?q={gps_info['latitude']},{gps_info['longitude']}"
            print(f"  Google Maps: {maps_url}")
        print()
    else:
        print("No GPS location data found in the image")
        print()

    # Display other EXIF data unless GPS-only mode
    if not args.gps_only:
        print("CAMERA & PHOTO DATA:")

        # Important camera and photo information
        important_data = {
            'DateTime': 'Date/Time',
            'DateTimeOriginal': 'Date Taken',
            'Make': 'Camera Make',
            'Model': 'Camera Model',
            'Software': 'Software',
            'ImageWidth': 'Width',
            'ImageLength': 'Height',
            'Orientation': 'Orientation',
            'ExposureTime': 'Shutter Speed',
            'FNumber': 'Aperture',
            'ISO': 'ISO',
            'FocalLength': 'Focal Length',
            'Flash': 'Flash',
            'WhiteBalance': 'White Balance',
            'ColorSpace': 'Color Space',
            'ExposureMode': 'Exposure Mode',
            'SceneType': 'Scene Type'
        }

        # Show important tags with nice formatting
        for exif_tag, display_name in important_data.items():
            if exif_tag in exif_data:
                value = exif_data[exif_tag]

                # Format specific values nicely
                if exif_tag == 'ExposureTime':
                    value = format_exposure_time(value)
                elif exif_tag == 'FocalLength':
                    value = format_focal_length(value)
                elif exif_tag == 'FNumber':
                    value = format_f_number(value)

                print(f"  {display_name}: {value}")

        # Show all tags if verbose mode
        if args.verbose:
            print("\nALL EXIF TAGS:")
            remaining_tags = set(exif_data.keys()) - set(important_data.keys()) - {'GPSInfo'}
            for tag in sorted(remaining_tags):
                value = exif_data[tag]
                # Truncate very long values
                if isinstance(value, (str, bytes)) and len(str(value)) > 100:
                    value = str(value)[:100] + "..."
                print(f"  {tag}: {value}")


if __name__ == "__main__":
    main()
