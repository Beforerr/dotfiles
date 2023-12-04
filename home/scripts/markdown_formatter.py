#!/usr/bin/env python3
import re
import pyperclip

def convert_html_image_to_markdown(html):
    # Extracting URL, image source, and title from the HTML
    match = re.search(r'<a href="(.*?)".*?><img src="(.*?)" alt=".*?"/></a>', html)
    if not match:
        return "Invalid HTML format"

    link, img_src, title = match.groups()

    # Constructing the markdown format
    markdown = f'[![{title}]({img_src})]({link})'
    return markdown

# Example usage
input = pyperclip.paste()
output = convert_html_image_to_markdown(input)
pyperclip.copy('The text to be copied to the clipboard.')