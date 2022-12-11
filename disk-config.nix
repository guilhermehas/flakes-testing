# Example to create a bios compatible gpt partition
{ disks ? [ "/dev/sda" ], ... }: {
  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        root = {
          type = "lv";
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
  disk = {
    vdb = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            type = "partition";
            start = "0";
            end = "1M";
            part-type = "primary";
            flags = ["bios_grub"];
          }
          {
            type = "partition";
            name = "ESP";
            start = "1MiB";
            end = "100MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "root";
            type = "partition";
            start = "100MiB";
            end = "-16G";
            part-type = "primary";
            flags = ["bios_grub"];
            content = {
              type = "luks";
              name = "crypted";
              keyFile = "/tmp/secret.key";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          }
          {
            name = "root";
            type = "partition";
            start = "-16G";
            end = "100%";
            part-type = "primary";
            bootable = true;
            content = {
              type = "swap";
              randomEncryption = true;
            };
          }
        ];
      };
    };
  };
}
