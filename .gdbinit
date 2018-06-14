python

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
        print(inf)
        if len(inf) > 0:
            inf = inf[0]
            mem = inf.read_memory(int(a), length)
            print(hex(mem.tobytes().hex()))

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
                self.rb.read_address(addr)
            else:
                print("Register '"+arg+"' not recognised")

class CortexM4(RegisterBase):
    "Use this command to access cortex-m4 specific registers"

    def __init__(self):
        RegisterBase.__init__(self, 'cortex-m4')
        RegisterBase.ListRegistersCommand(self)
        RegisterBase.ReadRegisterCommand(self)
        
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
        for k, r in self.registers.items():
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
