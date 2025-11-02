from dataclasses import dataclass


@dataclass
class Waitlist:
    arg0: int
    arg1: bool


Status = Waitlist
w = Status(2, True)
