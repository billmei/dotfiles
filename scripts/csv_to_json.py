import csv
import json
import re
from bs4 import BeautifulSoup
import argparse

def convert_quotes_in_text(text):
    # Function to handle quote conversion
    def replace_quotes(match):
        quote = match.group(0)
        prev_char = match.string[max(0, match.start() - 1):match.start()]
        
        if quote == '"':
            # Opening quote if at start or after space/punctuation
            if not prev_char or prev_char.isspace() or prev_char in '([{<':
                return '“'
            # Closing quote
            return '”'
        elif quote == "'":
            # Opening quote if at start or after space/punctuation
            if not prev_char or prev_char.isspace() or prev_char in '([{<':
                return '‘'
            # Closing quote
            return '’'

    # Convert double quotes
    text = re.sub(r'"', replace_quotes, text)
    # Convert single quotes
    text = re.sub(r"'", replace_quotes, text)
    
    return text

def convert_html_quotes(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Iterate over all text elements in the HTML
    for element in soup.find_all(string=True):
        if element.parent.name not in ['script', 'style']:  # Skip script and style tags
            original_text = element.string
            converted_text = convert_quotes_in_text(original_text)
            element.replace_with(converted_text)
    
    return str(soup)

def csv_to_json(csv_file_path, json_file_path):
    # Initialize the dictionary to hold the JSON structure
    json_data = {"variations": {}}

    # Open the CSV file and read its contents
    with open(csv_file_path, mode='r', encoding='utf-8') as csv_file:
        csv_reader = csv.reader(csv_file)
        next(csv_reader)  # Skip the header row
        for row in csv_reader:
            # Extract the keyword and content from each row
            keyword, content = row
            # Add the keyword and content to the JSON structure
            # Convert smart quotes to dumb quotes before saving
            json_data["variations"][keyword] = {"content": convert_html_quotes(content)}

    # Write the JSON structure to a file
    with open(json_file_path, mode='w', encoding='utf-8') as json_file:
        json.dump(json_data, json_file, indent=2, ensure_ascii=False)

def main():
    parser = argparse.ArgumentParser(description='Convert CSV to JSON with smart quote conversion.')
    parser.add_argument('csv_file_path', type=str, help='Path to the input CSV file')
    parser.add_argument('json_file_path', type=str, help='Path to the output JSON file')
    args = parser.parse_args()

    # Convert the CSV to JSON
    csv_to_json(args.csv_file_path, args.json_file_path)

if __name__ == '__main__':
    main()
