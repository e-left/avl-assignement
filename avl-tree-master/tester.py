#!/usr/bin/env python3

import sys

for i, line in enumerate(sys.stdin, 1):
    def error(msg, *args, **kwargs):
        return "line {}: {}\n{}".format(i, line, msg.format(*args, **kwargs))
    words = line.split()
    assert " ".join(words) + '\n' == line, error("wrong line formatting")
    assert words[0] in ['i', 'l', 'r', 's', 'c', 'p'], error("wrong operation")
    if words[0] in ['i', 'l', 'r']:
        assert len(words) == 2, error("one operand expected")
        assert -1000000000 <= int(words[1]) <= 1000000000
    elif words[0] in ['s', 'c', 'p']:
        assert len(words) == 1, error("no operands expected")
