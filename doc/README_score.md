# General Requirements

- Rust toolchain, prefer X86_64 (intel architecture). This code probably works on other architectures but is untested.
- A linear algebra package/library for Rust linear algebra libraries to link against. This has been tested with OpenBLAS, a native library of linear algebra.


The build process is just:
```
cargo build
```

To run the code:
```
cargo run
```

You can also call the built binary in the target directory to run it.

## Needs
We need a way to validate the scores being produced, preferably by producing baseline scoring results using Tetrad for comparison.
