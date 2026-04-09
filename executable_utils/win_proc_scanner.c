/*
===
 File        : win_proc_scanner.c
 Description : 
    Windows utility to scan specific processes and retrieve the TCP ports
    currently bound by those processes. The result is exported as a JSON file
    for integration with external applications (e.g., Flutter Desktop).

 Usage       :
    prog.exe <process1> <process2> ...

 Example     :
    prog.exe mariadb.exe httpd.exe

 Output      :
    process_ports.json

 Author      : Yohanes Oktanio
 Copyright   : © 2026 Yohanes Oktanio
 Platform    : Windows (WinAPI required)
===
*/
#define _WIN32_WINNT 0x0600

#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <tlhelp32.h>
#include <iphlpapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "Ws2_32.lib")

/* 
   SECTION: Macros & Constants
*/

#define OUTPUT_FILE "process_ports.json"

/* 
   SECTION: Data Structures
*/

/*
 * Structure: ProcessInfo
 * ----------------------
 * Stores basic process metadata.
 *
 * pid  : Process ID
 * name : Executable name (e.g., mariadb.exe)
 */
typedef struct {
    DWORD pid;
    char name[MAX_PATH];
} ProcessInfo;

/* 
   SECTION: Process Discovery
*/

/*
 * Function: find_process
 * ----------------------
 * Searches for a running process by executable name.
 *
 * target : Name of executable (case-insensitive)
 * result : Output structure containing PID and name
 *
 * returns:
 *   1  -> Process found
 *   0  -> Process not found
 *
 * Notes:
 *   - Uses Toolhelp32Snapshot API.
 *   - Returns first matching process only.
 */
int find_process(const char* target, ProcessInfo* result) {

    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE)
        return 0;

    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);

    if (Process32First(snapshot, &pe)) {
        do {
            if (_stricmp(pe.szExeFile, target) == 0) {
                result->pid = pe.th32ProcessID;
                strcpy(result->name, pe.szExeFile);
                CloseHandle(snapshot);
                return 1;
            }
        } while (Process32Next(snapshot, &pe));
    }

    CloseHandle(snapshot);
    return 0;
}

/*
SECTION: Port Mapping

 * Function: get_ports_by_pid
 * --------------------------
 * Retrieves all TCP IPv4 ports owned by a specific PID and writes them
 * directly to the JSON output file stream.
 *
 * pid : Process ID to inspect
 * out : Open FILE pointer for JSON output
 *
 * Notes:
 *   - Uses GetExtendedTcpTable (TCP_TABLE_OWNER_PID_ALL).
 *   - Only scans IPv4 TCP connections.
 *   - Ports are written as JSON array.
 */
void get_ports_by_pid(DWORD pid) {

    PMIB_TCPTABLE_OWNER_PID tcpTable;
    DWORD size = 0;

    GetExtendedTcpTable(NULL, &size, FALSE, AF_INET,
                        TCP_TABLE_OWNER_PID_ALL, 0);

    tcpTable = (PMIB_TCPTABLE_OWNER_PID)malloc(size);

    if (GetExtendedTcpTable(tcpTable, &size, FALSE,
                            AF_INET, TCP_TABLE_OWNER_PID_ALL, 0) != NO_ERROR) {
        free(tcpTable);
        printf("[]");
        return;
    }

    int first = 1;
    printf("[");

    for (DWORD i = 0; i < tcpTable->dwNumEntries; i++) {

        if (tcpTable->table[i].dwOwningPid == pid) {

            DWORD port = ntohs((u_short)tcpTable->table[i].dwLocalPort);

            if (!first)
                printf(",");

            printf("%lu", port);
            first = 0;
        }
    }

    printf("]");
    free(tcpTable);
}

/* 
   SECTION: Application Entry Point
    */

/*
 * Function: main
 * --------------
 * Entry point of application.
 *
 * argc : Argument count
 * argv : Argument vector
 *
 * Flow:
 *   1. Validate arguments
 *   2. Create JSON output file
 *   3. For each process argument:
 *        - Find process
 *        - Retrieve PID
 *        - Extract ports
 *   4. Close JSON structure
 *
 * Returns:
 *   0 -> Success
 *   1 -> Error
 */
int main(int argc, char* argv[]) {

    if (argc < 2) {
        printf("Usage: %s <process1> <process2> ...\n", argv[0]);
        return 1;
    }

    printf("[\n");

    int firstProc = 1;

    for (int i = 1; i < argc; i++) {

        ProcessInfo info;

        if (find_process(argv[i], &info)) {

            if (!firstProc)
                printf(",\n");

            printf("  {\n");
            printf("    \"process\": \"%s\",\n", info.name);
            printf("    \"pid\": %lu,\n", info.pid);
            printf("    \"ports\": ");

            get_ports_by_pid(info.pid);

            printf("\n  }");

            firstProc = 0;
        }
    }

    printf("\n]\n");

    return 0;
}