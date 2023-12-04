#!/usr/bin/env python
import re
import pyperclip

def convert_html_image_to_markdown(input):
    # Extracting URL, image source, and title from the HTML
    match = re.search(r'<a href="(.*?)"><img src="(.*?)" alt="(.*?)"/></a>', input)
    if not match:
        return input

    link, img_src, img_alt = match.groups()

    # Constructing the markdown format
    markdown = f'[![]({img_src}){{fig-alt="{img_alt}"}}]({link})'
    return markdown

# Example usage
input = pyperclip.paste()
output = convert_html_image_to_markdown(input)
pyperclip.copy(output)