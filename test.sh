#!/bin/bash 

readonly BASE_URL=https://speedtest.edgecompute.app/
readonly TEST_TYPE=$1
readonly SIZE=$2

cleanup_old_files() {
    rm -rf curl.out.g*
}

download_data() {

    local size=$1

    case $size in
        100M)
            local url="${BASE_URL}__down?bytes=100000000"
            ;;
        200M)
            local url="${BASE_URL}__down?bytes=200000000"
            ;;
        500M)
            local url="${BASE_URL}__down?bytes=500000000"
            ;;
        1G)
            local url="${BASE_URL}__down?bytes=1000000000"
            ;;
        *)
            print_usage
    esac

    curl -w '\nTEST - Download size:\t%{size_download}\nTEST - Average download speed:\t%{speed_download}\n\n' -L -o /dev/null "${url}" 2>&1 \
        | tr -u '\r' '\n' > curl.out

}

upload_data() {

    local size=$1
    local url="${BASE_URL}__up"

    # Create test file
    dd if=/dev/zero of=upload.bin  bs=1024  count=10240 > /dev/null 2>&1

    curl -w '\nTEST - Upload size:\t%{size_upload}\nTEST - Average upload speed:\t%{speed_upload}\n\n' -F 'data=@upload.bin' "${url}" 2>&1 \
        | tr '\r' '\n' > curl.out

    rm upload.bin

}

generate_report() {

    ./curl_data.py curl.out 
    
    ./imgcat curl.out.png
}

run_tests() {
    local test_type=${TEST_TYPE}
    local size=${SIZE}

    case $test_type in 
        up)
            upload_data
            ;;
        ddown)
            download_data $size 
            ;;
        *)  
            print_usage
            ;;
    esac
            

}

show_average_speed() {
    echo ""
    echo "-----------------------------------"
    grep "TEST -" curl.out
    echo "-----------------------------------"
    echo ""
}

print_usage() {
    echo "Usage: $(basename $0) (up|down) [100M|200M|500M|1G]"
    exit 1
}

show_error() {
    echo "Missing components for report generation. Please run './requirements.sh'"
    exit 1
}

main() {

    local test_type=${TEST_TYPE}
    local size=${SIZE}

    cleanup_old_files

    run_tests $test_type $size

    show_average_speed

    generate_report || show_error
}

main $TEST_TYPE $SIZE