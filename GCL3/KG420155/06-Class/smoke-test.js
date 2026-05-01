const { Command } = require('commander');
const program = new Command();

program
  .name('test-app')
  .description('Aplikacja do walidacji paczki commander')
  .version('1.0.0')
  .option('-d, --debug', 'output extra debugging')
  .option('-p, --pizza-type <type>', 'flavour of pizza');

// Example Input
program.parse(['node', 'test', '-d', '-p', 'hawajska']);

const options = program.opts();

// Walidacja
if (options.debug === true && options.pizzaType === 'hawajska') {
    console.log("SMOKE TEST PASSED: Flagi zostały poprawnie sparsowane!");
    process.exit(0);
} else {
    console.error("SMOKE TEST FAILED: Zły wynik parsowania!", options);
    process.exit(1);
}