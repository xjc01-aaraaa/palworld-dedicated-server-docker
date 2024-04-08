package main

import (
    "fmt"
    "os"
    "strconv"
    "golang.org/x/text/encoding/unicode"
    "golang.org/x/text/transform"
    "github.com/zhenjl/cityhash"
)


func steamIDToPlayerUID(steamID int) (int) {

	steamIDStr := strconv.Itoa(steamID)

    utf16Encoder := unicode.UTF16(unicode.LittleEndian, unicode.IgnoreBOM).NewEncoder()
    steamIDUtf16, _, _ := transform.Bytes(utf16Encoder, []byte(steamIDStr))

    hash := cityhash.CityHash64(steamIDUtf16, uint32(len(steamIDUtf16)))
    
    low := u32(hash)
    high := u32(hash >> 32)

	playerUID := low + high*23
	
    return int(playerUID)
}

func u32(value uint64) uint32 {
    return uint32(value & 0xFFFFFFFF)
}


func main() {
    if len(os.Args) < 2 {
        fmt.Println("Please provide a Steam ID as an argument.")
        return
    }

    steamID, err := strconv.Atoi(os.Args[1])
    if err != nil {
        fmt.Println("Invalid Steam ID. Please provide a numeric Steam ID.")
        return
    }

    playerUID := steamIDToPlayerUID(steamID)
    fmt.Println(playerUID)
}
