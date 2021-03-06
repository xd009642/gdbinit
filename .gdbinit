python
from array import array
import struct
import sys
print("xd009642 gdb init. Python " +sys.version);

class reg():

    def __init__(self, address, description, access="rw"):
        self.addr = address
        self.desc = description
        self.access = access
    
    def __repr__(self):
        return self.__str__()

    def __str__(self):
        return self.access + "\t" +self.desc+ " ("+hex(self.addr)+ ")" 

class RegisterBase(gdb.Command):
    
    def __init__(self, command_name):
        gdb.Command.__init__(self, command_name, gdb.COMMAND_USER, gdb.COMPLETE_NONE, True)
        self.cmd_name = command_name
        
    def list_registers(self):
        pass

    def read_address(self, a, length = 4):
        inf = gdb.inferiors()
        if len(inf) > 0 and inf[0].is_valid():
            inf = inf[0]
            value = inf.read_memory(a, length);
            value = bytearray(value)
            value = struct.unpack("<I", value)
            return value[0]
        else:
            return []
   
    def write_address(self, addr, data):
        inf = gdb.inferiors()[0]
        if inf.is_valid():
            data = struct.pack("<I", data)
            value = inf.write_memory(addr, data, 4)

    class ListRegistersCommand(gdb.Command):
        "List the available registers to interact with"
        def __init__(self, rb):
            cmd = rb.cmd_name + " list-registers"
            gdb.Command.__init__(self, cmd, gdb.COMMAND_USER, gdb.COMPLETE_NONE)
            self.rb = rb
        
        
        def invoke(self, arg, from_tty):
            self.rb.list_registers()

        def show(self):
            pass

        def complete(self, text, word):
            pass

    class ReadRegisterCommand(gdb.Command):
        "Read the contents of a register (use the short name)"
        def __init__(self, rb):
            cmd = rb.cmd_name + " read-register"
            gdb.Command.__init__(self, cmd, gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)
            self.rb = rb

        def invoke(self, arg, from_tty):
            addr = self.rb.get_address(arg)
            if addr != None:
                value = self.rb.read_address(addr)
                print(hex(value))
            else:
                print("Register '"+arg+"' not recognised")

    class WriteRegisterCommand(gdb.Command):
        "write the contents of a register given register short name and hex data"
        def __init__(self, rb):
            cmd = rb.cmd_name + " write-register"
            gdb.Command.__init__(self, cmd, gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)
            self.rb = rb

        def invoke(self, arg, from_tty):
            args = arg.split()
            if len(args) == 2:
                addr = self.rb.get_address(args[0])
                data = int(args[1], 16)
                if addr != None:
                    self.rb.write_address(addr, data)
                else:
                    print("Register '"+arg+"' not recognised")
            else:
                print("Invalid args specified. Give args as <SHORT_NAME> <DATA>")

class CortexM4(RegisterBase):
    "Use this command to access cortex-m4 specific registers"

    def __init__(self):
        RegisterBase.__init__(self, 'cortex-m4')
        RegisterBase.ListRegistersCommand(self)
        RegisterBase.ReadRegisterCommand(self)
        RegisterBase.WriteRegisterCommand(self)

        self.registers = {
            "actlr"   : reg(0xE000E008, "Auxiliary control"),
            "cpuid"   : reg(0xE000ED00, "CPUID Base", "ro"),
            "icsr"    : reg(0xE000ED04, "Interrupt control and state"),
            "vtor"    : reg(0xE000ED08, "Vector table offset"),
            "aircr"   : reg(0xE000ED0C, "Application Interrupt and reset control"),
            "scr"     : reg(0xE000ED10, "System control register"),
            "ccr"     : reg(0xE000ED14, "Configuration and control"),
            "shpr1"   : reg(0xE000ED18, "System handler priority register 1"),
            "shpr2"   : reg(0xE000ED1C, "System handler priority register 2"),
            "shpr3"   : reg(0xE000ED20, "System handler priority register 3"),
            "shcrs"   : reg(0xE000ED24, "System handler control and state"),
            "cfsr"    : reg(0xE000ED28, "Configurable fault status"),
            "mmsr"    : reg(0xE000ED28, "MemManage fault status"),
            "bfsr"    : reg(0xE000ED29, "BusFault status"),
            "ufsr"    : reg(0xE000ED2A, "UsageFault status"),
            "hfsr"    : reg(0xE000ED2C, "HardFault status"),
            "mmar"    : reg(0xE000ED34, "MemManage fault address"),
            "bfar"    : reg(0xE000ED38, "BusFault address"),
            "afsr"    : reg(0xE000ED3C, "Auxiliary fault status")
        }

    def list_registers(self):
        for k, r in sorted(self.registers.items(), key=lambda x:x[1].addr):
            print(k + ":\t"+str(r))

    def get_address(self, addr):
        reg = self.registers.get(addr, None)
        if reg != None:
            return reg.addr
        return None
    
    @staticmethod
    def start():
        cortex_m4 = CortexM4()

        
end

define openocd_connect
    target remote :3333
    monitor arm semihosting enable 
    monitor reset halt
end


set print pretty on
set python print-stack full

python CortexM4.start()
