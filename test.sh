#!/bin/bash 

# readonly BASE_URL=https://speedtest.edgecompute.app/
readonly BASE_URL=https://speedtest.global.ssl.fastly.net/
readonly TEST_TYPE=$1
readonly SIZE=$2
readonly BOLD_TEXT=$(tput bold 2>/dev/null)
readonly NORMAL_TEXT=$(tput sgr0 2>/dev/null)

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

    echo "${BOLD_TEXT}Beginning download of ${size} test file...${NORMAL_TEXT}"
    curl -w "\nDownload size:\t%{size_download}\nAverage speed:\t%{speed_download}\n\n" -L -o /dev/null "${url}" 2>&1 \
        | tr '\r' '\n' > curl.out

    echo ""
    echo "-----------------------------------"
    grep "Download size" curl.out | awk '{print $1,$2,$3 / 1048576,"MB"}'

}

upload_data() {
    local size=$1
    local url="${BASE_URL}__up"

    # Create test file
    echo "${BOLD_TEXT}Creating ${size} test file...${NORMAL_TEXT}"
    dd if=/dev/zero of=upload.bin  bs=1024  count=10240 > /dev/null 2>&1

    echo ""
    echo "${BOLD_TEXT}Beginning upload of ${size} test file...${NORMAL_TEXT}"
    # curl -F 'data=@upload.bin' "${url}" 2>&1 \
    curl -w '\nUpload size:\t%{size_upload}\nAverage speed:\t%{speed_upload}\n\n' -F 'data=@upload.bin' "${url}" 2>&1 \
        | tr '\r' '\n' > curl.out
    echo ""
    echo "-----------------------------------"
    grep "Upload size" curl.out | awk '{print $1,$2,$3 / 1048576,"MB"}'

    rm upload.bin

}

generate_report() {
    echo "${BOLD_TEXT}Generating visual report..${NORMAL_TEXT}"
    echo ""

    ./curl_data.py curl.out 
    
    ./imgcat curl.out.png

    echo ""
}

run_tests() {
    local test_type=${TEST_TYPE}
    local size=${SIZE}

    case $test_type in 
        up)
            upload_data
            ;;
        down)
            download_data $size 
            ;;
        *)  
            print_usage
            ;;
    esac
            

}

show_average_speed() {
    grep "Average speed" curl.out | awk '{print $1,$2,$3 / 125000,"mbit/sec"}'
    echo "-----------------------------------"
    echo ""
}

print_usage() {
    echo "Usage: $(basename $0) (up|down) [100M|200M|500M|1G]"
    exit 1
}

show_error() {
    echo "${BOLD_TEXT}Missing components for report generation. Please run './requirements.sh'${NORMAL_TEXT}"
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