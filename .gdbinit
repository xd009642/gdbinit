python

class reg():

    def __init__(self, address, description, read_only=False):
        self.addr = address
        self.desc = description
        self.ro = read_only
    
    def __repr__(self):
        return self.__str__()

    def __str__(self):
        if self.ro:
            read_status = " [READ ONLY] "
        else:
            read_status = ""
        return hex(self.addr) + ":"+read_status+self.desc

class RegisterBase(gdb.Command):
    def __init__(self, command_name):
        gdb.Command.__init__(self, command_name, gdb.COMMAND_USER, gdb.COMPLETE_NONE, True)
        self.cmd_name = command_name
        
    def list_registers(self):
        pass

    class ListRegistersCommand(gdb.Command):
        def __init__(self, rb):
            cmd = rb.cmd_name + " list-registers"
            gdb.Command.__init__(self, cmd, gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)
            self.rb = rb
        
        
        def invoke(self, arg, from_tty):
            self.rb.list_registers()

        def show(self):
            pass

        def complete(self, text, word):
            pass

class CortexM4(RegisterBase):
    def __init__(self):
        RegisterBase.__init__(self, 'cortex-m4')
        RegisterBase.ListRegistersCommand(self)
        self.actlr   = 1
        self.cpuid   = 2
        self.icsr    = 3
        self.vtor    = 4
        self.aircr   = 5
        self.scr     = 6
        self.ccr     = 7
        self.shpr1   = 8
        self.shpr2   = 9
        self.shpr3   = 10
        self.shcrs   = 11
        self.cfsr    = 12
        self.mmsr    = 13
        self.bfsr    = 14
        self.ufsr    = 15
        self.hfsr    = 16
        self.mmar    = 17
        self.bfar    = 18
        self.afsr    = 19

        self.registers = {
            self.actlr   : reg(0xE000E008, "Auxiliary control"),
            self.cpuid   : reg(0xE000ED00, "CPUID Base"),
            self.icsr    : reg(0xE000ED04, "Interrupt control and state"),
            self.vtor    : reg(0xE000ED08, "Vector table offset"),
            self.aircr   : reg(0xE000ED0C, "Application Interrupt and reset control"),
            self.scr     : reg(0xE000ED10, "System control register"),
            self.ccr     : reg(0xE000ED14, "Configuration and control"),
            self.shpr1   : reg(0xE000ED18, "System handler priority register 1"),
            self.shpr2   : reg(0xE000ED1C, "System handler priority register 2"),
            self.shpr3   : reg(0xE000ED20, "System handler priority register 3"),
            self.shcrs   : reg(0xE000ED24, "System handler control and state"),
            self.cfsr    : reg(0xE000ED28, "Configurable fault status"),
            self.mmsr    : reg(0xE000ED28, "MemManage fault status"),
            self.bfsr    : reg(0xE000ED29, "BusFault status"),
            self.ufsr    : reg(0xE000ED2A, "UsageFault status"),
            self.hfsr    : reg(0xE000ED2C, "HardFault status"),
            self.mmar    : reg(0xE000ED34, "MemManage fault address"),
            self.bfar    : reg(0xE000ED38, "BusFault address"),
            self.afsr    : reg(0xE000ED3C, "Auxiliary fault status")
        }

    def list_registers(self):
        for r in self.registers.values():
            print(r.desc)

    @staticmethod
    def start():
        cortex_m4 = CortexM4()
end

set print pretty on
set python print-stack full

python CortexM4.start()
