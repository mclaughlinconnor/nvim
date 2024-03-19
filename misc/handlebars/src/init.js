import * as pug from 'pug';
import * as readline from 'readline';
import Handlebars from 'handlebars';
import beautifier from 'js-beautify';
import html2jade from 'html2jade';

const mode = process.argv[2];

const convertHtmlToJade = async (html, options) => {
  return new Promise((resolve, reject) => {
    html2jade.convertHtml(html, options, (err, jade) => {
      if (err) {
        reject(err);
      } else {
        resolve(jade);
      }
    });
  });
};


const rl = readline.createInterface({input: process.stdin});

let inputTemplate = '';

rl.on('line', function (line) {
  inputTemplate += line + '\n';
});

rl.on('close', async function () {
  let compiledTemplate;
  let pugDocument;
  let htmlDocument;

  try {
    if (mode === 'html') {
      htmlDocument = inputTemplate;
      pugDocument = await convertHtmlToJade(htmlDocument, {bodyless: true});
      compiledTemplate = Handlebars.compile(inputTemplate);
    } else {
      pugDocument = inputTemplate;
      htmlDocument = beautifier.html(pug.render(pugDocument), {indent_size: 2});

      compiledTemplate = Handlebars.compile(htmlDocument);
    }

    const variables = JSON.parse(process.argv[3]);

    const output = JSON.stringify({html: htmlDocument, pug: pugDocument, compiledTemplate: compiledTemplate(variables)});
    process.stdout.write(output);
    process.exit(0);
  } catch (error) {
    process.stderr.write("Error: ", error);
    process.exit(1);
  }
});
