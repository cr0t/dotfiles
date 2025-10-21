#!/bin/bash

# ZFS-Aware Performance Benchmark Script

# Detect OS and set appropriate I/O engine
detect_os() {
    case "$(uname -s)" in
        Linux*)
            IO_ENGINE="libaio"
            ;;
        Darwin*)
            IO_ENGINE="posixaio"
            ;;
        *)
            echo "Warning: Unknown OS, defaulting to posixaio"
            IO_ENGINE="posixaio"
            ;;
    esac
}

# Default values
DATASET_PATH="${1:-}"
TEST_SIZE="${2:-4G}"
RUNTIME="${3:-30}"
USE_DIRECT_IO="${4:-0}"
NUMJOBS="${5:-4}"

detect_os

show_usage() {
    cat << EOF
ZFS Performance Benchmark Script

Usage: $0 <dataset_path> [test_size] [runtime] [direct_io] [numjobs]

Arguments:
    dataset_path    Path to ZFS dataset (required)
    test_size       Size of test file (default: 4G)
    runtime         Test duration in seconds (default: 30)
    direct_io       0=use ZFS cache, 1=bypass cache (default: 0)
    numjobs         Number of parallel jobs for random tests (default: 4)

Examples:
    # Basic test with defaults (4 parallel jobs)
    $0 /mnt/tank/benchmark

    # Quick test with smaller size
    $0 /mnt/tank/benchmark 1G 15

    # Test with 16 parallel jobs (stress test for NVMe)
    $0 /mnt/tank/benchmark 4G 30 0 16

    # Single job test (baseline performance)
    $0 /mnt/tank/benchmark 4G 30 0 1

    # Full test suite with direct I/O
    $0 /mnt/tank/benchmark 8G 120 1 8
EOF
}

validate_environment() {
    if [ -z "$DATASET_PATH" ]; then
        echo "Error: Dataset path is required"
        echo ""
        show_usage
        exit 1
    fi

    if ! command -v fio &> /dev/null; then
      echo "Error: fio is not installed. Install it with: apt install fio (brew install fio)"
        exit 1
    fi

    mkdir -p "$DATASET_PATH"
    if [ ! -w "$DATASET_PATH" ]; then
        echo "Error: Cannot write to $DATASET_PATH"
        exit 1
    fi
}

print_header() {
    echo "=== ZFS Performance Benchmark ==="
    echo "OS: $(uname -s)"
    echo "I/O Engine: $IO_ENGINE"
    echo "Dataset: $DATASET_PATH"
    echo "Test Size: $TEST_SIZE"
    echo "Runtime: ${RUNTIME}s per test"
    echo "Parallel Jobs: $NUMJOBS (for random tests)"
    echo "Direct I/O: $([ "$USE_DIRECT_IO" -eq 1 ] && echo "enabled (cache bypass)" || echo "disabled (cached)")"
    echo "==============================="
    echo ""
}

run_fio_test() {
    local test_name="$1"
    local description="$2"
    shift 2

    echo "=== $description ==="
    local output
    output=$(fio --name="$test_name" \
        --directory="$TEST_DIR" \
        --random_generator=tausworthe64 \
        --group_reporting \
        --time_based \
        --runtime="$RUNTIME" \
        --direct="$USE_DIRECT_IO" \
        "$@" 2>&1)

    echo "$output"
    echo ""

    # Parse results for summary
    parse_fio_results "$test_name" "$output"
}

parse_fio_results() {
    local test_name="$1"
    local output="$2"

    # Cross-platform parsing using awk (works on both Linux and macOS)
    local read_iops=$(echo "$output" | awk '/read:.*IOPS=/ {match($0, /IOPS=[0-9.]+[kM]?/); print substr($0, RSTART+5, RLENGTH-5)}' | head -1)
    local read_bw=$(echo "$output" | awk '/read:.*BW=/ {match($0, /BW=[0-9.]+[kMG]i?B\/s/); print substr($0, RSTART+3, RLENGTH-3)}' | head -1)

    local write_iops=$(echo "$output" | awk '/write:.*IOPS=/ {match($0, /IOPS=[0-9.]+[kM]?/); print substr($0, RSTART+5, RLENGTH-5)}' | head -1)
    local write_bw=$(echo "$output" | awk '/write:.*BW=/ {match($0, /BW=[0-9.]+[kMG]i?B\/s/); print substr($0, RSTART+3, RLENGTH-3)}' | head -1)

    # Store in arrays for summary
    SUMMARY_NAMES+=("$test_name")
    SUMMARY_READ_BW+=("${read_bw:-N/A}")
    SUMMARY_READ_IOPS+=("${read_iops:-N/A}")
    SUMMARY_WRITE_BW+=("${write_bw:-N/A}")
    SUMMARY_WRITE_IOPS+=("${write_iops:-N/A}")
}

run_sequential_tests() {
    run_fio_test "seq-read" "Sequential Read (1MB blocks)" \
        --ioengine="$IO_ENGINE" \
        --iodepth=32 \
        --rw=read \
        --bs=1M \
        --size="$TEST_SIZE" \
        --numjobs=1

    run_fio_test "seq-write" "Sequential Write (1MB blocks)" \
        --ioengine="$IO_ENGINE" \
        --iodepth=32 \
        --rw=write \
        --bs=1M \
        --size="$TEST_SIZE" \
        --numjobs=1 \
        --refill_buffers \
        --scramble_buffers=1
}

run_random_tests() {
    run_fio_test "rand-read" "Random Read IOPS (4K blocks, $NUMJOBS jobs)" \
        --ioengine="$IO_ENGINE" \
        --iodepth=32 \
        --rw=randread \
        --bs=4k \
        --size="$TEST_SIZE" \
        --numjobs="$NUMJOBS"

    run_fio_test "rand-write" "Random Write IOPS (4K blocks, $NUMJOBS jobs)" \
        --ioengine="$IO_ENGINE" \
        --iodepth=32 \
        --rw=randwrite \
        --bs=4k \
        --size="$TEST_SIZE" \
        --numjobs="$NUMJOBS" \
        --refill_buffers \
        --scramble_buffers=1

    run_fio_test "rand-rw" "Mixed Random 70/30 Read/Write (4K blocks, $NUMJOBS jobs)" \
        --ioengine="$IO_ENGINE" \
        --iodepth=32 \
        --rw=randrw \
        --rwmixread=70 \
        --bs=4k \
        --size="$TEST_SIZE" \
        --numjobs="$NUMJOBS" \
        --refill_buffers \
        --scramble_buffers=1
}

cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

print_summary() {
    echo "========================================"
    echo "===       BENCHMARK SUMMARY          ==="
    echo "========================================"
    printf "%-25s | %-15s | %-15s | %-15s | %-15s\n" "Test" "Read BW" "Read IOPS" "Write BW" "Write IOPS"
    echo "--------------------------------------------------------------------------------------------------------"

    for i in "${!SUMMARY_NAMES[@]}"; do
        local name="${SUMMARY_NAMES[$i]}"
        local read_bw="${SUMMARY_READ_BW[$i]:-N/A}"
        local read_iops="${SUMMARY_READ_IOPS[$i]:-N/A}"
        local write_bw="${SUMMARY_WRITE_BW[$i]:-N/A}"
        local write_iops="${SUMMARY_WRITE_IOPS[$i]:-N/A}"

        printf "%-25s | %-15s | %-15s | %-15s | %-15s\n" "$name" "$read_bw" "$read_iops" "$write_bw" "$write_iops"
    done

    echo "========================================"
}

main() {
    # Initialize summary arrays
    SUMMARY_NAMES=()
    SUMMARY_READ_BW=()
    SUMMARY_READ_IOPS=()
    SUMMARY_WRITE_BW=()
    SUMMARY_WRITE_IOPS=()

    validate_environment

    TEST_DIR="$DATASET_PATH/fio-test-$"
    mkdir -p "$TEST_DIR"

    trap cleanup EXIT

    print_header
    run_sequential_tests
    run_random_tests

    echo "=== Benchmark Complete ==="
    echo ""
    print_summary
}

main
