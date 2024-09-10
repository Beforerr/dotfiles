{
  "translatorID":"dda092d2-a257-46af-b9a3-2f04a55cb04f",
  "translatorType":2,
  "label":"Tana Metadata Export",
  "creator":"Stian Håklev based on Joel Chan's work",
  "target":"md",
  "minVersion":"2.0",
  "maxVersion":"",
  "priority":200,
  "inRepository":false,
  "lastUpdated":"2022-09-07 - 10:15"
}
   
function doExport() {
  Zotero.write('%%tana%%\n');
  var item;
  while (item = Zotero.nextItem()) {

    Zotero.write(`- **${item.title}** #[[\.zotero]] #[[publication]] #${item.itemType} \n`);
    Zotero.write(`  - Citation Key:: @${item.citationKey}\n`);
    Zotero.write(`  - Title:: ${item.title}\n`);

    // tags
    let tags =  item.tags.map(i => i.tag)
    if (tags.length){
      Zotero.write(`  - Tags:: ${tags} \n`);
    }

    // author
    let authors = item.creators.slice(0,3)
    let coauthors = item.creators.slice(3)
    
    Zotero.write('  - Author(s):: \n');
    for (const author of authors) {
      Zotero.write(`    - ${author.firstName || ''} ${author.lastName || ''}\n`);
    }
    Zotero.write('\n');

    Zotero.write('  - Co-author(s):: \n');
    for (const author of coauthors) {
      Zotero.write(`    - ${author.firstName || ''} ${author.lastName || ''}\n`);
    }
    Zotero.write('\n');
  
    // year
    var date = Zotero.Utilities.strToDate(item.date);
    var dateS = (date.year) ? date.year : item.date;   
    Zotero.write(`  - Year:: ${dateS || ''}\n`)
    
    // publication
    Zotero.write(`  - Publication:: ${item.publicationTitle || ''}\n`);


    // zotero link
    let library_id = item.libraryID ? item.libraryID : 0;  
    let itemLink = `zotero://select/items/${library_id}_${item.key}`;

    // url with citation
    Zotero.write('  - Links:: \n')
    Zotero.write(`    - ${itemLink}\n`);
    if (item.DOI) {
      Zotero.write(`    - [DOI](https://doi.org/${item.DOI})\n`);
      Zotero.write(`    - [Connected Papers](https://connectedpapers.com/api/redirect/doi/${item.DOI})\n`);
      // Zotero.write(`    - [Semantic scholar](https://www.semanticscholar.org/paper/${getDOIInfoBySemanticscholar(item.DOI)})\n`);
    } else if (item.url){
      Zotero.write(`    - [URL](${item.url})\n`);
    }
    
    if (item.abstractNote){
      Zotero.write(`  - Abstract:: ${item.abstractNote || ''}\n`);
    }

    Zotero.write('  - Attachment(s):: \n')
    for (const attachment of item.attachments) {
      if (attachment.mimeType === 'application/pdf') {
        Zotero.write(`    - zotero://open-pdf/library/items/${attachment.key} #pdf\n`);
      }
      if (attachment.mimeType === 'application/epub+zip') {
        Zotero.write(`    - zotero://open/library/items/${attachment.key} #epub\n`);
      }
    }
  }
}

async function getDOIInfoBySemanticscholar(DOI) {
  const api = `https://api.semanticscholar.org/graph/v1/paper/${DOI}`
  let response = await this.requests.get(api)
  return response.paperId
}
