// Copies a file into GARMIN/Apps on the first connected MTP device (a Garmin
// watch), replacing any file of the same name, then verifies the size.
// usage: mtp-install <local file> <remote name>
#include <libmtp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/stat.h>

// Returns the id of a child folder with this name, or 0.
static uint32_t find_folder(LIBMTP_mtpdevice_t *dev, uint32_t storage, uint32_t parent, const char *name) {
    uint32_t found = 0;
    LIBMTP_file_t *files = LIBMTP_Get_Files_And_Folders(dev, storage, parent);
    for (LIBMTP_file_t *f = files; f != NULL;) {
        if (found == 0 && f->filetype == LIBMTP_FILETYPE_FOLDER && f->filename != NULL
                && strcasecmp(f->filename, name) == 0) {
            found = f->item_id;
        }
        LIBMTP_file_t *next = f->next;
        LIBMTP_destroy_file_t(f);
        f = next;
    }
    return found;
}

// Returns the id of an existing file with this name in the folder, or 0.
static uint32_t find_file(LIBMTP_mtpdevice_t *dev, uint32_t storage, uint32_t folder, const char *name, uint64_t *size) {
    uint32_t found = 0;
    LIBMTP_file_t *files = LIBMTP_Get_Files_And_Folders(dev, storage, folder);
    for (LIBMTP_file_t *f = files; f != NULL;) {
        if (found == 0 && f->filename != NULL && strcasecmp(f->filename, name) == 0) {
            found = f->item_id;
            if (size) *size = f->filesize;
        }
        LIBMTP_file_t *next = f->next;
        LIBMTP_destroy_file_t(f);
        f = next;
    }
    return found;
}

int main(int argc, char **argv) {
    if (argc != 3) { fprintf(stderr, "usage: %s <file> <remote-name>\n", argv[0]); return 2; }
    struct stat st;
    if (stat(argv[1], &st) != 0) { perror(argv[1]); return 1; }

    // Open uncached: the cached handle does not allow per-folder file listing,
    // which we need to replace and verify the file.
    LIBMTP_Init();
    LIBMTP_raw_device_t *raw = NULL;
    int count = 0;
    LIBMTP_mtpdevice_t *dev = NULL;
    if (LIBMTP_Detect_Raw_Devices(&raw, &count) == LIBMTP_ERROR_NONE && count > 0) {
        dev = LIBMTP_Open_Raw_Device_Uncached(&raw[0]);
    }
    free(raw);
    if (dev == NULL) {
        fprintf(stderr, "No watch found. Check: USB connected, watch USB Mode = MTP, OpenMTP closed.\n");
        return 1;
    }

    // Walk root -> GARMIN -> Apps on each storage until found.
    if (LIBMTP_Get_Storage(dev, LIBMTP_STORAGE_SORTBY_NOTSORTED) != 0) {
        fprintf(stderr, "Could not read the device's storage.\n");
        LIBMTP_Release_Device(dev); return 1;
    }
    uint32_t folder = 0;
    uint32_t storage = 0;
    for (LIBMTP_devicestorage_t *st_ = dev->storage; st_ != NULL && folder == 0; st_ = st_->next) {
        uint32_t garmin = find_folder(dev, st_->id, LIBMTP_FILES_AND_FOLDERS_ROOT, "GARMIN");
        if (garmin != 0) {
            folder = find_folder(dev, st_->id, garmin, "Apps");
            storage = st_->id;
        }
    }
    if (folder == 0) {
        fprintf(stderr, "GARMIN/Apps folder not found on the device.\n");
        LIBMTP_Release_Device(dev); return 1;
    }

    uint32_t old = find_file(dev, storage, folder, argv[2], NULL);
    if (old != 0 && LIBMTP_Delete_Object(dev, old) != 0) {
        fprintf(stderr, "Could not remove the old %s.\n", argv[2]);
        LIBMTP_Dump_Errorstack(dev); LIBMTP_Release_Device(dev); return 1;
    }

    LIBMTP_file_t *meta = LIBMTP_new_file_t();
    meta->filename = strdup(argv[2]);
    meta->filesize = (uint64_t)st.st_size;
    meta->filetype = LIBMTP_FILETYPE_UNKNOWN;
    meta->parent_id = folder;
    meta->storage_id = storage;
    int rc = LIBMTP_Send_File_From_File(dev, argv[1], meta, NULL, NULL);
    LIBMTP_destroy_file_t(meta);
    if (rc != 0) {
        fprintf(stderr, "Send failed.\n");
        LIBMTP_Dump_Errorstack(dev); LIBMTP_Release_Device(dev); return 1;
    }

    uint64_t size = 0;
    uint32_t id = find_file(dev, storage, folder, argv[2], &size);
    LIBMTP_Release_Device(dev);
    if (id == 0 || size != (uint64_t)st.st_size) {
        fprintf(stderr, "Verification failed: expected %lld bytes, found %llu.\n",
                (long long)st.st_size, (unsigned long long)size);
        return 1;
    }
    printf("%s %s: %llu bytes in GARMIN/Apps (verified). Unplug the watch to install.\n",
           old ? "Replaced" : "Installed", argv[2], (unsigned long long)size);
    return 0;
}
