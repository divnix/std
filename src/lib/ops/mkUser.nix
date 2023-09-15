let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in
  /*
  Creates a setup task which adds the given user to the container.

  Args:
    user: Username
    uid: User ID
    group: Group name
    gid: Group ID
    withHome: If true, creates a home directory for the user.

  Returns:
    A setup task which adds the user to the container.
  */
  {
    user,
    uid,
    group,
    gid,
    shell ? "",
    withHome ? false,
    withRoot ? false,
  }: let
    perms = l.optionals withHome [
      {
        regex = "/home/${user}";
        mode = "0744";
        uid = l.toInt uid;
        gid = l.toInt gid;
        uname = user;
        gname = group;
      }
    ];
    withHomeStr = l.optionalString withHome "mkdir -p $out/home/${user}";
    withRootStr = l.optionalString withRoot ''
      echo "root:x:0:0::" >> $out/etc/passwd
      echo "root:!x:::::::" >> $out/etc/shadow
      echo "root:x:0:" >> $out/etc/group
      echo "root:x::" >> $out/etc/gshadow

      mkdir $out/root
    '';
  in
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/docker/default.nix#L177-L199
    cell.ops.mkSetup "users" perms ''
      mkdir -p $out/etc/pam.d

      echo "${user}:x:${uid}:${gid}::${l.optionalString withHome "/home/${user}"}:${shell}" >> $out/etc/passwd
      echo "${user}:!x:::::::" >> $out/etc/shadow

      echo "${group}:x:${gid}:" >> $out/etc/group
      echo "${group}:x::" >> $out/etc/gshadow

      ${withRootStr}

      cat > $out/etc/pam.d/other <<EOF
      account sufficient pam_unix.so
      auth sufficient pam_rootok.so
      password requisite pam_unix.so nullok sha512
      session required pam_unix.so
      EOF

      touch $out/etc/login.defs

      ${withHomeStr}
    ''
