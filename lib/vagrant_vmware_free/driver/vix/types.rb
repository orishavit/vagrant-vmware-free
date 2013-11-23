require 'ffi'

module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      module VIX
        enum :VIX_API_VERSION, -1

        typedef :int, :VixHandle
        enum :VIX_INVALID_HANDLE

        enum :VixHandleType, [
          :VIX_HANDLETYPE_NONE,               0,
          :VIX_HANDLETYPE_HOST,               2,
          :VIX_HANDLETYPE_VM ,                3,
          :VIX_HANDLETYPE_NETWORK,            5,
          :VIX_HANDLETYPE_JOB,                6,
          :VIX_HANDLETYPE_SNAPSHOT,           7,
          :VIX_HANDLETYPE_PROPERTY_LIST,      9,
          :VIX_HANDLETYPE_METADATA_CONTAINER, 11,
        ]

        typedef :uint64, :VixError

        enum :VixHostOptions, [
          :VIX_HOSTOPTION_VERIFY_SSL_CERT, 0x4000,
        ]

        typedef :pointer, :VixEventProc

        enum :VixServiceProvider, [
          :VIX_SERVICEPROVIDER_DEFAULT,                     1,
          :VIX_SERVICEPROVIDER_VMWARE_SERVER,               2,
          :VIX_SERVICEPROVIDER_VMWARE_WORKSTATION,          3,
          :VIX_SERVICEPROVIDER_VMWARE_PLAYER,               4,
          :VIX_SERVICEPROVIDER_VMWARE_VI_SERVER,            10,
          :VIX_SERVICEPROVIDER_VMWARE_WORKSTATION_SHARED,   11,
        ]

        enum :VixVMOpenOptions, [:VIX_VMOPEN_NORMAL]

        enum :VixVMPowerOpOptions, [
          :VIX_VMPOWEROP_NORMAL,                    0,
          :VIX_VMPOWEROP_FROM_GUEST,                0x0004,
          :VIX_VMPOWEROP_SUPPRESS_SNAPSHOT_POWERON, 0x0080,
          :VIX_VMPOWEROP_LAUNCH_GUI,                0x0200,
          :VIX_VMPOWEROP_START_VM_PAUSED,           0x1000,
        ]

        enum :VixPropertyID, [
         :VIX_PROPERTY_NONE, 0,

         :VIX_PROPERTY_META_DATA_CONTAINER, 2,

         :VIX_PROPERTY_HOST_HOSTTYPE,         50,
         :VIX_PROPERTY_HOST_API_VERSION,      51,
         :VIX_PROPERTY_HOST_SOFTWARE_VERSION, 52,
         
         :VIX_PROPERTY_VM_NUM_VCPUS,          101,
         :VIX_PROPERTY_VM_VMX_PATHNAME,       103, 
         :VIX_PROPERTY_VM_VMTEAM_PATHNAME,    105, 
         :VIX_PROPERTY_VM_MEMORY_SIZE,        106,
         :VIX_PROPERTY_VM_READ_ONLY,          107,
         :VIX_PROPERTY_VM_NAME,               108,
         :VIX_PROPERTY_VM_GUESTOS,            109,
         :VIX_PROPERTY_VM_IN_VMTEAM,          128,
         :VIX_PROPERTY_VM_POWER_STATE,        129,
         :VIX_PROPERTY_VM_TOOLS_STATE,        152,
         :VIX_PROPERTY_VM_IS_RUNNING,         196,
         :VIX_PROPERTY_VM_SUPPORTED_FEATURES, 197,
         
         :VIX_PROPERTY_VM_SSL_ERROR, 293,
         
         :VIX_PROPERTY_JOB_RESULT_ERROR_CODE,                 3000,
         :VIX_PROPERTY_JOB_RESULT_VM_IN_GROUP,                3001,
         :VIX_PROPERTY_JOB_RESULT_USER_MESSAGE,               3002,
         :VIX_PROPERTY_JOB_RESULT_EXIT_CODE,                  3004,
         :VIX_PROPERTY_JOB_RESULT_COMMAND_OUTPUT,             3005,
         :VIX_PROPERTY_JOB_RESULT_HANDLE,                     3010,
         :VIX_PROPERTY_JOB_RESULT_GUEST_OBJECT_EXISTS,        3011,
         :VIX_PROPERTY_JOB_RESULT_GUEST_PROGRAM_ELAPSED_TIME, 3017,
         :VIX_PROPERTY_JOB_RESULT_GUEST_PROGRAM_EXIT_CODE,    3018,
         :VIX_PROPERTY_JOB_RESULT_ITEM_NAME,                  3035,
         :VIX_PROPERTY_JOB_RESULT_FOUND_ITEM_DESCRIPTION,     3036,
         :VIX_PROPERTY_JOB_RESULT_SHARED_FOLDER_COUNT,        3046,
         :VIX_PROPERTY_JOB_RESULT_SHARED_FOLDER_HOST,         3048,
         :VIX_PROPERTY_JOB_RESULT_SHARED_FOLDER_FLAGS,        3049,
         :VIX_PROPERTY_JOB_RESULT_PROCESS_ID,                 3051,
         :VIX_PROPERTY_JOB_RESULT_PROCESS_OWNER,              3052,
         :VIX_PROPERTY_JOB_RESULT_PROCESS_COMMAND,            3053,
         :VIX_PROPERTY_JOB_RESULT_FILE_FLAGS,                 3054,
         :VIX_PROPERTY_JOB_RESULT_PROCESS_START_TIME,         3055,
         :VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING,         3056,
         :VIX_PROPERTY_JOB_RESULT_PROCESS_BEING_DEBUGGED,     3057,
         :VIX_PROPERTY_JOB_RESULT_SCREEN_IMAGE_SIZE,          3058,
         :VIX_PROPERTY_JOB_RESULT_SCREEN_IMAGE_DATA,          3059,
         :VIX_PROPERTY_JOB_RESULT_FILE_SIZE,                  3061,
         :VIX_PROPERTY_JOB_RESULT_FILE_MOD_TIME,              3062,
         :VIX_PROPERTY_JOB_RESULT_EXTRA_ERROR_INFO,           3084,
         
         :VIX_PROPERTY_FOUND_ITEM_LOCATION, 4010,
         
         :VIX_PROPERTY_SNAPSHOT_DISPLAYNAME,  4200,   
         :VIX_PROPERTY_SNAPSHOT_DESCRIPTION,  4201,
         :VIX_PROPERTY_SNAPSHOT_POWERSTATE,   4205,

         :VIX_PROPERTY_GUEST_SHAREDFOLDERS_SHARES_PATH, 4525,
         
         :VIX_PROPERTY_VM_ENCRYPTION_PASSWORD, 7001,
       ]

       enum :VixCloneType, [
        :VIX_CLONETYPE_FULL,    0,
        :VIX_CLONETYPE_LINKED,  1,
      ]

      enum :VixPowerState, [
        :VIX_POWERSTATE_POWERING_OFF,   0x0001,
        :VIX_POWERSTATE_POWERED_OFF,    0x0002,
        :VIX_POWERSTATE_POWERING_ON,    0x0004,
        :VIX_POWERSTATE_POWERED_ON,     0x0008,
        :VIX_POWERSTATE_SUSPENDING,     0x0010,
        :VIX_POWERSTATE_SUSPENDED,      0x0020,
        :VIX_POWERSTATE_TOOLS_RUNNING,  0x0040,
        :VIX_POWERSTATE_RESETTING,      0x0080,
        :VIX_POWERSTATE_BLOCKED_ON_MSG, 0x0100,
        :VIX_POWERSTATE_PAUSED,         0x0200,
        :VIX_POWERSTATE_RESUMING,       0x0800,
      ]

      enum :VixVariableType, [
        :VIX_VM_GUEST_VARIABLE,           1,
        :VIX_VM_CONFIG_RUNTIME_ONLY,      2,
        :VIX_GUEST_ENVIRONMENT_VARIABLE,  3,
      ]

      enum :VixVMDeleteOptions, [
        :VIX_VMDELETE_DISK_FILES, 0x0002,
      ]
      end
    end
  end
end