"""QART Hardware Adapter Protocol reference boundary.
No physical hardware is controlled by this file.
"""
from dataclasses import dataclass
from typing import Literal

Backend = Literal["simulator","fpga","qpu"]

@dataclass(frozen=True)
class Command:
    sequence: int
    channel: int
    amplitude_q15: int
    duration_ticks: int

def safety_gate(c: Command) -> bool:
    return (
        0 <= c.sequence <= 0xFFFFFFFF and
        0 <= c.channel < 64 and
        0 <= c.amplitude_q15 <= 0x7FFF and
        1 <= c.duration_ticks <= 1_000_000
    )

class HardwareAdapter:
    backend: Backend
    hardware_verified: bool = False
    def status(self): raise NotImplementedError
    def execute(self, command: Command):
        if not safety_gate(command):
            return {"accepted": False, "failClosed": True, "reason": "safety_gate"}
        raise NotImplementedError("Physical execution intentionally unavailable")

class FPGAAdapter(HardwareAdapter):
    backend: Backend = "fpga"
    def status(self):
        return {"backend": self.backend, "connected": False, "hardwareVerified": False}
