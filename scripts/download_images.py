import requests
import os
import json
from concurrent.futures import ThreadPoolExecutor
import time

def download_image(image_id):
    # Using 1080p resolution (1920x1080) instead of 4K
    url = f'https://picsum.photos/id/{image_id}/1920/1080'
    output_path = f'assets/images/picsum/{image_id}.jpg'
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        
        with open(output_path, 'wb') as f:
            f.write(response.content)
        print(f"Downloaded image {image_id}")
        time.sleep(0.1)  # Be nice to the server
        
    except Exception as e:
        print(f"Error downloading image {image_id}: {str(e)}")

def main():
    os.makedirs('assets/images/picsum', exist_ok=True)
    
    # Read image IDs from the config file
    with open('assets/config/image_ids.json', 'r') as f:
        config = json.load(f)
        image_ids = config['imageIds']
    
    # Download images
    with ThreadPoolExecutor(max_workers=4) as executor:
        executor.map(download_image, image_ids)

if __name__ == '__main__':
    main()