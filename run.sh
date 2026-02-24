rm -rf target
mkdir -p target
mkdir -p target/bench
cargo build
cargo build --release
cargo bsan build
RUNS=100
WARMUP=10
MFLAGS="-Zmiri-deterministic-concurrency -Zmiri-disable-validation -Zmiri-disable-alignment-check -Zmiri-disable-data-race-detector -Zmiri-tree-borrows -Zmiri-provenance-gc=0"
# we need to override the ABI warning due to what seems to be a bug in nightly (https://github.com/mozilla/cubeb-coreaudio-rs/issues/269)
CARGO_TARGET_DIR=./target/asan RUSTFLAGS="-Cunsafe-allow-abi-mismatch=sanitizer -Zsanitizer=address --target=x86_64-unknown-linux-gnu" RUSTDOCFLAGS=$RUSTFLAGS cargo build -Zbuild-std
CARGO_TARGET_DIR=./target/tsan RUSTFLAGS="-Cunsafe-allow-abi-mismatch=sanitizer -Zsanitizer=thread --target=x86_64-unknown-linux-gnu" RUSTDOCFLAGS=$RUSTFLAGS cargo build -Zbuild-std
hyperfine -N --prepare="sync" --warmup=$WARMUP --runs=$RUNS --export-json=./target/bench/AddressSanitizer.json "./target/asan/debug/testbench"
hyperfine -N --prepare="sync" --warmup=$WARMUP --runs=$RUNS --export-json=./target/bench/ThreadSanitizer.json "./target/tsan/debug/testbench"
hyperfine -N --prepare="sync" --warmup=$WARMUP --runs=$RUNS --export-json=./target/bench/release.json "./target/release/testbench"
hyperfine -N --prepare="sync" --warmup=$WARMUP --runs=$RUNS --export-json=./target/bench/debug.json "./target/debug/testbench"
hyperfine -N --prepare="sync" --warmup=$WARMUP --runs=$RUNS --export-json=./target/bench/BorrowSanitizer.json "cargo bsan run"
MIRIFLAGS="$MFLAGS" hyperfine -N --prepare="sync" --warmup=$WARMUP --runs=$RUNS --export-json=./target/bench/Miri.json "cargo miri run"
