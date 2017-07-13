
# OmniOS build zone configuration

Without these settings, it is not possible to build the `kayak-kernel`

```
limitpriv: default,dtrace_user,dtrace_proc
fs-allowed: ufs
fs:
        dir: /boot
        special: /boot
        raw not specified
        type: lofs
        options: [ro]
fs:
        dir: /platform/i86pc/kernel/amd64
        special: /platform/i86pc/kernel/amd64
        raw not specified
        type: lofs
        options: [ro]
```

