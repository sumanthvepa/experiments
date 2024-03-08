// Note that it does not matter how the program was invoked
// on the command line. i.e. either as
// $ node args.mjs 
// or
// $ ./args.mjs
// The argv array will always have as its first element
// the path to the node executable.
// The second element of the array will always be the
// path to this script.
// The third element onwards will contain any command
// line arguments passed to the script.
for(let n = 0; n < process.argv.length; ++n) {
  console.log(process.argv[n]);
}
