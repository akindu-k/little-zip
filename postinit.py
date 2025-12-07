from dataclasses import dataclass

@dataclass
class Student:
    name: str
    marks: int
    
    def __post_init__(self):
        if (self.marks < 0):
            raise ValueError("Marks cannot be negative")
        
        self.passed = self.marks >= 40

s = Student("Akindu", 85)
print(s.passed)